<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class TransferApiController extends Controller
{
    // Search for a user by email or name (for P2P recipient lookup)
    public function lookup(Request $request)
    {
        $query = $request->input('query');
        if (!$query) {
             return response()->json(['status' => 'error', 'message' => 'Query required']);
        }

        $users = User::where('email', 'like', "%{$query}%")
                    ->orWhere('name', 'like', "%{$query}%")
                    ->select('id', 'name', 'email') // Don't expose balance etc
                    ->limit(5)
                    ->get();

        return response()->json(['status' => 'success', 'data' => $users]);
    }

    /**
     * Internal P2P Transfer (Afritrade User to User)
     */
    public function transfer(Request $request)
    {
        $request->validate([
            'recipient_email' => 'required|email|exists:users,email',
            'amount' => 'required|numeric|min:1.00',
        ]);

        $sender = Auth::user();
        if ($sender->email === $request->recipient_email) {
             return response()->json(['status' => 'error', 'message' => 'Cannot transfer to self']);
        }

        if ($sender->balance < $request->amount) {
             return response()->json(['status' => 'error', 'message' => 'Insufficient balance']);
        }

        $recipient = User::where('email', $request->recipient_email)->first();

        // Atomic Transaction
        DB::transaction(function () use ($sender, $recipient, $request) {
            // Debit Sender
            $sender->decrement('balance', $request->amount);
            
            // Credit Recipient
            $recipient->increment('balance', $request->amount);

            // Log for Sender
            Transaction::create([
                'user_id' => $sender->id,
                'type' => 'debit',
                'amount' => $request->amount,
                'currency' => $sender->currency ?? 'USD',
                'recipient' => $recipient->email,
                'status' => 'completed',
                'reference' => 'P2P-' . uniqid()
            ]);

            // Log for Recipient
            Transaction::create([
                'user_id' => $recipient->id,
                'type' => 'credit',
                'amount' => $request->amount,
                'currency' => $recipient->currency ?? 'USD',
                'recipient' => $sender->email, // From
                'status' => 'completed',
                'reference' => 'P2P-RX-' . uniqid()
            ]);
        });

        return response()->json(['status' => 'success', 'message' => 'Transfer successful', 'new_balance' => $sender->fresh()->balance]);
    }

    /**
     * International Supplier Payment (via Yellow Card)
     */
    public function paySupplier(Request $request, \App\Services\YellowCardService $ycService)
    {
        $request->validate([
            'amount' => 'required|numeric|min:10',
            'currency' => 'required|string|size:3', // e.g. CNY, GBP
            'recipient_name' => 'required|string',
            'bank_details' => 'required|string', // Simple string for now, could be JSON
        ]);

        $user = Auth::user();
        
        // 1. Check Balance
        if ($user->balance < $request->amount) {
            return response()->json(['status' => 'error', 'message' => 'Insufficient balance']);
        }

        // 2. Get Quote (USD -> Target Currency)
        // Assuming user balance is in USD.
        $quote = $ycService->createQuote('USD', $request->currency, $request->amount);

        if ($quote['status'] !== 'success') {
            return response()->json(['status' => 'error', 'message' => 'Failed to get exchange rate']);
        }

        // 3. Execute Transfer
        $transfer = $ycService->executeTransfer($quote['data']['id'], [
            'name' => $request->recipient_name,
            'details' => $request->bank_details
        ]);

        if ($transfer['status'] === 'success') {
            // Debit User
            $user->decrement('balance', $request->amount);
            
            Transaction::create([
                'user_id' => $user->id,
                'type' => 'debit',
                'amount' => $request->amount,
                'currency' => 'USD',
                'recipient' => $request->recipient_name . " ($request->currency)",
                'status' => 'pending', // Yellow Card is async
                'reference' => $transfer['data']['reference']
            ]);

            return response()->json([
                'status' => 'success', 
                'message' => 'Payment initiated successfully',
                'reference' => $transfer['data']['reference']
            ]);
        }

        return response()->json(['status' => 'error', 'message' => 'Payment failed at provider']);
    }
}
