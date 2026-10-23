<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\WargaController;
use App\Http\Controllers\PengurusController;
use App\Http\Controllers\DlhController;
use App\Http\Controllers\KatalogController;
use Illuminate\Support\Facades\Route;

Route::get('/tes-koneksi', function () {
    return response()->json([
        'status' => 'berhasil',
        'pesan' => 'Halo Warga Eco Plamo, koneksi ke Laravel sukses!'
    ]);
});

// Authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Katalog harga sampah
Route::get('/katalog', [KatalogController::class, 'index']);

// Informasi & Pengumuman posko
Route::get('/pengumuman', function () {
    $pengumuman = \App\Models\Pengumuman::orderByDesc('created_at')->get()->map(function ($p) {
        $kategori = 'Pengumuman';
        $lower = strtolower($p->judul);
        if (str_contains($lower, 'jadwal') || str_contains($lower, 'agenda') || str_contains($lower, 'kegiatan')) {
            $kategori = 'Agenda';
        } elseif (str_contains($lower, 'tips') || str_contains($lower, 'cara') || str_contains($lower, 'edukasi') || str_contains($lower, 'daur ulang')) {
            $kategori = 'Edukasi';
        }
        return [
            'id' => $p->id_pengumuman,
            'judul' => $p->judul,
            'isi' => $p->isi,
            'kategori' => $kategori,
            'tanggal' => \Carbon\Carbon::parse($p->created_at)->translatedFormat('d M Y'),
            'created_at' => $p->created_at,
        ];
    });

    return response()->json([
        'success' => true,
        'data' => $pengumuman,
    ]);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/profile/update', [AuthController::class, 'updateProfile']);
    Route::post('/profile/change-password', [AuthController::class, 'changePassword']);

    // Warga routes (Real Database)
    Route::get('/warga/dashboard', [WargaController::class, 'dashboard']);
    Route::post('/warga/pencairan', [WargaController::class, 'ajukanPencairan']);
    Route::get('/warga/mutasi', [WargaController::class, 'mutasiSaldo']);

    // Pengurus routes (Real Database)
    Route::get('/pengurus/dashboard', [PengurusController::class, 'dashboard']);
    Route::get('/pengurus/warga-list', [PengurusController::class, 'wargaList']);
    Route::get('/pengurus/warga-search', [PengurusController::class, 'wargaSearch']);
    Route::post('/pengurus/setoran', [PengurusController::class, 'catatSetoran']);
    Route::get('/pengurus/pencairan', [PengurusController::class, 'pencairanList']);
    Route::post('/pengurus/pencairan/{id}/validasi', [PengurusController::class, 'validasiPencairan']);
    Route::post('/pengurus/pengumuman', [PengurusController::class, 'buatPengumuman']);
    Route::delete('/pengurus/pengumuman/{id}', [PengurusController::class, 'hapusPengumuman']);
    Route::get('/pengurus/pengaturan-pencairan', [PengurusController::class, 'getPengaturanPencairan']);
    Route::post('/pengurus/pengaturan-pencairan', [PengurusController::class, 'simpanPengaturanPencairan']);
    Route::get('/pengurus/laporan', [PengurusController::class, 'laporanRekap']);

    // Pengurus Kelola Katalog Sampah (Tambah, Edit, Toggle Status, Hapus)
    Route::post('/pengurus/katalog', [KatalogController::class, 'store']);
    Route::put('/pengurus/katalog/{id}', [KatalogController::class, 'update']);
    Route::post('/pengurus/katalog/{id}/toggle-status', [KatalogController::class, 'toggleStatus']);
    Route::delete('/pengurus/katalog/{id}', [KatalogController::class, 'destroy']);

    // DLH routes (Real Database)
    Route::get('/dlh/dashboard', [DlhController::class, 'dashboard']);
    Route::get('/dlh/verifikasi', [DlhController::class, 'verifikasiList']);
    Route::post('/dlh/verifikasi', [DlhController::class, 'simpanVerifikasi']);
});