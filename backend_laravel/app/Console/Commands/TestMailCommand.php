<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class TestMailCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:test-mail-command';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        try {
            $this->info("Fetching mail settings...");
            $settings = \App\Models\SystemSetting::whereIn('setting_key', [
                'mail_mailer', 'mail_host', 'mail_port', 'mail_username', 
                'mail_password', 'mail_encryption', 'mail_from_address', 'mail_from_name'
            ])->pluck('setting_value', 'setting_key');
            
            $this->info("Settings: " . json_encode($settings));
            $this->info("Attempting to send email...");
            
            \Illuminate\Support\Facades\Mail::raw('Test connection', function($msg) use ($settings) {
                $msg->to('test@example.com')->subject('SMTP Test');
            });
            
            $this->info("Email Sent Successfully!");
        } catch (\Exception $e) {
            $this->error("ERROR: " . $e->getMessage());
        }
    }
}
