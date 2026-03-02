<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class TaxReportApiController extends Controller
{
    public function index()
    {
        $reports = DB::table('tax_reports')
            ->where('user_id', Auth::id())
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $reports,
        ]);
    }

    public function generate(Request $request)
    {
        $request->validate([
            'type' => 'required|string|in:monthly,quarterly,annual',
        ]);

        $user = Auth::user();
        $type = $request->type;

        // Determine date range
        $startDate = match ($type) {
            'monthly' => now()->startOfMonth(),
            'quarterly' => now()->startOfQuarter(),
            'annual' => now()->startOfYear(),
        };

        $transactions = Transaction::where('user_id', $user->id)
            ->where('created_at', '>=', $startDate)
            ->get();

        $totalIncome = $transactions->where('type', 'credit')->sum('amount');
        $totalExpenses = $transactions->where('type', 'debit')->sum('amount');
        $txCount = $transactions->count();

        $id = DB::table('tax_reports')->insertGetId([
            'user_id' => $user->id,
            'type' => $type,
            'period_start' => $startDate->toDateString(),
            'period_end' => now()->toDateString(),
            'total_income' => $totalIncome,
            'total_expenses' => $totalExpenses,
            'transaction_count' => $txCount,
            'status' => 'generated',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => ucfirst($type) . ' tax report generated.',
            'data' => DB::table('tax_reports')->find($id),
        ]);
    }
}
