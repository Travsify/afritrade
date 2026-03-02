<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TradeInsightsApiController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();
        $period = $request->query('period', '30d');

        // Calculate date range
        $days = match ($period) {
            '7d' => 7,
            '30d' => 30,
            '90d' => 90,
            '1y' => 365,
            default => 30,
        };

        $startDate = now()->subDays($days);

        $transactions = Transaction::where('user_id', $user->id)
            ->where('created_at', '>=', $startDate)
            ->orderBy('created_at', 'desc')
            ->get();

        $totalSpent = $transactions->where('type', 'debit')->sum('amount');
        $totalReceived = $transactions->where('type', 'credit')->sum('amount');

        // Build spending trend (daily aggregates)
        $trend = $transactions->where('type', 'debit')
            ->groupBy(fn ($tx) => $tx->created_at->format('Y-m-d'))
            ->map(fn ($group) => [
                'date' => $group->first()->created_at->format('Y-m-d'),
                'amount' => $group->sum('amount'),
            ])
            ->values()
            ->toArray();

        // Top categories
        $categories = $transactions->where('type', 'debit')
            ->groupBy('description')
            ->map(fn ($group) => [
                'category' => $group->first()->description ?? 'Other',
                'amount' => $group->sum('amount'),
                'count' => $group->count(),
            ])
            ->sortByDesc('amount')
            ->take(5)
            ->values()
            ->toArray();

        return response()->json([
            'status' => 'success',
            'total_spent' => round($totalSpent, 2),
            'total_received' => round($totalReceived, 2),
            'spending_trend' => $trend,
            'top_categories' => $categories,
            'recommendations' => $this->generateRecommendations($totalSpent, $totalReceived),
        ]);
    }

    private function generateRecommendations(float $spent, float $received): array
    {
        $recommendations = [];

        if ($spent > $received) {
            $recommendations[] = 'Your spending exceeds income this period. Consider reviewing recurring payments.';
        }
        if ($spent > 0) {
            $recommendations[] = 'Set rate alerts to optimize your currency conversion timing.';
        }
        $recommendations[] = 'Use scheduled payments to automate your regular transactions.';

        return $recommendations;
    }
}
