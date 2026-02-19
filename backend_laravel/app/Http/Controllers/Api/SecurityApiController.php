<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class SecurityApiController extends Controller
{
    /**
     * Check if a transaction PIN is set.
     */
    public function checkPinStatus()
    {
        $user = Auth::user();
        return response()->json([
            'status' => 'success',
            'is_pin_set' => !empty($user->transaction_pin)
        ]);
    }

    /**
     * Set a new transaction PIN.
     * Only allowed if no PIN is currently set.
     */
    public function setPin(Request $request)
    {
        $request->validate([
            'pin' => 'required|string|digits:4'
        ]);

        $user = Auth::user();

        /** @var \App\Models\User $user */
        if ($user->transaction_pin) {
            return response()->json([
                'status' => 'error',
                'message' => 'PIN already set. Use change PIN instead.'
            ], 400);
        }

        $user->update([
            'transaction_pin' => Hash::make($request->pin)
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Transaction PIN set successfully'
        ]);
    }

    /**
     * Verify the transaction PIN before a sensitive action.
     */
    public function verifyPin(Request $request)
    {
        $request->validate([
            'pin' => 'required|string|digits:4'
        ]);

        $user = Auth::user();

        if (!$user->transaction_pin) {
             return response()->json([
                'status' => 'error',
                'message' => 'No PIN set.'
            ], 400);
        }

        if (Hash::check($request->pin, $user->transaction_pin)) {
            return response()->json([
                'status' => 'success',
                'message' => 'PIN Verified'
            ]);
        }

        return response()->json([
            'status' => 'error',
            'message' => 'Incorrect PIN'
        ], 401);
    }

    /**
     * Change an existing transaction PIN.
     */
    public function changePin(Request $request)
    {
        $request->validate([
            'old_pin' => 'required|string|digits:4',
            'new_pin' => 'required|string|digits:4|confirmed' // expect new_pin_confirmation
        ]);

        $user = Auth::user();
        /** @var \App\Models\User $user */
        if (!$user->transaction_pin) {
             return response()->json([
                'status' => 'error',
                'message' => 'No PIN set. Use set PIN instead.'
            ], 400);
        }

        if (!Hash::check($request->old_pin, $user->transaction_pin)) {
             return response()->json([
                'status' => 'error',
                'message' => 'Current PIN is incorrect'
            ], 401);
        }

        $user->update([
            'transaction_pin' => Hash::make($request->new_pin)
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Transaction PIN updated successfully'
        ]);
    }
}
