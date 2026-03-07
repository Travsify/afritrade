<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class IdentityPassService
{
    private $baseUrl;
    private $apiKey;
    private $appId;

    public function __construct()
    {
        $this->baseUrl = config('services.identitypass.base_url', 'https://api.prembly.com');
        $this->apiKey = config('services.identitypass.api_key');
        $this->appId = config('services.identitypass.app_id');
    }

    /**
     * Verify Business (CAC)
     */
    public function verifyCac($registrationNumber, $companyName = null)
    {
        return $this->processRequest('/identitypass/verification/cac', [
            'registration_number' => $registrationNumber,
            'company_name' => $companyName,
        ]);
    }

    /**
     * Verify TIN (Tax Identification Number)
     */
    public function verifyTin($tin)
    {
        return $this->processRequest('/identitypass/verification/tin', [
            'number' => $tin,
        ]);
    }

    /**
     * Verify Director (NIN/BVN) via IdentityPass
     */
    public function verifyDirector($idNumber, $idType = 'nin')
    {
        $endpoint = $idType === 'nin' ? '/identitypass/verification/nin' : '/identitypass/verification/bvn';
        return $this->processRequest($endpoint, [
            'number' => $idNumber,
        ]);
    }

    /**
     * Verify Driver's License
     */
    public function verifyDriversLicense($number, $dob)
    {
        return $this->processRequest('/identitypass/verification/dl', [
            'number' => $number,
            'dob' => $dob,
        ]);
    }

    /**
     * Verify International Passport
     */
    public function verifyPassport($number, $lastName)
    {
        return $this->processRequest('/identitypass/verification/passport', [
            'number' => $number,
            'last_name' => $lastName,
        ]);
    }

    /**
     * Verify Voter's Card
     */
    public function verifyVotersCard($number, $state, $lastName)
    {
        return $this->processRequest('/identitypass/verification/voter_card', [
            'number' => $number,
            'state' => $state,
            'last_name' => $lastName,
        ]);
    }

    private function processRequest($endpoint, $payload)
    {
        try {
            $response = Http::withHeaders([
                'x-api-key' => $this->apiKey,
                'app-id' => $this->appId,
                'Accept' => 'application/json',
                'Content-Type' => 'application/json',
            ])->post($this->baseUrl . $endpoint, $payload);

            if ($response->successful()) {
                return [
                    'status' => 'success',
                    'data' => $response->json()
                ];
            }

            Log::error("IdentityPass API Error ({$endpoint}): " . $response->body());
            return [
                'status' => 'error',
                'message' => $response->json()['message'] ?? 'Identity Verification failed',
                'code' => $response->status()
            ];
        } catch (\Exception $e) {
            Log::error("IdentityPass Exception: " . $e->getMessage());
            return [
                'status' => 'error',
                'message' => 'System error during verification'
            ];
        }
    }
}
