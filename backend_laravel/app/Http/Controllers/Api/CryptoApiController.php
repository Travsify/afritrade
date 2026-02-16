<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CryptoApiController extends Controller
{
    // Return a static or generated USDT address for the user
    public function getAddress(Request $request)
    {
        // In a real app, integrate with CoinRemitter/BitGo/etc to generate unique address
        // For 'Afritrad Unicorn', we simulate a unique deposit address per user
        $user = Auth::user();
        
        // Ensure user has an address saved (column not created yet, using static mock for MVP)
        // Or usage of 'reference' field logic
        $mockAddress = '0x' . substr(md5($user->id . 'USDT'), 0, 30); 

        return response()->json([
            'status' => 'success',
            'network' => 'TRC20',
            'currency' => 'USDT',
            'address' => $mockAddress,
            'note' => 'Only send USDT (TRC20). Deposits are auto-converted to USD.'
        ]);
    }

    // Webhook or Manual Trigger to simulate deposit (since we don't have real blockchain node)
    public function simulateDeposit(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:5',
        ]);

        $user = Auth::user();
        $amount = $request->amount;
        $rate = 0.90; // 1 USDT = 0.90 USD
        
        $creditAmount = $amount * $rate;
        $fee = $amount - $creditAmount;

        // Auto-Convert Logic
        $user->increment('balance', $creditAmount);

        // Log User Credit
        Transaction::create([
            'user_id' => $user->id,
            'type' => 'credit',
            'amount' => $creditAmount,
            'currency' => 'USD',
            'recipient' => 'Wallet',
            'status' => 'completed',
            'reference' => 'CRYPTO-' . uniqid()
        ]);
        
        // TODO: Log System Profit/Fee ($fee) to a system_revenue table or admin dashboard metric

        return response()->json([
            'status' => 'success',
            'message' => 'Deposit successful. Rate applied: ' . $rate,
            'original_amount' => $amount,
            'credited_amount' => $creditAmount,
            'new_balance' => $user->fresh()->balance
        ]);
    }
}
