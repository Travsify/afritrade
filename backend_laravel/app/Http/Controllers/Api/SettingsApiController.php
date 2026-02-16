<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SystemSetting;
use Illuminate\Http\Request;

class SettingsApiController extends Controller
{
    public function index()
    {
        $settings = SystemSetting::all()->pluck('setting_value', 'setting_key');

        return response()->json([
            'status' => 'success',
            'data' => [
                'min_android_version' => $settings['min_android_version'] ?? '1.0.0',
                'min_ios_version' => $settings['min_ios_version'] ?? '1.0.0',
                'force_update' => (bool)($settings['force_update'] ?? false),
                'play_store_url' => $settings['play_store_url'] ?? '',
                'app_store_url' => $settings['app_store_url'] ?? '',
                'support_email' => $settings['support_email'] ?? '',
                'privacy_policy_url' => $settings['privacy_policy_url'] ?? '',
                'terms_of_service_url' => $settings['terms_of_service_url'] ?? '',
                'exchange_rate_usd_ngn' => $settings['exchange_rate_usd_ngn'] ?? '1450.00',
                'maintenance_mode' => (bool)($settings['maintenance_mode'] ?? false),
                'anchor_base_url' => $settings['anchor_base_url'] ?? 'https://api.anchor.com',
            ]
        ]);
    }
}
