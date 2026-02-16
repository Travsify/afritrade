<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\Admin;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        if (!Admin::where('email', 'admin@afritrad.com')->exists()) {
            Admin::create([
                'name' => 'Super Admin',
                'email' => 'admin@afritrad.com',
                'password' => Hash::make('password'),
            ]);
            $this->command->info('Admin user created: admin@afritrad.com / password');
        } else {
            $this->command->info('Admin user already exists.');
        }
    }
}
