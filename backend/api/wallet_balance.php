<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/db.php';

$user_id = $_GET['user_id'] ?? '';

if (!$user_id) {
    echo json_encode(['status' => 'error', 'message' => 'User ID required']);
    exit;
}

try {
    // 1. Calculate Balances from Transactions
    // Assumes types: 'credit', 'deposit' map to + and 'debit', 'withdrawal' map to -
    $sql = "SELECT 
                currency, 
                SUM(CASE 
                    WHEN type IN ('credit', 'deposit') THEN amount 
                    WHEN type IN ('debit', 'withdrawal') THEN -amount 
                    ELSE 0 
                END) as balance 
            FROM transactions 
            WHERE user_id = ? AND status = 'completed' 
            GROUP BY currency";
            
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$user_id]);
    $balances = $stmt->fetchAll(PDO::FETCH_KEY_PAIR); // [ 'USD' => 100.00, 'NGN' => 5000 ]

    // 2. Load Exchange Rates from Settings
    $stmt = $pdo->query("SELECT setting_value FROM system_settings WHERE setting_key = 'exchange_rate_usd_ngn'");
    $ngn_rate = $stmt->fetchColumn() ?: 1600;

    // Platform Mock Rates (mirroring AnchorService for consistency until we have a rate API)
    $rates = [
        'USD' => 1.0,
        'NGN' => 1 / $ngn_rate, // ~0.000625
        'GBP' => 1.26,
        'EUR' => 1.08,
        'CNY' => 0.138,
        'USDT' => 1.0,
        'USDC' => 1.0
    ];

    $total_usd = 0.0;
    $assets = [];

    // Currency Names Map
    $names = [
        'USD' => 'US Dollar',
        'NGN' => 'Nigerian Naira',
        'GBP' => 'British Pound',
        'EUR' => 'Euro',
        'CNY' => 'Chinese Yuan',
        'USDT' => 'Tether',
        'USDC' => 'USD Coin'
    ];

    // Ensure common currencies are present even if 0 balance
    $defaultCurrencies = ['USD', 'NGN', 'GBP', 'EUR', 'CNY', 'USDT', 'USDC'];
    
    foreach ($defaultCurrencies as $currency) {
        $bal = isset($balances[$currency]) ? floatval($balances[$currency]) : 0.0;
        
        // Calculate USD Value
        $rate = $rates[$currency] ?? 0; // Default to 0 if unknown
        $usd_val = $bal * $rate;
        $total_usd += $usd_val;

        $assets[] = [
            'currency' => $currency,
            'name' => $names[$currency] ?? $currency,
            'balance' => $bal,
            'usd_value' => round($usd_val, 2)
        ];
    }

    echo json_encode([
        'status' => 'success',
        'total_usd' => round($total_usd, 2),
        'assets' => $assets
    ]);

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $e->getMessage()]);
}
?>
