<?php
// backend/seed.php
require_once __DIR__ . '/config/db.php';

// Prevent seeding if users already exist (safety check)
// $check = $pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
// if ($check > 00) { die("Database already has data. Seeding aborted to prevent duplicates."); }

echo "<pre>";
echo "Starting Database Seeding...\n";

try {
    // 2. Create Users
    $names = ['John Doe', 'Jane Smith', 'Michael Johnson', 'Sarah Wilson', 'David Brown', 'Emily Davis', 'Chris Miller', 'Jessica Taylor', 'Daniel Anderson', 'Lisa Thomas'];
    $userIds = [];

    $stmtUser = $pdo->prepare("INSERT INTO users (name, email, password, phone, role, created_at) VALUES (?, ?, ?, ?, 'user', ?)");

    foreach ($names as $i => $name) {
        $email = strtolower(str_replace(' ', '.', $name)) . rand(100, 999) . '@example.com';
        // Password: password123
        $pass = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi';
        $phone = '+234' . rand(7000000000, 9099999999);
        $date = date('Y-m-d H:i:s', strtotime("-" . rand(1, 30) . " days"));

        // Check if exists
        $chk = $pdo->prepare("SELECT id FROM users WHERE email = ?");
        $chk->execute([$email]);
        if ($chk->rowCount() == 0) {
            $stmtUser->execute([$name, $email, $pass, $phone, $date]);
            $userIds[] = $pdo->lastInsertId();
            echo "Created User: $name ($email)\n";
        } else {
            $userIds[] = $chk->fetchColumn();
        }
    }

    // 3. Create Transactions
    if (!empty($userIds)) {
        $types = ['deposit', 'withdrawal', 'swap', 'transfer'];
        $statuses = ['completed', 'pending', 'failed'];
        $currencies = ['NGN', 'USD', 'GBP'];

        $stmtTx = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, status, recipient, reference, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");

        foreach ($userIds as $uid) {
            $numTx = rand(3, 8);
            for ($k = 0; $k < $numTx; $k++) {
                $type = $types[array_rand($types)];
                $amount = rand(5000, 500000);
                $curr = $currencies[array_rand($currencies)];
                $status = $statuses[array_rand($statuses)];
                $recipient = ($type == 'transfer') ? 'Bank Account ****' . rand(1000, 9999) : 'System';
                $ref = 'TX-' . strtoupper(uniqid());
                $date = date('Y-m-d H:i:s', strtotime("-" . rand(1, 30) . " days"));

                $stmtTx->execute([$uid, $type, $amount, $curr, $status, $recipient, $ref, $date]);
            }
        }
        echo "Created Transactions for all users.\n";
    }

    // 4. Create KYC Docs
    if (!empty($userIds)) {
        $stmtKyc = $pdo->prepare("INSERT INTO kyc_documents (user_id, doc_type, file_path, status, created_at) VALUES (?, ?, ?, ?, ?)");
        foreach ($userIds as $i => $uid) {
            if ($i % 3 == 0)
                continue; // Skip some users
            $status = ($i % 2 == 0) ? 'approved' : 'pending';
            $type = ($i % 2 == 0) ? 'passport' : 'nin';
            $path = 'uploads/kyc/dummy.jpg';
            $date = date('Y-m-d H:i:s');

            // Start simple
            $stmtKyc->execute([$uid, $type, $path, $status, $date]);
        }
        echo "Created KYC Documents.\n";
    }

    // 5. Create Referrals
    if (count($userIds) > 2) {
        $stmtRef = $pdo->prepare("INSERT INTO referrals (user_id, referrer_id, commission_earned, status, created_at) VALUES (?, ?, ?, ?, ?)");
        for ($j = 0; $j < 5; $j++) {
            $referrer = $userIds[array_rand($userIds)];
            $invitee = $userIds[array_rand($userIds)];
            if ($referrer == $invitee)
                continue;

            $comm = rand(500, 5000);
            $status = 'active';
            $date = date('Y-m-d H:i:s');
            $stmtRef->execute([$invitee, $referrer, $comm, $status, $date]);
        }
        echo "Created Referrals.\n";
    }

    echo "Seeding Completed Successfully!\n";
    echo "</pre>";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>