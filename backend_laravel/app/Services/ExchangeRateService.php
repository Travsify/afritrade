<?php

namespace App\Services;

use App\Models\ExchangeRateMarkup;
use Illuminate\Support\Facades\Log;

class ExchangeRateService
{
    protected $fincraService;

    public function __construct(FincraService $fincraService)
    {
        $this->fincraService = $fincraService;
    }

    /**
     * Get the final exchange rate for a pair, including markups.
     */
    public function getFinalRate(string $from, string $to)
    {
        // 1. Fetch Base Rate from Provider (defaulting to Fincra for now)
        $result = $this->fincraService->getExchangeRate($from, $to);

        if ($result['status'] !== 'success') {
            Log::error("Failed to fetch base rate for $from/$to: " . ($result['message'] ?? 'Unknown error'));
            return null;
        }

        $baseRate = (float) $result['data']['rate']; // Fincra's response format

        // 2. Fetch Markup Rule
        $markup = ExchangeRateMarkup::where('from_currency', strtoupper($from))
            ->where('to_currency', strtoupper($to))
            ->where('is_active', true)
            ->first();

        if (!$markup) {
            // No markup defined, return base rate (or add a default safety margin)
            return $baseRate;
        }

        // 3. Apply Markup Logic: Flat, Percentage, or Both
        $finalRate = $baseRate;

        switch ($markup->markup_type) {
            case 'fixed':
                $finalRate += (float) $markup->fixed_markup;
                break;
                
            case 'percentage':
                $finalRate *= (1 + ((float) $markup->percentage_markup / 100));
                break;
                
            case 'both':
                // Apply percentage first, then add fixed fee (Standard Practice)
                $finalRate = ($baseRate * (1 + ((float) $markup->percentage_markup / 100))) + (float) $markup->fixed_markup;
                break;
        }

        return round($finalRate, 4);
    }
}
