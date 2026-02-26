<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ExchangeRateService;
use Illuminate\Http\Request;

class RateApiController extends Controller
{
    protected $rateService;

    public function __construct(ExchangeRateService $rateService)
    {
        $this->rateService = $rateService;
    }

    /**
     * Get market rates for common pairs.
     */
    public function index()
    {
        $pairs = [
            'USD_NGN', 'EUR_NGN', 'GBP_NGN', 
            'EUR_USD', 'GBP_USD', 'CNY_USD'
        ];

        $rates = [];
        foreach ($pairs as $pair) {
            [$from, $to] = explode('_', $pair);
            $rates[$pair] = $this->rateService->getFinalRate($from, $to) ?? 0.0;
        }

        return response()->json([
            'status' => 'success',
            'data' => $rates
        ]);
    }
}
