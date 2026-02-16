<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PremblyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class KycApiController extends Controller
{
    protected $prembly;

    public function __construct(PremblyService $prembly)
    {
        $this->prembly = $prembly;
    }

    public function status()
    {
        $user = Auth::user();
        return response()->json([
            'kyc_tier' => $user->kyc_tier ?? 0,
            'verification_status' => $user->verification_status ?? 'unverified',
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
             // Success logic
             /** @var \App\Models\User $user */
             $user = Auth::user();
             $user->verification_status = 'verified';
             $user->kyc_tier = 1; // Start with Tier 1
             $user->save();

             return response()->json(['message' => 'Verification successful', 'data' => $result]);
        }

        return response()->json(['message' => 'Verification failed', 'error' => $result['message'] ?? 'Unknown error'], 400);
    }
}
