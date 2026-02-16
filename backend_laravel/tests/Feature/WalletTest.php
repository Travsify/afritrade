<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class WalletTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Seed or setup basic needs if any
    }

    public function test_user_can_create_wallet()
    {
        $user = User::factory()->create();
        
        $response = $this->actingAs($user, 'sanctum')->postJson('/api/wallets', [
            'currency' => 'EUR',
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('wallets', [
            'user_id' => $user->id,
            'currency' => 'EUR',
            'balance' => 0,
        ]);
    }

    public function test_user_can_fund_wallet()
    {
        $user = User::factory()->create();
        $wallet = Wallet::create(['user_id' => $user->id, 'currency' => 'USD', 'balance' => 0]);

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/wallets/fund', [
            'wallet_id' => $wallet->id,
            'amount' => 100,
            'reference' => 'REF12345',
        ]);

        $response->assertStatus(200);
        $this->assertDatabaseHas('wallets', [
            'id' => $wallet->id,
            'balance' => 100,
        ]);
        $this->assertDatabaseHas('transactions', [
            'user_id' => $user->id,
            'amount' => 100,
            'type' => 'credit',
        ]);
    }
}
