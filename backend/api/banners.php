<?php
header('Content-Type: application/json');
require_once '../config/db.php';

try {
    $stmt = $pdo->query("SELECT * FROM cms_banners WHERE status = 'active' ORDER BY created_at DESC");
    $banners = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Add full URL prefix if needed (assuming relative paths in DB)
    // The DB stores 'uploads/banners/xyz.jpg'
    // We need to return 'https://admin.afritradepay.com/uploads/banners/xyz.jpg'
    $baseUrl = 'https://admin.afritradepay.com/'; // Adjust if needed

    $output = [];
    foreach ($banners as $b) {
        $output[] = [
            'id' => $b['id'],
            'image_url' => $baseUrl . $b['image_path'],
            'action' => $b['action_url'] ?? null
        ];
    }

    echo json_encode(['status' => 'success', 'data' => $output]);
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB Error']);
}
?>