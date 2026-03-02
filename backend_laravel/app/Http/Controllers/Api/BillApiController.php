<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Wallet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class BillApiController extends Controller
{
    public function pay(Request $request)
    {
        $request->validate([
            'type' => 'required|string|in:Airtime & Data,Electricity,Cable TV',
            'amount' => 'required|numeric|min:0.01',
            'reference' => 'nullable|string',
        ]);

        $user = Auth::user();
        $amount = $request->amount;
        $type = $request->type;

        // Debit from user's NGN wallet
        $wallet = Wallet::where('user_id', $user->id)
            ->where('currency', 'NGN')
            ->first();

        if (!$wallet || $wallet->balance < $amount) {
            return response()->json([
                'status' => 'error',
                'message' => 'Insufficient NGN balance for this bill payment.',
            ], 422);
        }

        $wallet->balance -= $amount;
        $wallet->save();

        // Record transaction
        $reference = $request->reference ?? 'BILL_' . Str::upper(Str::random(10));
        Transaction::create([
            'user_id' => $user->id,
            'type' => 'debit',
            'amount' => $amount,
            'currency' => 'NGN',
            'description' => "$type bill payment",
            'reference' => $reference,
            'status' => 'completed',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => "$type payment of ₦" . number_format($amount, 2) . " successful.",
            'data' => [
                'reference' => $reference,
                'amount' => $amount,
                'type' => $type,
            ],
        ]);
    }
}
