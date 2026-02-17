<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class MapleradService
{
    private $baseUrl;
    private $secretKey;

    public function __construct()
    {
        $settings = DB::table('system_settings')
            ->whereIn('setting_key', ['maplerad_base_url', 'maplerad_secret_key'])
            ->pluck('setting_value', 'setting_key');

        $this->baseUrl = $settings['maplerad_base_url'] ?? config('services.maplerad.url', 'https://api.maplerad.com/v1');
        $this->secretKey = $settings['maplerad_secret_key'] ?? config('services.maplerad.key');
    }

    /**
     * Issue a Virtual USD Card.
     */
    public function createVirtualCard(array $data)
    {
        $payload = [
            'type' => 'VISA', // or MASTERCARD
            'currency' => 'USD',
            'amount' => $data['amount'] * 100, // in cents
            'customer_id' => $data['customer_id'],
            'brand_name' => 'Afritrad',
        ];

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $this->secretKey,
                'Content-Type' => 'application/json',
            ])->post("{$this->baseUrl}/issuing/cards", $payload);

            if ($response->successful()) {
                return [
                    'status' => 'success',
                    'data' => $response->json()['data']
                ];
            }

            Log::error('Maplerad Card Error: ' . $response->body());
            return ['status' => 'error', 'message' => $response->json()['message'] ?? 'Maplerad error'];

        } catch (\Exception $e) {
            Log::error('Maplerad Connection Error: ' . $e->getMessage());
            return ['status' => 'error', 'message' => 'Connection failed'];
        }
    }

    /**
     * Freeze/Unfreeze a card.
     */
    public function toggleCardStatus($cardId, $status = 'freeze')
    {
        try {
            $endpoint = $status === 'freeze' ? 'freeze' : 'unfreeze';
            $response = Http::withHeaders(['Authorization' => 'Bearer ' . $this->secretKey])
                ->post("{$this->baseUrl}/issuing/cards/{$cardId}/{$endpoint}");
            
            return $response->json();
        } catch (\Exception $e) {
            return ['status' => 'error', 'message' => $e->getMessage()];
        }
    }
}
