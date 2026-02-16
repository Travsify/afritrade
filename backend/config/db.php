<?php
/**
 * Database Configuration for Afritrad
 * 
 * IMPORTANT: Update the $pass variable with your actual database password!
 */

$host = 'localhost';
$db = 'u532854725_afritrade';
$user = 'u532854725_afritrade';
$pass = 'YOUR_PASSWORD_HERE'; // <--- ENTER YOUR ACTUAL DATABASE PASSWORD HERE
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];

$pdo = null;
$db_error = null;

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (\PDOException $e) {
    $db_error = $e->getMessage();
    // Log error for debugging (check your server's error log)
    error_log("Afritrad DB Connection Error: " . $e->getMessage());
}

// Helper function to check if database is connected
function isDbConnected() {
    global $pdo;
    return $pdo !== null;
}
?>