<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Akun Testing untuk Warga
        User::factory()->create([
            'nama_lengkap' => 'Budi Warga',
            'no_whatsapp' => '081111111111',
            'role' => 'warga',
            'password' => Hash::make('password123'), // Password yang mudah diingat
        ]);

        // 2. Akun Testing untuk Pengurus RT
        User::factory()->create([
            'nama_lengkap' => 'Pak RT Pengurus',
            'no_whatsapp' => '082222222222',
            'role' => 'pengurus',
            'password' => Hash::make('password123'),
        ]);

        // 3. Akun Testing untuk Pihak DLH
        User::factory()->create([
            'nama_lengkap' => 'Pegawai DLH',
            'no_whatsapp' => '083333333333',
            'role' => 'dlh',
            'password' => Hash::make('password123'),
        ]);

        User::factory(10)->create(['role' => 'warga']);
    }
}