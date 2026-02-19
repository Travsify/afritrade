<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ExchangeRateMarkup;

class ExchangeRateMarkupSeeder extends Seeder
{
    public function run(): void
    {
        $markups = [
            [
                'from_currency' => 'USD',
                'to_currency' => 'NGN',
                'markup_type' => 'percentage',
                'fixed_markup' => 0.00,
                'percentage_markup' => 2.50, // 2.5% margin
            ],
            [
                'from_currency' => 'GBP',
                'to_currency' => 'NGN',
                'markup_type' => 'percentage',
                'fixed_markup' => 0.00,
                'percentage_markup' => 2.50,
            ],
            [
                'from_currency' => 'EUR',
                'to_currency' => 'NGN',
                'markup_type' => 'percentage',
                'fixed_markup' => 0.00,
                'percentage_markup' => 2.50,
            ],
            [
                'from_currency' => 'USD',
                'to_currency' => 'GHS',
                'markup_type' => 'both',
                'fixed_markup' => 1.00, // $1 + 1.5%
                'percentage_markup' => 1.50,
            ],
            [
                'from_currency' => 'CNY',
                'to_currency' => 'NGN',
                'markup_type' => 'percentage',
                'fixed_markup' => 0.00,
                'percentage_markup' => 4.00, // Higher margin for CNY
            ],
        ];

        foreach ($markups as $markup) {
            ExchangeRateMarkup::updateOrCreate(
                ['from_currency' => $markup['from_currency'], 'to_currency' => $markup['to_currency']],
                $markup
            );
        }
    }
}
