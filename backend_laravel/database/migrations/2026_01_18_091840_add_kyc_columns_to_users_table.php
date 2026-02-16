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
        Schema::table('users', function (Blueprint $table) {
            // Check if columns exist before adding (since we have multiple kyc migrations in legacy list)
            if (!Schema::hasColumn('users', 'kyc_tier')) {
                $table->tinyInteger('kyc_tier')->default(0)->after('balance'); 
            }
            if (!Schema::hasColumn('users', 'verification_status')) {
                $table->string('verification_status', 20)->default('unverified')->after('kyc_tier');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
             if (Schema::hasColumn('users', 'kyc_tier')) {
                $table->dropColumn('kyc_tier');
             }
             if (Schema::hasColumn('users', 'verification_status')) {
                $table->dropColumn('verification_status');
             }
        });
    }
};
