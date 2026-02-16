<?php
header('Content-Type: application/json');
require_once '../config/db.php';

// Handle GET Request (List Transactions)
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $userId = $_GET['user_id'] ?? 0;

    if (!$userId) {
        echo json_encode(['status' => 'error', 'message' => 'User ID required']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("SELECT * FROM transactions WHERE user_id = ? ORDER BY created_at DESC");
        $stmt->execute([$userId]);
        $transactions = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Map to mobile UI expected format if needed, or send raw
        // AnchorService expects: { type, title, date, amount, currency }
        $mapped = [];
        foreach ($transactions as $t) {
            $title = ucfirst($t['type']) . ($t['recipient'] ? " to " . $t['recipient'] : "");
            $mapped[] = [
                'type' => $t['type'], // 'debit', 'credit', 'swap'
                'title' => $title,
                'date' => $t['created_at'], // You might want to format this client-side or here
                'amount' => floatval($t['amount']),
                'currency' => $t['currency'],
                'recipient' => $t['recipient']
            ];
        }

        echo json_encode(['status' => 'success', 'data' => $mapped]);
    } catch (PDOException $e) {
        echo json_encode(['status' => 'error', 'message' => 'Database error']);
    }
    exit;
}

// Handle POST Request (Create Transaction) as before
$input = json_decode(file_get_contents('php://input'), true);
$userId = $input['user_id'] ?? 0;
$type = $input['type'] ?? '';
$amount = $input['amount'] ?? 0;
$currency = $input['currency'] ?? '';
$recipient = $input['recipient'] ?? '';
$reference = $input['reference'] ?? '';

if (!$userId || !$type || !$amount || !$currency) {
    echo json_encode(['status' => 'error', 'message' => 'Missing transaction data']);
    exit;
}

try {
    $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, recipient, reference, status) VALUES (?, ?, ?, ?, ?, ?, 'pending')");
    $stmt->execute([$userId, $type, $amount, $currency, $recipient, $reference]);

    echo json_encode([
        'status' => 'success',
        'message' => 'Transaction logged',
        'id' => $pdo->lastInsertId()
    ]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Server error: ' . $e->getMessage()]);
}
?>