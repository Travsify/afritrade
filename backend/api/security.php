<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) $input = $_POST;

$action = $_GET['action'] ?? '';
$user_id = $input['user_id'] ?? 0;

if (!$user_id) {
    echo json_encode(['status' => 'error', 'message' => 'User ID required']);
    exit;
}

try {
    if ($action === 'set_pin') {
        $pin = $input['pin'] ?? '';
        if (strlen($pin) < 4) {
            echo json_encode(['status' => 'error', 'message' => 'PIN must be at least 4 digits']);
            exit;
        }

        $hashed_pin = password_hash($pin, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare("UPDATE users SET transaction_pin = ? WHERE id = ?");
        $stmt->execute([$hashed_pin, $user_id]);

        echo json_encode(['status' => 'success', 'message' => 'PIN set successfully']);

    } elseif ($action === 'verify_pin') {
        $pin = $input['pin'] ?? '';
        
        $stmt = $pdo->prepare("SELECT transaction_pin FROM users WHERE id = ?");
        $stmt->execute([$user_id]);
        $stored_pin = $stmt->fetchColumn();

        if (!$stored_pin) {
            echo json_encode(['status' => 'error', 'message' => 'PIN not set', 'code' => 'NOT_SET']);
            exit;
        }

        if (password_verify($pin, $stored_pin)) {
            echo json_encode(['status' => 'success', 'message' => 'PIN verified']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Incorrect PIN']);
        }

    } elseif ($action === 'check_status') {
        $stmt = $pdo->prepare("SELECT transaction_pin FROM users WHERE id = ?");
        $stmt->execute([$user_id]);
        $stored_pin = $stmt->fetchColumn();

        echo json_encode([
            'status' => 'success', 
            'is_pin_set' => !empty($stored_pin)
        ]);

    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
    }

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB Error: ' . $e->getMessage()]);
}
?>
