<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::latest();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        if ($request->has('status')) {
            // Assuming we add a status column to users table later, 
            // for now we can filter by kyc_tier or verification_status
            if ($request->status == 'verified') {
                $query->where('verification_status', 'verified');
            } elseif ($request->status == 'unverified') {
                $query->where('verification_status', '!=', 'verified');
            }
        }

        $users = $query->paginate(15);
        return view('admin.users.index', compact('users'));
    }

    public function show(User $user)
    {
        $user->load(['wallets', 'transactions' => function($q) {
            $q->latest()->take(10);
        }, 'kycDocuments', 'virtualAccounts', 'cards']);

        $totalBalanceUSD = $user->wallets ? $user->wallets->where('currency', 'USD')->sum('balance') : 0;
        $totalBalanceNGN = $user->wallets ? $user->wallets->where('currency', 'NGN')->sum('balance') : 0;

        return view('admin.users.show', compact('user', 'totalBalanceUSD', 'totalBalanceNGN'));
    }

    public function update(Request $request, User $user)
    {
        $request->validate([
            'name' => 'required',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'kyc_tier' => 'required|integer|min:0|max:3',
            'verification_status' => 'required|string'
        ]);

        $user->update($request->only('name', 'email', 'kyc_tier', 'verification_status'));

        \App\Services\AuditLogger::log("Updated User Profile #{$user->id}", "Modified KYC Tier to {$request->kyc_tier} and Status to {$request->verification_status}");

        return back()->with('success', 'User profile updated successfully.');
    }

    public function toggleStatus(User $user)
    {
        $user->is_active = !$user->is_active;
        $user->status = $user->is_active ? 'active' : 'suspended';
        $user->save();

        $action = $user->is_active ? 'Activated' : 'Suspended';
        \App\Services\AuditLogger::log("{$action} User #{$user->id}", "User status changed to {$user->status}");

        return back()->with('success', "User account has been {$user->status} successfully.");
    }
}
