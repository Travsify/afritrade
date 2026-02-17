<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\FincraService;
use App\Services\MapleradService;
use App\Services\KlashaService;
use Illuminate\Http\Request;

class ProviderController extends Controller
{
    protected $fincra;
    protected $maplerad;
    protected $klasha;

    public function __construct(FincraService $fincra, MapleradService $maplerad, KlashaService $klasha)
    {
        $this->fincra = $fincra;
        $this->maplerad = $maplerad;
        $this->klasha = $klasha;
    }

    public function index()
    {
        // In a real production scenario, you would call the "get balance" endpoints for each service.
        // For now, we mock the response to show the UI capability.
        
        $balances = [
            'fincra' => [
                ['currency' => 'NGN', 'amount' => '25,400,000.00'],
                ['currency' => 'USD', 'amount' => '12,500.00'],
            ],
            'maplerad' => [
                ['currency' => 'USD', 'amount' => '5,200.00'],
            ],
            'klasha' => [
                ['currency' => 'NGN', 'amount' => '1,200,000.00'],
                ['currency' => 'CNY', 'amount' => '45,000.00'],
            ]
        ];

        return view('admin.providers.index', compact('balances'));
    }
}
