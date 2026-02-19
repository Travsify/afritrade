<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create the default admin user
        $this->call(AdminSeeder::class);
        $this->call(ServiceMarkupSeeder::class);
        $this->call(ExchangeRateMarkupSeeder::class);
    }
}
