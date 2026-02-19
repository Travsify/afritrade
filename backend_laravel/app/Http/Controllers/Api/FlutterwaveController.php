<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Wallet;
use App\Services\FlutterwaveService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use App\Services\NotificationService;

class FlutterwaveController extends Controller
{
    protected FlutterwaveService $flutterwaveService;
    protected NotificationService $notificationService;

    public function __construct(FlutterwaveService $flutterwaveService, NotificationService $notificationService)
    {
        $this->flutterwaveService = $flutterwaveService;
        $this->notificationService = $notificationService;
    }

    /**
     * Initialize a payment — returns a Flutterwave payment link.
     */
    public function initializePayment(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:100',
            'currency' => 'sometimes|string|size:3',
        ]);

        $user = Auth::user();
        $reference = 'FLW-' . strtoupper(uniqid()) . '-' . $user->id;

        $result = $this->flutterwaveService->initializePayment([
            'reference' => $reference,
            'amount' => $request->amount,
            'currency' => $request->currency ?? 'NGN',
            'email' => $user->email,
            'name' => $user->name,
        ]);

        if ($result['status'] === 'success') {
            // Create pending transaction
            Transaction::create([
                'user_id' => $user->id,
                'type' => 'credit',
                'amount' => $request->amount,
                'currency' => $request->currency ?? 'NGN',
                'status' => 'pending',
                'reference' => $reference,
                'recipient' => 'Wallet Funding',
            ]);
        }

        return response()->json($result);
    }

    /**
     * Verify a payment after redirect/callback.
     */
    public function verifyPayment(Request $request, $reference)
    {
        $transactionId = $request->query('transaction_id');
        
        if (!$transactionId) {
            return response()->json(['status' => 'error', 'message' => 'Transaction ID required'], 400);
        }

        $result = $this->flutterwaveService->verifyPayment($transactionId);

        if ($result['status'] === 'success') {
            $data = $result['data'];
            $user = Auth::user();

            // Prevent double-crediting
            $existingTx = Transaction::where('reference', $data['reference'])->where('status', 'completed')->first();
            if ($existingTx) {
                return response()->json(['status' => 'success', 'message' => 'Already processed']);
            }

            DB::transaction(function () use ($user, $data) {
                $currency = $data['currency'];
                $amount = $data['amount'];

                $wallet = Wallet::firstOrCreate(
                    ['user_id' => $user->id, 'currency' => $currency],
                    ['balance' => 0]
                );

                $wallet->increment('balance', $amount);

                Transaction::where('reference', $data['reference'])->update(['status' => 'completed']);

                $this->notificationService->transactionCredit($user->id, $amount, $currency, $data['reference']);
            });

            return response()->json([
                'status' => 'success',
                'message' => 'Payment verified and wallet funded',
                'amount' => $data['amount'],
                'currency' => $data['currency'],
            ]);
        }

        return response()->json(['status' => 'error', 'message' => 'Payment verification failed'], 400);
    }

    /**
     * Get list of banks (for withdrawal destination selection).
     */
    public function getBanks()
    {
        $result = $this->flutterwaveService->getBanks();
        return response()->json($result);
    }
}
