<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Admins Table
        Schema::create('admins', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('password');
            $table->timestamps();
        });

        // 2. Transactions Table
        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->index(); // Assuming relationship with users
            $table->string('type', 20); // credit, debit
            $table->decimal('amount', 15, 2);
            $table->string('currency', 10);
            $table->string('recipient', 100)->nullable();
            $table->string('status', 20); // pending, completed
            $table->string('reference')->nullable();
            $table->timestamps();
        });

        // 3. System Settings Table
        Schema::create('system_settings', function (Blueprint $table) {
            $table->string('setting_key', 50)->primary();
            $table->text('setting_value')->nullable();
            $table->timestamps();
        });

        // 4. KYC Documents Table
        Schema::create('kyc_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('doc_type', 50); // passport, id_card
            $table->string('file_path');
            $table->string('status', 20)->default('pending'); // pending, approved, rejected
            $table->text('rejection_reason')->nullable();
            $table->timestamps();
        });

        // 5. Referrals Table
        Schema::create('referrals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->comment('The new user');
            $table->foreignId('referrer_id')->comment('Who invited them');
            $table->decimal('commission_earned', 10, 2)->default(0.00);
            $table->string('status', 20)->default('active');
            $table->timestamps();
        });

        // 6. CMS Banners Table
        Schema::create('cms_banners', function (Blueprint $table) {
            $table->id();
            $table->string('title', 100)->nullable();
            $table->string('image_url');
            $table->string('link_url')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps(); // Created_at wasn't in legacy but good to have
        });

        // 7. CMS FAQs Table
        Schema::create('cms_faqs', function (Blueprint $table) {
            $table->id();
            $table->text('question');
            $table->text('answer');
            $table->string('category', 50)->nullable();
            $table->integer('ordering')->default(0);
            $table->timestamps();
        });

        // 8. Audit Logs Table
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_id')->nullable();
            $table->string('action', 100);
            $table->text('details')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->timestamps();
        });

        // 9. Chat Sessions Table
        Schema::create('chat_sessions', function (Blueprint $table) {
            $table->string('id', 50)->primary();
            $table->string('user_id', 50)->nullable();
            $table->string('status', 20)->default('ai');
            $table->timestamps();
        });

        // 10. Chat Messages Table
        Schema::create('chat_messages', function (Blueprint $table) {
            $table->id();
            $table->string('session_id', 50)->index();
            $table->string('sender', 20);
            $table->text('message');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('chat_messages');
        Schema::dropIfExists('chat_sessions');
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('cms_faqs');
        Schema::dropIfExists('cms_banners');
        Schema::dropIfExists('referrals');
        Schema::dropIfExists('kyc_documents');
        Schema::dropIfExists('system_settings');
        Schema::dropIfExists('transactions');
        Schema::dropIfExists('admins');
    }
};
