<?php
// universal_setup.php
// A standalone script to fix your DB without relying on the router or existing files.

ini_set('display_errors', 1);
error_reporting(E_ALL);

echo "<h1>Afritrad Universal Setup</h1>";

// 1. Try to find DB Connection
$dbPaths = [
    __DIR__ . '/config/db.php',
    __DIR__ . '/../config/db.php',
    'config/db.php'
];

$pdo = null;
$configFound = false;

echo "<h3>1. Checking Database Connection...</h3>";
foreach ($dbPaths as $path) {
    if (file_exists($path)) {
        echo "Found config at: $path<br>";
        require_once $path;
        $configFound = true;
        if (isset($pdo)) {
            echo "<strong style='color:green'>Database Connected Successfully!</strong><br>";
            break;
        }
    }
}

if (!$pdo) {
    die("<h2 style='color:red'>Critical Error: Could not connect to Database. Check config/db.php</h2>");
}

// 2. Run Seeder
echo "<h3>2. Seeding Data...</h3>";
try {
    // Users
    $names = ['John Doe', 'Admin User', 'Test Trader'];
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
        } else {
            echo "User $email already exists<br>";
        }
    }
    
    // Transactions
    $uid = $pdo->lastInsertId(); // Last created user
    if ($uid) {
        $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, status, recipient, reference, created_at) VALUES (?, 'deposit', 10000, 'NGN', 'completed', 'Wallet', 'SETUP-TEST', NOW())");
        $stmt->execute([$uid]);
        echo "Created test transaction.<br>";
    }

    echo "<h2 style='color:green'>SUCCESS: System is ready!</h2>";
    echo "You can now login with: <b>adminuser@afritrade.com</b> / <b>password123</b>";

} catch (Exception $e) {
    echo "<p style='color:red'>Error: " . $e->getMessage() . "</p>";
}
?>
