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
        Schema::create('virtual_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('account_name');
            $table->string('account_number');
            $table->string('bank_name');
            $table->string('currency', 3); // USD, EUR, GBP, NGN
            $table->decimal('balance', 15, 2)->default(0.00);
            $table->string('label')->nullable();
            $table->string('status')->default('active'); // active, frozen
            
            // Banking Details (Optional depending on currency)
            $table->string('routing_number')->nullable();
            $table->string('iban')->nullable();
            $table->string('bic')->nullable();
            $table->string('sort_code')->nullable();
            
            // Provider Reference
            $table->string('reference')->unique()->comment('ID from Anchor/Provider');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('virtual_accounts');
    }
};
