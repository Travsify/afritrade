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
        Schema::create('service_markups', function (Blueprint $table) {
            $table->id();
            $table->string('service_name')->unique(); // e.g., airtime, data, virtual_card, fx
            $table->enum('fee_type', ['fixed', 'percentage', 'both'])->default('fixed');
            $table->decimal('fixed_fee', 15, 2)->default(0.00);
            $table->decimal('percentage_fee', 5, 2)->default(0.00); // e.g., 2.50 for 2.5%
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('service_markups');
    }
};
