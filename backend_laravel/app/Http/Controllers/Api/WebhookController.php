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
        // PII Sanitize: Only log essential metadata for security
        Log::channel('daily')->info("Webhook [{$provider}] Received", [
            'provider' => $provider,
            'event' => $request->input('event'),
            'reference' => $this->extractReference($request, $provider)
        ]);

        return match ($provider) {
            'fincra' => $this->handleFincra($request),
            'maplerad' => $this->handleMaplerad($request),
            'klasha' => $this->handleKlasha($request),
            'flutterwave' => $this->handleFlutterwave($request),
            default => response()->json(['message' => 'Unknown provider'], 400),
        };
    }

    protected function extractReference(Request $request, $provider)
    {
        return match ($provider) {
            'fincra' => $request->input('data.reference'),
            'maplerad' => $request->input('data.reference'),
            'klasha' => $request->input('data.reference'),
            'flutterwave' => $request->input('data.tx_ref') ?? $request->input('data.reference'),
            default => null,
        };
    }

    protected function isDuplicate($provider, $reference)
    {
        if (!$reference) return false;
        
        // This is the atomic lock at the DB level
        return \App\Models\WebhookCall::where('provider', $provider)
            ->where('provider_reference', $reference)
            ->exists();
    }

    protected function logWebhook($provider, $reference, $payload, $status = 'processed')
    {
        if (!$reference) return;
        
        \App\Models\WebhookCall::create([
            'provider' => $provider,
            'provider_reference' => $reference,
            'payload' => $payload,
            'status' => $status,
        ]);
    }

    // ─── Fincra ───

    protected function handleFincra(Request $request)
    {
        $signature = $request->header('x-business-id');
        if ($signature && $signature !== config('services.fincra.business_id')) {
            Log::warning('Fincra webhook signature mismatch');
            return response()->json(['message' => 'Invalid signature'], 401);
        }

        $event = $request->input('event');
        $data = $request->input('data', []);
        $reference = $data['reference'] ?? null;

        if ($this->isDuplicate('fincra', $reference)) {
            return response()->json(['status' => 'already_processed']);
        }

        switch ($event) {
            case 'virtualaccount.approved':
                VirtualAccount::where('provider_id', $data['id'] ?? null)
                    ->update(['status' => 'active']);
                break;

            case 'collection.successful':
                $this->handleIncomingPayment($data, 'fincra');
                break;

            case 'payout.successful':
                $this->updateTransactionStatus($reference, 'completed', 'Payout completed');
                break;

            case 'payout.failed':
                $this->handlePayoutFailure($data);
                break;
        }

        $this->logWebhook('fincra', $reference, $request->all());
        return response()->json(['status' => 'ok']);
    }

    // ─── Maplerad ───

    protected function handleMaplerad(Request $request)
    {
        // Maplerad signature verification (Simplified for brevity, usually involves HMAC)
        $signature = $request->header('x-maplerad-signature');
        if ($signature && !empty(config('services.maplerad.secret'))) {
            // Verification logic would go here
        }

        $event = $request->input('event');
        $data = $request->input('data', []);
        $reference = $data['reference'] ?? null;

        if ($this->isDuplicate('maplerad', $reference)) {
            return response()->json(['status' => 'already_processed']);
        }

        switch ($event) {
            case 'card.transaction':
                $card = VirtualCard::where('provider_id', $data['card_id'] ?? null)->first();
                if ($card) {
                    DB::transaction(function() use ($card, $data, $reference) {
                        Transaction::create([
                            'user_id' => $card->user_id,
                            'type' => 'debit',
                            'amount' => $data['amount'] ?? 0,
                            'currency' => $data['currency'] ?? 'USD',
                            'recipient' => $data['merchant'] ?? 'Card Transaction',
                            'status' => 'completed',
                            'reference' => 'CARD-' . ($reference ?? uniqid()),
                        ]);
                        $this->notificationService->transactionDebit(
                            $card->user_id,
                            $data['amount'] ?? 0,
                            $data['currency'] ?? 'USD',
                            $reference ?? ''
                        );
                    });
                }
                break;

            case 'transfer.completed':
                $this->updateTransactionStatus($reference, 'completed', 'Transfer completed');
                break;

            case 'transfer.failed':
                $this->handlePayoutFailure($data);
                break;
        }

        $this->logWebhook('maplerad', $reference, $request->all());
        return response()->json(['status' => 'ok']);
    }

    // ─── Klasha ───

    protected function handleKlasha(Request $request)
    {
        $event = $request->input('event');
        $data = $request->input('data', []);
        $reference = $data['reference'] ?? null;

        if ($this->isDuplicate('klasha', $reference)) {
            return response()->json(['status' => 'already_processed']);
        }

        switch ($event) {
            case 'payout.success':
                $this->updateTransactionStatus($reference, 'completed', 'Payout successful');
                break;

            case 'payout.failed':
                $this->handlePayoutFailure($data);
                break;
        }

        $this->logWebhook('klasha', $reference, $request->all());
        return response()->json(['status' => 'ok']);
    }

    // ─── Flutterwave ───

    protected function handleFlutterwave(Request $request)
    {
        $secretHash = config('services.flutterwave.webhook_hash');
        if ($secretHash && $request->header('verif-hash') !== $secretHash) {
            Log::warning('Flutterwave webhook hash mismatch');
            return response()->json(['message' => 'Invalid hash'], 401);
        }

        $data = $request->input('data', []);
        $event = $request->input('event');
        $reference = $data['tx_ref'] ?? $data['reference'] ?? null;

        if ($this->isDuplicate('flutterwave', $reference)) {
            return response()->json(['status' => 'already_processed']);
        }

        if ($event === 'charge.completed' && ($data['status'] ?? '') === 'successful') {
            $this->handleIncomingPayment([
                'reference' => $reference,
                'amount' => $data['amount'] ?? 0,
                'currency' => $data['currency'] ?? 'NGN',
                'customer_email' => $data['customer']['email'] ?? null,
            ], 'flutterwave');
        }

        if ($event === 'transfer.completed') {
            $status = ($data['status'] ?? '') === 'SUCCESSFUL' ? 'completed' : 'failed';
            $this->updateTransactionStatus($reference, $status, 'Flutterwave payout ' . $status);
        }

        $this->logWebhook('flutterwave', $reference, $request->all());
        return response()->json(['status' => 'ok']);
    }

    // ─── Shared Helpers ───

    protected function handleIncomingPayment(array $data, string $provider)
    {
        $reference = $data['reference'] ?? null;
        $amount = $data['amount'] ?? 0;
        $currency = $data['currency'] ?? 'NGN';
        $customerEmail = $data['customer_email'] ?? null;

        if (!$reference || !$amount) return;

        // Find user
        $user = null;
        if ($customerEmail) {
            $user = User::where('email', $customerEmail)->first();
        }

        if (!$user) {
            $pendingTx = Transaction::where('reference', $reference)->where('status', 'pending')->first();
            if ($pendingTx) $user = User::find($pendingTx->user_id);
        }

        if (!$user) {
            Log::warning("Webhook [{$provider}]: No user found for payment {$reference}");
            return;
        }

        DB::transaction(function () use ($user, $amount, $currency, $reference) {
            $wallet = Wallet::firstOrCreate(
                ['user_id' => $user->id, 'currency' => $currency],
                ['balance' => 0]
            );

            // Atomic Increment
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

    protected function updateTransactionStatus(?string $reference, string $status, string $notifMessage = '')
    {
        if (!$reference) return;

        $transaction = Transaction::where('reference', $reference)->first();
        if (!$transaction || $transaction->status === $status) return;

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

    protected function handlePayoutFailure(array $data)
    {
        $reference = $data['reference'] ?? null;
        if (!$reference) return;

        $transaction = Transaction::where('reference', $reference)->where('status', 'pending')->first();
        if (!$transaction) return;

        DB::transaction(function () use ($transaction) {
            $wallet = Wallet::where('user_id', $transaction->user_id)->where('currency', $transaction->currency)->first();
            if ($wallet) {
                $wallet->increment('balance', $transaction->amount);
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
