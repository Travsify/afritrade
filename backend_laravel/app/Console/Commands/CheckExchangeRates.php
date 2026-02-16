<?php

namespace App\Console\Commands;

use App\Models\ExchangeRateAlert;
use App\Models\Notification;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class CheckExchangeRates extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'rates:check';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Check exchange rates and trigger user alerts';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Checking exchange rates...');

        // Mock current rates for now. In production, fetch from an API (e.g. Anchor, Fixer.io)
        $currentRates = [
            'USD/NGN' => 1550.00,
            'GBP/NGN' => 1950.00,
            'EUR/NGN' => 1650.00,
        ];

        $alerts = ExchangeRateAlert::where('status', 'active')->get();

        foreach ($alerts as $alert) {
            $pair = $alert->pair;
            if (!isset($currentRates[$pair])) {
                continue;
            }

            $currentRate = $currentRates[$pair];
            $shouldTrigger = false;

            if ($alert->condition == 'above' && $currentRate >= $alert->target_rate) {
                $shouldTrigger = true;
            } elseif ($alert->condition == 'below' && $currentRate <= $alert->target_rate) {
                $shouldTrigger = true;
            }

            if ($shouldTrigger) {
                // Trigger Alert
                Notification::create([
                    'user_id' => $alert->user_id,
                    'type' => 'rate_alert',
                    'title' => 'Exchange Rate Alert',
                    'message' => "{$pair} is now {$alert->condition} your target of {$alert->target_rate}. Current Rate: {$currentRate}",
                    'data' => [
                        'pair' => $pair,
                        'rate' => $currentRate,
                        'target' => $alert->target_rate
                    ]
                ]);

                // Update status if it's a one-time alert (optional, or keep active?)
                // Usually one-time to avoid spam.
                $alert->status = 'triggered';
                $alert->save();

                $this->info("Triggered alert for User {$alert->user_id} on {$pair}");
            }
        }

        $this->info('Done.');
    }
}
