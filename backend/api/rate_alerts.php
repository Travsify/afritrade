<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/db.php';

$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) $input = $_POST;

$user_id = $input['user_id'] ?? 0;

if (!$user_id) {
    echo json_encode(['status' => 'error', 'message' => 'User ID required']);
    exit;
}

try {
    if ($method === 'GET') {
        $stmt = $pdo->prepare("SELECT * FROM rate_alerts WHERE user_id = ? AND status != 'disabled' ORDER BY created_at DESC");
        $stmt->execute([$user_id]);
        $alerts = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['status' => 'success', 'data' => $alerts]);

    } elseif ($method === 'POST') {
        $action = $_GET['action'] ?? 'create';

        if ($action === 'create') {
            $pair = $input['currency_pair'] ?? '';
            $rate = $input['target_rate'] ?? 0;
            $direction = $input['direction'] ?? 'above';

            $stmt = $pdo->prepare("INSERT INTO rate_alerts (user_id, currency_pair, target_rate, direction) VALUES (?, ?, ?, ?)");
            $stmt->execute([$user_id, $pair, $rate, $direction]);
            echo json_encode(['status' => 'success', 'message' => 'Alert created']);

        } elseif ($action === 'delete') {
            $alert_id = $input['alert_id'] ?? 0;
            $stmt = $pdo->prepare("UPDATE rate_alerts SET status = 'disabled' WHERE id = ? AND user_id = ?");
            $stmt->execute([$alert_id, $user_id]);
            echo json_encode(['status' => 'success', 'message' => 'Alert disabled']);
        }
    }

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB Error']);
}
?>
