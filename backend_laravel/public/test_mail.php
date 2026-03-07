<?php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

try {
    $settings = \App\Models\SystemSetting::whereIn('setting_key', [
        'mail_mailer', 'mail_host', 'mail_port', 'mail_username', 
        'mail_password', 'mail_encryption', 'mail_from_address', 'mail_from_name'
    ])->pluck('setting_value', 'setting_key');
    
    echo "Current Settings in DB:\n";
    print_r($settings->toArray());
    
    echo "\n\nTesting Mail Connection...\n";
    
    \Illuminate\Support\Facades\Mail::raw('Test connection', function($msg) {
        $msg->to('testing@example.com')->subject('SMTP Test');
    });
    
    echo "\nEmail Sent Successfully!\n";
} catch (\Exception $e) {
    echo "\nERROR: " . $e->getMessage() . "\n";
}
