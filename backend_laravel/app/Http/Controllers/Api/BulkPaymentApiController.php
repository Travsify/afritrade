<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class BulkPaymentApiController extends Controller
{
    public function index()
    {
        $payments = DB::table('bulk_payments')
            ->where('user_id', Auth::id())
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $payments,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'recipients' => 'required|array|min:1',
            'recipients.*.name' => 'required|string',
            'recipients.*.account' => 'required|string',
            'recipients.*.amount' => 'required|numeric|min:0.01',
            'recipients.*.bank' => 'required|string',
            'currency' => 'nullable|string|max:5',
        ]);

        $batchRef = 'BULK_' . Str::upper(Str::random(8));
        $currency = $request->currency ?? 'NGN';
        $items = [];

        foreach ($request->recipients as $r) {
            $id = DB::table('bulk_payments')->insertGetId([
                'user_id' => Auth::id(),
                'batch_reference' => $batchRef,
                'recipient_name' => $r['name'],
                'account_number' => $r['account'],
                'bank_name' => $r['bank'],
                'amount' => $r['amount'],
                'currency' => $currency,
                'status' => 'pending',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            $items[] = $id;
        }

        return response()->json([
            'status' => 'success',
            'message' => count($items) . ' payments queued.',
            'data' => [
                'batch_reference' => $batchRef,
                'count' => count($items),
            ],
        ]);
    }

    public function process(Request $request)
    {
        $request->validate([
            'ids' => 'required|array|min:1',
        ]);

        $user = Auth::user();
        $totalAmount = DB::table('bulk_payments')
            ->whereIn('id', $request->ids)
            ->where('user_id', $user->id)
            ->where('status', 'pending')
            ->sum('amount');

        // Check wallet balance
        $wallet = \App\Models\Wallet::where('user_id', $user->id)
            ->where('currency', 'NGN')
            ->first();

        if (!$wallet || $wallet->balance < $totalAmount) {
            return response()->json([
                'status' => 'error',
                'message' => 'Insufficient balance to process bulk payments. Required: ₦' . number_format($totalAmount, 2),
            ], 422);
        }

        // Deduct and mark as completed
        $wallet->balance -= $totalAmount;
        $wallet->save();

        DB::table('bulk_payments')
            ->whereIn('id', $request->ids)
            ->where('user_id', $user->id)
            ->update(['status' => 'completed', 'updated_at' => now()]);

        // Record single transaction for the batch
        Transaction::create([
            'user_id' => $user->id,
            'type' => 'debit',
            'amount' => $totalAmount,
            'currency' => 'NGN',
            'description' => 'Bulk payment batch processed',
            'reference' => 'BULK_TX_' . Str::upper(Str::random(8)),
            'status' => 'completed',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => count($request->ids) . ' payments processed successfully.',
        ]);
    }
}
