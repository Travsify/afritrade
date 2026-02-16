<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PremblyService
{
    protected $baseUrl;
    protected $apiKey;

    public function __construct()
    {
        $this->baseUrl = config('services.prembly.base_url', 'https://api.prembly.com'); // Default fallback
        $this->apiKey = config('services.prembly.api_key');
    }

    /**
     * Verify Identity (NIN, BVN, etc.)
     * 
     * @param string $type The type of verification (e.g., 'NIN', 'BVN')
     * @param string $number The identity number
     * @param array $data Additional data (e.g., DOB, Lastname for matching)
     * @return array
     */
    public function verifyIdentity($type, $number, $data = [])
    {
        // endpoint structure usually /identity/{type}/verify or similar
        // Adjusting based on standard Prembly/IdentityPass patterns
        $endpoint = "/identity/" . strtolower($type);
        
        $payload = array_merge(['number' => $number], $data);

        try {
            $response = Http::withHeaders([
                'x-api-key' => $this->apiKey,
                'app-id' => config('services.prembly.app_id'), // Some endpoints need app-id
            ])->post($this->baseUrl . $endpoint, $payload);

            if ($response->successful()) {
                return $response->json();
            }

            Log::error("Prembly Verification Failed: " . $response->body());
            return ['status' => false, 'message' => 'Verification failed at provider'];
        } catch (\Exception $e) {
            Log::error("Prembly Exception: " . $e->getMessage());
            return ['status' => false, 'message' => 'Service error'];
        }
    }

    /**
     * Verify Business (CAC)
     */
    public function verifyBusiness($rcNumber, $companyName = null)
    {
        $endpoint = "/business/cac"; // Hypothetical endpoint

        try {
            $response = Http::withHeaders([
                'x-api-key' => $this->apiKey,
            ])->post($this->baseUrl . $endpoint, [
                'rc_number' => $rcNumber,
                'company_name' => $companyName // Optional matching
            ]);

            return $response->json();
        } catch (\Exception $e) {
            Log::error("Prembly Business Verification Exception: " . $e->getMessage());
            return ['status' => false, 'message' => 'Service error'];
        }
    }
}
