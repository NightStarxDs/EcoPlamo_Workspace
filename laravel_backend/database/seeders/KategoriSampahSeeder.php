<?php

namespace Database\Seeders;

use App\Models\KategoriSampah;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Data katalog harga sampah sesuai Daftar Harga Nasabah
 * Unit Merapi Berkah Perum Merapi Subur – Periode: 1 Agustus 2026
 */
class KategoriSampahSeeder extends Seeder
{
    public function run(): void
    {
        // Pastikan ada akun pengurus sebagai pemilik data katalog
        $pengurus = User::firstOrCreate(
            ['no_whatsapp' => '082222222222'],
            [
                'nama_lengkap' => 'Pak RT Pengurus',
                'password'     => 'password123',
                'role'         => 'pengurus',
            ]
        );

        // Pastikan pengurus tersebut juga ada di tabel pengurus_rtrw
        DB::table('pengurus_rtrw')->updateOrInsert(
            ['id_pengguna' => $pengurus->id_pengguna],
            ['jabatan' => 'Ketua Posko', 'created_at' => now(), 'updated_at' => now()]
        );

        // ---------------------------------------------------------------
        // Daftar Harga Nasabah – Unit Merapi Berkah Perum Merapi Subur
        // Periode: 1 Agustus 2026
        // Kolom: [kode, nama, deskripsi, harga/kg, satuan, jenis]
        // ---------------------------------------------------------------
        $katalog = [
            // ── Plastik ─────────────────────────────────────────────────
            ['P1',  'Gelas Cup Bening Bersih',          'Gelas cup plastik bening dalam kondisi bersih',             1000, 'Kg', 'Plastik'],
            ['P2',  'Gelas Cup Bening Kotor',           'Gelas cup plastik bening dalam kondisi kotor',              500,  'Kg', 'Plastik'],
            ['P3',  'Botol Plastik Bersih Bening',      'Botol plastik bening, bersih, dan dikempiskan',             2800, 'Kg', 'Plastik'],
            ['P4',  'Botol Plastik Kotor',              'Botol plastik kotor atau berwarna (non-bening)',            1000, 'Kg', 'Plastik'],
            ['P7',  'Ember',                            'Ember plastik berbagai ukuran',                             500,  'Kg', 'Plastik'],
            ['P8',  'Tutup Galon',                      'Tutup galon air minum plastik',                             3000, 'Kg', 'Plastik'],
            ['P9',  'Tutup Botol',                      'Tutup botol plastik berbagai ukuran',                       1000, 'Kg', 'Plastik'],
            ['P10', 'Asoy Warna Warni (Tidak Hitam)',   'Kantong plastik warna warni, bukan hitam',                  2000, 'Kg', 'Plastik'],
            ['P18', 'Ember Hitam',                      'Ember plastik berwarna hitam',                              400,  'Kg', 'Plastik'],
            ['P20', 'Aki Bekas',                        'Aki / baterai kendaraan bekas',                             7000, 'Kg', 'Plastik'],
            ['P21', 'Kaset CD',                         'CD / DVD plastik bekas',                                    3000, 'Kg', 'Plastik'],
            ['P23', 'HDPE',                             'Plastik jenis HDPE (High-Density Polyethylene)',            500,  'Kg', 'Plastik'],
            ['P24', 'Gelas Cup Warna',                  'Gelas cup plastik berwarna',                                2500, 'Kg', 'Plastik'],

            // ── Logam / Kaleng ───────────────────────────────────────────
            ['C1',  'Aluminium Kaleng (Alka)',           'Kaleng aluminium minuman, bersih',                         21500, 'Kg', 'Logam'],
            ['C2',  'Besi Keropos',                      'Besi tua atau keropos',                                    1000,  'Kg', 'Logam'],
            ['C2',  'Kaleng Keropos',                    'Kaleng besi/timah dalam kondisi keropos',                  300,   'Kg', 'Logam'],
            ['C3',  'Aluminium Dapur / Panci (Alma)',    'Peralatan dapur aluminium seperti panci, wajan, dll.',     21000, 'Kg', 'Logam'],

            // ── Kertas ───────────────────────────────────────────────────
            ['K1',  'Kardus',                            'Kardus / dus bekas dalam kondisi kering',                  1000, 'Kg', 'Kertas'],
            ['K2',  'Buku Paket Pelajaran',              'Buku pelajaran / majalah bekas',                           500,  'Kg', 'Kertas'],
            ['K3',  'HVS',                               'Kertas HVS / fotokopi bekas',                              1000, 'Kg', 'Kertas'],
            ['K4',  'Kertas Padat',                      'Kertas tebal / karton padat',                              150,  'Kg', 'Kertas'],
            ['K4',  'Papan Telur',                       'Egg tray / nampan telur karton',                           100,  'Kg', 'Kertas'],
            ['K5',  'Koran Bekas',                       'Koran / surat kabar bekas',                                500,  'Kg', 'Kertas'],

            // ── Minyak ───────────────────────────────────────────────────
            ['Mj',  'Minyak Jelantah',                   'Minyak goreng bekas, disaring, tanpa ampas makanan',      2800, 'Kg', 'Minyak'],
        ];

        foreach ($katalog as [$kode, $nama, $deskripsi, $harga, $satuan, $jenis]) {
            KategoriSampah::updateOrCreate(
                ['nama_kategori' => $nama],
                [
                    'id_pengurus'  => $pengurus->id_pengguna,
                    'kode'         => $kode,
                    'deskripsi'    => $deskripsi,
                    'harga_per_kg' => $harga,
                    'satuan'       => $satuan,
                    'jenis'        => $jenis,
                    'gambar'       => null,
                    'status'       => 'aktif',
                ]
            );
        }
    }
}