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

        $totalBalanceUSD = $user->wallets->where('currency', 'USD')->sum('balance');
        $totalBalanceNGN = $user->wallets->where('currency', 'NGN')->sum('balance');

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

        return back()->with('success', 'User profile updated successfully.');
    }

    public function toggleStatus(User $user)
    {
        // This requires an 'is_active' or 'status' column on users table.
        // For now, we'll assume a 'status' column or just toggle a flag if it exists.
        // Let's check migration first. If not exists, we might need to add it.
        // CHECK: We have 'verification_status' but not account status (active/suspended).
        // For now, let's just redirect with a message that this feature needs a migration.
        
        return back()->with('info', 'User suspension feature coming soon (needs migration).');
    }
}
