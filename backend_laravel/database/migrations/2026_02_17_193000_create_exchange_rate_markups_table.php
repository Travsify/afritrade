<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('exchange_rate_markups', function (Blueprint $table) {
            $table->id();
            $table->string('from_currency', 3);
            $table->string('to_currency', 3);
            $table->enum('markup_type', ['fixed', 'percentage', 'both'])->default('percentage');
            $table->decimal('fixed_markup', 15, 2)->default(0.00);
            $table->decimal('percentage_markup', 5, 2)->default(0.00); // e.g., 2.00 for 2%
            $table->boolean('is_active')->default(true);
            $table->unique(['from_currency', 'to_currency']);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exchange_rate_markups');
    }
};
