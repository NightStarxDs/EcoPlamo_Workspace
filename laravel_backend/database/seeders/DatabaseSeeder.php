<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Warga;
use App\Models\Pengurus;
use App\Models\Dlh;
use App\Models\KategoriSampah;
use App\Models\Setoran;
use App\Models\DetailSetoran;
use App\Models\PengaturanPencairan;
use App\Models\Pencairan;
use App\Models\Pengumuman;
use App\Models\MutasiSaldo;
use App\Models\VerifikasiLaporan;
use Illuminate\Database\Seeder;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database with domain data that matches live APIs.
     * Password is stored as plain text here; User model hashed-cast hashes once.
     */
    public function run(): void
    {
        $now = Carbon::now();

        $pengurusUser = User::create([
            'nama_lengkap' => 'Pak RT Pengurus',
            'no_whatsapp' => '082222222222',
            'role' => 'pengurus',
            'password' => 'password123',
        ]);
        $pengurus = Pengurus::create([
            'id_pengguna' => $pengurusUser->id_pengguna,
            'jabatan' => 'Ketua RT 05 / RW 03',
        ]);

        $dlhUser = User::create([
            'nama_lengkap' => 'Pegawai DLH',
            'no_whatsapp' => '083333333333',
            'role' => 'dlh',
            'password' => 'password123',
        ]);
        $dlh = Dlh::create([
            'id_pengguna' => $dlhUser->id_pengguna,
            'nip_pegawai' => '198501012010011001',
        ]);

        $budiUser = User::create([
            'nama_lengkap' => 'Budi Warga',
            'no_whatsapp' => '081111111111',
            'role' => 'warga',
            'password' => 'password123',
        ]);
        $budiWarga = Warga::create([
            'id_pengguna' => $budiUser->id_pengguna,
            'alamat' => 'Blok A2 / No. 14',
            'total_saldo' => 0,
        ]);

        $wargaSeed = [
            ['Siti Aminah', '081299990001', 'Blok B1 / No. 05'],
            ['Joko Susilo', '081299990002', 'Blok A3 / No. 08'],
            ['Dewi Lestari', '081299990003', 'Blok C2 / No. 12'],
            ['Ahmad Fauzi', '081299990004', 'Blok B3 / No. 03'],
            ['Sri Wahyuni', '081299990005', 'Blok D1 / No. 07'],
        ];

        $wargaModels = ['Budi Warga' => $budiWarga];
        foreach ($wargaSeed as [$nama, $wa, $alamat]) {
            $u = User::create([
                'nama_lengkap' => $nama,
                'no_whatsapp' => $wa,
                'role' => 'warga',
                'password' => 'password123',
            ]);
            $wargaModels[$nama] = Warga::create([
                'id_pengguna' => $u->id_pengguna,
                'alamat' => $alamat,
                'total_saldo' => 0,
            ]);
        }

        $kategoriList = [
            ['Plastik PET', 'Botol PET bersih, dikempeskan', 2500, 'Kg', 'Botol'],
            ['Kardus Bekas', 'Kardus kering dan diikat rapi', 2000, 'Kg', 'Kardus'],
            ['Kaleng Bekas', 'Kaleng logam bebas karat berlebih', 8000, 'Kg', 'Logam'],
            ['Minyak Jelantah', 'Disaring, tanpa ampas makanan', 5000, 'Liter', 'Minyak'],
            ['Kertas & Arsip', 'Kertas kering tanpa plastik', 1500, 'Kg', 'Kardus'],
            ['Botol Kaca', 'Botol kaca utuh atau pecahan', 800, 'Kg', 'Botol'],
        ];

        $kategoriModels = [];
        foreach ($kategoriList as [$nama, $deskripsi, $harga, $satuan, $jenis]) {
            $kategoriModels[$nama] = KategoriSampah::create([
                'id_pengurus' => $pengurus->id_pengguna,
                'nama_kategori' => $nama,
                'deskripsi' => $deskripsi,
                'harga_per_kg' => $harga,
                'satuan' => $satuan,
                'jenis' => $jenis,
                'status' => 'aktif',
            ]);
        }

        $pengaturan = PengaturanPencairan::create([
            'id_pengurus' => $pengurus->id_pengguna,
            'target_minimal' => 50000,
            'tanggal_mulai' => $now->copy()->startOfMonth()->toDateString(),
            'tanggal_selesai' => $now->copy()->endOfMonth()->toDateString(),
            'created_at' => $now,
        ]);

        // Budi: setoran berurutan lalu pencairan, saldo akhir konsisten dengan mutasi.
        $this->catatSetoran($budiWarga, $pengurus, $now->copy()->subDays(14), [
            ['Kardus Bekas', 5.0],
            ['Minyak Jelantah', 1.9],
        ], $kategoriModels);

        $this->catatSetoran($budiWarga, $pengurus, $now->copy()->subDays(10), [
            ['Kaleng Bekas', 3.5],
        ], $kategoriModels);

        $this->catatPencairan(
            $budiWarga,
            $pengurus,
            $pengaturan,
            20000,
            'disetujui',
            $now->copy()->subDays(8),
            $now->copy()->subDays(7),
        );

        $this->catatSetoran($budiWarga, $pengurus, $now->copy()->subDays(5), [
            ['Plastik PET', 2.5],
            ['Kardus Bekas', 2.5],
        ], $kategoriModels);

        $this->catatSetoran($wargaModels['Siti Aminah'], $pengurus, $now->copy()->subDays(4), [
            ['Plastik PET', 8.0],
            ['Kardus Bekas', 12.0],
            ['Kaleng Bekas', 2.0],
        ], $kategoriModels);

        $this->catatSetoran($wargaModels['Joko Susilo'], $pengurus, $now->copy()->subDays(6), [
            ['Plastik PET', 6.0],
            ['Kertas & Arsip', 10.0],
        ], $kategoriModels);

        $this->catatSetoran($wargaModels['Dewi Lestari'], $pengurus, $now->copy()->subDays(3), [
            ['Minyak Jelantah', 4.0],
            ['Botol Kaca', 8.0],
        ], $kategoriModels);

        $this->catatSetoran($wargaModels['Ahmad Fauzi'], $pengurus, $now->copy()->subDays(2), [
            ['Kaleng Bekas', 1.5],
            ['Plastik PET', 3.0],
        ], $kategoriModels);

        $this->catatSetoran($wargaModels['Sri Wahyuni'], $pengurus, $now->copy()->subDays(1), [
            ['Kardus Bekas', 4.0],
            ['Kertas & Arsip', 3.0],
        ], $kategoriModels);

        // Antrean pencairan menunggu agar dashboard pengurus tidak kosong.
        $this->catatPencairan(
            $wargaModels['Siti Aminah'],
            $pengurus,
            $pengaturan,
            50000,
            'menunggu',
            $now->copy()->subHours(6),
            null,
        );

        Pengumuman::create([
            'id_pengurus' => $pengurus->id_pengguna,
            'judul' => 'Jadwal Penimbangan Sampah Anorganik',
            'isi' => 'Penimbangan sampah anorganik RT 05 / RW 03 dibuka setiap Sabtu pagi pukul 08:00 - 11:00 WIB di Posko Bank Sampah Eco Plamo. Bawa sampah yang sudah dipilah sesuai katalog harga.',
            'created_at' => $now->copy()->subDays(3),
        ]);
        Pengumuman::create([
            'id_pengurus' => $pengurus->id_pengguna,
            'judul' => 'Pencairan Saldo Periode ' . $now->translatedFormat('F Y'),
            'isi' => 'Warga yang telah mencapai saldo minimum Rp 50.000 dapat mengajukan pencairan tunai melalui aplikasi hingga akhir bulan. Validasi dilakukan pengurus di posko.',
            'created_at' => $now->copy()->subDay(),
        ]);
        Pengumuman::create([
            'id_pengurus' => $pengurus->id_pengguna,
            'judul' => 'Tips Memilah Plastik PET',
            'isi' => 'Cuci botol bekas, buang tutup metal jika ada, dan kempeskan botol agar muat lebih banyak. Plastik kotor menurunkan harga saat timbang.',
            'created_at' => $now->copy()->subDays(7),
        ]);
        Pengumuman::create([
            'id_pengurus' => $pengurus->id_pengguna,
            'judul' => 'Cara Menabung Minyak Jelantah',
            'isi' => 'Saring minyak bekas dari sisa makanan, simpan di botol tertutup, dan setor minimal 1 liter. Jangan campur dengan air atau oli mesin.',
            'created_at' => $now->copy()->subDays(9),
        ]);

        $bulanLalu = $now->copy()->subMonth();
        $volumeBulanIni = (float) Setoran::whereMonth('tanggal', $now->month)
            ->whereYear('tanggal', $now->year)
            ->sum('total_berat_kg');

        VerifikasiLaporan::create([
            'id_dlh' => $dlh->id_pengguna,
            'nip_pegawai' => $dlh->nip_pegawai,
            'bulan' => $bulanLalu->month,
            'tahun' => $bulanLalu->year,
            'status' => 'diverifikasi',
            'tanggal_verifikasi' => $now->copy()->subDays(12),
            'total_volume_kg' => 42.5,
            'total_insentif_rp' => 42.5 * 500,
            'catatan' => 'Laporan bulan sebelumnya sesuai data timbangan posko.',
        ]);
        VerifikasiLaporan::create([
            'id_dlh' => null,
            'nip_pegawai' => null,
            'bulan' => $now->month,
            'tahun' => $now->year,
            'status' => 'menunggu',
            'tanggal_verifikasi' => null,
            'total_volume_kg' => $volumeBulanIni,
            'total_insentif_rp' => $volumeBulanIni * 500,
            'catatan' => 'Menunggu verifikasi pegawai DLH untuk periode berjalan.',
        ]);
    }

    /**
     * @param  array<int, array{0: string, 1: float}>  $items
     * @param  array<string, KategoriSampah>  $kategoriModels
     */
    private function catatSetoran(
        Warga $warga,
        Pengurus $pengurus,
        Carbon $tanggal,
        array $items,
        array $kategoriModels,
    ): Setoran {
        $totalBerat = 0.0;
        $totalNilai = 0.0;
        $details = [];

        foreach ($items as [$namaKategori, $berat]) {
            $kategori = $kategoriModels[$namaKategori];
            $harga = (float) $kategori->harga_per_kg;
            $subtotal = round($berat * $harga, 2);
            $totalBerat += $berat;
            $totalNilai += $subtotal;
            $details[] = [
                'id_kategori' => $kategori->id_kategori,
                'berat_kg' => $berat,
                'harga_saat_setor' => $harga,
                'subtotal_rp' => $subtotal,
            ];
        }

        $setoran = Setoran::create([
            'id_warga' => $warga->id_pengguna,
            'id_pengurus' => $pengurus->id_pengguna,
            'tanggal' => $tanggal->toDateString(),
            'total_berat_kg' => $totalBerat,
            'total_nilai_rp' => $totalNilai,
            'created_at' => $tanggal,
            'updated_at' => $tanggal,
        ]);

        foreach ($details as $d) {
            DetailSetoran::create([
                'id_setoran' => $setoran->id_setoran,
                ...$d,
            ]);
        }

        $warga->total_saldo = (float) $warga->total_saldo + $totalNilai;
        $warga->save();

        MutasiSaldo::create([
            'id_warga' => $warga->id_pengguna,
            'id_setoran' => $setoran->id_setoran,
            'id_pencairan' => null,
            'tipe' => 'kredit',
            'nominal' => $totalNilai,
            'saldo_setelah_mutasi' => $warga->total_saldo,
            'created_at' => $tanggal,
            'updated_at' => $tanggal,
        ]);

        return $setoran;
    }

    private function catatPencairan(
        Warga $warga,
        Pengurus $pengurus,
        PengaturanPencairan $pengaturan,
        float $nominal,
        string $status,
        Carbon $pengajuan,
        ?Carbon $validasi,
    ): Pencairan {
        $pencairan = Pencairan::create([
            'id_warga' => $warga->id_pengguna,
            'id_pengaturan' => $pengaturan->id_pengaturan,
            'id_pengurus_validasi' => $status === 'menunggu' ? null : $pengurus->id_pengguna,
            'nominal_pencairan' => $nominal,
            'status' => $status,
            'tanggal_pengajuan' => $pengajuan,
            'tanggal_validasi' => $validasi,
        ]);

        if ($status === 'disetujui') {
            $warga->total_saldo = (float) $warga->total_saldo - $nominal;
            $warga->save();

            MutasiSaldo::create([
                'id_warga' => $warga->id_pengguna,
                'id_setoran' => null,
                'id_pencairan' => $pencairan->id_pencairan,
                'tipe' => 'debit',
                'nominal' => $nominal,
                'saldo_setelah_mutasi' => $warga->total_saldo,
                'created_at' => $validasi ?? $pengajuan,
                'updated_at' => $validasi ?? $pengajuan,
            ]);
        }

        return $pencairan;
    }
}
