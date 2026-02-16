<?php
// backend/api/send_notification.php
// Usage: POST { user_id: 1, title: "Alert", body: "Msg" }

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/db.php';

// Ideally, fetch this from System Settings
// $stmt = $pdo->query("SELECT setting_value FROM system_settings WHERE setting_key = 'fcm_server_key'");
// $server_key = $stmt->fetchColumn();
$server_key = 'YOUR_FCM_SERVER_KEY_HERE'; // <--- REPLACE THIS or set in DB

$input = json_decode(file_get_contents('php://input'), true);
if (!$input && isset($_POST['user_id'])) $input = $_POST;

if (!$input) {
    echo json_encode(['status' => 'error', 'message' => 'No input']);
    exit;
}

$user_id = $input['user_id'] ?? 0;
$title = $input['title'] ?? 'Afritrade';
$body = $input['body'] ?? '';

if (!$user_id || !$body) {
    echo json_encode(['status' => 'error', 'message' => 'Missing ID or Body']);
    exit;
}

function sendFCM($token, $title, $body, $server_key) {
    $url = "https://fcm.googleapis.com/fcm/send";
    $notification = [
        'title' => $title,
        'body' => $body,
        'sound' => 'default', 
        'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
    ];
    $extraNotificationData = ["message" => $notification];

    $fcmNotification = [
        'to'        => $token,
        'notification' => $notification,
        'data' => $extraNotificationData
    ];

    $headers = [
        'Authorization: key=' . $server_key,
        'Content-Type: application/json'
    ];

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fcmNotification));

    $result = curl_exec($ch);
    curl_close($ch);

    return $result;
}

try {
    // Get User Token
    $stmt = $pdo->prepare("SELECT fcm_token FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $token = $stmt->fetchColumn();

    if ($token) {
        $res = sendFCM($token, $title, $body, $server_key);
        echo json_encode(['status' => 'success', 'fcm_result' => json_decode($res)]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'User has no token']);
    }

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB Error']);
}
?>
