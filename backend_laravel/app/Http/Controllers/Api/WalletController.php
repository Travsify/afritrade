<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class WalletController extends Controller
{
    /**
     * Get user's wallets and balance.
     */
    public function index()
    {
        $wallets = Auth::user()->wallets;
        return response()->json(['wallets' => $wallets]);
    }

    /**
     * Create a new wallet (currency).
     */
    public function store(Request $request)
    {
        $request->validate([
            'currency' => 'required|string|size:3|unique:wallets,currency,NULL,id,user_id,' . Auth::id(),
        ]);

        $wallet = Wallet::create([
            'user_id' => Auth::id(),
            'currency' => $request->currency,
            'balance' => 0,
        ]);

        return response()->json(['wallet' => $wallet, 'message' => 'Wallet created successfully']);
    }

    /**
     * Fund wallet (Deposit).
     */
    public function fund(Request $request)
    {
        $request->validate([
            'wallet_id' => 'required|exists:wallets,id',
            'amount' => 'required|numeric|min:1',
            'reference' => 'required|string|unique:transactions,reference', // Payment gateway ref
        ]);

        $wallet = Wallet::where('id', $request->wallet_id)->where('user_id', Auth::id())->firstOrFail();

        DB::transaction(function () use ($wallet, $request) {
            $wallet->balance += $request->amount;
            $wallet->save();

            Transaction::create([
                'user_id' => Auth::id(),
                'wallet_id' => $wallet->id,
                'type' => 'credit', // or 'deposit'
                'amount' => $request->amount,
                'currency' => $wallet->currency,
                'status' => 'completed',
                'reference' => $request->reference,
            ]);

            event(new \App\Events\UserFunded(Auth::user(), $request->amount, $wallet->currency));
        });

        return response()->json(['message' => 'Wallet funded successfully', 'balance' => $wallet->balance]);
    }

    /**
     * Transfer funds to another user.
     */
    public function transfer(Request $request)
    {
        $request->validate([
            'source_wallet_id' => 'required|exists:wallets,id',
            'recipient_email' => 'required|email|exists:users,email',
            'amount' => 'required|numeric|min:1',
            'pin' => 'required|string',
        ]);

        $user = Auth::user();
        
        // Verify PIN
        if (!\Illuminate\Support\Facades\Hash::check($request->pin, $user->transaction_pin)) {
             return response()->json(['error' => 'Invalid transaction PIN'], 403);
        }

        $sourceWallet = Wallet::where('id', $request->source_wallet_id)
            ->where('user_id', $user->id)
            ->lockForUpdate()
            ->firstOrFail();

        if ($sourceWallet->balance < $request->amount) {
            return response()->json(['error' => 'Insufficient funds'], 400);
        }

        $recipientUser = \App\Models\User::where('email', $request->recipient_email)->first();
        $recipientWallet = Wallet::where('user_id', $recipientUser->id)
            ->where('currency', $sourceWallet->currency)
            ->first();

        if (!$recipientWallet) {
             return response()->json(['error' => 'Recipient needs a ' . $sourceWallet->currency . ' wallet'], 400);
        }

        DB::transaction(function () use ($sourceWallet, $recipientWallet, $request, $user, $recipientUser) {
            // Debit Sender
            $sourceWallet->decrement('balance', $request->amount);

            Transaction::create([
                'user_id' => $user->id,
                'wallet_id' => $sourceWallet->id,
                'type' => 'debit',
                'amount' => $request->amount,
                'currency' => $sourceWallet->currency,
                'recipient' => $recipientUser->email,
                'status' => 'completed',
                'reference' => 'TRF-' . uniqid(),
            ]);

            // Credit Recipient
            $recipientWallet->increment('balance', $request->amount);

            Transaction::create([
                'user_id' => $recipientUser->id,
                'wallet_id' => $recipientWallet->id,
                'type' => 'credit',
                'amount' => $request->amount,
                'currency' => $recipientWallet->currency,
                'status' => 'completed',
                'reference' => 'RCV-' . uniqid(),
            ]);
        });

        return response()->json(['message' => 'Transfer successful']);
    }
    /**
     * Swap currency between user's wallets.
     */
    public function swap(Request $request, \App\Services\ExchangeRateService $rateService)
    {
        $request->validate([
            'from_currency' => 'required|string|size:3',
            'to_currency' => 'required|string|size:3',
            'amount' => 'required|numeric|min:0.01',
            'pin' => 'required|string',
        ]);

        $user = Auth::user();

        // 1. Verify PIN
        if (!\Illuminate\Support\Facades\Hash::check($request->pin, $user->transaction_pin)) {
            return response()->json(['status' => 'error', 'message' => 'Invalid transaction PIN'], 403);
        }

        // 2. Get Wallets
        $sourceWallet = Wallet::where('user_id', $user->id)->where('currency', $request->from_currency)->firstOrFail();
        $destWallet = Wallet::where('user_id', $user->id)->where('currency', $request->to_currency)->first();

        if (!$destWallet) {
            return response()->json(['status' => 'error', 'message' => "Recipient wallet ({$request->to_currency}) not initialized"], 400);
        }

        if ($sourceWallet->balance < $request->amount) {
            return response()->json(['status' => 'error', 'message' => 'Insufficient funds in source wallet'], 400);
        }

        // 3. Get Conversion Rate
        $rate = $rateService->getFinalRate($request->from_currency, $request->to_currency);
        if (!$rate) {
            return response()->json(['status' => 'error', 'message' => 'Exchange rate currently unavailable'], 400);
        }

        $convertedAmount = $request->amount * $rate;

        // 4. Atomic Swap
        return DB::transaction(function () use ($sourceWallet, $destWallet, $request, $convertedAmount, $rate) {
            // Debit
            $sourceWallet->decrement('balance', $request->amount);
            
            // Credit
            $destWallet->increment('balance', $convertedAmount);

            // Log Transaction
            Transaction::create([
                'user_id' => $sourceWallet->user_id,
                'wallet_id' => $sourceWallet->id,
                'type' => 'debit',
                'amount' => $request->amount,
                'currency' => $request->from_currency,
                'status' => 'completed',
                'reference' => 'SWAP_OUT_' . strtoupper(uniqid()),
                'narration' => "Swapped {$request->from_currency} for {$request->to_currency} at rate of {$rate}",
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Currency swapped successfully',
                'data' => [
                    'from_amount' => $request->amount,
                    'to_amount' => $convertedAmount,
                    'rate' => $rate,
                    'new_balances' => [
                        $request->from_currency => $sourceWallet->fresh()->balance,
                        $request->to_currency => $destWallet->fresh()->balance,
                    ]
                ]
            ]);
        });
    }
}
