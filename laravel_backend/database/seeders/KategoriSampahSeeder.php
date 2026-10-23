<?php

namespace Database\Seeders;

use App\Models\KategoriSampah;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Data awal katalog harga sampah.
 */
class KategoriSampahSeeder extends Seeder
{
    public function run(): void
    {
        //Pastikan ada akun pengurus sebagai pemilik data katalog
        $pengurus = User::firstOrCreate(
            ['no_whatsapp' => '082222222222'],
            [
                'nama_lengkap' => 'Pak RT Pengurus',
                'password' => 'password123', // di-hash otomatis oleh model User
                'role' => 'pengurus',
            ]
        );

        //Pastikan pengurus tersebut juga ada di tabel pengurus_rtrw
        DB::table('pengurus_rtrw')->updateOrInsert(
            ['id_pengguna' => $pengurus->id_pengguna],
            ['jabatan' => 'Ketua Posko', 'created_at' => now(), 'updated_at' => now()]
        );

        //Data katalog awal (sesuai desain Figma)
        //Gambar disimpan di: storage/app/public/katalog/
        $katalog = [
            ['Botol Plastik PET', 'Bersih, kosong, dan dikempeskan', 2500, 'Kg', 'Botol', 'katalog/botol.jpg'],
            ['Kardus & Kertas Bekas', 'Kering dan diikat rapi', 1500, 'Kg', 'Kardus', 'katalog/kardus.jpg'],
            ['Minyak Jelantah', 'Disaring, tanpa ampas makanan', 4000, 'Liter', 'Minyak', 'katalog/minyak.jpg'],
            ['Besi & Kaleng', 'Bebas karat berlebih', 3000, 'Kg', 'Logam', 'katalog/logam.jpg'],
        ];

        foreach ($katalog as [$nama, $deskripsi, $harga, $satuan, $jenis, $gambar]) {
            KategoriSampah::updateOrCreate(
                ['nama_kategori' => $nama],
                [
                    'id_pengurus' => $pengurus->id_pengguna,
                    'deskripsi' => $deskripsi,
                    'harga_per_kg' => $harga,
                    'satuan' => $satuan,
                    'jenis' => $jenis,
                    'gambar' => $gambar,
                    'status' => 'aktif',
                ]
            );
        }
    }
}