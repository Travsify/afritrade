<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// ─── Public Routes (with rate limiting) ───
Route::middleware('throttle:10,1')->group(function () {
    Route::post('/register', [\App\Http\Controllers\Api\AuthApiController::class, 'register']);
    Route::post('/login', [\App\Http\Controllers\Api\AuthApiController::class, 'login']);
    Route::post('/verify-otp', [\App\Http\Controllers\Api\AuthApiController::class, 'verifyOtp']);
});

Route::get('/banners', [\App\Http\Controllers\Api\GeneralApiController::class, 'banners']);
Route::get('/settings', [\App\Http\Controllers\Api\SettingsApiController::class, 'index']);
Route::get('/banks', [\App\Http\Controllers\Api\FlutterwaveController::class, 'getBanks']);

// ─── Fintech Webhooks (no auth, verified by signature) ───
Route::post('/webhooks/{provider}', [\App\Http\Controllers\Api\WebhookController::class, 'handle']);

// ─── Authenticated Routes ───
Route::middleware(['auth:sanctum', 'throttle:120,1'])->group(function () {
    // Profile & Auth
    Route::get('/user', function (Request $request) { return $request->user(); });
    Route::get('/profile', [\App\Http\Controllers\Api\AuthApiController::class, 'profile']);
    Route::put('/profile', [\App\Http\Controllers\Api\AuthApiController::class, 'updateProfile']);
    Route::post('/logout', [\App\Http\Controllers\Api\AuthApiController::class, 'logout']);

    // Transactions
    Route::post('/transactions', [\App\Http\Controllers\Api\TransactionApiController::class, 'store']);
    Route::get('/transactions', [\App\Http\Controllers\Api\TransactionApiController::class, 'index']);
    Route::get('/transactions/{id}/receipt', [\App\Http\Controllers\Api\TransactionApiController::class, 'receipt']);

    // KYC
    Route::get('/kyc_status', [\App\Http\Controllers\Api\KycApiController::class, 'status']);
    Route::post('/kyc/verify', [\App\Http\Controllers\Api\KycApiController::class, 'verifyIdentity']);
    Route::post('/kyc/verify-business', [\App\Http\Controllers\Api\KycApiController::class, 'verifyBusiness']);

    // Chat
    Route::post('/support_chat', [\App\Http\Controllers\Api\ChatApiController::class, 'handle']);

    // P2P Transfers (lookup is read-only, transfer needs PIN)
    Route::get('/transfer/lookup', [\App\Http\Controllers\Api\TransferApiController::class, 'lookup']);

    // Virtual Accounts
    Route::get('/virtual-accounts', [\App\Http\Controllers\Api\VirtualAccountApiController::class, 'index']);
    Route::post('/virtual-accounts', [\App\Http\Controllers\Api\VirtualAccountApiController::class, 'store']);

    // Security (PIN)
    Route::get('/security/pin/status', [\App\Http\Controllers\Api\SecurityApiController::class, 'checkPinStatus']);
    Route::post('/security/pin/set', [\App\Http\Controllers\Api\SecurityApiController::class, 'setPin']);
    Route::post('/security/pin/verify', [\App\Http\Controllers\Api\SecurityApiController::class, 'verifyPin']);
    Route::post('/security/pin/change', [\App\Http\Controllers\Api\SecurityApiController::class, 'changePin']);

    // Invoices
    Route::get('/invoices', [\App\Http\Controllers\Api\InvoiceApiController::class, 'index']);
    Route::post('/invoices', [\App\Http\Controllers\Api\InvoiceApiController::class, 'store']);

    // Virtual Cards (read-only)
    Route::get('/cards', [\App\Http\Controllers\Api\CardApiController::class, 'index']);

    // Withdrawals (history is read-only)
    Route::get('/withdrawals', [\App\Http\Controllers\Api\WithdrawalApiController::class, 'history']);
    Route::get('/withdrawals/{reference}', [\App\Http\Controllers\Api\WithdrawalApiController::class, 'status']);

    // Notifications
    Route::get('/notifications', [\App\Http\Controllers\Api\NotificationApiController::class, 'index']);
    Route::get('/notifications/unread-count', [\App\Http\Controllers\Api\NotificationApiController::class, 'unreadCount']);
    Route::post('/notifications/{id}/read', [\App\Http\Controllers\Api\NotificationApiController::class, 'markAsRead']);
    Route::post('/notifications/mark-all-read', [\App\Http\Controllers\Api\NotificationApiController::class, 'markAllAsRead']);
    Route::delete('/notifications/{id}', [\App\Http\Controllers\Api\NotificationApiController::class, 'destroy']);
    Route::post('/fcm/token', [\App\Http\Controllers\Api\NotificationApiController::class, 'updateFcmToken']);

    // Wallets (read-only, create)
    Route::get('/wallets', [\App\Http\Controllers\Api\WalletController::class, 'index']);
    Route::post('/wallets', [\App\Http\Controllers\Api\WalletController::class, 'store']);

    // Exchange Rate Alerts
    Route::get('/alerts', [\App\Http\Controllers\Api\RateAlertController::class, 'index']);
    Route::post('/alerts', [\App\Http\Controllers\Api\RateAlertController::class, 'store']);
    Route::delete('/alerts/{id}', [\App\Http\Controllers\Api\RateAlertController::class, 'destroy']);

    // Crypto
    Route::get('/crypto/address', [\App\Http\Controllers\Api\CryptoApiController::class, 'getAddress']);

    // Flutterwave Payments
    Route::post('/payments/initialize', [\App\Http\Controllers\Api\FlutterwaveController::class, 'initializePayment']);
    Route::get('/payments/verify/{reference}', [\App\Http\Controllers\Api\FlutterwaveController::class, 'verifyPayment']);

    // ─── PIN-Protected Financial Routes ───
    Route::middleware('verify.pin')->group(function () {
        Route::post('/transfer/send', [\App\Http\Controllers\Api\TransferApiController::class, 'transfer']);
        Route::post('/payment/supplier', [\App\Http\Controllers\Api\TransferApiController::class, 'paySupplier']);
        Route::post('/withdraw', [\App\Http\Controllers\Api\WithdrawalApiController::class, 'withdraw']);
        Route::post('/wallets/fund', [\App\Http\Controllers\Api\WalletController::class, 'fund']);
        Route::post('/wallets/transfer', [\App\Http\Controllers\Api\WalletController::class, 'transfer']);
        Route::post('/cards', [\App\Http\Controllers\Api\CardApiController::class, 'store']);
        Route::post('/cards/{id}/fund', [\App\Http\Controllers\Api\CardApiController::class, 'fund']);
        Route::post('/cards/{id}/toggle-freeze', [\App\Http\Controllers\Api\CardApiController::class, 'toggleFreeze']);
        Route::post('/invoices/{id}/pay', [\App\Http\Controllers\Api\InvoiceApiController::class, 'pay']);
    });
});
