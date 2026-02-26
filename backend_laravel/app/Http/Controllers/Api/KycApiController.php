<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PremblyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class KycApiController extends Controller
{
    protected $identityPass;
    protected $prembly;

    public function __construct(PremblyService $prembly, \App\Services\IdentityPassService $identityPass)
    {
        $this->prembly = $prembly;
        $this->identityPass = $identityPass;
    }

    public function verifyBusiness(Request $request)
    {
        $request->validate([
            'registration_number' => 'required|string',
            'company_name' => 'nullable|string',
            'tin' => 'nullable|string',
        ]);

        // 1. Verify CAC
        $cacResult = $this->identityPass->verifyCac($request->registration_number, $request->company_name);

        if ($cacResult['status'] !== 'success') {
            return response()->json(['message' => 'CAC Verification failed', 'error' => $cacResult['message']], 400);
        }

        // 2. Verify TIN if provided
        if ($request->tin) {
            $tinResult = $this->identityPass->verifyTin($request->tin);
            if ($tinResult['status'] !== 'success') {
                return response()->json(['message' => 'TIN Verification failed', 'error' => $tinResult['message']], 400);
            }
        }

        // Success: Update User/Business Status
        /** @var \App\Models\User $user */
        $user = Auth::user();
        $user->kyc_tier = 3; // Business Tier
        $user->verification_status = 'verified';
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Business Verification Successful',
            'data' => $cacResult['data']
        ]);
    }

    public function verifyIdentity(Request $request)
    {
        $request->validate([
            'type' => 'required|string|in:NIN,BVN,VIN',
            'number' => 'required|string',
        ]);

        $result = $this->prembly->verifyIdentity($request->type, $request->number);

        if ($result['status'] ?? false) {
             $user = Auth::user();
             $user->verification_status = 'verified';
             $user->kyc_tier = max($user->kyc_tier, 1);
             $user->save();

             return response()->json(['message' => 'Verification successful', 'data' => $result]);
        }

        return response()->json(['message' => 'Verification failed', 'error' => $result['message'] ?? 'Unknown error'], 400);
    }

    public function status(Request $request)
    {
        $user = Auth::user();
        $documents = $user->kycDocuments()->get()->map(function ($doc) {
            return [
                'document_type' => $doc->doc_type,
                'document_number' => $doc->document_number ?? 'N/A',
                'status' => $doc->status,
                'rejection_reason' => $doc->rejection_reason,
            ];
        });

        // Define tier limits for display
        $tierLimits = [
            0 => ['daily' => 0, 'monthly' => 0, 'description' => 'Unverified - Please complete KYC'],
            1 => ['daily' => 50000, 'monthly' => 500000, 'description' => 'Tier 1 - Basic Limits'],
            2 => ['daily' => 500000, 'monthly' => 5000000, 'description' => 'Tier 2 - Enhanced Limits'],
            3 => ['daily' => 10000000, 'monthly' => 100000000, 'description' => 'Tier 3 - Business/Unlimited'],
        ];

        $currentTier = $user->kyc_tier ?? 0;

        return response()->json([
            'status' => 'success',
            'data' => [
                'kyc_tier' => $currentTier,
                'verification_status' => $user->verification_status,
                'tier_info' => $tierLimits[$currentTier] ?? $tierLimits[0],
                'documents' => $documents,
                'required_for_next_tier' => $this->getRequiredForNextTier($currentTier)
            ]
        ]);
    }

    private function getRequiredForNextTier($currentTier)
    {
        switch ($currentTier) {
            case 0:
                return ['bvn' => 'Verify BVN', 'nin' => 'Verify NIN'];
            case 1:
                return ['drivers_license' => 'Upload Driver License', 'passport' => 'Upload International Passport'];
            case 2:
                return ['utility_bill' => 'Upload Utility Bill (T3 Proof of Address)'];
            default:
                return [];
        }
    }
}
