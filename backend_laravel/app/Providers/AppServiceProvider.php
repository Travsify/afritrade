<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Schema;
use App\Models\SystemSetting;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Paginator::useTailwind();

        if ($this->app->environment('production')) {
            \Illuminate\Support\Facades\URL::forceScheme('https');
        }

        // Dynamically load mail settings
        try {
            if (Schema::hasTable('system_settings')) {
                $settings = SystemSetting::whereIn('setting_key', [
                    'mail_mailer', 'mail_host', 'mail_port', 'mail_username', 
                    'mail_password', 'mail_encryption', 'mail_from_address', 'mail_from_name'
                ])->pluck('setting_value', 'setting_key');

                if ($settings->get('mail_host')) {
                    Config::set('mail.default', $settings->get('mail_mailer', 'smtp'));
                    Config::set('mail.mailers.smtp.host', $settings->get('mail_host'));
                    Config::set('mail.mailers.smtp.port', $settings->get('mail_port', 2525));
                    Config::set('mail.mailers.smtp.encryption', $settings->get('mail_encryption', 'tls'));
                    Config::set('mail.mailers.smtp.username', $settings->get('mail_username'));
                    Config::set('mail.mailers.smtp.password', $settings->get('mail_password'));
                    Config::set('mail.from.address', $settings->get('mail_from_address', 'noreply@afritrad.com'));
                    Config::set('mail.from.name', $settings->get('mail_from_name', 'Afritrad'));
                }
            }
        } catch (\Exception $e) {
            // Ignore if DB not ready
        }
    }
}
