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
        
        // Verify PIN (Assuming basic check for now, should be more robust)
        if ($user->transaction_pin !== $request->pin) {
             return response()->json(['error' => 'Invalid transaction PIN'], 403);
        }

        $sourceWallet = Wallet::where('id', $request->source_wallet_id)->where('user_id', $user->id)->firstOrFail();

        if ($sourceWallet->balance < $request->amount) {
            return response()->json(['error' => 'Insufficient funds'], 400);
        }

        $recipientUser = \App\Models\User::where('email', $request->recipient_email)->first();
        // Find recipient wallet of same currency, or create? For now assume they need one.
        // Or if not found, maybe fail or create pending?
        // Let's assume we find one or fail for MVP.
        $recipientWallet = Wallet::where('user_id', $recipientUser->id)->where('currency', $sourceWallet->currency)->first();

        if (!$recipientWallet) {
             return response()->json(['error' => 'Recipient needs a ' . $sourceWallet->currency . ' wallet'], 400);
        }

        DB::transaction(function () use ($sourceWallet, $recipientWallet, $request, $user, $recipientUser) {
            // Debit Sender
            $sourceWallet->balance -= $request->amount;
            $sourceWallet->save();

            Transaction::create([
                'user_id' => $user->id,
                'wallet_id' => $sourceWallet->id,
                'type' => 'debit', // transfer_out
                'amount' => $request->amount,
                'currency' => $sourceWallet->currency,
                'recipient' => $recipientUser->email,
                'status' => 'completed',
                'reference' => 'TRF-' . uniqid(),
            ]);

            // Credit Recipient
            $recipientWallet->balance += $request->amount;
            $recipientWallet->save();

            Transaction::create([
                'user_id' => $recipientUser->id,
                'wallet_id' => $recipientWallet->id,
                'type' => 'credit', // transfer_in
                'amount' => $request->amount,
                'currency' => $recipientWallet->currency,
                'status' => 'completed',
                'reference' => 'RCV-' . uniqid(),
            ]);
        });

        return response()->json(['message' => 'Transfer successful']);
    }
}
