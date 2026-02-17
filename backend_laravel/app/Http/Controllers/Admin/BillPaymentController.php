<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;

class BillPaymentController extends Controller
{
    public function index(Request $request)
    {
        // Bill payments are transactions with type 'bill_payment'
        $query = Transaction::with('user')->where('type', 'bill_payment')->latest();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where('reference', 'like', "%{$search}%")
                  ->orWhereHas('user', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                  });
        }
        
        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }

        $payments = $query->paginate(15);
        
        return view('admin.bill-payments.index', compact('payments'));
    }

    public function show(Transaction $transaction)
    {
        if ($transaction->type !== 'bill_payment') {
            return redirect()->route('transactions.show', $transaction->id);
        }
        return view('admin.bill-payments.show', compact('transaction'));
    }
    
    // In a real app, we'd have a separate 'Service' model to toggle providers.
    // For now, we'll just stub a view for Service Settings.
    public function settings()
    {
        return view('admin.bill-payments.settings');
    }
}
