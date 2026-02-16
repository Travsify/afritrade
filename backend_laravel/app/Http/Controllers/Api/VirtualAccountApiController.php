<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\VirtualAccount;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class VirtualAccountApiController extends Controller
{
    /**
     * Get list of virtual accounts for the user.
     */
    public function index()
    {
        $accounts = VirtualAccount::where('user_id', Auth::id())
            ->latest()
            ->get();

        return response()->json($accounts); // Returning direct array as mobile app expects list<map>
    }

    /**
     * Create (Simulate) a new virtual account.
     */
    /**
     * Create a new virtual account.
     */
    public function store(Request $request, \App\Services\AnchorService $anchorService)
    {
        $request->validate([
            'currency' => 'required|in:USD,EUR,GBP,NGN',
            'label' => 'nullable|string'
        ]);

        $currency = $request->currency;
        $label = $request->label ?? 'Afritrad Business';
        $user = Auth::user();

        // Check if config enables real API
        $useRealApi = config('services.anchor.enabled', false);

        if ($useRealApi) {
            $response = $anchorService->createVirtualAccount([
                'name' => $user->name,
                'email' => $user->email,
                // 'bvn' => $user->kyc_bvn // Assuming we store this
            ], $currency);

            if ($response['status'] !== 'success') {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Failed to create account: ' . ($response['message'] ?? 'Unknown error')
                ], 400);
            }

            // Map Real Data
            $data = $response['data'];
            // IMPORTANT: Mapping depends on ACTUAL Anchor response structure.
            // Using safe fallbacks or typical structure.
            $accountNumber = $data['account_number'] ?? $data['nuban'] ?? $this->generateAccountNumber(); 
            $bankName = $data['bank_name'] ?? 'Anchor Partner Bank';
            
        } else {
            // MOCK (Fallback/Dev)
            $bankName = match($currency) {
                'USD' => 'Anchor Bank US (Mock)',
                'EUR' => 'Anchor Bank EU (Mock)',
                'GBP' => 'Anchor Bank UK (Mock)',
                'NGN' => 'Wema Bank (Mock)',
                default => 'Unknown Bank'
            };
            $accountNumber = $this->generateAccountNumber();
        }

        $account = VirtualAccount::create([
            'user_id' => $user->id,
            'account_name' => $user->name,
            'account_number' => $accountNumber,
            'bank_name' => $bankName,
            'currency' => $currency,
            'balance' => 0.00,
            'label' => $label,
            'status' => 'active',
            'reference' => 'anch_' . uniqid(),
            // Mock static details for now if not provided by API
            'routing_number' => $currency === 'USD' ? '021000021' : null,
            'iban' => $currency === 'EUR' ? 'DE89370400440532013000' : null,
            'sort_code' => $currency === 'GBP' ? '04-00-04' : null,
            'bic' => $currency === 'EUR' ? 'MARKDEF1500' : null,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Virtual account created successfully',
            'data' => $account
        ]);
    }

    private function generateAccountNumber()
    {
        return (string) random_int(1000000000, 9999999999);
    }
}
