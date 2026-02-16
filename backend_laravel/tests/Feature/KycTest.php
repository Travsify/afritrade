<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\PremblyService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Mockery;
use Tests\TestCase;

class KycTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_verify_identity()
    {
        $user = User::factory()->create(['kyc_tier' => 0]);
        
        // Mock Prembly response
        $this->mock(PremblyService::class, function ($mock) {
            $mock->shouldReceive('verifyIdentity')
                ->once()
                ->with('NIN', '12345678901')
                ->andReturn(['status' => true, 'data' => ['first_name' => 'John']]);
        });

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/kyc/verify', [
            'type' => 'NIN',
            'number' => '12345678901',
        ]);

        $response->assertStatus(200);
        
        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'kyc_tier' => 1,
            'verification_status' => 'verified',
        ]);
    }
}
