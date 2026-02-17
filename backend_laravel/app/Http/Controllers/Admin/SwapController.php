<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;

class SwapController extends Controller
{
    public function index(Request $request)
    {
        // Swaps are transactions with type 'swap'
        // But we might want a detailed view showing 'sell_currency', 'buy_currency', 'exchange_rate'
        // These details are likely in the 'metadata' column or separate columns if structured.
        // For now, we filter Transactions by type 'swap'.

        $query = Transaction::with('user')->where('type', 'swap')->latest();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where('reference', 'like', "%{$search}%")
                  ->orWhereHas('user', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                  });
        }
        
        // TODO: Filter by currency pair if available in metadata

        $swaps = $query->paginate(15);
        
        return view('admin.swaps.index', compact('swaps'));
    }

    public function show(Transaction $transaction)
    {
        if ($transaction->type !== 'swap') {
            return redirect()->route('transactions.show', $transaction->id);
        }
        return view('admin.swaps.show', compact('transaction'));
    }
}
