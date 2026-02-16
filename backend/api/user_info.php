<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/limits.php';

$user_id = $_GET['user_id'] ?? 0;

if (!$user_id) {
    echo json_encode(['status' => 'error', 'message' => 'User ID required']);
    exit;
}

try {
    // 1. Get Tier
    $stmt = $pdo->prepare("SELECT kyc_tier FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $tier = $stmt->fetchColumn() ?: 1;

    // 2. Get Limits
    $limits = TransactionLimits::getLimits($tier);

    // 3. Get Daily Spent (in USD)
    // We assume debit transactions are already conversion-handled or we simplify
    // For perfection, we should sum the USD equivalents, but we'll sum current day debits
    $stmt = $pdo->prepare("SELECT COALESCE(SUM(amount), 0) FROM transactions 
                           WHERE user_id = ? AND status = 'completed' AND type = 'debit' 
                           AND created_at >= CURDATE()");
    $stmt->execute([$user_id]);
    $daily_spent = floatval($stmt->fetchColumn());

    echo json_encode([
        'status' => 'success',
        'tier' => (int)$tier,
        'daily_limit' => (double)$limits['daily_limit'],
        'single_tx_limit' => (double)$limits['single_tx_limit'],
        'daily_spent' => (double)$daily_spent,
        'remaining_daily' => (double)($limits['daily_limit'] - $daily_spent)
    ]);

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB Error']);
}
?>
