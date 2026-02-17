<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ServiceMarkupSeeder extends Seeder
{
    public function run(): void
    {
        $markups = [
            [
                'service_name' => 'airtime',
                'fee_type' => 'percentage',
                'fixed_fee' => 0.00,
                'percentage_fee' => 3.00, // 3% commission/markup
                'is_active' => true,
            ],
            [
                'service_name' => 'data',
                'fee_type' => 'percentage',
                'fixed_fee' => 0.00,
                'percentage_fee' => 3.00,
                'is_active' => true,
            ],
            [
                'service_name' => 'power',
                'fee_type' => 'fixed',
                'fixed_fee' => 100.00, // 100 NGN flat fee
                'percentage_fee' => 0.00,
                'is_active' => true,
            ],
            [
                'service_name' => 'fx',
                'fee_type' => 'percentage',
                'fixed_fee' => 0.00,
                'percentage_fee' => 2.00, // 2% margin on exchange rates
                'is_active' => true,
            ],
            [
                'service_name' => 'virtual_card_issuance',
                'fee_type' => 'fixed',
                'fixed_fee' => 5.00, // $5 setup fee
                'percentage_fee' => 0.00,
                'is_active' => true,
            ],
            [
                'service_name' => 'virtual_card_funding',
                'fee_type' => 'both',
                'fixed_fee' => 1.00, // $1 + 1%
                'percentage_fee' => 1.00,
                'is_active' => true,
            ],
        ];

        foreach ($markups as $markup) {
            DB::table('service_markups')->updateOrInsert(
                ['service_name' => $markup['service_name']],
                array_merge($markup, ['created_at' => now(), 'updated_at' => now()])
            );
        }
    }
}
