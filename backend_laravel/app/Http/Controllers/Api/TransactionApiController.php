<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TransactionApiController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric',
            'type' => 'required|string',
            'currency' => 'required|string',
            // 'user_id' is ignored, we use Auth::id()
        ]);

        $transaction = Transaction::create([
            'user_id' => Auth::id(),
            'type' => $request->type,
            'amount' => $request->amount,
            'currency' => $request->currency,
            'recipient' => $request->recipient,
            'reference' => $request->reference ?? uniqid('txn_'),
            'status' => 'pending', // Default to pending
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Transaction logged',
            'id' => $transaction->id
        ]);
    }

    public function index(Request $request)
    {
        $transactions = Transaction::where('user_id', Auth::id())
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $transactions
        ]);
    }

    public function receipt($id)
    {
        $transaction = Transaction::where('user_id', Auth::id())
            ->with('user:id,name,email')
            ->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data' => [
                'transaction_id' => $transaction->reference,
                'amount' => number_format($transaction->amount, 2),
                'currency' => $transaction->currency,
                'type' => ucfirst($transaction->type),
                'status' => ucfirst($transaction->status),
                'date' => $transaction->created_at->format('M d, Y H:i:s'),
                'recipient' => $transaction->recipient ?? 'N/A',
                'user_name' => $transaction->user->name,
                'user_email' => $transaction->user->email,
            ]
        ]);
    }
}
