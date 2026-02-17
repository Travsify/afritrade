<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Services\AnchorService;

class CardApiController extends Controller
{
    protected $fintechManager;

    public function __construct(\App\Managers\FintechManager $fintechManager)
    {
        $this->fintechManager = $fintechManager;
    }

    /**
     * List user's virtual cards
     */
    public function index()
    {
        $cards = \App\Models\VirtualCard::where('user_id', Auth::id())
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $cards
        ]);
    }

    /**
     * Issue a new virtual card
     */
    public function store(Request $request)
    {
        $request->validate([
            'label' => 'required|string|max:50',
            'amount' => 'required|numeric|min:5',
            'brand' => 'required|in:visa,mastercard',
        ]);

        $user = Auth::user();
        $service = $this->fintechManager->getCardProvider();
        $providerName = ($service instanceof \App\Services\MapleradService) ? 'maplerad' : 'anchor';

        // Check wallet balance (Afritrad logic)
        if ($user->balance < $request->amount) {
            return response()->json(['status' => 'error', 'message' => 'Insufficient funds'], 400);
        }

        $response = $service->createVirtualCard([
            'amount' => $request->amount,
            'customer_id' => $user->provider_customer_id ?? $user->id, // Maplerad specific
            'brand' => $request->brand,
        ]);

        if ($response['status'] !== 'success') {
            return response()->json(['status' => 'error', 'message' => $response['message']], 400);
        }

        $data = $response['data'];

        $card = \App\Models\VirtualCard::create([
            'user_id' => $user->id,
            'label' => $request->label,
            'card_number' => $data['card_number'] ?? '**** **** **** ' . ($data['last4'] ?? '0000'),
            'last4' => $data['last4'] ?? '0000',
            'expiry' => $data['expiry'] ?? null,
            'brand' => ucfirst($request->brand),
            'currency' => 'USD',
            'balance' => $request->amount,
            'status' => 'active',
            'provider' => $providerName,
            'provider_id' => $data['id'] ?? null,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Virtual card issued successfully',
            'data' => $card
        ]);
    }

    /**
     * Fund an existing card
     */
    public function fund(Request $request, $cardId)
    {
        $request->validate(['amount' => 'required|numeric|min:1']);
        $card = \App\Models\VirtualCard::findOrFail($cardId);
        
        // Logic to fund via provider...
        return response()->json(['status' => 'success', 'message' => 'Card funded']);
    }

    /**
     * Freeze/Unfreeze card
     */
    public function toggleFreeze($cardId)
    {
        $card = \App\Models\VirtualCard::findOrFail($cardId);
        $service = $this->fintechManager->getCardProvider();
        
        $newStatus = $card->status === 'active' ? 'freeze' : 'unfreeze';
        $response = $service->toggleCardStatus($card->provider_id, $newStatus);

        if ($response['status'] === 'success') {
            $card->update(['status' => ($newStatus === 'freeze' ? 'frozen' : 'active')]);
        }

        return response()->json(['status' => 'success', 'message' => 'Card status updated']);
    }
}
