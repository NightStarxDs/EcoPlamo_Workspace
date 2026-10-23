<?php

namespace App\Http\Controllers;

use App\Models\KategoriSampah;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KatalogController extends Controller
{
    /**
     * Daftar katalog harga sampah.
     * GET /api/katalog?all=1
     */
    public function index(Request $request)
    {
        $query = KategoriSampah::query();

        // Jika tidak meminta semua (misal warga), hanya tampilkan yang aktif
        if (!$request->boolean('all')) {
            $query->where('status', 'aktif');
        }

        $items = $query->orderBy('status', 'asc') // aktif di atas
            ->orderBy('nama_kategori', 'asc')
            ->get()
            ->map(function (KategoriSampah $item) {
                return [
                    'id_kategori' => $item->id_kategori,
                    'nama' => $item->nama_kategori,
                    'deskripsi' => $item->deskripsi ?? '',
                    'harga' => (float) $item->harga_per_kg,
                    'satuan' => $item->satuan ?? 'kg',
                    'jenis' => $item->jenis ?? 'Anorganik',
                    'status' => $item->status ?? 'aktif',
                    'gambar_url' => $item->gambar ? url(Storage::url($item->gambar)) : null,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $items,
        ]);
    }

    /**
     * Tambah kategori sampah baru (Pengurus)
     * POST /api/pengurus/katalog
     */
    public function store(Request $request)
    {
        $user = $request->user();
        if (!$user || !$user->pengurus) {
            return response()->json(['success' => false, 'message' => 'Hanya pengurus yang dapat menambah kategori sampah.'], 403);
        }

        $request->validate([
            'nama_kategori' => 'required|string|max:100',
            'harga_per_kg' => 'required|numeric|min:0',
            'satuan' => 'nullable|string|max:20',
            'jenis' => 'nullable|string|max:50',
            'deskripsi' => 'nullable|string',
        ]);

        $item = KategoriSampah::create([
            'id_pengurus' => $user->id_pengguna,
            'nama_kategori' => $request->nama_kategori,
            'harga_per_kg' => $request->harga_per_kg,
            'satuan' => $request->satuan ?? 'kg',
            'jenis' => $request->jenis ?? 'Anorganik',
            'deskripsi' => $request->deskripsi ?? '',
            'status' => 'aktif',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Kategori sampah berhasil ditambahkan!',
            'data' => $item,
        ], 201);
    }

    /**
     * Update kategori sampah (Pengurus)
     * PUT/POST /api/pengurus/katalog/{id}
     */
    public function update(Request $request, $id)
    {
        $user = $request->user();
        if (!$user || !$user->pengurus) {
            return response()->json(['success' => false, 'message' => 'Hanya pengurus yang dapat mengubah kategori sampah.'], 403);
        }

        $item = KategoriSampah::find($id);
        if (!$item) {
            return response()->json(['success' => false, 'message' => 'Kategori sampah tidak ditemukan.'], 404);
        }

        $request->validate([
            'nama_kategori' => 'required|string|max:100',
            'harga_per_kg' => 'required|numeric|min:0',
            'satuan' => 'nullable|string|max:20',
            'jenis' => 'nullable|string|max:50',
            'deskripsi' => 'nullable|string',
        ]);

        $item->update([
            'nama_kategori' => $request->nama_kategori,
            'harga_per_kg' => $request->harga_per_kg,
            'satuan' => $request->satuan ?? $item->satuan,
            'jenis' => $request->jenis ?? $item->jenis,
            'deskripsi' => $request->deskripsi ?? $item->deskripsi,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Kategori sampah berhasil diperbarui!',
            'data' => $item,
        ]);
    }

    /**
     * Toggle status aktif / nonaktif (Pengurus)
     * POST /api/pengurus/katalog/{id}/toggle-status
     */
    public function toggleStatus(Request $request, $id)
    {
        $user = $request->user();
        if (!$user || !$user->pengurus) {
            return response()->json(['success' => false, 'message' => 'Hanya pengurus yang dapat mengubah status kategori sampah.'], 403);
        }

        $item = KategoriSampah::find($id);
        if (!$item) {
            return response()->json(['success' => false, 'message' => 'Kategori sampah tidak ditemukan.'], 404);
        }

        $newStatus = ($item->status === 'aktif') ? 'nonaktif' : 'aktif';
        $item->status = $newStatus;
        $item->save();

        return response()->json([
            'success' => true,
            'message' => 'Kategori "' . $item->nama_kategori . '" diubah menjadi ' . $newStatus . '.',
            'data' => $item,
        ]);
    }

    /**
     * Hapus kategori sampah (Pengurus)
     * DELETE /api/pengurus/katalog/{id}
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        if (!$user || !$user->pengurus) {
            return response()->json(['success' => false, 'message' => 'Hanya pengurus yang dapat menghapus kategori sampah.'], 403);
        }

        $item = KategoriSampah::find($id);
        if (!$item) {
            return response()->json(['success' => false, 'message' => 'Kategori sampah tidak ditemukan.'], 404);
        }

        // Cek apakah pernah dipakai di setoran
        $isUsed = \App\Models\DetailSetoran::where('id_kategori', $id)->exists();
        if ($isUsed) {
            // Jika pernah dipakai dalam transaksi, jadikan nonaktif agar riwayat setoran tetap valid
            $item->status = 'nonaktif';
            $item->save();
            return response()->json([
                'success' => true,
                'message' => 'Kategori ini pernah dipakai dalam riwayat setoran sehingga dinonaktifkan (arsip) dan tidak dihapus permanen.',
            ]);
        }

        $item->delete();
        return response()->json([
            'success' => true,
            'message' => 'Kategori sampah berhasil dihapus.',
        ]);
    }
}