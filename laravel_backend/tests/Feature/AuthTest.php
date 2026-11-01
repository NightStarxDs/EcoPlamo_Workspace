<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_login_with_valid_credentials(): void
    {
        User::factory()->create([
            'nama_lengkap' => 'Budi Warga',
            'no_whatsapp' => '081111111111',
            'password' => 'password123',
        ]);

        $response = $this->postJson('/api/login', [
            'no_whatsapp' => '081111111111',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'token',
                    'user' => [
                        'id_pengguna',
                        'nama_lengkap',
                        'no_whatsapp',
                        'role',
                    ],
                ],
            ]);
    }

    public function test_login_fails_with_invalid_credentials(): void
    {
        $response = $this->postJson('/api/login', [
            'no_whatsapp' => '081111111111',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'success' => false,
            ]);
    }

    public function test_login_validation_errors(): void
    {
        $response = $this->postJson('/api/login', []);

        $response->assertStatus(422)
            ->assertJsonStructure([
                'success',
                'message',
                'errors',
            ]);
    }

    public function test_registration_stores_housing_type_and_room_number_separately(): void
    {
        $response = $this->postJson('/api/register', [
            'nama_lengkap' => 'Budi Warga',
            'no_whatsapp' => '081111111111',
            'tipe_hunian' => 'kos_kontrakan',
            'alamat' => null,
            'nomor_hunian' => 'Pintu 3',
            'password' => 'password123',
        ]);

        $response->assertCreated();
        $this->assertDatabaseHas('warga', [
            'id_pengguna' => $response->json('data.id_pengguna'),
            'tipe_hunian' => 'kos_kontrakan',
            'alamat' => null,
            'nomor_hunian' => 'Pintu 3',
        ]);
    }

    public function test_registration_stores_regular_home_address_separately(): void
    {
        $response = $this->postJson('/api/register', [
            'nama_lengkap' => 'Siti Warga',
            'no_whatsapp' => '082222222222',
            'tipe_hunian' => 'rumah_biasa',
            'alamat' => 'Blok A No. 2',
            'nomor_hunian' => null,
            'password' => 'password123',
        ]);

        $response->assertCreated();
        $this->assertDatabaseHas('warga', [
            'id_pengguna' => $response->json('data.id_pengguna'),
            'tipe_hunian' => 'rumah_biasa',
            'alamat' => 'Blok A No. 2',
            'nomor_hunian' => null,
        ]);
    }
}
