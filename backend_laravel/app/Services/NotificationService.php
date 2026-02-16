<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;

class NotificationService
{
    /**
     * Send notification to a user
     */
    public function send(int $userId, string $type, string $title, string $message, array $data = [])
    {
        return Notification::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'message' => $message,
            'data' => $data
        ]);
    }

    /**
     * Send notification to multiple users
     */
    public function sendToMany(array $userIds, string $type, string $title, string $message, array $data = [])
    {
        $notifications = [];
        foreach ($userIds as $userId) {
            $notifications[] = [
                'user_id' => $userId,
                'type' => $type,
                'title' => $title,
                'message' => $message,
                'data' => json_encode($data),
                'is_read' => false,
                'created_at' => now(),
                'updated_at' => now()
            ];
        }
        Notification::insert($notifications);
    }

    /**
     * Send to all users
     */
    public function sendToAll(string $type, string $title, string $message, array $data = [])
    {
        $userIds = User::pluck('id')->toArray();
        $this->sendToMany($userIds, $type, $title, $message, $data);
    }

    // Convenience methods for common notification types

    public function transactionCredit($userId, $amount, $currency, $reference)
    {
        return $this->send($userId, 'transaction', 'Money Received', 
            "You received {$currency} {$amount}. Ref: {$reference}", 
            ['amount' => $amount, 'currency' => $currency, 'reference' => $reference, 'action' => 'credit']
        );
    }

    public function transactionDebit($userId, $amount, $currency, $reference)
    {
        return $this->send($userId, 'transaction', 'Payment Sent', 
            "You sent {$currency} {$amount}. Ref: {$reference}", 
            ['amount' => $amount, 'currency' => $currency, 'reference' => $reference, 'action' => 'debit']
        );
    }

    public function kycApproved($userId, $tier)
    {
        return $this->send($userId, 'kyc', 'KYC Approved', 
            "Congratulations! You've been upgraded to Tier {$tier}.", 
            ['tier' => $tier]
        );
    }

    public function kycRejected($userId, $reason)
    {
        return $this->send($userId, 'kyc', 'KYC Document Rejected', 
            "Your document was rejected: {$reason}", 
            ['reason' => $reason]
        );
    }

    public function securityAlert($userId, $action, $ip = null)
    {
        return $this->send($userId, 'security', 'Security Alert', 
            "A {$action} was performed on your account" . ($ip ? " from IP: {$ip}" : ""), 
            ['action' => $action, 'ip' => $ip]
        );
    }

    public function invoiceReceived($userId, $amount, $currency, $from)
    {
        return $this->send($userId, 'transaction', 'Invoice Received', 
            "You received an invoice for {$currency} {$amount} from {$from}", 
            ['amount' => $amount, 'currency' => $currency, 'from' => $from]
        );
    }

    public function withdrawalComplete($userId, $amount, $reference)
    {
        return $this->send($userId, 'transaction', 'Withdrawal Complete', 
            "Your withdrawal of ₦{$amount} has been processed. Ref: {$reference}", 
            ['amount' => $amount, 'reference' => $reference]
        );
    }
}
