<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('webhook_calls', function (Blueprint $blueprint) {
            $blueprint->id();
            $blueprint->string('provider');
            $blueprint->string('provider_reference')->unique();
            $blueprint->json('payload')->nullable();
            $blueprint->string('status')->default('received'); // received, processed, failed
            $blueprint->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('webhook_calls');
    }
};
