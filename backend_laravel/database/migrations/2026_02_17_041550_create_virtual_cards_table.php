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
        Schema::create('virtual_cards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('label')->nullable();
            $table->string('card_number')->unique()->nullable(); // Nullable if card is being provisioned
            $table->string('last4', 4)->nullable();
            $table->string('name_on_card')->nullable();
            $table->string('expiration_date')->nullable(); // MM/YY
            $table->string('cvv')->nullable();
            $table->string('card_type')->default('virtual'); // virtual, physical
            $table->string('brand')->default('Visa'); // Visa, Mastercard
            $table->string('currency')->default('USD');
            $table->decimal('balance', 15, 2)->default(0.00);
            $table->string('status')->default('active'); // active, frozen, terminated
            $table->string('provider')->nullable();
            $table->string('provider_id')->unique()->nullable();
            $table->string('billing_address')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('virtual_cards');
    }
};
