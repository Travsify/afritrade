<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once __DIR__ . '/../config/db.php';
// db.php exposes $pdo
$db = isset($pdo) ? $pdo : null;

if (!$db) {
    echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
    exit;
}

$data = json_decode(file_get_contents("php://input"));
$action = isset($_GET['action']) ? $_GET['action'] : '';

// Retrieve API Key from DB
$openai_api_key = "";
try {
    $stmt = $db->query("SELECT setting_value FROM system_settings WHERE setting_key = 'openai_api_key'");
    $openai_api_key = $stmt->fetchColumn();
} catch (Exception $e) {
}

// Fallback to placeholder if empty
if (!$openai_api_key)
    $openai_api_key = "YOUR_OPENAI_API_KEY_HERE";

if ($action == 'init') {
    // Start or Resume a chat session
    $user_id = $data->user_id ?? 'guest';
    $session_id = $data->session_id ?? null;

    if ($session_id) {
        // Check if session exists
        $stmt = $db->prepare("SELECT id FROM chat_sessions WHERE id = ?");
        $stmt->execute([$session_id]);
        if (!$stmt->fetch()) {
            $session_id = uniqid('chat_');
            $stmt = $db->prepare("INSERT INTO chat_sessions (id, user_id, status) VALUES (?, ?, 'ai')");
            $stmt->execute([$session_id, $user_id]);
        }
    } else {
        $session_id = uniqid('chat_');
        $stmt = $db->prepare("INSERT INTO chat_sessions (id, user_id, status) VALUES (?, ?, 'ai')");
        $stmt->execute([$session_id, $user_id]);
    }

    echo json_encode(['status' => 'success', 'session_id' => $session_id]);

} elseif ($action == 'fetch') {
    $session_id = $_GET['session_id'] ?? '';
    if (!$session_id) {
        echo json_encode(['status' => 'error', 'message' => 'Missing session ID']);
        exit;
    }

    $stmt = $db->prepare("SELECT * FROM chat_messages WHERE session_id = ? ORDER BY created_at ASC");
    $stmt->execute([$session_id]);
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $stmt = $db->prepare("SELECT status FROM chat_sessions WHERE id = ?");
    $stmt->execute([$session_id]);
    $status = $stmt->fetchColumn();

    echo json_encode(['status' => 'success', 'messages' => $messages, 'mode' => $status == 'ai' ? 'ai' : 'human']);

} elseif ($action == 'send') {
    $session_id = $data->session_id;
    $message = $data->message;

    // Save User Message
    $stmt = $db->prepare("INSERT INTO chat_messages (session_id, sender, message) VALUES (?, 'user', ?)");
    $stmt->execute([$session_id, $message]);

    // Check Status
    $stmt = $db->prepare("SELECT status FROM chat_sessions WHERE id = ?");
    $stmt->execute([$session_id]);
    $status = $stmt->fetchColumn();

    if ($status == 'human') {
        echo json_encode(['status' => 'success', 'reply' => null, 'mode' => 'human']);
        exit;
    }

    if ($status == 'pending_human') {
        echo json_encode(['status' => 'success', 'reply' => "An agent will be with you shortly.", 'mode' => 'human']);
        exit;
    }

    // Call OpenAI
    $reply = callOpenAI($message, $openai_api_key);

    // Save AI Reply
    $stmt = $db->prepare("INSERT INTO chat_messages (session_id, sender, message) VALUES (?, 'ai', ?)");
    $stmt->execute([$session_id, $reply]);

    echo json_encode(['status' => 'success', 'reply' => $reply, 'mode' => 'ai']);

} elseif ($action == 'handover') {
    $session_id = $data->session_id;

    $stmt = $db->prepare("UPDATE chat_sessions SET status = 'pending_human' WHERE id = ?");
    $stmt->execute([$session_id]);

    // Create notification for admin (mock)
    // insertIntoAdminNotifications(...)

    echo json_encode(['status' => 'success', 'message' => 'Handover requested']);
}

function callOpenAI($userInfo, $apiKey)
{
    if ($apiKey == "YOUR_OPENAI_API_KEY_HERE") {
        return "I am unable to connect to the AI brain right now (API Key Missing). Please contact admin.";
    }

    $url = 'https://api.openai.com/v1/chat/completions';
    $data = [
        'model' => 'gpt-3.5-turbo',
        'messages' => [
            ['role' => 'system', 'content' => 'You are Bridget, a helpful support assistant for Afritrade. You help users with cross-border payments, currency swaps, and tax filing.'],
            ['role' => 'user', 'content' => $userInfo]
        ]
    ];

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $apiKey
    ]);

    $response = curl_exec($ch);

    if (curl_errno($ch)) {
        return "Sorry, I'm having trouble connecting to the server.";
    }

    curl_close($ch);

    $result = json_decode($response, true);
    return $result['choices'][0]['message']['content'] ?? "I didn't understand that.";
}
?>