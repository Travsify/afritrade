<?php
header('Content-Type: application/json');
require_once '../config/db.php';

$user_id = $_GET['user_id'] ?? '';

if (!$user_id) {
    echo json_encode(['status' => 'error', 'message' => 'User ID required']);
    exit;
}

try {
    // 1. Get Referral Code (Assuming it's stored in users table or generating it)
    $stmt = $pdo->prepare("SELECT referral_code FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch();
    $code = $user['referral_code'] ?? 'AFRI-' . $user_id; // Fallback if column missing

    // 2. Get Referrals List
    $stmt = $pdo->prepare("
        SELECT r.status, r.created_at, u.name, r.commission_earned 
        FROM referrals r 
        JOIN users u ON r.user_id = u.id 
        WHERE r.referrer_id = ? 
        ORDER BY r.created_at DESC
    ");
    $stmt->execute([$user_id]);
    $list = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 3. Calculate Stats
    $totalEarned = 0;
    $pendingCount = 0;
    $referralList = [];

    foreach ($list as $item) {
        if ($item['status'] == 'active')
            $totalEarned += $item['commission_earned'];
        if ($item['status'] == 'pending')
            $pendingCount++;

        $referralList[] = [
            'name' => $item['name'],
            'status' => $item['status'], // active, pending
            'earned' => '$' . number_format($item['commission_earned'], 2),
            'date' => date('M d', strtotime($item['created_at']))
        ];
    }

    echo json_encode([
        'status' => 'success',
        'code' => $code,
        'list' => $referralList,
        'stats' => [
            'total_earned' => $totalEarned,
            'referrals' => count($list),
            'pending' => $pendingCount
        ]
    ]);

} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>