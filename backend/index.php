<?php
// backend/index.php

// Enable error reporting for development
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Basic Router
$request_uri = $_SERVER['REQUEST_URI'];
$method = $_SERVER['REQUEST_METHOD'];

// Remove query string
$uri_parts = explode('?', $request_uri);
$path = $uri_parts[0];

// Define base path - Attempt to auto-detect
$script_name = $_SERVER['SCRIPT_NAME'];
$base_path = str_replace('/index.php', '', $script_name);

if (strpos($path, $base_path) === 0) {
    if ($base_path !== '') {
        $path = substr($path, strlen($base_path));
    }
}

// Routes
if ($path === '/' || $path === '/index.php' || $path === '') {
    echo json_encode(['status' => 'success', 'message' => 'Afritrad Backend API v1.0']);
} elseif ($path === '/api/health') {
    echo json_encode(['status' => 'ok', 'timestamp' => time()]);
// Route: /seed (Emergency Database Setup)
} elseif ($path === '/seed') {
    require_once __DIR__ . '/config/db.php';
    echo "<h1>Database Seeding...</h1>";
    try {
        // Users
        $names = ['Admin User', 'John Doe'];
        foreach ($names as $name) {
            $email = strtolower(str_replace(' ', '', $name)) . '@afritrade.com';
            $pass = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'; // password123
            $role = ($name === 'Admin User') ? 'admin' : 'user';
            
            $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
            $stmt->execute([$email]);
            if (!$stmt->fetch()) {
                $stmt = $pdo->prepare("INSERT INTO users (name, email, password, role, created_at) VALUES (?, ?, ?, ?, NOW())");
                $stmt->execute([$name, $email, $pass, $role]);
                echo "Created $role: $email<br>";
            }
        }
        // Transaction
        $uid = $pdo->lastInsertId();
        if ($uid) {
            $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, status, recipient, reference, created_at) VALUES (?, 'deposit', 50000, 'NGN', 'completed', 'System', 'FIX-TEST', NOW())")->execute([$uid]);
        }
        echo "<h3 style='color:green'>Done. Login: adminuser@afritrade.com / password123</h3>";
    } catch (Exception $e) { echo "Error: " . $e->getMessage(); }
    exit;

} else {
    // If accessing a real file (like admin/login.php) let it pass
    $file = ltrim($path, '/');
    if (file_exists($file) && is_file($file)) {
        include $file;
        exit;
    }

    http_response_code(404);
    echo json_encode(['status' => 'error', 'message' => 'Not Found', 'path' => $path]);
}
?>