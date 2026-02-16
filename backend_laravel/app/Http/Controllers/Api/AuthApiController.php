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
        // Legacy: "status" => "error", "message" => "..."
        // Laravel validation errors are usually 422, but we'll try to catch them or let standard behavior apply 
        // and mobile app should handle 422. However, legacy app expects 200 OK with "status": "error".
        // For compatibility, we might need manual validation or exception handling.
        
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error', 
                'message' => $validator->errors()->first()
            ]);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Legacy register.php checks email first. Unique validation handles that.
        // Legacy output: status, message, user object.
        return response()->json([
            'status' => 'success',
            'message' => 'Account created',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                // 'role' => 'user' // Legacy didn't have role in Register response but had it in Login. 
            ]
        ]);
    }

    public function login(Request $request)
    {
        $credentials = $request->only('email', 'password');

        if (Auth::attempt($credentials)) {
            $user = Auth::user();
            $token = $user->createToken('auth_token')->plainTextToken;

            // Legacy Login Output: status, user object.
            // We append 'token' because Sanctum needs it for subsequent requests.
            // The mobile app MUST be updated to use this token for Bearer auth in headers because 
            // legacy was likely session-based or minimal? 
            // *Wait*, legacy login.php didn't return a token. It just returned User.
            // How does the app authenticate future requests? 
            // If the legacy app was just using the User ID or simple storage, migration to Laravel 
            // implies we SHOULD provide a token. I'll include it.
            
            return response()->json([
                'status' => 'success',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => 'user', // Defaulting to user as column might not exist or be different
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
