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
use Illuminate\Support\Facades\Mail;
use App\Mail\SendOtpMail;
use Carbon\Carbon;

class AuthApiController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20|unique:users',
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

        $otp = rand(100000, 999999);
        $expiresAt = Carbon::now()->addMinutes(15);

        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'country' => $request->country,
                'business_name' => $request->business_name,
                'otp_code' => $otp,
                'otp_expires_at' => $expiresAt,
                'is_otp_verified' => false,
                'kyb_status' => 'none',
            ]);

            if (!$user) {
                Log::error("User creation failed for email: {$request->email}");
                return response()->json([
                    'status' => 'error',
                    'message' => 'Account creation failed internally.'
                ], 500);
            }

            Log::info("Successful registration for User ID: {$user->id}, Email: {$user->email}");
            
            // Send OTP Email
            try {
                Mail::to($user->email)->send(new SendOtpMail($otp, $user->name));
            } catch (\Exception $e) {
                Log::error("Failed to send OTP email to {$user->email}: " . $e->getMessage());
                // Still return success, but maybe prompt them to resend
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Account created successfully. Please check your email for the verification code.',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'is_verified' => false
                ]
            ]);
        } catch (\Exception $e) {
            Log::error("Registration Exception for {$request->email}: " . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Database persistence error: ' . $e->getMessage()
            ], 500);
        }
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp_code' => 'required|string|min:6|max:6',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'User not found'
            ], 404);
        }

        if ($user->is_otp_verified) {
             return response()->json([
                'status' => 'error',
                'message' => 'Account is already verified'
            ], 400);
        }

        // Verify OTP and Expiration
        if ($user->otp_code !== $request->otp_code) {
             return response()->json([
                'status' => 'error',
                'message' => 'Invalid verification code'
            ], 400);
        }

        if (Carbon::now()->isAfter($user->otp_expires_at)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Verification code has expired. Please request a new one.'
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
            'message' => 'Email verified successfully',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'is_verified' => $user->is_kyc_verified
            ]
        ]);
    }

    public function resendOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
             return response()->json([
                'status' => 'error',
                'message' => 'User not found'
            ], 404);
        }

        if ($user->is_otp_verified) {
             return response()->json([
                'status' => 'error',
                'message' => 'Account is already verified'
            ], 400);
        }

        $otp = rand(100000, 999999);
        $expiresAt = Carbon::now()->addMinutes(15);

        $user->update([
            'otp_code' => $otp,
            'otp_expires_at' => $expiresAt,
        ]);

        try {
            Mail::to($user->email)->send(new SendOtpMail($otp, $user->name));
        } catch (\Exception $e) {
            Log::error("Failed to resend OTP email to {$user->email}: " . $e->getMessage());
             return response()->json([
                'status' => 'error',
                'message' => 'Failed to send email: ' . $e->getMessage()
            ], 500);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'A new verification code has been sent to your email.'
        ]);
    }

    public function login(Request $request)
    {
        $credentials = $request->only('email', 'password');

        if (Auth::attempt($credentials)) {
            $user = Auth::user();
            
            // Enforce OTP on every login as requested
            $otp = rand(100000, 999999);
            $expiresAt = Carbon::now()->addMinutes(15);
            
            $user->update([
                'otp_code' => $otp,
                'otp_expires_at' => $expiresAt,
                'is_otp_verified' => false,
            ]);

            try {
                Mail::to($user->email)->send(new SendOtpMail($otp, $user->name));
            } catch (\Exception $e) {
                Log::error("Failed to send OTP email during login to {$user->email}: " . $e->getMessage());
            }

            // Return 403 to trigger OTP verification screen on mobile
            return response()->json([
                'status' => 'error',
                'message' => 'OTP verification required to continue',
                'requires_otp' => true,
                'email' => $user->email,
                'phone' => $user->phone
            ], 403);
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
