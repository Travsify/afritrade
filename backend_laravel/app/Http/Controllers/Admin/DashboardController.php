<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        // 1. Total Users
        $totalUsers = \App\Models\User::count();

        // 2. Revenue (Assuming we take a percentage or fees, but for now Total Transaction Volume)
        $totalRevenue = (float) \App\Models\Transaction::where('status', 'completed')
            ->whereIn('type', ['deposit', 'withdrawal']) // Only count external movements as "volume" for now
            ->sum('amount');
        
        // 3. Pending KYC (Using the new 'verification_status' column or legacy KycDocument model)
        // We moved to 'verification_status' on User model for Prembly, but check legacy table too if needed.
        // For now, let's use the User model status 'pending' if we implement manual review, 
        // but since we use Prembly auto-verify, 'pending' might mean manual intervention needed.
        $pendingKyc = \App\Models\User::where('verification_status', 'pending')->count();

        // 4. Recent Users
        $recentUsers = \App\Models\User::latest()->take(5)->get();

        // 5. Recent Transactions (New addition for better visibility)
        $recentTransactions = \App\Models\Transaction::with('user:id,name,email')
            ->latest()
            ->take(5)
            ->get();

        return view('admin.dashboard', compact(
            'totalUsers', 
            'totalRevenue', 
            'pendingKyc', 
            'recentUsers',
            'recentTransactions'
        ));
    }
}
