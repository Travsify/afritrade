<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class KlashaService
{
    private $baseUrl;
    private $apiKey;

    public function __construct()
    {
        $settings = DB::table('system_settings')
            ->whereIn('setting_key', ['klasha_base_url', 'klasha_api_key'])
            ->pluck('setting_value', 'setting_key');

        $this->baseUrl = $settings['klasha_base_url'] ?? config('services.klasha.url', 'https://api.klasha.com');
        $this->apiKey = $settings['klasha_api_key'] ?? config('services.klasha.key');
    }

    /**
     * Pay to China (CNY).
     * Supports: Alipay, WeChat, Bank Account.
     */
    public function payToChina(array $data)
    {
        $payload = [
            'amount' => $data['amount'],
            'currency' => $data['source_currency'] ?? 'NGN',
            'destination_currency' => 'CNY',
            'recipient' => [
                'type' => $data['recipient_type'], // alipay, wechat, bank
                'account_number' => $data['account_number'],
                'name' => $data['name'],
                'bank_name' => $data['bank_name'] ?? null,
            ],
            'narration' => $data['narration'] ?? 'Supplier Payment',
            'reference' => 'KL_' . uniqid(),
        ];

        try {
            $response = Http::withHeaders([
                'x-api-key' => $this->apiKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/payouts/china", $payload);

            if ($response->successful()) {
                return [
                    'status' => 'success',
                    'data' => $response->json()['data']
                ];
            }

            Log::error('Klasha Payout Error: ' . $response->body());
            return ['status' => 'error', 'message' => $response->json()['message'] ?? 'Klasha error'];

        } catch (\Exception $e) {
            Log::error('Klasha Connection Error: ' . $e->getMessage());
            return ['status' => 'error', 'message' => 'Connection failed'];
        }
    }

    /**
     * Klasha Wire for global FX payouts.
     */
    public function initiateWire(array $data)
    {
        $payload = [
            'amount' => $data['amount'],
            'source_currency' => $data['source_currency'],
            'destination_currency' => $data['destination_currency'], // USD, EUR, GBP
            'beneficiary' => $data['beneficiary'],
            'reference' => 'WIRE_' . uniqid(),
        ];

        try {
            $response = Http::withHeaders(['x-api-key' => $this->apiKey])
                ->post("{$this->baseUrl}/payouts/wire", $payload);

            return $response->json();
        } catch (\Exception $e) {
            return ['status' => 'error', 'message' => $e->getMessage()];
        }
    }
}
