<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Services\AnchorService;

class WithdrawalApiController extends Controller
{
    protected $anchorService;

    public function __construct(AnchorService $anchorService)
    {
        $this->anchorService = $anchorService;
    }

    /**
     * Withdraw to local bank account via Anchor Transfer API
     */
    public function withdraw(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
            'bank_code' => 'required|string',
            'account_number' => 'required|string|digits:10',
            'account_name' => 'required|string',
        ]);

        $user = Auth::user();
        $amount = $request->amount;

        // Convert USD to NGN for local payout
        $rate = $this->anchorService->getExchangeRate('USD', 'NGN');
        $ngnAmount = $amount * $rate;
        
        // Fee calculation (e.g., 1%)
        $fee = $amount * 0.01;
        $totalDebit = $amount + $fee;

        if ($user->balance < $totalDebit) {
            return response()->json([
                'status' => 'error',
                'message' => 'Insufficient balance (including ₦' . number_format($fee * $rate, 2) . ' fee)'
            ], 400);
        }

        // Call Anchor Transfer API
        $transferResult = $this->anchorService->initiateTransfer([
            'amount' => $ngnAmount,
            'bank_code' => $request->bank_code,
            'account_number' => $request->account_number,
            'account_name' => $request->account_name,
            'narration' => 'Afritrad Withdrawal - ' . $user->email,
        ]);

        if ($transferResult['status'] !== 'success') {
            return response()->json([
                'status' => 'error',
                'message' => $transferResult['message'] ?? 'Transfer failed. Please try again.'
            ], 400);
        }

        // Debit user balance on successful initiation
        $user->decrement('balance', $totalDebit);

        // Log transaction with Anchor reference
        Transaction::create([
            'user_id' => $user->id,
            'type' => 'debit',
            'amount' => $amount,
            'currency' => 'USD',
            'recipient' => $request->account_name . ' - ' . $request->account_number,
            'status' => 'pending', // Will be updated via webhook
            'reference' => $transferResult['reference'] ?? 'WD-' . uniqid()
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Withdrawal initiated. ₦' . number_format($ngnAmount, 2) . ' will be credited shortly.',
            'data' => [
                'usd_amount' => $amount,
                'ngn_amount' => $ngnAmount,
                'fee' => $fee,
                'rate' => $rate,
                'reference' => $transferResult['reference'] ?? null,
                'anchor_data' => $transferResult['data'] ?? null
            ]
        ]);
    }

    /**
     * Get withdrawal history from Anchor
     */
    public function history(Request $request)
    {
        $page = $request->query('page', 1);
        $limit = $request->query('limit', 20);

        $result = $this->anchorService->getTransfers([
            'page' => $page,
            'limit' => $limit
        ]);

        return response()->json([
            'status' => $result['status'],
            'data' => $result['data'],
            'meta' => $result['meta'] ?? null
        ]);
    }

    /**
     * Get single withdrawal status
     */
    public function status($reference)
    {
        $result = $this->anchorService->getTransfer($reference);

        return response()->json($result);
    }
}
