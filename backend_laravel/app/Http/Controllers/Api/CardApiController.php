<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Services\AnchorService;

class CardApiController extends Controller
{
    protected $anchorService;

    public function __construct(AnchorService $anchorService)
    {
        $this->anchorService = $anchorService;
    }

    /**
     * List user's virtual cards
     */
    public function index()
    {
        $user = Auth::user();

        // In production, fetch from Anchor API or local DB
        // For now, mocking a response

        return response()->json([
            'status' => 'success',
            'data' => [
                // Mock cards - would come from DB / Anchor
                [
                    'id' => 'card_001',
                    'label' => 'Business Expenses',
                    'last4' => '4532',
                    'balance' => 250.00,
                    'currency' => 'USD',
                    'brand' => 'Visa',
                    'status' => 'active',
                    'expiry' => '12/28',
                ],
            ]
        ]);
    }

    /**
     * Issue a new virtual card (via Anchor)
     */
    public function store(Request $request)
    {
        $request->validate([
            'label' => 'required|string|max:50',
            'amount' => 'required|numeric|min:5',
            'brand' => 'required|in:visa,mastercard',
        ]);

        $user = Auth::user();

        // Check balance
        if ($user->balance < $request->amount) {
            return response()->json([
                'status' => 'error',
                'message' => 'Insufficient funds for card creation'
            ], 400);
        }

        // In real integration:
        // $result = $this->anchorService->issueCard($user, $request->all());

        // Mock for MVP
        $card = [
            'id' => 'card_' . uniqid(),
            'label' => $request->label,
            'last4' => rand(1000, 9999),
            'balance' => $request->amount,
            'currency' => 'USD',
            'brand' => ucfirst($request->brand),
            'status' => 'active',
            'expiry' => '12/' . (date('y') + 3),
            'cvv' => rand(100, 999),
            'card_number' => '4' . rand(100000000000000, 999999999999999), // Mock PAN
        ];

        // Debit user wallet
        $user->decrement('balance', $request->amount);

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
        $request->validate([
            'amount' => 'required|numeric|min:1',
        ]);

        $user = Auth::user();

        if ($user->balance < $request->amount) {
            return response()->json(['status' => 'error', 'message' => 'Insufficient wallet balance'], 400);
        }

        // In real: call Anchor to fund the card
        $user->decrement('balance', $request->amount);

        return response()->json([
            'status' => 'success',
            'message' => 'Card funded successfully'
        ]);
    }

    /**
     * Freeze/Unfreeze card
     */
    public function toggleFreeze($cardId)
    {
        // Mock toggle
        return response()->json([
            'status' => 'success',
            'message' => 'Card status toggled'
        ]);
    }
}
