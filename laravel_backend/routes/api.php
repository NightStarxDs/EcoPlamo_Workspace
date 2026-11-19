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

// Authentication routes (Public)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Katalog harga sampah (Public read)
Route::get('/katalog', [KatalogController::class, 'index']);

// Informasi & Pengumuman posko (Public read)
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

// Authenticated routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/profile/update', [AuthController::class, 'updateProfile']);
    Route::post('/profile/change-password', [AuthController::class, 'changePassword']);

    // ── Pengurus Routes ───────────────────────────────────────────────────────
    Route::prefix('pengurus')->group(function () {
        Route::get('/dashboard', [PengurusController::class, 'dashboard']);
        Route::get('/verifikasi-warga', [PengurusController::class, 'getDaftarVerifikasi']);
        Route::post('/verifikasi-warga/{id}/setujui', [PengurusController::class, 'setujuiWarga']);
        Route::post('/verifikasi-warga/{id}/tolak', [PengurusController::class, 'tolakWarga']);
        Route::get('/warga-list', [PengurusController::class, 'wargaList']);
        Route::get('/warga-search', [PengurusController::class, 'wargaSearch']);
        Route::post('/setoran', [PengurusController::class, 'catatSetoran']);
        Route::get('/pencairan', [PengurusController::class, 'pencairanList']);
        Route::post('/pencairan/{id}/validasi', [PengurusController::class, 'validasiPencairan']);
        Route::get('/pengaturan-pencairan', [PengurusController::class, 'getPengaturanPencairan']);
        Route::post('/pengaturan-pencairan', [PengurusController::class, 'simpanPengaturanPencairan']);
        Route::get('/laporan', [PengurusController::class, 'laporanRekap']);
        Route::post('/pengumuman', [PengurusController::class, 'buatPengumuman']);
        Route::delete('/pengumuman/{id}', [PengurusController::class, 'hapusPengumuman']);
        Route::post('/katalog', [KatalogController::class, 'store']);
        Route::put('/katalog/{id}', [KatalogController::class, 'update']);
        Route::post('/katalog/{id}/toggle-status', [KatalogController::class, 'toggleStatus']);
        Route::delete('/katalog/{id}', [KatalogController::class, 'destroy']);
    });

    // Top-level aliases for service compatibility
    Route::get('/warga/search', [PengurusController::class, 'wargaSearch']);
    Route::post('/setoran', [PengurusController::class, 'catatSetoran']);
    Route::get('/pencairan', [PengurusController::class, 'pencairanList']);
    Route::post('/pencairan/{id}/validasi', [PengurusController::class, 'validasiPencairan']);
    Route::post('/pengumuman', [PengurusController::class, 'buatPengumuman']);
    Route::delete('/pengumuman/{id}', [PengurusController::class, 'hapusPengumuman']);
    Route::post('/katalog', [KatalogController::class, 'store']);
    Route::put('/katalog/{id}', [KatalogController::class, 'update']);
    Route::post('/katalog/{id}/toggle-status', [KatalogController::class, 'toggleStatus']);
    Route::delete('/katalog/{id}', [KatalogController::class, 'destroy']);

    // ── Warga Routes ──────────────────────────────────────────────────────────
    Route::get('/warga/dashboard', [WargaController::class, 'dashboard']);
    Route::post('/warga/pencairan', [WargaController::class, 'ajukanPencairan']);
    Route::get('/warga/mutasi', [WargaController::class, 'mutasiSaldo']);

    // ── DLH Routes ────────────────────────────────────────────────────────────
    Route::get('/dlh/dashboard', [DlhController::class, 'dashboard']);
    Route::get('/dlh/verifikasi', [DlhController::class, 'verifikasiList']);
    Route::post('/dlh/verifikasi', [DlhController::class, 'simpanVerifikasi']);
});
