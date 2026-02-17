<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

echo "<h1>Database Connection Test</h1>";

$url = getenv('DATABASE_URL') ?: getenv('DB_URL');

if (!$url) {
    die("Error: DATABASE_URL environment variable is not set.");
}

echo "Attempting to connect to: " . substr($url, 0, 20) . "...<br>";

try {
    $dbopts = parse_url($url);
    $dsn = "pgsql:host=" . $dbopts["host"] . ";port=" . $dbopts["port"] . ";dbname=" . ltrim($dbopts["path"], '/') . ";user=" . $dbopts["user"] . ";password=" . $dbopts["pass"];
    
    $pdo = new PDO($dsn);
    echo "<h2 style='color:green'>Success! Connected to PostgreSQL.</h2>";
    
    $query = $pdo->query("SELECT version()");
    $row = $query->fetch();
    echo "PostgreSQL Version: " . $row[0] . "<br>";
    
} catch (PDOException $e) {
    echo "<h2 style='color:red'>Connection Failed</h2>";
    echo "Error: " . $e->getMessage();
}
