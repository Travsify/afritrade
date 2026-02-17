<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\VirtualCard;
use Illuminate\Http\Request;

class VirtualCardController extends Controller
{
    public function index(Request $request)
    {
        $query = VirtualCard::with('user')->latest();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where('card_number', 'like', "%{$search}%")
                  ->orWhere('name_on_card', 'like', "%{$search}%")
                  ->orWhereHas('user', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                  });
        }

        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }

        $cards = $query->paginate(15);
        return view('admin.virtual-cards.index', compact('cards'));
    }

    public function show(VirtualCard $virtualCard)
    {
        return view('admin.virtual-cards.show', compact('virtualCard'));
    }

    public function freeze(VirtualCard $virtualCard)
    {
        $virtualCard->update(['status' => 'frozen']);
        // TODO: Call API to freeze card on provider side
        return back()->with('success', 'Card frozen successfully.');
    }

    public function unfreeze(VirtualCard $virtualCard)
    {
        $virtualCard->update(['status' => 'active']);
        // TODO: Call API to unfreeze card on provider side
        return back()->with('success', 'Card unfrozen successfully.');
    }
}
