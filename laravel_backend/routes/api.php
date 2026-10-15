<?php

use App\Http\Controllers\AuthController;
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

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
});