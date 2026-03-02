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

    public function freeze(VirtualCard $virtualCard, \App\Services\AnchorService $anchorService)
    {
        if (!$virtualCard->provider_card_id) {
            // Fallback for demo cards or cards created before migration
            $virtualCard->update(['status' => 'frozen']);
            return back()->with('warning', 'Card frozen locally, but no provider ID found.');
        }

        $response = $anchorService->freezeCard($virtualCard->provider_card_id);

        if ($response['status'] === 'success') {
            $virtualCard->update(['status' => 'frozen']);
            return back()->with('success', 'Card frozen successfully on provider side.');
        }

        return back()->with('error', 'Failed to freeze card on provider: ' . ($response['message'] ?? 'Unknown error'));
    }

    public function unfreeze(VirtualCard $virtualCard, \App\Services\AnchorService $anchorService)
    {
        if (!$virtualCard->provider_card_id) {
            // Fallback for demo cards
            $virtualCard->update(['status' => 'active']);
            return back()->with('warning', 'Card activated locally, but no provider ID found.');
        }

        $response = $anchorService->unfreezeCard($virtualCard->provider_card_id);

        if ($response['status'] === 'success') {
            $virtualCard->update(['status' => 'active']);
            return back()->with('success', 'Card unfrozen successfully on provider side.');
        }

        return back()->with('error', 'Failed to unfreeze card on provider: ' . ($response['message'] ?? 'Unknown error'));
    }
}
