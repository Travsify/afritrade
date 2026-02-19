<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class VerifyTransactionPin
{
    /**
     * Require a valid transaction PIN for sensitive financial operations.
     * The PIN should be sent in the X-Transaction-Pin header or in the request body as 'pin'.
     */
    public function handle(Request $request, Closure $next)
    {
        $user = Auth::user();

        if (!$user) {
            return response()->json(['status' => 'error', 'message' => 'Unauthenticated'], 401);
        }

        // Skip if user hasn't set a PIN yet (first-time users)
        if (empty($user->transaction_pin)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Please set a transaction PIN before performing financial operations.',
                'requires_pin_setup' => true
            ], 403);
        }

        $pin = $request->header('X-Transaction-Pin') ?? $request->input('pin');

        if (!$pin) {
            return response()->json([
                'status' => 'error',
                'message' => 'Transaction PIN is required for this operation.'
            ], 403);
        }

        if (!Hash::check($pin, $user->transaction_pin)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid transaction PIN.'
            ], 403);
        }

        return $next($request);
    }
}
