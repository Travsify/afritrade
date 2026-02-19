<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class AuthApiController extends Controller
{
    public function register(Request $request)
    {
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
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

        // In production, we'd send an email here.
        \Illuminate\Support\Facades\Log::info("OTP for {$user->email}: {$otp}");

        return response()->json([
            'status' => 'success',
            'message' => 'Account created. Please verify OTP.',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'otp_debug' => $otp // For MVP/Demo purposes
            ]
        ]);
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|string|length:4',
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
            
            // Check if OTP verified
            if (!$user->is_otp_verified) {
                 // Regenerate OTP if needed? For now, just tell them to verify
                 return response()->json([
                    'status' => 'error',
                    'message' => 'Email not verified. Please verify OTP.',
                    'requires_otp' => true,
                    'email' => $user->email
                ], 403);
            }

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'status' => 'success',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => 'user',
                    'is_verified' => $user->is_kyc_verified || ($user->verification_status === 'verified'),
                    'kyb_status' => $user->kyb_status
                ],
                'token' => $token
            ]);
        }

        return response()->json([
            'status' => 'error',
            'message' => 'Invalid credentials'
        ]);
    }
}
