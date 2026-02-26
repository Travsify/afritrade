<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SystemSettingsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $settings = [
            // Anchor Settings
            ['setting_key' => 'anchor_base_url', 'setting_value' => 'https://api.getanchor.co/api/v1'],
            ['setting_key' => 'anchor_api_key', 'setting_value' => 'YOUR_ANCHOR_API_KEY'],
            
            // Fincra Settings
            ['setting_key' => 'fincra_base_url', 'setting_value' => 'https://api.fincra.com'],
            ['setting_key' => 'fincra_api_key', 'setting_value' => 'YOUR_FINCRA_API_KEY'],
            ['setting_key' => 'fincra_merchant_id', 'setting_value' => 'YOUR_FINCRA_MERCHANT_ID'],
            
            // Card Provider (anchor or maplerad)
            ['setting_key' => 'active_card_provider', 'setting_value' => 'anchor'],
            ['setting_key' => 'active_va_provider', 'setting_value' => 'fincra'],

            // Maplerad Settings
            ['setting_key' => 'maplerad_base_url', 'setting_value' => 'https://api.maplerad.com/v1'],
            ['setting_key' => 'maplerad_secret_key', 'setting_value' => 'YOUR_MAPLERAD_SECRET_KEY'],

            // Crypto Rates
            ['setting_key' => 'usdt_usd_rate', 'setting_value' => '0.95'],
            
            // KYC Settings
            ['setting_key' => 'prembly_api_key', 'setting_value' => 'YOUR_PREMBLY_API_KEY'],
            ['setting_key' => 'identitypass_api_key', 'setting_value' => 'YOUR_IDENTITYPASS_API_KEY'],
        ];

        foreach ($settings as $setting) {
            DB::table('system_settings')->updateOrInsert(
                ['setting_key' => $setting['setting_key']],
                ['setting_value' => $setting['setting_value'], 'updated_at' => now(), 'created_at' => now()]
            );
        }
    }
}
