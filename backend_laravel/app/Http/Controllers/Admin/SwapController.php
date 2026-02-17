<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;

class SwapController extends Controller
{
    public function index(Request $request)
    {
        $query = \App\Models\Transaction::where('type', 'swap')
            ->with('user');

        if ($request->has('search')) {
            $search = $request->search;
            $query->where('reference', 'like', "%{$search}%");
        }

        $swaps = $query->latest()->paginate(15);
        return view('admin.swaps.index', compact('swaps'));
    }

    public function show(Transaction $transaction)
    {
        if ($transaction->type !== 'swap') {
            return redirect()->route('admin.transactions.show', $transaction->id);
        }
        return view('admin.swaps.show', compact('transaction'));
    }
}
