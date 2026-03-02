<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('beneficiaries')) {
            Schema::create('beneficiaries', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->string('name');
                $table->string('bank_name');
                $table->string('account_number', 20);
                $table->string('currency', 5)->default('NGN');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('bulk_payments')) {
            Schema::create('bulk_payments', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->string('batch_reference');
                $table->string('recipient_name');
                $table->string('account_number', 20);
                $table->string('bank_name');
                $table->decimal('amount', 15, 2);
                $table->string('currency', 5)->default('NGN');
                $table->string('status')->default('pending');
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('tax_reports')) {
            Schema::create('tax_reports', function (Blueprint $table) {
                $table->id();
                $table->foreignId('user_id')->constrained()->onDelete('cascade');
                $table->string('type'); // monthly, quarterly, annual
                $table->date('period_start');
                $table->date('period_end');
                $table->decimal('total_income', 15, 2)->default(0);
                $table->decimal('total_expenses', 15, 2)->default(0);
                $table->integer('transaction_count')->default(0);
                $table->string('status')->default('generated');
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('tax_reports');
        Schema::dropIfExists('bulk_payments');
        Schema::dropIfExists('beneficiaries');
    }
};
