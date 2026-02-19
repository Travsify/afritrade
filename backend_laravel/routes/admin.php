<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;

// Auth Routes
Route::get('login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('login', [AuthController::class, 'login'])
    ->middleware('throttle:10,1')
    ->name('login.submit');
Route::post('logout', [AuthController::class, 'logout'])->name('logout');

// Protected Routes
Route::middleware(['auth:admin'])->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    
    // User Management
    Route::resource('users', \App\Http\Controllers\Admin\UserController::class);

    // Transaction Management
    Route::get('transactions/{transaction}', [\App\Http\Controllers\Admin\TransactionController::class, 'show'])->name('transactions.show');
    Route::put('transactions/{transaction}', [\App\Http\Controllers\Admin\TransactionController::class, 'update'])->name('transactions.update');
    Route::post('transactions/{transaction}/requery', [\App\Http\Controllers\Admin\TransactionController::class, 'requery'])->name('transactions.requery');
    Route::resource('transactions', \App\Http\Controllers\Admin\TransactionController::class)->only(['index']);

    // Virtual Accounts
    Route::resource('virtual-accounts', \App\Http\Controllers\Admin\VirtualAccountController::class)->only(['index', 'show']);

    // Virtual Cards
    Route::post('virtual-cards/{virtualCard}/freeze', [\App\Http\Controllers\Admin\VirtualCardController::class, 'freeze'])->name('virtual-cards.freeze');
    Route::post('virtual-cards/{virtualCard}/unfreeze', [\App\Http\Controllers\Admin\VirtualCardController::class, 'unfreeze'])->name('virtual-cards.unfreeze');
    Route::resource('virtual-cards', \App\Http\Controllers\Admin\VirtualCardController::class)->only(['index', 'show']);

    // Swaps
    Route::resource('swaps', \App\Http\Controllers\Admin\SwapController::class)->only(['index', 'show']);

    // Bill Payments
    Route::get('bill-payments/settings', [\App\Http\Controllers\Admin\BillPaymentController::class, 'settings'])->name('bill-payments.settings');
    Route::resource('bill-payments', \App\Http\Controllers\Admin\BillPaymentController::class)->only(['index', 'show']);

    // Exchange Rates
    Route::get('exchange-rates', [\App\Http\Controllers\Admin\ExchangeRateController::class, 'index'])->name('exchange-rates.index');
    Route::post('exchange-rates', [\App\Http\Controllers\Admin\ExchangeRateController::class, 'update'])->name('exchange-rates.update');

    // KYC Management
    Route::resource('kyc', \App\Http\Controllers\Admin\KycController::class);

    // CMS Management
    Route::get('cms', [\App\Http\Controllers\Admin\CmsController::class, 'index'])->name('cms.index');
    Route::post('cms/banners', [\App\Http\Controllers\Admin\CmsController::class, 'storeBanner'])->name('cms.banners.store');
    Route::delete('cms/banners/{banner}', [\App\Http\Controllers\Admin\CmsController::class, 'deleteBanner'])->name('cms.banners.delete');
    Route::post('cms/faqs', [\App\Http\Controllers\Admin\CmsController::class, 'storeFaq'])->name('cms.faqs.store');
    Route::delete('cms/faqs/{faq}', [\App\Http\Controllers\Admin\CmsController::class, 'deleteFaq'])->name('cms.faqs.delete');

    // System Settings
    Route::get('settings', [\App\Http\Controllers\Admin\SettingController::class, 'index'])->name('settings.index');
    Route::post('settings', [\App\Http\Controllers\Admin\SettingController::class, 'update'])->name('settings.update');

    // Admin Management
    Route::resource('admins', \App\Http\Controllers\Admin\ManageAdminController::class)->only(['index', 'store', 'destroy']);

    // New Modules
    // Fintech Provider Monitoring
    Route::get('providers', [\App\Http\Controllers\Admin\ProviderController::class, 'index'])->name('providers.index');

    Route::resource('referrals', \App\Http\Controllers\Admin\ReferralController::class)->only(['index']);
    Route::resource('audit', \App\Http\Controllers\Admin\AuditLogController::class)->only(['index']);
    // Pricing & Markups
    Route::get('pricing', [\App\Http\Controllers\Admin\MarkupController::class, 'index'])->name('pricing.index');
    Route::put('pricing/{id}', [\App\Http\Controllers\Admin\MarkupController::class, 'update'])->name('pricing.update');

    Route::resource('chat', \App\Http\Controllers\Admin\ChatController::class)->only(['index', 'show', 'update']);
    Route::resource('notifications', \App\Http\Controllers\Admin\NotificationController::class)->only(['index', 'store', 'destroy']);
});
