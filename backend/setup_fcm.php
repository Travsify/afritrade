<?php
// backend/setup_fcm.php
require_once __DIR__ . '/config/db.php';

try {
    // Check if column exists
    $stmt = $pdo->query("SHOW COLUMNS FROM users LIKE 'fcm_token'");
    if ($stmt->fetch()) {
        echo "Column 'fcm_token' already exists.\n";
    } else {
        $sql = "ALTER TABLE users ADD COLUMN fcm_token TEXT DEFAULT NULL";
        $pdo->exec($sql);
        echo "Successfully added 'fcm_token' to users table.\n";
    }

} catch (PDOException $e) {
    die("DB Error: " . $e->getMessage() . "\n");
}
?>
