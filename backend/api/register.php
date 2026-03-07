<?php
header('Content-Type: application/json');
require_once '../config/db.php';

$input = json_decode(file_get_contents('php://input'), true);

$name = $input['name'] ?? '';
$email = $input['email'] ?? '';
$password = $input['password'] ?? '';
$phone = $input['phone'] ?? '';
$country = $input['country'] ?? '';
$business_name = $input['business_name'] ?? '';

if (!$name || !$email || !$password) {
    echo json_encode(['status' => 'error', 'message' => 'Missing fields']);
    exit;
}

try {
    // Check email exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        echo json_encode(['status' => 'error', 'message' => 'Email already exists']);
        exit;
    }

    $hashed = password_hash($password, PASSWORD_DEFAULT);

    // Create User with all fields and mark OTP verified
    $stmt = $pdo->prepare("INSERT INTO users (name, email, password, phone, country, business_name, is_otp_verified) VALUES (?, ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$name, $email, $hashed, $phone, $country, $business_name, 1]);
    $userId = $pdo->lastInsertId();

    echo json_encode([
        'status' => 'success',
        'message' => 'Account created successfully',
        'user' => [
            'id' => $userId,
            'name' => $name,
            'email' => $email,
            'phone' => $phone,
            'country' => $country,
            'business_name' => $business_name,
            'is_verified' => true
        ]
    ]);

} catch (PDOException $e) {
    error_log("Legacy Registration Error: " . $e->getMessage());
    echo json_encode(['status' => 'error', 'message' => 'Database error: ' . $e->getMessage()]);
}
?>