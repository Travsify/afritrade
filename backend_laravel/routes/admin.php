<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;

// Auth Routes
Route::get('login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('login', [AuthController::class, 'login'])->name('login.submit');
Route::post('logout', [AuthController::class, 'logout'])->name('logout');

// Protected Routes
Route::middleware(['auth:admin'])->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    
    // User Management
    Route::resource('users', \App\Http\Controllers\Admin\UserController::class);

    // Transaction Management
    Route::resource('transactions', \App\Http\Controllers\Admin\TransactionController::class)->only(['index', 'update']);

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
    Route::resource('referrals', \App\Http\Controllers\Admin\ReferralController::class)->only(['index']);
    Route::resource('audit', \App\Http\Controllers\Admin\AuditLogController::class)->only(['index']);
    Route::resource('chat', \App\Http\Controllers\Admin\ChatController::class)->only(['index', 'show', 'update']);
    Route::resource('notifications', \App\Http\Controllers\Admin\NotificationController::class)->only(['index', 'store', 'destroy']);
});
