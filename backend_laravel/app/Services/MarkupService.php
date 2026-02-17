<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class MarkupService
{
    /**
     * Calculate the final amount after adding markups.
     * 
     * @param string $serviceName The name of the service (e.g., 'airtime', 'data')
     * @param float $baseAmount The original cost from the provider
     * @return array Contains final_amount, total_markup, and breakdown
     */
    public function calculate($serviceName, $baseAmount)
    {
        $markup = DB::table('service_markups')
            ->where('service_name', $serviceName)
            ->where('is_active', true)
            ->first();

        if (!$markup) {
            return [
                'final_amount' => $baseAmount,
                'total_fee' => 0.00,
                'breakdown' => ['type' => 'none']
            ];
        }

        $fixedAdd = 0.00;
        $percAdd = 0.00;

        if ($markup->fee_type === 'fixed' || $markup->fee_type === 'both') {
            $fixedAdd = (float) $markup->fixed_fee;
        }

        if ($markup->fee_type === 'percentage' || $markup->fee_type === 'both') {
            $percAdd = $baseAmount * ((float) $markup->percentage_fee / 100);
        }

        $totalFee = $fixedAdd + $percAdd;

        return [
            'final_amount' => round($baseAmount + $totalFee, 2),
            'total_fee' => round($totalFee, 2),
            'breakdown' => [
                'fixed' => $fixedAdd,
                'percentage' => $percAdd,
                'markup_data' => $markup
            ]
        ];
    }

    /**
     * Apply FX margin to a base rate.
     */
    public function applyFxMargin($baseRate)
    {
        $fxMarkup = DB::table('service_markups')
            ->where('service_name', 'fx')
            ->where('is_active', true)
            ->first();

        if (!$fxMarkup) return $baseRate;

        // For FX, we usually only use percentage margin
        $margin = $baseRate * ((float) $fxMarkup->percentage_fee / 100);
        
        return round($baseRate + $margin, 4);
    }
}
