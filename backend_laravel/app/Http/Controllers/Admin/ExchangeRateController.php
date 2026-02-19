<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ExchangeRateMarkup;
use Illuminate\Support\Facades\DB;

class ExchangeRateController extends Controller
{
    public function index()
    {
        $markups = ExchangeRateMarkup::all();
        
        // Fetch current base rates from a provider (e.g. Fincra) for display if needed
        // For now, we focus on managing the markups
        
        return view('admin.exchange-rates.index', compact('markups'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'id' => 'required|exists:exchange_rate_markups,id',
            'markup_type' => 'required|in:fixed,percentage,both',
            'fixed_markup' => 'required|numeric|min:0',
            'percentage_markup' => 'required|numeric|min:0',
            'is_active' => 'required|boolean',
        ]);

        $markup = ExchangeRateMarkup::findOrFail($request->id);
        $markup->update([
            'markup_type' => $request->markup_type,
            'fixed_markup' => $request->fixed_markup,
            'percentage_markup' => $request->percentage_markup,
            'is_active' => $request->is_active,
        ]);

        return back()->with('success', "Markup for {$markup->from_currency}/{$markup->to_currency} updated successfully.");
    }

    public function store(Request $request)
    {
        $request->validate([
            'from_currency' => 'required|string|size:3',
            'to_currency' => 'required|string|size:3',
            'markup_type' => 'required|in:fixed,percentage,both',
            'fixed_markup' => 'required|numeric|min:0',
            'percentage_markup' => 'required|numeric|min:0',
        ]);

        ExchangeRateMarkup::updateOrCreate(
            ['from_currency' => strtoupper($request->from_currency), 'to_currency' => strtoupper($request->to_currency)],
            [
                'markup_type' => $request->markup_type,
                'fixed_markup' => $request->fixed_markup,
                'percentage_markup' => $request->percentage_markup,
                'is_active' => true,
            ]
        );

        return back()->with('success', 'New FX pair markup added successfully.');
    }
}
