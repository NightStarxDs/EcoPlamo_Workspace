<?php

namespace App\Http\Controllers;

use App\Models\KategoriSampah;
use Illuminate\Support\Facades\Storage;

class KatalogController extends Controller
{
    /**
     * Daftar katalog harga sampah yang aktif.
     * GET /api/katalog
     */
    public function index()
    {
        $items = KategoriSampah::where('status', 'aktif')
            ->orderBy('nama_kategori')
            ->get()
            ->map(function (KategoriSampah $item) {
                return [
                    'id_kategori' => $item->id_kategori,
                    'nama' => $item->nama_kategori,
                    'deskripsi' => $item->deskripsi,
                    'harga' => (float) $item->harga_per_kg,
                    'satuan' => $item->satuan,
                    'jenis' => $item->jenis,
                    // null jika belum ada gambar; Flutter akan menampilkan placeholder
                    'gambar_url' => $item->gambar ? url(Storage::url($item->gambar)) : null,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $items,
        ]);
    }
}