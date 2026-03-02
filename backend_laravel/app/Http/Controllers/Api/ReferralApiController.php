<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Referral;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class ReferralApiController extends Controller
{
    public function index()
    {
        $user = Auth::user();

        // Get referrals where this user is the referrer
        $referrals = Referral::where('referrer_id', $user->id)
            ->with('user:id,name,email,created_at')
            ->orderBy('created_at', 'desc')
            ->get();

        $totalEarned = $referrals->sum('commission_earned');
        $pending = $referrals->where('status', 'pending')->count();

        return response()->json([
            'status' => 'success',
            'code' => $user->referral_code ?? strtoupper(substr($user->name, 0, 3)) . $user->id,
            'list' => $referrals,
            'stats' => [
                'total_earned' => $totalEarned,
                'referrals' => $referrals->count(),
                'pending' => $pending,
            ],
        ]);
    }
}
