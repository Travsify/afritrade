<?php
header('Content-Type: application/json');
require_once '../config/db.php';

$user_id = $_GET['user_id'] ?? '';

if (!$user_id) {
    echo json_encode(['status' => 'error', 'message' => 'User ID required']);
    exit;
}

try {
    // Check tables exist (simple fallback)
    $stmt = $pdo->prepare("SELECT status FROM kyc_documents WHERE user_id = ? ORDER BY created_at DESC LIMIT 1");
    $stmt->execute([$user_id]);
    $doc = $stmt->fetch();

    if (!$doc) {
        echo json_encode(['status' => 'success', 'kyc_status' => 'none', 'reason' => null]);
    } else {
        // If approved, verify user table too?
        // Ideally admin updates users table 'is_verified' too.
        // For now, let's rely on document status.
        $status = $doc['status']; // pending, approved, rejected

        // Map to mobile app enums (verified, pending, rejected)
        $mobileStatus = 'pending';
        if ($status === 'approved')
            $mobileStatus = 'verified';
        if ($status === 'rejected')
            $mobileStatus = 'rejected';

        echo json_encode([
            'status' => 'success',
            'kyc_status' => $mobileStatus,
            'reason' => ($status === 'rejected') ? 'Document rejected by admin' : null
        ]);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'DB Error']);
}
?>