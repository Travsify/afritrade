<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
// use App\Models\ExchangeRate; // If we had a model, but likely stored in settings or a simpler table

class ExchangeRateController extends Controller
{
    public function index()
    {
        // Mock data for now, ideally fetched from DB or API
        $rates = [
            ['pair' => 'USD/NGN', 'buy' => 1450.00, 'sell' => 1480.00, 'source' => 'Manual'],
            ['pair' => 'GBP/NGN', 'buy' => 1820.00, 'sell' => 1850.00, 'source' => 'Manual'],
            ['pair' => 'EUR/NGN', 'buy' => 1550.00, 'sell' => 1580.00, 'source' => 'Manual'],
        ];

        return view('admin.exchange-rates.index', compact('rates'));
    }

    public function update(Request $request)
    {
        // Logic to update rates in DB/Cache
        return back()->with('success', 'Exchange rates updated successfully.');
    }
}
