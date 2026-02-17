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
    /**
     * Create a new virtual account.
     */
    public function store(Request $request, \App\Managers\FintechManager $fintechManager)
    {
        $request->validate([
            'currency' => 'required|in:USD,EUR,GBP,NGN',
            'label' => 'nullable|string'
        ]);

        $currency = $request->currency;
        $label = $request->label ?? 'Afritrad Business';
        $user = Auth::user();

        // Use the FintechManager to get the active provider for accounts
        $service = $fintechManager->getAccountProvider();
        $providerName = ($service instanceof \App\Services\FincraService) ? 'fincra' : 'anchor';

        $response = $service->createVirtualAccount([
            'first_name' => explode(' ', $user->name)[0],
            'last_name' => explode(' ', $user->name)[1] ?? $user->name,
            'email' => $user->email,
            'name' => $user->name,
            'bvn' => $user->kyc_bvn ?? null,
        ], $currency);

        if ($response['status'] !== 'success') {
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to create account: ' . ($response['message'] ?? 'Unknown error')
            ], 400);
        }

        $data = $response['data'];
        
        $account = VirtualAccount::create([
            'user_id' => $user->id,
            'account_name' => $data['account_name'] ?? $data['accountName'] ?? $user->name,
            'account_number' => $data['account_number'] ?? $data['nuban'] ?? $data['accountNumber'] ?? null,
            'bank_name' => $data['bank_name'] ?? $data['bankName'] ?? ($providerName === 'fincra' ? 'Fincra Partner' : 'Anchor Partner'),
            'currency' => $currency,
            'balance' => 0.00,
            'label' => $label,
            'status' => 'active',
            'provider' => $providerName,
            'provider_id' => $data['id'] ?? null,
            'reference' => 'va_' . uniqid(),
            'routing_number' => $data['routing_number'] ?? null,
            'iban' => $data['iban'] ?? null,
            'sort_code' => $data['sort_code'] ?? null,
            'bic' => $data['bic'] ?? null,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Virtual account created successfully',
            'data' => $account
        ]);
    }
}
