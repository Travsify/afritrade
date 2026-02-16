<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/limits.php';

$input = json_decode(file_get_contents('php://input'), true);

$user_id = $input['user_id'] ?? '';
$amount = floatval($input['amount'] ?? 0);
$from = $input['from_currency'] ?? '';
$to = $input['to_currency'] ?? '';

if (!$user_id || $amount <= 0 || !$from || !$to) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid swap details']);
    exit;
}

// 0. Pre-check Limits (Convert to USD first)
$stmt_r = $pdo->query("SELECT setting_value FROM system_settings WHERE setting_key = 'exchange_rate_usd_ngn'");
$ngn_rate_val = $stmt_r->fetchColumn() ?: 1600;
$all_base_rates = ['USD' => 1.0, 'NGN' => floatval($ngn_rate_val), 'GBP' => 0.79, 'EUR' => 0.92, 'CNY' => 7.20];

// Convert input amount to USD
$tx_usd_val = ($from === 'USD') ? $amount : ($amount / ($all_base_rates[$from] ?? 1.0));

$limitCheck = TransactionLimits::checkLimit($pdo, $user_id, $tx_usd_val);
if (!$limitCheck['allowed']) {
    echo json_encode(['status' => 'error', 'message' => $limitCheck['message']]);
    exit;
}

try {
    $pdo->beginTransaction();

    // 1. Check Balance
    // Sum previous txs
    $stmt = $pdo->prepare("SELECT 
                SUM(CASE 
                    WHEN type IN ('credit', 'deposit') THEN amount 
                    WHEN type IN ('debit', 'withdrawal') THEN -amount 
                    ELSE 0 
                END) as balance 
            FROM transactions 
            WHERE user_id = ? AND currency = ? AND status = 'completed'");
    $stmt->execute([$user_id, $from]);
    $current_balance = floatval($stmt->fetchColumn() ?: 0);

    if ($current_balance < $amount) {
        throw new Exception("Insufficient $from balance");
    }

    // 2. Get Rate (Simplified Platform Rates)
    // Ideally fetch from DB system_settings or external API
    // For MVP, we define the same rates as mobile or fetch one main pair
    $rates = [
        'USD_NGN' => 1600.0, 'NGN_USD' => 0.000625,
        'USD_GBP' => 0.79, 'GBP_USD' => 1.26,
        'USD_EUR' => 0.92, 'EUR_USD' => 1.08,
        'USD_CNY' => 7.20, 'CNY_USD' => 0.138,
        // Add reverse pairs derived or explicit...
    ];
    // Dynamic reverse calc if missing?
    
    $key = "{$from}_{$to}";
    $rate = $rates[$key] ?? 0;
    
    if ($rate == 0) {
        // Try reverse
        $revKey = "{$to}_{$from}";
        if (isset($rates[$revKey])) {
            $rate = 1 / $rates[$revKey];
        } else {
             // Default 1.0 same currency
             if ($from == $to) $rate = 1.0;
             else $rate = 1.0; // Fallback or Error
        }
    }
    
    // Check NGN rate from DB setting for accuracy
    if ($key == 'USD_NGN') {
         $stmt = $pdo->query("SELECT setting_value FROM system_settings WHERE setting_key = 'exchange_rate_usd_ngn'");
         $db_rate = $stmt->fetchColumn();
         if ($db_rate) $rate = floatval($db_rate);
    }

    $to_amount = $amount * $rate;

    // 3. Debit From
    $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, status, recipient, reference, created_at) VALUES (?, 'debit', ?, ?, 'completed', 'Swap Pool', ?, NOW())");
    $ref = "SWAP-" . time();
    $stmt->execute([$user_id, $amount, $from, $ref]);

    // 4. Credit To
    $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, status, recipient, reference, created_at) VALUES (?, 'credit', ?, ?, 'completed', 'Swap Pool', ?, NOW())");
    $stmt->execute([$user_id, $to_amount, $to, $ref]);

    $pdo->commit();

    echo json_encode([
        'status' => 'success',
        'message' => 'Swap successful',
        'from_amount' => $amount,
        'to_amount' => $to_amount,
        'rate' => $rate,
        'tx_id' => $ref
    ]);

} catch (Exception $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
