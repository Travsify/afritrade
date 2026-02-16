<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ExchangeRateAlert;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RateAlertController extends Controller
{
    public function index()
    {
        $alerts = ExchangeRateAlert::where('user_id', Auth::id())
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $alerts
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'pair' => 'required|string', // e.g. USD/NGN
            'target_rate' => 'required|numeric',
            'condition' => 'required|in:above,below',
        ]);

        $alert = ExchangeRateAlert::create([
            'user_id' => Auth::id(),
            'pair' => $request->pair,
            'target_rate' => $request->target_rate,
            'condition' => $request->condition,
            'status' => 'active'
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Alert created successfully',
            'data' => $alert
        ]);
    }

    public function destroy($id)
    {
        $alert = ExchangeRateAlert::where('user_id', Auth::id())
            ->findOrFail($id);
            
        $alert->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Alert deleted successfully'
        ]);
    }
}
