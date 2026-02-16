<?php
// backend/setup_advanced_features.php
require_once __DIR__ . '/config/db.php';

try {
    // 1. Update Users table for PIN and Tiers
    $cols = [
        'transaction_pin' => "VARCHAR(255) DEFAULT NULL",
        'kyc_tier' => "INT DEFAULT 1"
    ];

    foreach ($cols as $col => $def) {
        $stmt = $pdo->query("SHOW COLUMNS FROM users LIKE '$col'");
        if (!$stmt->fetch()) {
            $pdo->exec("ALTER TABLE users ADD COLUMN $col $def");
            echo "Added column '$col' to users table.\n";
        }
    }

    // 2. Create Rate Alerts Table
    $sql = "CREATE TABLE IF NOT EXISTS rate_alerts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        currency_pair VARCHAR(20), -- e.g. USD_NGN
        target_rate DECIMAL(15,4),
        direction ENUM('above', 'below'),
        status ENUM('active', 'triggered', 'disabled') DEFAULT 'active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX (user_id),
        INDEX (status)
    )";
    $pdo->exec($sql);
    echo "✔ Rate Alerts table verified.\n";

} catch (PDOException $e) {
    die("DB Error: " . $e->getMessage() . "\n");
}
?>
