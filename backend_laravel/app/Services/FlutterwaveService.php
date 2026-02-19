<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FlutterwaveService
{
    protected string $baseUrl = 'https://api.flutterwave.com/v3';
    protected ?string $secretKey;

    public function __construct()
    {
        $this->secretKey = config('services.flutterwave.secret_key');
    }

    /**
     * Initialize a payment — generate a payment link for the user.
     */
    public function initializePayment(array $params): array
    {
        try {
            $response = Http::withToken($this->secretKey)
                ->post("{$this->baseUrl}/payments", [
                    'tx_ref' => $params['reference'],
                    'amount' => $params['amount'],
                    'currency' => $params['currency'] ?? 'NGN',
                    'redirect_url' => $params['redirect_url'] ?? config('app.url') . '/api/payments/callback',
                    'customer' => [
                        'email' => $params['email'],
                        'name' => $params['name'] ?? '',
                    ],
                    'customizations' => [
                        'title' => 'Afritrad Wallet Funding',
                        'description' => 'Fund your Afritrad wallet',
                        'logo' => 'https://afritrade.onrender.com/logo.png',
                    ],
                    'payment_options' => 'card,banktransfer,ussd,mobilemoney',
                ]);

            if ($response->successful() && $response->json('status') === 'success') {
                return [
                    'status' => 'success',
                    'payment_link' => $response->json('data.link'),
                    'reference' => $params['reference'],
                ];
            }

            return [
                'status' => 'error',
                'message' => $response->json('message') ?? 'Payment initialization failed',
            ];
        } catch (\Exception $e) {
            Log::error('Flutterwave initializePayment error: ' . $e->getMessage());
            return ['status' => 'error', 'message' => 'Payment service unavailable'];
        }
    }

    /**
     * Verify a payment transaction.
     */
    public function verifyPayment(string $transactionId): array
    {
        try {
            $response = Http::withToken($this->secretKey)
                ->get("{$this->baseUrl}/transactions/{$transactionId}/verify");

            if ($response->successful()) {
                $data = $response->json('data');
                return [
                    'status' => ($data['status'] ?? '') === 'successful' ? 'success' : 'failed',
                    'data' => [
                        'amount' => $data['amount'] ?? 0,
                        'currency' => $data['currency'] ?? 'NGN',
                        'reference' => $data['tx_ref'] ?? '',
                        'flw_ref' => $data['flw_ref'] ?? '',
                        'customer_email' => $data['customer']['email'] ?? '',
                    ],
                ];
            }

            return ['status' => 'error', 'message' => 'Verification failed'];
        } catch (\Exception $e) {
            Log::error('Flutterwave verifyPayment error: ' . $e->getMessage());
            return ['status' => 'error', 'message' => 'Verification service unavailable'];
        }
    }

    /**
     * Initiate a bank transfer payout.
     */
    public function initiateTransfer(array $params): array
    {
        try {
            $response = Http::withToken($this->secretKey)
                ->post("{$this->baseUrl}/transfers", [
                    'account_bank' => $params['bank_code'],
                    'account_number' => $params['account_number'],
                    'amount' => $params['amount'],
                    'currency' => $params['currency'] ?? 'NGN',
                    'narration' => $params['narration'] ?? 'Afritrad Withdrawal',
                    'reference' => $params['reference'] ?? 'WD-' . uniqid(),
                    'debit_currency' => 'NGN',
                ]);

            if ($response->successful() && $response->json('status') === 'success') {
                return [
                    'status' => 'success',
                    'data' => $response->json('data'),
                    'reference' => $response->json('data.reference') ?? $params['reference'],
                ];
            }

            return [
                'status' => 'error',
                'message' => $response->json('message') ?? 'Transfer initiation failed',
            ];
        } catch (\Exception $e) {
            Log::error('Flutterwave transfer error: ' . $e->getMessage());
            return ['status' => 'error', 'message' => 'Transfer service unavailable'];
        }
    }

    /**
     * Get list of Nigerian banks.
     */
    public function getBanks(string $country = 'NG'): array
    {
        try {
            $response = Http::withToken($this->secretKey)
                ->get("{$this->baseUrl}/banks/{$country}");

            if ($response->successful()) {
                return [
                    'status' => 'success',
                    'data' => $response->json('data') ?? [],
                ];
            }

            return ['status' => 'error', 'message' => 'Could not fetch banks'];
        } catch (\Exception $e) {
            Log::error('Flutterwave getBanks error: ' . $e->getMessage());
            return ['status' => 'error', 'message' => 'Bank list unavailable'];
        }
    }

    /**
     * Resolve account number to get account name.
     */
    public function resolveAccount(string $accountNumber, string $bankCode): array
    {
        try {
            $response = Http::withToken($this->secretKey)
                ->post("{$this->baseUrl}/accounts/resolve", [
                    'account_number' => $accountNumber,
                    'account_bank' => $bankCode,
                ]);

            if ($response->successful()) {
                return [
                    'status' => 'success',
                    'data' => $response->json('data'),
                ];
            }

            return ['status' => 'error', 'message' => 'Account resolution failed'];
        } catch (\Exception $e) {
            Log::error('Flutterwave resolveAccount error: ' . $e->getMessage());
            return ['status' => 'error', 'message' => 'Account resolution unavailable'];
        }
    }
}
