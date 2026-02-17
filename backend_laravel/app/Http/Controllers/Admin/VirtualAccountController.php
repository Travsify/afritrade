<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\VirtualAccount;
use Illuminate\Http\Request;

class VirtualAccountController extends Controller
{
    public function index(Request $request)
    {
        $query = VirtualAccount::with('user')->latest();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where('account_number', 'like', "%{$search}%")
                  ->orWhere('account_name', 'like', "%{$search}%")
                  ->orWhereHas('user', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                  });
        }

        if ($request->has('bank_name') && $request->bank_name) {
            $query->where('bank_name', 'like', "%{$request->bank_name}%");
        }
        
        // Filter by active status if column exists (assuming 'is_active' or similar)
        // For now, we just paginate.

        $accounts = $query->paginate(15);

        return view('admin.virtual-accounts.index', compact('accounts'));
    }

    public function show(VirtualAccount $virtualAccount)
    {
        return view('admin.virtual-accounts.show', compact('virtualAccount'));
    }

    // Toggle status or re-generate could be added here
}
