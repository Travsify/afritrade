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
        
        // Fetch rate from DB or fallback
        $rate = (float) \Illuminate\Support\Facades\DB::table('system_settings')
            ->where('setting_key', 'usdt_usd_rate')
            ->value('setting_value') ?? 0.95;

        $creditAmount = $amount * $rate;

        \Illuminate\Support\Facades\DB::transaction(function () use ($user, $amount, $creditAmount, $rate) {
            // 1. Credit USD Wallet
            $usdWallet = $user->wallets()->firstOrCreate(
                ['currency' => 'USD'],
                ['balance' => 0]
            );
            $usdWallet->increment('balance', $creditAmount);
            
            // 2. Sync flat balance
            $user->increment('balance', $creditAmount);

            // 3. Log Transaction
            Transaction::create([
                'user_id' => $user->id,
                'wallet_id' => $usdWallet->id,
                'type' => 'credit',
                'amount' => $creditAmount,
                'currency' => 'USD',
                'recipient' => 'Crypto Deposit (USDT)',
                'status' => 'completed',
                'reference' => 'CRYPTO-' . strtoupper(uniqid()),
                'narration' => "USDT Deposit of $amount converted at rate $rate"
            ]);
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Deposit processed successfully.',
            'credited' => $creditAmount,
            'new_balance' => $user->fresh()->balance
        ]);
    }
}
