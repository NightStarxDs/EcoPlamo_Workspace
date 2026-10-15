<?php

namespace Database\Seeders;

use App\Models\KategoriSampah;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Data awal katalog harga sampah.
 * Jalankan: php artisan db:seed --class=KategoriSampahSeeder
 */
class KategoriSampahSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Pastikan ada akun pengurus sebagai pemilik data katalog
        $pengurus = User::firstOrCreate(
            ['no_whatsapp' => '082222222222'],
            [
                'nama_lengkap' => 'Pak RT Pengurus',
                'password' => 'password123', // di-hash otomatis oleh model User
                'role' => 'pengurus',
            ]
        );

        // 2. Pastikan pengurus tersebut juga ada di tabel pengurus_rtrw
        DB::table('pengurus_rtrw')->updateOrInsert(
            ['id_pengguna' => $pengurus->id_pengguna],
            ['jabatan' => 'Ketua Posko', 'created_at' => now(), 'updated_at' => now()]
        );

        // 3. Data katalog awal (sesuai desain Figma)
        $katalog = [
            ['Botol Plastik PET', 'Bersih, kosong, dan dikempeskan', 2500, 'Kg', 'Botol'],
            ['Kardus & Kertas Bekas', 'Kering dan diikat rapi', 1500, 'Kg', 'Kardus'],
            ['Minyak Jelantah', 'Disaring, tanpa ampas makanan', 4000, 'Liter', 'Minyak'],
            ['Besi & Kaleng', 'Bebas karat berlebih', 3000, 'Kg', 'Logam'],
        ];

        foreach ($katalog as [$nama, $deskripsi, $harga, $satuan, $jenis]) {
            KategoriSampah::updateOrCreate(
                ['nama_kategori' => $nama],
                [
                    'id_pengurus' => $pengurus->id_pengguna,
                    'deskripsi' => $deskripsi,
                    'harga_per_kg' => $harga,
                    'satuan' => $satuan,
                    'jenis' => $jenis,
                    'status' => 'aktif',
                ]
            );
        }
    }
}