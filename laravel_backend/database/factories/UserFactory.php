<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            // Disesuaikan dengan nama kolom di migration/model
            'nama_lengkap' => fake()->name(), 
            
            // Menghasilkan format nomor telepon acak (misal: 081234567890)
            'no_whatsapp' => fake()->unique()->numerify('08##########'), 
            
            'whatsapp_verified_at' => now(),
            
            'password' => static::$password ??= Hash::make('password'),
            
            'role' => 'warga', 
            
            'remember_token' => Str::random(10),
        ];
    }

    /**
     * Indicate that the model's WhatsApp number should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'whatsapp_verified_at' => null, 
        ]);
    }
}