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
        Schema::table('virtual_accounts', function (Blueprint $table) {
            $table->string('provider')->default('anchor')->after('id');
            $table->string('provider_id')->nullable()->after('provider');
            $table->json('provider_metadata')->nullable()->after('provider_id');
        });

        Schema::table('virtual_cards', function (Blueprint $table) {
            $table->string('provider')->default('anchor')->after('id');
            $table->string('provider_id')->nullable()->after('provider');
            $table->json('provider_metadata')->nullable()->after('provider_id');
        });

        Schema::table('transactions', function (Blueprint $table) {
            $table->string('provider')->nullable()->after('id');
            $table->string('exchange_rate_source')->nullable()->after('provider');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('virtual_accounts', function (Blueprint $table) {
            $table->dropColumn(['provider', 'provider_id', 'provider_metadata']);
        });

        Schema::table('virtual_cards', function (Blueprint $table) {
            $table->dropColumn(['provider', 'provider_id', 'provider_metadata']);
        });

        Schema::table('transactions', function (Blueprint $table) {
            $table->dropColumn(['provider', 'exchange_rate_source']);
        });
    }
};
