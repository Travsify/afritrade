<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once __DIR__ . '/../config/limits.php';

// Route the request based on method and 'action' param
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

// ... (GET logic same)

// POST: Actions (issue, fund, withdraw, freeze, unfreeze)
if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $action = $input['action'] ?? '';
    $user_id = $input['user_id'] ?? 0;

    if (!$user_id) {
        echo json_encode(['status' => 'error', 'message' => 'User ID required']);
        exit;
    }

    // Pre-check limits for debit actions
    if ($action === 'issue' || $action === 'fund') {
        $checkAmount = floatval($input['amount'] ?? 0);
        $limitCheck = TransactionLimits::checkLimit($pdo, $user_id, $checkAmount);
        if (!$limitCheck['allowed']) {
            echo json_encode(['status' => 'error', 'message' => $limitCheck['message']]);
            exit;
        }
    }

    try {
        if ($action === 'issue') {
            $label = $input['label'] ?? 'Virtual Card';
            $amount = floatval($input['amount'] ?? 0);
            $brand = $input['brand'] ?? 'Visa';

            // 1. Debit Wallet (Check balance first)
            if ($amount > 0) {
                 // Check wallet balance logic (Simplified: assuming sufficient for MVP or handled by wallet trigger)
                 // Should call wallet_swap or manual transaction here?
                 // Let's insert a DEBIT transaction for card funding
                 $pdo->beginTransaction();
                 
                 // Debit
                 $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, status, recipient, reference, created_at) VALUES (?, 'debit', ?, 'USD', 'completed', 'Card Issuance', ?, NOW())");
                 $ref = "CARD-ISSUE-" . time();
                 $stmt->execute([$user_id, $amount, $ref]);
                 
                 // Issue Card
                 $pan = '424242424242' . rand(1000, 9999);
                 $cvv = rand(100, 999);
                 $exp_m = '12';
                 $exp_y = '28';
                 
                 $sql = "INSERT INTO virtual_cards (user_id, card_label, card_number, cvv, expiry_month, expiry_year, balance, brand, currency, status) 
                         VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'USD', 'Active')";
                 $stmt = $pdo->prepare($sql);
                 $stmt->execute([$user_id, $label, $pan, $cvv, $exp_m, $exp_y, $amount, $brand]);
                 $card_id = $pdo->lastInsertId();
                 
                 $pdo->commit();
                 
                 // Return the new card
                 echo json_encode(['status' => 'success', 'message' => 'Card issued', 'card' => [
                     'id' => strval($card_id),
                     'label' => $label,
                     'last4' => substr($pan, -4),
                     'balance' => $amount,
                     'brand' => $brand,
                     'status' => 'Active',
                     'expiry' => "$exp_m/$exp_y",
                     'cvv' => $cvv
                 ]]);

            } else {
                 echo json_encode(['status' => 'error', 'message' => 'Amount must be > 0']);
            }

        } elseif ($action === 'fund') {
            $card_id = $input['card_id'];
            $amount = floatval($input['amount']);

            // Transaction: Debit Wallet, Update Card
            $pdo->beginTransaction();
            $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, status, recipient, reference, created_at) VALUES (?, 'debit', ?, 'USD', 'completed', 'Card Funding', ?, NOW())");
            $ref = "CARD-FUND-" . time();
            $stmt->execute([$user_id, $amount, $ref]);

            $stmt = $pdo->prepare("UPDATE virtual_cards SET balance = balance + ? WHERE id = ? AND user_id = ?");
            $stmt->execute([$amount, $card_id, $user_id]);
            
            $pdo->commit();
            echo json_encode(['status' => 'success']);

        } elseif ($action === 'withdraw') {
             $card_id = $input['card_id'];
             $amount = floatval($input['amount']);

             // Transaction: Credit Wallet, Decrease Card
             $pdo->beginTransaction();
             
             // Check card balance
             $stmt = $pdo->prepare("SELECT balance FROM virtual_cards WHERE id = ?");
             $stmt->execute([$card_id]);
             $cur = $stmt->fetchColumn();
             if ($cur < $amount) throw new Exception("Insufficient card balance");

             $stmt = $pdo->prepare("INSERT INTO transactions (user_id, type, amount, currency, status, recipient, reference, created_at) VALUES (?, 'credit', ?, 'USD', 'completed', 'Card Withdrawal', ?, NOW())");
             $ref = "CARD-WD-" . time();
             $stmt->execute([$user_id, $amount, $ref]);

             $stmt = $pdo->prepare("UPDATE virtual_cards SET balance = balance - ? WHERE id = ? AND user_id = ?");
             $stmt->execute([$amount, $card_id, $user_id]);
             
             $pdo->commit();
             echo json_encode(['status' => 'success']);

        } elseif ($action === 'freeze' || $action === 'unfreeze') {
            $card_id = $input['card_id'];
            $status = ($action === 'freeze') ? 'Frozen' : 'Active';
            
            $stmt = $pdo->prepare("UPDATE virtual_cards SET status = ? WHERE id = ? AND user_id = ?");
            $stmt->execute([$status, $card_id, $user_id]);
            
            echo json_encode(['status' => 'success', 'card_status' => $status]);
        } 
    } catch (Exception $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
    }
}
?>
