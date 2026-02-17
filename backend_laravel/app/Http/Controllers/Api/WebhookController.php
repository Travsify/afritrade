<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Models\Transaction;
use App\Models\VirtualAccount;
use App\Models\VirtualCard;

class WebhookController extends Controller
{
    /**
     * Handle incoming webhooks from Fincra, Maplerad, and Klasha.
     */
    public function handle(Request $request, $provider)
    {
        Log::info("Webhook received from {$provider}: " . json_encode($request->all()));

        switch ($provider) {
            case 'fincra':
                return $this->handleFincra($request);
            case 'maplerad':
                return $this->handleMaplerad($request);
            case 'klasha':
                return $this->handleKlasha($request);
            default:
                return response()->json(['message' => 'Unknown provider'], 400);
        }
    }

    protected function handleFincra(Request $request)
    {
        $event = $request->input('event');
        $data = $request->input('data');

        if ($event === 'virtualaccount.approved') {
            VirtualAccount::where('provider_id', $data['id'])->update(['status' => 'active']);
        }

        if ($event === 'collection.successful') {
            // Credit user wallet, update transaction
        }

        return response()->json(['status' => 'ok']);
    }

    protected function handleMaplerad(Request $request)
    {
        // Handle card funding, transactions, status changes
        return response()->json(['status' => 'ok']);
    }

    protected function handleKlasha(Request $request)
    {
        // Handle payout success/failure
        return response()->json(['status' => 'ok']);
    }
}
