<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make('Illuminate\Contracts\Console\Kernel');
$kernel->bootstrap();

use App\Models\KategoriSampah;
use App\Models\User;
use App\Models\Warga;
use App\Models\Pengurus;

echo "========================================\n";
echo "EcoPlamo API Response Tester\n";
echo "========================================\n\n";

// Test 1: Katalog Data
echo "[1] Testing Kategori Sampah (Katalog) API Response\n";
echo "----------------------------------------\n";

$kategoriItems = KategoriSampah::where('status', 'aktif')
    ->orderBy('nama_kategori', 'asc')
    ->get()
    ->map(function ($item) {
        return [
            'id_kategori' => $item->id_kategori,
            'nama' => $item->nama_kategori,
            'deskripsi' => $item->deskripsi ?? '',
            'harga' => (float) $item->harga_per_kg,
            'satuan' => $item->satuan ?? 'kg',
            'jenis' => $item->jenis ?? 'Anorganik',
            'status' => $item->status ?? 'aktif',
            'gambar_url' => null,
        ];
    });

echo "Expected API Response Format:\n";
echo json_encode([
    'success' => true,
    'data' => $kategoriItems
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

echo "\n\nTotal Active Categories: " . $kategoriItems->count() . "\n";

// Test 2: User Data
echo "\n[2] Testing User Data\n";
echo "----------------------------------------\n";

$wargaUser = User::where('role', 'warga')->with('warga')->first();
if ($wargaUser) {
    echo "Warga User Example:\n";
    echo "  ID: {$wargaUser->id_pengguna}\n";
    echo "  Nama: {$wargaUser->nama_lengkap}\n";
    echo "  WhatsApp: {$wargaUser->no_whatsapp}\n";
    echo "  Role: {$wargaUser->role}\n";
    if ($wargaUser->warga) {
        echo "  Alamat: {$wargaUser->warga->alamat}\n";
        echo "  Saldo: Rp " . number_format($wargaUser->warga->total_saldo, 0, ',', '.') . "\n";
    }
}

echo "\n";

$pengurusUser = User::where('role', 'pengurus')->with('pengurus')->first();
if ($pengurusUser) {
    echo "Pengurus User Example:\n";
    echo "  ID: {$pengurusUser->id_pengguna}\n";
    echo "  Nama: {$pengurusUser->nama_lengkap}\n";
    echo "  WhatsApp: {$pengurusUser->no_whatsapp}\n";
    echo "  Role: {$pengurusUser->role}\n";
    if ($pengurusUser->pengurus) {
        echo "  Jabatan: {$pengurusUser->pengurus->jabatan}\n";
    }
}

// Test 3: Statistics
echo "\n[3] Database Statistics\n";
echo "----------------------------------------\n";

$totalUsers = User::count();
$totalWarga = Warga::count();
$totalPengurus = Pengurus::count();
$totalKategori = KategoriSampah::count();
$activeKategori = KategoriSampah::where('status', 'aktif')->count();

$totalSetoran = \App\Models\Setoran::count();
$totalNilaiSetoran = \App\Models\Setoran::sum('total_nilai_rp');
$totalBeratSetoran = \App\Models\Setoran::sum('total_berat_kg');

echo "Users:\n";
echo "  Total: $totalUsers\n";
echo "  Warga: $totalWarga\n";
echo "  Pengurus: $totalPengurus\n\n";

echo "Kategori Sampah:\n";
echo "  Total: $totalKategori\n";
echo "  Active: $activeKategori\n\n";

echo "Setoran (Deposits):\n";
echo "  Total Transaksi: $totalSetoran\n";
echo "  Total Nilai: Rp " . number_format($totalNilaiSetoran, 0, ',', '.') . "\n";
echo "  Total Berat: " . number_format($totalBeratSetoran, 2, ',', '.') . " Kg\n";

// Test 4: API Endpoint URLs
echo "\n[4] API Endpoints to Test\n";
echo "----------------------------------------\n";
echo "Public Endpoints:\n";
echo "  GET  http://127.0.0.1:8000/api/tes-koneksi\n";
echo "  GET  http://127.0.0.1:8000/api/katalog\n";
echo "  GET  http://127.0.0.1:8000/api/pengumuman\n";
echo "  POST http://127.0.0.1:8000/api/login\n";
echo "       Body: {\"no_whatsapp\":\"081111111111\",\"password\":\"password123\"}\n\n";

echo "Authenticated Endpoints (need token):\n";
echo "  GET  http://127.0.0.1:8000/api/me\n";
echo "  GET  http://127.0.0.1:8000/api/warga/dashboard\n";
echo "  GET  http://127.0.0.1:8000/api/pengurus/dashboard\n";

echo "\n========================================\n";
echo "✅ All Tests Complete!\n";
echo "========================================\n";
echo "\nNext Steps:\n";
echo "1. Start server: php artisan serve\n";
echo "2. Test endpoints with curl or Postman\n";
echo "3. Connect Flutter app to API\n";
echo "========================================\n";
