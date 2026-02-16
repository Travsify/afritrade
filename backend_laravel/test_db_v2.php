<?php
$host = '127.0.0.1';
$port = '3306';
$db   = 'u532854725_afritradepay';
$user = 'u532854725_afritradepay';
$pass = 'Brevity230./';

echo "Testing connection to $db at $host:$port as $user...\n";

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$db", $user, $pass);
    echo "Connection SUCCESS!\n";
} catch (PDOException $e) {
    echo "Connection FAILED: " . $e->getMessage() . "\n";
}

$host = 'localhost';
echo "\nTesting connection to $db at $host:$port as $user...\n";

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$db", $user, $pass);
    echo "Connection SUCCESS!\n";
} catch (PDOException $e) {
    echo "Connection FAILED: " . $e->getMessage() . "\n";
}
