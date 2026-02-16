<?php
// Enable ALL error reporting
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

echo "<h2>Afritrade Database Installation</h2>";
echo "<p>Connecting to database...</p>";

include __DIR__ . '/config/db.php';

// Check if PDO connection was successful
if (!isset($pdo) || $pdo === null) {
    echo "<p style='color:red;'><strong>ERROR:</strong> Database connection failed!</p>";
    echo "<p>Please check your <code>config/db.php</code> file:</p>";
    echo "<ul>";
    echo "<li>Database name is correct</li>";
    echo "<li>Username is correct</li>";
    echo "<li><strong>Password is entered</strong> (not empty)</li>";
    echo "</ul>";
    exit;
}

echo "<p style='color:green;'>✔ Database connected successfully!</p>";

try {

    // 1. Users Table
    $sql = "CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100),
        email VARCHAR(100) UNIQUE,
        password VARCHAR(255),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "✔ Users table created.<br>";

    // 2. Transactions Table
    $sql = "CREATE TABLE IF NOT EXISTS transactions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        type VARCHAR(20), -- credit, debit
        amount DECIMAL(15,2),
        currency VARCHAR(10),
        recipient VARCHAR(100),
        status VARCHAR(20), -- pending, completed
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "✔ Transactions table created.<br>";

    // 3. Admin Table
    $sql = "CREATE TABLE IF NOT EXISTS admins (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100),
        email VARCHAR(100) UNIQUE,
        password VARCHAR(255),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "✔ Admins table created.<br>";

    // 4. Default Admin (admin@taxpalng.site / password)
    // Only insert if empty
    $stmt = $pdo->query("SELECT COUNT(*) FROM admins");
    if ($stmt->fetchColumn() == 0) {
        $pass = password_hash("password", PASSWORD_DEFAULT);
        $sql = "INSERT INTO admins (name, email, password) VALUES ('Super Admin', 'admin@taxpalng.site', '$pass')";
        $pdo->exec($sql);
        echo "✔ Default Admin created (Email: admin@taxpalng.site, Pass: password).<br>";
    }

    // 5. Chat Tables (Redundant with support_chat.php but safely ensures they exist)
    $sql = "CREATE TABLE IF NOT EXISTS chat_sessions (
        id VARCHAR(50) PRIMARY KEY,
        user_id VARCHAR(50),
        status VARCHAR(20) DEFAULT 'ai', 
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);

    $sql = "CREATE TABLE IF NOT EXISTS chat_messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        session_id VARCHAR(50),
        sender VARCHAR(20),
        message TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    // 6. System Settings Table
    $sql = "CREATE TABLE IF NOT EXISTS system_settings (
        setting_key VARCHAR(50) PRIMARY KEY,
        setting_value TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);

    // Seed Default Settings
    $defaults = [
        'openai_api_key' => '',
        'anchor_base_url' => 'https://api.anchor.com',
        'exchange_rate_usd_ngn' => '1450.00',
        'maintenance_mode' => '0'
    ];

    foreach ($defaults as $key => $val) {
        $stmt = $pdo->prepare("INSERT IGNORE INTO system_settings (setting_key, setting_value) VALUES (?, ?)");
        $stmt->execute([$key, $val]);
    }
    echo "✔ System Settings table created.<br>";

    // 5. Chat Tables

    // 7. KYC Documents
    $sql = "CREATE TABLE IF NOT EXISTS kyc_documents (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        doc_type VARCHAR(50), -- passport, id_card
        file_path VARCHAR(255),
        status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected
        rejection_reason TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "✔ KYC Documents table created.<br>";

    // 8. Referrals
    $sql = "CREATE TABLE IF NOT EXISTS referrals (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT, -- The new user
        referrer_id INT, -- Who invited them
        commission_earned DECIMAL(10,2) DEFAULT 0.00,
        status VARCHAR(20) DEFAULT 'active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "✔ Referrals table created.<br>";

    // 9. CMS - Banners & FAQ
    $sql = "CREATE TABLE IF NOT EXISTS cms_banners (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(100),
        image_url VARCHAR(255),
        link_url VARCHAR(255),
        is_active TINYINT DEFAULT 1
    )";
    $pdo->exec($sql);

    $sql = "CREATE TABLE IF NOT EXISTS cms_faqs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        question TEXT,
        answer TEXT,
        category VARCHAR(50),
        ordering INT DEFAULT 0
    )";
    $pdo->exec($sql);
    echo "✔ CMS tables created.<br>";

    // 10. Audit Logs
    $sql = "CREATE TABLE IF NOT EXISTS audit_logs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        admin_id INT,
        action VARCHAR(100),
        details TEXT,
        ip_address VARCHAR(45),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";
    $pdo->exec($sql);
    echo "✔ Audit Logs table created.<br>";

    echo "<h3>Installation Complete! Delete this file before going production.</h3>";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>