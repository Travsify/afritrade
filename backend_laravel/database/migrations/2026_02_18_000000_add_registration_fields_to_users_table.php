<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('country')->nullable()->after('email');
            $table->string('business_name')->nullable()->after('country');
            $table->string('otp_code', 6)->nullable()->after('password');
            $table->timestamp('otp_expires_at')->nullable()->after('otp_code');
            $table->boolean('is_otp_verified')->default(false)->after('otp_expires_at');
            $table->string('kyb_status')->default('none')->after('verification_status');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'country',
                'business_name',
                'otp_code',
                'otp_expires_at',
                'is_otp_verified',
                'kyb_status'
            ]);
        });
    }
};
