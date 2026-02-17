<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $query = Transaction::with('user')->latest();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where('reference', 'like', "%{$search}%")
                  ->orWhereHas('user', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                  });
        }

        if ($request->has('type') && $request->type) {
            $query->where('type', $request->type);
        }

        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }

        if ($request->has('date') && $request->date) {
            $query->whereDate('created_at', $request->date);
        }

        $transactions = $query->paginate(15);
        $totalVolume = Transaction::where('status', 'completed')->sum('amount'); // diverse currencies make this tricky, ideally separate by currency.

        return view('admin.transactions.index', compact('transactions'));
    }

    public function show(Transaction $transaction)
    {
        return view('admin.transactions.show', compact('transaction'));
    }

    public function update(Request $request, Transaction $transaction)
    {
        $request->validate([
            'status' => 'required|in:pending,completed,failed,refunded',
        ]);

        $transaction->update(['status' => $request->status]);

        return back()->with('success', 'Transaction status updated.');
    }
    
    public function requery(Transaction $transaction)
    {
        // Logic to re-query the provider API would go here.
        // For now, we simulate a check.
        if ($transaction->status == 'pending') {
             // Simulating a successful check from provider
             // $transaction->update(['status' => 'completed']);
             return back()->with('info', 'Re-query checked. Status remains pending (simulation).');
        }
        
        return back()->with('info', 'Transaction is already ' . $transaction->status);
    }
}
