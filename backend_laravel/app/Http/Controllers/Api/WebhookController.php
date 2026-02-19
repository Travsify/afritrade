<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use App\Models\Transaction;
use App\Models\Wallet;
use App\Models\VirtualAccount;
use App\Models\VirtualCard;
use App\Models\User;
use App\Services\NotificationService;

class WebhookController extends Controller
{
    protected NotificationService $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Route incoming webhooks to the correct provider handler.
     */
    public function handle(Request $request, $provider)
    {
        Log::channel('daily')->info("Webhook [{$provider}]", $request->all());

        return match ($provider) {
            'fincra' => $this->handleFincra($request),
            'maplerad' => $this->handleMaplerad($request),
            'klasha' => $this->handleKlasha($request),
            'flutterwave' => $this->handleFlutterwave($request),
            default => response()->json(['message' => 'Unknown provider'], 400),
        };
    }

    // ─── Fincra ───

    protected function handleFincra(Request $request)
    {
        // Verify webhook signature
        $signature = $request->header('x-business-id');
        if ($signature && $signature !== config('services.fincra.business_id')) {
            Log::warning('Fincra webhook signature mismatch');
            return response()->json(['message' => 'Invalid signature'], 401);
        }

        $event = $request->input('event');
        $data = $request->input('data', []);

        switch ($event) {
            case 'virtualaccount.approved':
                VirtualAccount::where('provider_id', $data['id'] ?? null)
                    ->update(['status' => 'active']);
                break;

            case 'collection.successful':
                $this->handleIncomingPayment($data);
                break;

            case 'payout.successful':
                $this->updateTransactionStatus($data['reference'] ?? null, 'completed', 'Payout completed');
                break;

            case 'payout.failed':
                $this->handlePayoutFailure($data);
                break;
        }

        return response()->json(['status' => 'ok']);
    }

    // ─── Maplerad ───

    protected function handleMaplerad(Request $request)
    {
        $event = $request->input('event');
        $data = $request->input('data', []);

        switch ($event) {
            case 'card.transaction':
                // Log card transaction
                $card = VirtualCard::where('provider_id', $data['card_id'] ?? null)->first();
                if ($card) {
                    Transaction::create([
                        'user_id' => $card->user_id,
                        'type' => 'debit',
                        'amount' => $data['amount'] ?? 0,
                        'currency' => $data['currency'] ?? 'USD',
                        'recipient' => $data['merchant'] ?? 'Card Transaction',
                        'status' => 'completed',
                        'reference' => 'CARD-' . ($data['reference'] ?? uniqid()),
                    ]);
                    $this->notificationService->transactionDebit(
                        $card->user_id,
                        $data['amount'] ?? 0,
                        $data['currency'] ?? 'USD',
                        $data['reference'] ?? ''
                    );
                }
                break;

            case 'transfer.completed':
                $this->updateTransactionStatus($data['reference'] ?? null, 'completed', 'Transfer completed');
                break;

            case 'transfer.failed':
                $this->handlePayoutFailure($data);
                break;
        }

        return response()->json(['status' => 'ok']);
    }

    // ─── Klasha ───

    protected function handleKlasha(Request $request)
    {
        $event = $request->input('event');
        $data = $request->input('data', []);

        switch ($event) {
            case 'payout.success':
                $this->updateTransactionStatus($data['reference'] ?? null, 'completed', 'Payout successful');
                break;

            case 'payout.failed':
                $this->handlePayoutFailure($data);
                break;
        }

        return response()->json(['status' => 'ok']);
    }

    // ─── Flutterwave ───

    protected function handleFlutterwave(Request $request)
    {
        // Verify webhook hash
        $secretHash = config('services.flutterwave.webhook_hash');
        if ($secretHash && $request->header('verif-hash') !== $secretHash) {
            Log::warning('Flutterwave webhook hash mismatch');
            return response()->json(['message' => 'Invalid hash'], 401);
        }

        $data = $request->input('data', []);
        $event = $request->input('event');

        if ($event === 'charge.completed' && ($data['status'] ?? '') === 'successful') {
            $this->handleIncomingPayment([
                'reference' => $data['tx_ref'] ?? $data['flw_ref'] ?? null,
                'amount' => $data['amount'] ?? 0,
                'currency' => $data['currency'] ?? 'NGN',
                'customer_email' => $data['customer']['email'] ?? null,
            ]);
        }

        if ($event === 'transfer.completed') {
            $status = ($data['status'] ?? '') === 'SUCCESSFUL' ? 'completed' : 'failed';
            $this->updateTransactionStatus($data['reference'] ?? null, $status, 'Flutterwave payout ' . $status);
        }

        return response()->json(['status' => 'ok']);
    }

    // ─── Shared Helpers ───

    /**
     * Credit user wallet when a collection/payment is received.
     */
    protected function handleIncomingPayment(array $data)
    {
        $reference = $data['reference'] ?? null;
        $amount = $data['amount'] ?? 0;
        $currency = $data['currency'] ?? 'NGN';
        $customerEmail = $data['customer_email'] ?? null;

        if (!$reference || !$amount) return;

        // Prevent duplicate processing
        if (Transaction::where('reference', $reference)->exists()) {
            Log::info("Duplicate webhook: {$reference}");
            return;
        }

        // Find user by email or by existing pending transaction
        $user = null;
        if ($customerEmail) {
            $user = User::where('email', $customerEmail)->first();
        }

        if (!$user) {
            $pendingTx = Transaction::where('reference', $reference)->where('status', 'pending')->first();
            if ($pendingTx) $user = User::find($pendingTx->user_id);
        }

        if (!$user) {
            Log::warning("Webhook: No user found for payment {$reference}");
            return;
        }

        DB::transaction(function () use ($user, $amount, $currency, $reference) {
            // Find or create wallet for this currency
            $wallet = Wallet::firstOrCreate(
                ['user_id' => $user->id, 'currency' => $currency],
                ['balance' => 0]
            );

            $wallet->increment('balance', $amount);

            Transaction::create([
                'user_id' => $user->id,
                'wallet_id' => $wallet->id,
                'type' => 'credit',
                'amount' => $amount,
                'currency' => $currency,
                'status' => 'completed',
                'reference' => $reference,
                'recipient' => 'Wallet Funding',
            ]);

            $this->notificationService->transactionCredit($user->id, $amount, $currency, $reference);
        });
    }

    /**
     * Update an existing transaction's status.
     */
    protected function updateTransactionStatus(?string $reference, string $status, string $notifMessage = '')
    {
        if (!$reference) return;

        $transaction = Transaction::where('reference', $reference)->first();
        if (!$transaction) return;

        $transaction->update(['status' => $status]);

        if ($status === 'completed') {
            $this->notificationService->withdrawalComplete($transaction->user_id, $transaction->amount, $reference);
        } else {
            $this->notificationService->send(
                $transaction->user_id,
                'transaction',
                'Transaction Update',
                $notifMessage ?: "Transaction {$reference} status: {$status}"
            );
        }
    }

    /**
     * Handle a failed payout — refund user balance.
     */
    protected function handlePayoutFailure(array $data)
    {
        $reference = $data['reference'] ?? null;
        if (!$reference) return;

        $transaction = Transaction::where('reference', $reference)->where('status', 'pending')->first();
        if (!$transaction) return;

        DB::transaction(function () use ($transaction) {
            // Refund to user balance
            $user = User::find($transaction->user_id);
            if ($user) {
                $wallet = Wallet::where('user_id', $user->id)->where('currency', $transaction->currency)->first();
                if ($wallet) {
                    $wallet->increment('balance', $transaction->amount);
                }
            }

            $transaction->update(['status' => 'failed']);

            $this->notificationService->send(
                $transaction->user_id,
                'transaction',
                'Payment Failed — Refunded',
                "Your payment of {$transaction->currency} {$transaction->amount} (Ref: {$transaction->reference}) failed. The amount has been refunded.",
                ['amount' => $transaction->amount, 'reference' => $transaction->reference]
            );
        });
    }
}
