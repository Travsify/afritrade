<?php
header('Content-Type: application/json');
require_once '../config/db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['status' => 'error', 'message' => 'POST required']);
    exit;
}

$user_id = $_POST['user_id'] ?? '';
$doc_type = $_POST['document_type'] ?? 'ID';

if (!$user_id || !isset($_FILES['file'])) {
    echo json_encode(['status' => 'error', 'message' => 'Missing file or user_id']);
    exit;
}

$uploadDir = __DIR__ . '/../uploads/kyc/';
if (!is_dir($uploadDir))
    mkdir($uploadDir, 0777, true);

$fileName = time() . '_' . basename($_FILES['file']['name']);
$targetPath = $uploadDir . $fileName;

if (move_uploaded_file($_FILES['file']['tmp_name'], $targetPath)) {
    try {
        $stmt = $pdo->prepare("INSERT INTO kyc_documents (user_id, document_type, file_path) VALUES (?, ?, ?)");
        $stmt->execute([$user_id, $doc_type, 'uploads/kyc/' . $fileName]);

        echo json_encode(['status' => 'success', 'message' => 'Uploaded successfully']);
    } catch (PDOException $e) {
        echo json_encode(['status' => 'error', 'message' => 'Database error']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Upload failed']);
}
?>