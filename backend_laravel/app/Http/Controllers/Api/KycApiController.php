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
}
