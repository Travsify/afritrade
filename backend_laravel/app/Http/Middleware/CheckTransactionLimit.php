<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth;
use App\Models\Transaction;
use Carbon\Carbon;

class CheckTransactionLimit
{
    /**
     * Tiers & Limits (Daily in USD)
     */
    const LIMITS = [
        0 => 0,       // Email only (Frozen)
        1 => 100,     // Basic
        2 => 10000,   // Verified
        3 => 99999999 // Unlimited
    ];

    public function handle(Request $request, Closure $next): Response
    {
        $user = Auth::user();

        if (!$user) {
            return response()->json(['status' => 'error', 'message' => 'Unauthorized'], 401);
        }

        $tier = $user->kyc_tier ?? 1; // Default to 1 if null
        $limit = self::LIMITS[$tier] ?? 0;

        $amount = $request->input('amount');
        if (!$amount) {
            return $next($request); // Not a monetary request? Or validation handles it.
        }

        // Calculate daily total sent today
        $dailyTotal = Transaction::where('user_id', $user->id)
            ->whereIn('type', ['debit', 'p2p_transfer']) // Count all outgoing
            ->whereDate('created_at', Carbon::today())
            ->sum('amount');

        if (($dailyTotal + $amount) > $limit) {
            return response()->json([
                'status' => 'error',
                'message' => "Daily transaction limit of \${$limit} exceeded. Your current tier is {$tier}. Please upgrade your KYC to increase limits."
            ], 403);
        }

        return $next($request);
    }
}
