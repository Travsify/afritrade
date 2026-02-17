<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    
    Route::post('/transactions', [\App\Http\Controllers\Api\TransactionApiController::class, 'store']);
    Route::get('/transactions', [\App\Http\Controllers\Api\TransactionApiController::class, 'index']);
    Route::get('/transactions/{id}/receipt', [\App\Http\Controllers\Api\TransactionApiController::class, 'receipt']);

    // KYC
    // KYC
    Route::get('/kyc_status', [\App\Http\Controllers\Api\KycApiController::class, 'status']);
    Route::post('/kyc/verify', [\App\Http\Controllers\Api\KycApiController::class, 'verifyIdentity']);
    Route::post('/kyc/verify-business', [\App\Http\Controllers\Api\KycApiController::class, 'verifyBusiness']);


    // Chat
    Route::post('/support_chat', [\App\Http\Controllers\Api\ChatApiController::class, 'handle']); // Handles ?action=...

    // P2P Transfers
    Route::get('/transfer/lookup', [\App\Http\Controllers\Api\TransferApiController::class, 'lookup']);
    Route::post('/transfer/send', [\App\Http\Controllers\Api\TransferApiController::class, 'transfer'])->middleware('limit');

    // Supplier Payments (Yellow Card)
    Route::post('/payment/supplier', [\App\Http\Controllers\Api\TransferApiController::class, 'paySupplier']);

    // Crypto Funding
    Route::get('/crypto/address', [\App\Http\Controllers\Api\CryptoApiController::class, 'getAddress']);
    Route::post('/crypto/simulate_deposit', [\App\Http\Controllers\Api\CryptoApiController::class, 'simulateDeposit']); // Dev/Test endpoint

    // Virtual Accounts
    Route::get('/virtual-accounts', [\App\Http\Controllers\Api\VirtualAccountApiController::class, 'index']);
    Route::post('/virtual-accounts', [\App\Http\Controllers\Api\VirtualAccountApiController::class, 'store']);

    // Security (PIN)
    Route::post('/security/pin/set', [\App\Http\Controllers\Api\SecurityApiController::class, 'setPin']);
    Route::post('/security/pin/verify', [\App\Http\Controllers\Api\SecurityApiController::class, 'verifyPin']);
    Route::post('/security/pin/change', [\App\Http\Controllers\Api\SecurityApiController::class, 'changePin']);

    // Invoices
    Route::get('/invoices', [\App\Http\Controllers\Api\InvoiceApiController::class, 'index']);
    Route::post('/invoices', [\App\Http\Controllers\Api\InvoiceApiController::class, 'store']);
    Route::post('/invoices/{id}/pay', [\App\Http\Controllers\Api\InvoiceApiController::class, 'pay']);

    // Virtual Cards
    Route::get('/cards', [\App\Http\Controllers\Api\CardApiController::class, 'index']);
    Route::post('/cards', [\App\Http\Controllers\Api\CardApiController::class, 'store']);
    Route::post('/cards/{id}/fund', [\App\Http\Controllers\Api\CardApiController::class, 'fund']);
    Route::post('/cards/{id}/toggle-freeze', [\App\Http\Controllers\Api\CardApiController::class, 'toggleFreeze']);

    // Withdrawals (Local Payouts via Anchor)
    Route::post('/withdraw', [\App\Http\Controllers\Api\WithdrawalApiController::class, 'withdraw']);
    Route::get('/withdrawals', [\App\Http\Controllers\Api\WithdrawalApiController::class, 'history']);
    Route::get('/withdrawals/{reference}', [\App\Http\Controllers\Api\WithdrawalApiController::class, 'status']);

    // Notifications
    Route::get('/notifications', [\App\Http\Controllers\Api\NotificationApiController::class, 'index']);
    Route::get('/notifications/unread-count', [\App\Http\Controllers\Api\NotificationApiController::class, 'unreadCount']);

    // Wallets
    Route::get('/wallets', [\App\Http\Controllers\Api\WalletController::class, 'index']);
    Route::post('/wallets', [\App\Http\Controllers\Api\WalletController::class, 'store']);
    Route::post('/wallets/fund', [\App\Http\Controllers\Api\WalletController::class, 'fund']);
    Route::post('/wallets/transfer', [\App\Http\Controllers\Api\WalletController::class, 'transfer']);

    // Exchange Rate Alerts
    Route::get('/alerts', [\App\Http\Controllers\Api\RateAlertController::class, 'index']);
    Route::post('/alerts', [\App\Http\Controllers\Api\RateAlertController::class, 'store']);
    Route::delete('/alerts/{id}', [\App\Http\Controllers\Api\RateAlertController::class, 'destroy']);

    Route::post('/notifications/{id}/read', [\App\Http\Controllers\Api\NotificationApiController::class, 'markAsRead']);
    Route::post('/notifications/mark-all-read', [\App\Http\Controllers\Api\NotificationApiController::class, 'markAllAsRead']);
    Route::delete('/notifications/{id}', [\App\Http\Controllers\Api\NotificationApiController::class, 'destroy']);
});

Route::get('/banners', [\App\Http\Controllers\Api\GeneralApiController::class, 'banners']);

Route::post('/register', [\App\Http\Controllers\Api\AuthApiController::class, 'register']);
Route::post('/login', [\App\Http\Controllers\Api\AuthApiController::class, 'login']);

Route::get('/settings', [\App\Http\Controllers\Api\SettingsApiController::class, 'index']);

// Fintech Webhooks
Route::post('/webhooks/{provider}', [\App\Http\Controllers\Api\WebhookController::class, 'handle']);
