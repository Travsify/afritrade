<?php
// backend/includes/fcm_helper.php

function sendPushNotification($user_id, $title, $body, $pdo) {
    // 1. Get FCM Server Key from System Settings
    $stmt = $pdo->query("SELECT setting_value FROM system_settings WHERE setting_key = 'fcm_server_key'");
    $server_key = $stmt->fetchColumn();
    
    if (!$server_key || $server_key == 'YOUR_FCM_SERVER_KEY_HERE') {
        error_log("FCM Error: Server key not set in system_settings");
        return false;
    }

    // 2. Get User Token
    $stmt = $pdo->prepare("SELECT fcm_token FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $token = $stmt->fetchColumn();

    if (!$token) {
        error_log("FCM Error: User $user_id has no FCM token");
        return false;
    }

    // 3. Send via FCM REST API (v1 or Legacy - sticking to Legacy for simplicity if user has server key)
    $url = "https://fcm.googleapis.com/fcm/send";
    $notification = [
        'title' => $title,
        'body' => $body,
        'sound' => 'default',
        'click_action' => 'FLUTTER_NOTIFICATION_CLICK'
    ];
    
    $payload = [
        'to' => $token,
        'notification' => $notification,
        'data' => ["message" => $notification]
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
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

    $result = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return ($httpCode === 200);
}
?>
