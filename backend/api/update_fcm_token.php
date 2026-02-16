<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);
// Fallback to post fields if json decode fails
if (!$input) $input = $_POST;

$user_id = $input['user_id'] ?? 0;
// Note: Mobile might send 'token' in JSON
$token = $input['token'] ?? '';

if (!$user_id || !$token) {
    echo json_encode(['status' => 'error', 'message' => 'Missing data']);
    exit;
}

try {
    $stmt = $pdo->prepare("UPDATE users SET fcm_token = ? WHERE id = ?");
    $stmt->execute([$token, $user_id]);

    echo json_encode(['status' => 'success', 'message' => 'Token updated']);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB Error']);
}
?>
