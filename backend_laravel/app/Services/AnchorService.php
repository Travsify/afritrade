<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AnchorService
{
    private $baseUrl;
    private $apiKey;

    public function __construct()
    {
        // Fetch keys from DB (System Settings)
        $dbSettings = \Illuminate\Support\Facades\DB::table('system_settings')
            ->whereIn('setting_key', ['anchor_base_url', 'anchor_api_key'])
            ->pluck('setting_value', 'setting_key');

        $this->baseUrl = $dbSettings['anchor_base_url'] ?? config('services.anchor.url') ?? 'https://api.getanchor.co/api/v1';
        $this->apiKey = $dbSettings['anchor_api_key'] ?? config('services.anchor.key');
    }

    /**
     * Create a specific virtual account (NUBAN) for a user.
     * 
     * @param array $userData User details (email, name, phone)
     * @param string $currency USD, NGN, etc.
     */
    public function createVirtualAccount($userData, $currency = 'NGN')
    {
        // Determine endpoint based on currency/product
        // This is a GENERIC implementation based on standard banking APIs.
        // Needs actual Anchor Docs specific payload.
        
        $payload = [
            'currency' => $currency,
            'account_name' => $userData['name'],
            'email' => $userData['email'],
            'bvn' => $userData['bvn'] ?? null, // Required for NGN usually
            'reference' => 'ref_' . uniqid(),
            // Add other required fields
        ];

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
            ])->post("{$this->baseUrl}/accounts", $payload);

            if ($response->successful()) {
                return [
                    'status' => 'success',
                    'data' => $response->json()['data']
                ];
            }

            Log::error('Anchor API Error: ' . $response->body());
            return [
                'status' => 'error',
                'message' => 'Provider error: ' . $response->json()['message'] ?? 'Unknown error'
            ];

        } catch (\Exception $e) {
            Log::error('Anchor Connection Error: ' . $e->getMessage());
            return [
                'status' => 'error',
                'message' => 'Connection failed'
            ];
        }
    }

    /**
     * Get exchange rate between two currencies.
     * Platform rates for invoicing/swaps.
     */
    public function getExchangeRate($from, $to)
    {
        $rates = [
            'USD_NGN' => 1600.0, 'NGN_USD' => 0.000625,
            'USD_GBP' => 0.79, 'GBP_USD' => 1.26,
            'USD_EUR' => 0.92, 'EUR_USD' => 1.08,
            'USD_CNY' => 7.20, 'CNY_USD' => 0.138,
        ];

        $key = "{$from}_{$to}";
        return $rates[$key] ?? 1.0;
    }

    /**
     * Initiate a bank transfer (disbursement/payout) via Anchor.
     * 
     * @param array $transferData Required: amount, bank_code, account_number, account_name, narration
     */
    public function initiateTransfer($transferData)
    {
        $payload = [
            'amount' => $transferData['amount'] * 100, // Anchor uses kobo for NGN
            'currency' => 'NGN',
            'bank_code' => $transferData['bank_code'],
            'account_number' => $transferData['account_number'],
            'account_name' => $transferData['account_name'],
            'narration' => $transferData['narration'] ?? 'Afritrad Withdrawal',
            'reference' => 'WD_' . uniqid(),
        ];

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
            ])->post("{$this->baseUrl}/transfers", $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'status' => 'success',
                    'data' => $data['data'] ?? $data,
                    'reference' => $payload['reference']
                ];
            }

            Log::error('Anchor Transfer Error: ' . $response->body());
            return [
                'status' => 'error',
                'message' => $response->json()['message'] ?? 'Transfer failed'
            ];

        } catch (\Exception $e) {
            Log::error('Anchor Transfer Exception: ' . $e->getMessage());
            return [
                'status' => 'error',
                'message' => 'Connection failed: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Get transfer history from Anchor.
     * 
     * @param array $filters Optional filters: page, limit, status
     */
    public function getTransfers($filters = [])
    {
        try {
            $query = http_build_query($filters);
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Accept' => 'application/json',
            ])->get("{$this->baseUrl}/transfers?{$query}");

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'status' => 'success',
                    'data' => $data['data'] ?? [],
                    'meta' => $data['meta'] ?? null
                ];
            }

            return [
                'status' => 'error',
                'message' => 'Failed to fetch transfers',
                'data' => []
            ];

        } catch (\Exception $e) {
            Log::error('Anchor Get Transfers Error: ' . $e->getMessage());
            return [
                'status' => 'error',
                'message' => 'Connection failed',
                'data' => []
            ];
        }
    }

    /**
     * Get a single transfer by reference or ID.
     */
    public function getTransfer($transferId)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Accept' => 'application/json',
            ])->get("{$this->baseUrl}/transfers/{$transferId}");

            if ($response->successful()) {
                return [
                    'status' => 'success',
                    'data' => $response->json()['data'] ?? $response->json()
                ];
            }

            return ['status' => 'error', 'message' => 'Transfer not found'];

        } catch (\Exception $e) {
            return ['status' => 'error', 'message' => 'Connection failed'];
        }
    }
}
