<?php
// backend/config/limits.php

class TransactionLimits {
    public static function getLimits($tier) {
        switch ($tier) {
            case 3: // Pro
                return [
                    'daily_limit' => 100000.00,
                    'single_tx_limit' => 20000.00,
                    'features' => ['all']
                ];
            case 2: // Verified
                return [
                    'daily_limit' => 10000.00,
                    'single_tx_limit' => 2000.00,
                    'features' => ['all']
                ];
            case 1: // Basic
            default:
                return [
                    'daily_limit' => 1000.00,
                    'single_tx_limit' => 200.00,
                    'features' => ['basic_swaps', 'wallet_funding']
                ];
        }
    }

    public static function checkLimit($pdo, $user_id, $amount_usd) {
        // 1. Get User Tier
        $stmt = $pdo->prepare("SELECT kyc_tier FROM users WHERE id = ?");
        $stmt->execute([$user_id]);
        $tier = $stmt->fetchColumn() ?: 1;

        $limits = self::getLimits($tier);

        // 2. Check Single TX Limit
        if ($amount_usd > $limits['single_tx_limit']) {
            return [
                'allowed' => false, 
                'message' => "Limit exceeded. Tier $tier single transaction limit is $" . number_format($limits['single_tx_limit'], 2)
            ];
        }

        // 3. Check Daily Limit
        $stmt = $pdo->prepare("SELECT COALESCE(SUM(amount), 0) FROM transactions 
                               WHERE user_id = ? AND status = 'completed' 
                               AND type = 'debit' AND created_at >= CURDATE()");
        $stmt->execute([$user_id]);
        $daily_sum = $stmt->fetchColumn();

        if (($daily_sum + $amount_usd) > $limits['daily_limit']) {
            return [
                'allowed' => false, 
                'message' => "Daily limit reached. Remaining: $" . number_format($limits['daily_limit'] - $daily_sum, 2)
            ];
        }

        return ['allowed' => true];
    }
}
?>
