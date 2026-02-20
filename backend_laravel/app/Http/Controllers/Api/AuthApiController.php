<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class AuthApiController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
            'country' => 'required|string',
            'business_name' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error', 
                'message' => $validator->errors()->first()
            ]);
        }

        $otp = rand(1000, 9999);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'country' => $request->country,
            'business_name' => $request->business_name,
            'otp_code' => $otp,
            'otp_expires_at' => now()->addMinutes(15),
            'is_otp_verified' => false,
            'kyb_status' => 'none',
        ]);

        // Send OTP via email in production
        Log::info("OTP for {$user->email}: {$otp}");

        return response()->json([
            'status' => 'success',
            'message' => 'Account created. Please verify OTP.',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'otp_debug' => $otp // Remove in production
            ]
        ]);
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || $user->otp_code !== $request->otp) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid OTP code'
            ], 400);
        }

        if ($user->otp_expires_at && $user->otp_expires_at->isPast()) {
            return response()->json([
                'status' => 'error',
                'message' => 'OTP has expired'
            ], 400);
        }

        $user->update([
            'is_otp_verified' => true,
            'otp_code' => null,
            'otp_expires_at' => null,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'OTP verified successfully',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'is_verified' => $user->is_kyc_verified
            ]
        ]);
    }

    public function login(Request $request)
    {
        $credentials = $request->only('email', 'password');

        if (Auth::attempt($credentials)) {
            $user = Auth::user();
            
            if (!$user->is_otp_verified) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Email not verified. Please verify OTP.',
                    'requires_otp' => true,
                    'email' => $user->email
                ], 403);
            }

            $token = $user->createToken('auth_token')->plainTextToken;

            // Send login security alert
            try {
                $notifService = app(NotificationService::class);
                $notifService->loginAlert($user->id, $request->ip());
            } catch (\Exception $e) {
                Log::debug('Login alert failed: ' . $e->getMessage());
            }

            return response()->json([
                'status' => 'success',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => 'user',
                    'country' => $user->country,
                    'business_name' => $user->business_name,
                    'is_verified' => $user->is_kyc_verified || ($user->verification_status === 'verified'),
                    'kyb_status' => $user->kyb_status,
                    'has_pin' => !empty($user->transaction_pin),
                ],
                'token' => $token
            ]);
        }

        return response()->json([
            'status' => 'error',
            'message' => 'Invalid credentials'
        ]);
    }

    /**
     * Get authenticated user's full profile.
     */
    public function profile()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        $wallets = $user->wallets;
        $totalBalance = (float) $wallets->sum('balance');

        $referralCount = $user->referrals()->count();
        $monthlyUsage = (float) $user->transactions()
            ->where('created_at', '>=', now()->subDays(30))
            ->sum('amount');
        
        $securityLogs = $user->notifications()
            ->where('type', 'security')
            ->latest()
            ->take(5)
            ->get(['title', 'message', 'created_at']);

        return response()->json([
            'status' => 'success',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'country' => $user->country,
                'business_name' => $user->business_name,
                'kyb_status' => $user->kyb_status,
                'verification_status' => $user->verification_status,
                'kyc_tier' => $user->kyc_tier,
                'has_pin' => !empty($user->transaction_pin),
                'total_balance' => $totalBalance,
                'wallets_count' => $wallets->count(),
                'created_at' => $user->created_at->toISOString(),
                'trader_points' => (int) $user->trader_points,
                'referral_balance' => (float) $user->referral_balance,
                'referral_count' => $referralCount,
                'monthly_usage' => $monthlyUsage,
                'security_logs' => $securityLogs,
            ]
        ]);
    }

    /**
     * Update user profile.
     */
    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'business_name' => 'sometimes|string|max:255',
            'country' => 'sometimes|string|max:100',
        ]);

        /** @var \App\Models\User $user */
        $user = Auth::user();
        $user->update($request->only(['name', 'business_name', 'country']));

        return response()->json([
            'status' => 'success',
            'message' => 'Profile updated successfully',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'country' => $user->country,
                'business_name' => $user->business_name,
            ]
        ]);
    }

    /**
     * Logout — revoke current token.
     */
    public function logout(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = $request->user();
        
        // Revoke the current access token
        $user->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully'
        ]);
    }
}
