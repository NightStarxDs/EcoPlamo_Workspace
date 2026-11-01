<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\WargaController;
use App\Http\Controllers\PengurusController;
use App\Http\Controllers\DlhController;
use App\Http\Controllers\KatalogController;
use App\Http\Controllers\PengurusController;
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

    // ── Pengurus: Verifikasi Warga ──────────────────────────────────────────
    Route::prefix('pengurus')->group(function () {
        Route::get('/verifikasi-warga', [PengurusController::class, 'getDaftarVerifikasi']);
        Route::post('/verifikasi-warga/{id}/setujui', [PengurusController::class, 'setujuiWarga']);
        Route::post('/verifikasi-warga/{id}/tolak', [PengurusController::class, 'tolakWarga']);
    });
});