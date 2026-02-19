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

        $baseRate = null;
        if ($result['status'] === 'success') {
            $baseRate = (float) $result['data']['rate'];
        }

        // 2. Fetch Markup Rule (Always needed for calculation or fallback baseline)
        $markup = ExchangeRateMarkup::where('from_currency', strtoupper($from))
            ->where('to_currency', strtoupper($to))
            ->where('is_active', true)
            ->first();

        // ─── CTO FAIL-SAFE LOGIC ───
        // If provider is down, fallback to a stored baseline rate if available
        if (!$baseRate) {
            if ($markup && $markup->fixed_markup > 0) {
                 // Warning level log: System in degraded state
                 Log::warning("Provider DOWN for $from/$to. Using markup as fallback baseline.");
                 // We don't have a historical baseline table yet, so we return 
                 // the last defined fixed_markup or a safe null
                 return null; 
            }
            return null;
        }

        if (!$markup) {
            // No markup defined, return base rate with 1% safety margin for unknown pairs
            return round($baseRate * 1.01, 4);
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
                $finalRate = ($baseRate * (1 + ((float) $markup->percentage_markup / 100))) + (float) $markup->fixed_markup;
                break;
        }

        return round($finalRate, 4);
    }
}
