<?php
$dbPath = 'c:/Users/USER/Desktop/Afritrad/backend_laravel/database/database.sqlite';
echo "Testing SQLite connection to: $dbPath\n";

if (!file_exists($dbPath)) {
    echo "ERROR: Database file does not exist!\n";
    exit(1);
}

try {
    $pdo = new PDO("sqlite:$dbPath");
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Connection SUCCESS!\n";
    
    $pdo->exec("CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT)");
    echo "Table creation SUCCESS!\n";
} catch (PDOException $e) {
    echo "Connection FAILED: " . $e->getMessage() . "\n";
    
    $drivers = PDO::getAvailableDrivers();
    echo "Available PDO drivers: " . implode(', ', $drivers) . "\n";
}
