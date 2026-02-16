<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/db.php';

// Check DB setting for NGN
$stmt = $pdo->query("SELECT setting_value FROM system_settings WHERE setting_key = 'exchange_rate_usd_ngn'");
$ngn_rate = $stmt->fetchColumn() ?: 1600;

// Base Rates (USD base)
// In a real app, you would fetch these from CoinGecko/Fixer.io
$base_rates = [
    'USD' => 1.0,
    'NGN' => floatval($ngn_rate),
    'GBP' => 0.79,
    'EUR' => 0.92,
    'CNY' => 7.20,
    'KES' => 153.0,
    'GHS' => 15.5
];

// Return pairs expected by Mobile App
$pairs = [];

// Helper to calc rate
function getRate($from, $to, $base_rates) {
    if (!isset($base_rates[$from]) || !isset($base_rates[$to])) return 0;
    // from/USD * USD/to ? 
    // If base is USD:
    // Rate = (1/Rate_From_USD) * Rate_To_USD ? No.
    // Base Rates are USD -> X (e.g. 1 USD = 1600 NGN)
    // To convert From -> To:
    // Amount(USD) = Amount(From) / Rate(From)
    // Amount(To) = Amount(USD) * Rate(To)
    // Rate(From->To) = Rate(To) / Rate(From)
    
    return $base_rates[$to] / $base_rates[$from];
}

$target_pairs = [
    ['USD', 'NGN'], ['NGN', 'USD'],
    ['GBP', 'NGN'], ['NGN', 'GBP'],
    ['EUR', 'NGN'], ['NGN', 'EUR'],
    ['CNY', 'NGN'], ['NGN', 'CNY'],
    ['USD', 'GBP'], ['GBP', 'USD'],
    ['USD', 'EUR'], ['EUR', 'USD'],
    ['USD', 'CNY'], ['CNY', 'USD']
];

foreach ($target_pairs as $pair) {
    $from = $pair[0];
    $to = $pair[1];
    $key = "{$from}_{$to}";
    $val = getRate($from, $to, $base_rates);
    
    $pairs[$key] = round($val, 6);
}

// Also return list for Dashboard "Market Rates"
$market_list = [];
$dashboard_pairs = [
    ['USD', 'NGN'],
    ['GBP', 'NGN'],
    ['EUR', 'NGN'],
    ['CNY', 'NGN']
];

foreach ($dashboard_pairs as $pair) {
    $market_list[] = [
        'from' => $pair[0],
        'to' => $pair[1],
        'rate' => $pairs["{$pair[0]}_{$pair[1]}"],
        'change' => rand(-20, 20) / 10 // Mock change %
    ];
}

echo json_encode([
    'status' => 'success',
    'rates' => $pairs,
    'market' => $market_list
]);
?>
