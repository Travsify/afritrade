<?php
$combinations = [
    ['host' => '127.0.0.1', 'user' => 'u532854725_afritrade', 'pass' => 'Brevity230./', 'db' => 'u532854725_afritrade'],
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => 'Brevity230./', 'db' => 'afritrade'],
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => '', 'db' => 'afritrade'],
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => '', 'db' => 'test'],
    ['host' => '127.0.0.1', 'user' => 'root', 'pass' => 'root', 'db' => 'afritrade'],
];

echo "Testing Database Connections...\n";

foreach ($combinations as $idx => $creds) {
    echo "Test #$idx: User={$creds['user']} DB={$creds['db']} Pass=" . ($creds['pass'] ? 'YES' : 'NO') . " ... ";
    try {
        $dsn = "mysql:host={$creds['host']};dbname={$creds['db']};charset=utf8mb4";
        $options = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_TIMEOUT => 3];
        $pdo = new PDO($dsn, $creds['user'], $creds['pass'], $options);
        echo "SUCCESS!\n";
        exit(0);
    } catch (PDOException $e) {
        echo "FAILED: " . $e->getMessage() . "\n";
    }
}

echo "All attempts failed.\n";
exit(1);
