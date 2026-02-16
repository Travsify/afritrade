<?php
// backend/setup_cards_table.php
require_once __DIR__ . '/config/db.php';

try {
    $sql = "CREATE TABLE IF NOT EXISTS virtual_cards (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        card_label VARCHAR(100),
        card_number VARCHAR(16),
        cvv VARCHAR(3),
        expiry_month VARCHAR(2),
        expiry_year VARCHAR(2),
        balance DECIMAL(15, 2) DEFAULT 0.00,
        currency VARCHAR(3) DEFAULT 'USD',
        brand VARCHAR(20) DEFAULT 'Visa',
        status VARCHAR(20) DEFAULT 'Active', -- Active, Frozen, Terminated
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )";

    $pdo->exec($sql);
    echo "Successfully created 'virtual_cards' table.\n";

    // Seed one test card if empty
    $stmt = $pdo->query("SELECT COUNT(*) FROM virtual_cards");
    if ($stmt->fetchColumn() == 0) {
        $user_id = 1; // Default
        // Create a fake card
        $pan = '424242424242' . rand(1000, 9999);
        $cvv = rand(100, 999);
        $sql = "INSERT INTO virtual_cards (user_id, card_label, card_number, cvv, expiry_month, expiry_year, balance, brand) 
                VALUES (?, 'Shopping Card', ?, ?, '12', '28', 50.00, 'Visa')";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$user_id, $pan, $cvv]);
        echo "Seeded test card.\n";
    }

} catch (PDOException $e) {
    die("DB Error: " . $e->getMessage() . "\n");
}
?>
