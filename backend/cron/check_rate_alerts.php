<?php
// backend/cron/check_rate_alerts.php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../includes/fcm_helper.php';

// 1. Get current rates (Logic from api/rates.php)
$stmt = $pdo->query("SELECT setting_value FROM system_settings WHERE setting_key = 'exchange_rate_usd_ngn'");
$ngn_rate = $stmt->fetchColumn() ?: 1600;

$base_rates = [
    'USD' => 1.0, 'NGN' => floatval($ngn_rate), 'GBP' => 0.79, 'EUR' => 0.92, 'CNY' => 7.20, 'KES' => 153.0, 'GHS' => 15.5
];

function getRatePair($pair, $base_rates) {
    $parts = explode('_', $pair);
    if (count($parts) != 2) return 0;
    return $base_rates[$parts[1]] / $base_rates[$parts[0]];
}

// 2. Fetch Active Alerts
$stmt = $pdo->query("SELECT * FROM rate_alerts WHERE status = 'active'");
$alerts = $stmt->fetchAll();

foreach ($alerts as $alert) {
    $current_rate = getRatePair($alert['currency_pair'], $base_rates);
    $target = floatval($alert['target_rate']);
    $triggered = false;

    if ($alert['direction'] === 'above' && $current_rate >= $target) {
        $triggered = true;
    } elseif ($alert['direction'] === 'below' && $current_rate <= $target) {
        $triggered = true;
    }

    if ($triggered) {
        $msg = "Rate Alert! {$alert['currency_pair']} reached " . round($current_rate, 2);
        
        // 3. Send Notification
        if (sendPushNotification($alert['user_id'], "Afritrade Rate Alert", $msg, $pdo)) {
             // 4. Mark as Triggered
             $upd = $pdo->prepare("UPDATE rate_alerts SET status = 'triggered' WHERE id = ?");
             $upd->execute([$alert['id']]);
             echo "Triggered alert {$alert['id']} for User {$alert['user_id']}\n";
        }
    }
}

echo "Alert check complete.\n";
?>
