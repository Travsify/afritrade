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
        $email = env('ADMIN_DEFAULT_EMAIL', 'admin@afritrad.com');
        $password = env('ADMIN_DEFAULT_PASSWORD', 'password');

        if (!Admin::where('email', $email)->exists()) {
            Admin::create([
                'name' => 'Super Admin',
                'email' => $email,
                'password' => Hash::make($password),
            ]);
            $this->command->info("Admin user created: {$email}");
        } else {
            $this->command->info('Admin user already exists.');
        }
    }
}
