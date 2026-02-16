<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class YellowCardService
{
    private $baseUrl;
    private $apiKey;

    public function __construct()
    {
        // Fetch keys from DB (System Settings)
        $dbSettings = DB::table('system_settings')
            ->whereIn('setting_key', ['yellowcard_base_url', 'yellowcard_api_key'])
            ->pluck('setting_value', 'setting_key');

        $this->baseUrl = $dbSettings['yellowcard_base_url'] ?? 'https://api.yellowcard.io';
        $this->apiKey = $dbSettings['yellowcard_api_key'] ?? '';
    }

    /**
     * Create a Quote for International Settlement
     * 
     * @param string $fromCurrency Source Currency (e.g. 'NGN', 'USD')
     * @param string $toCurrency Destination Currency (e.g. 'CNY', 'GBP')
     * @param float $amount Amount to send
     */
    public function createQuote($fromCurrency, $toCurrency, $amount)
    {
        // In a real integration, we'd call Yellow Card API to get the rate/quote.
        // Endpoint: POST /business/quotes
        
        /* 
        $response = Http::withHeaders(...)->post("{$this->baseUrl}/business/quotes", [
            'from' => $fromCurrency,
            'to' => $toCurrency,
            'amount' => $amount
        ]);
        */

        // For now (until keys are live), we simulate a successful quote
        // Assuming we route via USDT on the backend: Fiat -> USDT -> Fiat
        
        return [
            'status' => 'success',
            'data' => [
                'id' => 'qt_' . uniqid(),
                'rate' => 1.0, // simplified
                'source_amount' => $amount,
                'destination_amount' => $amount * 0.98, // simulate fees
                'expires_at' => now()->addMinutes(15)->toIso8601String()
            ]
        ];
    }

    /**
     * Execute Transfer to Supplier
     */
    public function executeTransfer($quoteId, $beneficiaryDetails)
    {
        // Endpoint: POST /business/transfers
        
        return [
            'status' => 'success',
            'data' => [
                'id' => 'tx_' . uniqid(),
                'status' => 'pending', // Yellow Card transfers are often async
                'reference' => 'ref_' . uniqid()
            ]
        ];
    }
}
