<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class FincraService
{
    private $baseUrl;
    private $apiKey;
    private $merchantId;

    public function __construct()
    {
        $settings = DB::table('system_settings')
            ->whereIn('setting_key', ['fincra_base_url', 'fincra_api_key', 'fincra_merchant_id'])
            ->pluck('setting_value', 'setting_key');

        $this->baseUrl = $settings['fincra_base_url'] ?? config('services.fincra.url', 'https://api.fincra.com');
        $this->apiKey = $settings['fincra_api_key'] ?? config('services.fincra.key');
        $this->merchantId = $settings['fincra_merchant_id'] ?? config('services.fincra.merchant_id');
    }

    /**
     * Create a Virtual Business Account.
     * Supported: NGN, EUR, GBP, USD.
     */
    public function createVirtualAccount(array $data)
    {
        $payload = [
            'currency' => $data['currency'] ?? 'NGN',
            'accountType' => 'individual', 
            'KYCInformation' => [
                'firstName' => $data['first_name'],
                'lastName' => $data['last_name'],
                'email' => $data['email'],
                'bvn' => $data['bvn'] ?? null,
            ],
            'channel' => 'vbe', // Virtual Business Entity
        ];

        try {
            $response = Http::withHeaders([
                'api-key' => $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/virtual-accounts/requests", $payload);

            if ($response->successful()) {
                return [
                    'status' => 'success',
                    'data' => $response->json()['data']
                ];
            }

            Log::error('Fincra VA Error: ' . $response->body());
            return ['status' => 'error', 'message' => $response->json()['message'] ?? 'Fincra error'];

        } catch (\Exception $e) {
            Log::error('Fincra Connection Error: ' . $e->getMessage());
            return ['status' => 'error', 'message' => 'Connection failed'];
        }
    }

    /**
     * List all bill payment categories (Airtime, Data, Power).
     */
    public function getBillCategories()
    {
        try {
            $response = Http::withHeaders(['api-key' => $this->apiKey])
                ->get("{$this->baseUrl}/bills/categories");
            
            return $response->successful() ? $response->json()['data'] : [];
        } catch (\Exception $e) {
            return [];
        }
    }

    /**
     * Process a bill payment.
     */
    public function payBill(array $data)
    {
        $payload = [
            'amount' => $data['amount'],
            'customer' => [
                'name' => $data['customer_name'],
                'email' => $data['customer_email'],
            ],
            'bill' => [
                'category' => $data['category'],
                'item' => $data['item_code'],
                'id' => $data['customer_bill_id'], // e.g. Meter number
            ],
            'reference' => 'BILL_' . uniqid(),
        ];

        try {
            $response = Http::withHeaders(['api-key' => $this->apiKey])
                ->post("{$this->baseUrl}/bills/pay", $payload);

            return $response->json();
        } catch (\Exception $e) {
            return ['status' => 'error', 'message' => $e->getMessage()];
        }
    }
}
