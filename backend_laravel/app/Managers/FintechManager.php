<?php

namespace App\Managers;

use App\Services\FincraService;
use App\Services\MapleradService;
use App\Services\KlashaService;
use App\Services\AnchorService;
use Illuminate\Support\Facades\DB;

class FintechManager
{
    public function getAccountProvider()
    {
        $provider = DB::table('system_settings')->where('setting_key', 'active_va_provider')->value('setting_value') ?? 'fincra';
        return $provider === 'fincra' ? app(FincraService::class) : app(AnchorService::class);
    }

    public function getCardProvider()
    {
        $provider = DB::table('system_settings')->where('setting_key', 'active_card_provider')->value('setting_value') ?? 'maplerad';
        return $provider === 'maplerad' ? app(MapleradService::class) : app(AnchorService::class);
    }

    public function getPayoutProvider()
    {
        return app(KlashaService::class);
    }

    public function getBillProvider()
    {
        return app(FincraService::class);
    }
}
