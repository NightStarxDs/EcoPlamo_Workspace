<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Warga;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PengurusController extends Controller
{
    /**
     * Mengambil daftar warga untuk verifikasi pendaftaran & pembayaran kas posko.
     * GET /api/pengurus/verifikasi-warga
     */
    public function getDaftarVerifikasi(Request $request)
    {
        $status = $request->query('status', 'menunggu'); // menunggu | terverifikasi | ditolak | semua
        $search = $request->query('search', '');

        $query = Warga::with(['user:id_pengguna,nama_lengkap,no_whatsapp,created_at']);

        if ($status !== 'semua' && in_array($status, ['menunggu', 'terverifikasi', 'ditolak'])) {
            $query->where('status_verifikasi', $status);
        }

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('nomor_tiket', 'LIKE', "%{$search}%")
                  ->orWhere('alamat', 'LIKE', "%{$search}%")
                  ->orWhereHas('user', function ($qu) use ($search) {
                      $qu->where('nama_lengkap', 'LIKE', "%{$search}%")
                         ->orWhere('no_whatsapp', 'LIKE', "%{$search}%");
                  });
            });
        }

        $list = $query->orderByDesc('id_pengguna')->get()->map(function ($w) {
            return [
                'id_pengguna'        => $w->id_pengguna,
                'nomor_tiket'        => $w->nomor_tiket ?? ('REG-' . str_pad($w->id_pengguna, 4, '0', STR_PAD_LEFT)),
                'nama_lengkap'       => $w->user->nama_lengkap ?? 'Warga Plamo',
                'no_whatsapp'        => $w->user->no_whatsapp ?? '-',
                'alamat'             => $w->alamat ?? '-',
                'tipe_hunian'        => $w->tipe_hunian ?? 'rumah_biasa',
                'status_verifikasi'  => $w->status_verifikasi ?? 'menunggu',
                'status_pembayaran'  => $w->status_pembayaran ?? 'belum_lunas',
                'uang_pendaftaran'   => (float) ($w->uang_pendaftaran ?? 10000),
                'catatan_verifikasi' => $w->catatan_verifikasi,
                'verified_at'        => $w->verified_at,
                'created_at'         => $w->user->created_at ? $w->user->created_at->format('d M Y, H:i') : null,
            ];
        });

        // Hitung statistik ringkasan
        $counts = [
            'menunggu'      => Warga::where('status_verifikasi', 'menunggu')->count(),
            'terverifikasi' => Warga::where('status_verifikasi', 'terverifikasi')->count(),
            'ditolak'       => Warga::where('status_verifikasi', 'ditolak')->count(),
        ];

        return response()->json([
            'success' => true,
            'counts'  => $counts,
            'data'    => $list,
        ]);
    }

    /**
     * Menyetujui pendaftaran warga dan mengkonfirmasi penerimaan uang kas posko.
     * POST /api/pengurus/verifikasi-warga/{id}/setujui
     */
    public function setujuiWarga(Request $request, $id_pengguna)
    {
        $warga = Warga::with('user')->find($id_pengguna);

        if (!$warga) {
            return response()->json([
                'success' => false,
                'message' => 'Data warga tidak ditemukan.',
            ], 404);
        }

        $petugas = $request->user();

        $warga->status_verifikasi = 'terverifikasi';
        $warga->status_pembayaran = 'lunas';
        $warga->uang_pendaftaran = $request->input('uang_pendaftaran', 10000.00);
        $warga->verified_at = now();
        $warga->verified_by = $petugas ? $petugas->id_pengguna : null;
        $warga->catatan_verifikasi = $request->input('catatan', 'Telah diverifikasi dan uang kas pendaftaran telah lunas.');
        $warga->save();

        return response()->json([
            'success' => true,
            'message' => "Warga {$warga->user->nama_lengkap} berhasil diverifikasi! Akun warga kini aktif.",
            'data'    => [
                'id_pengguna'       => $warga->id_pengguna,
                'status_verifikasi' => $warga->status_verifikasi,
                'status_pembayaran' => $warga->status_pembayaran,
                'uang_pendaftaran'  => (float) $warga->uang_pendaftaran,
                'verified_at'       => $warga->verified_at,
            ],
        ]);
    }

    /**
     * Menolak permohonan pendaftaran warga (misal: bukan warga setempat).
     * POST /api/pengurus/verifikasi-warga/{id}/tolak
     */
    public function tolakWarga(Request $request, $id_pengguna)
    {
        $validator = Validator::make($request->all(), [
            'alasan' => 'required|string|max:255',
        ], [
            'alasan.required' => 'Alasan penolakan wajib diisi agar warga mendapat kejelasan.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
            ], 422);
        }

        $warga = Warga::with('user')->find($id_pengguna);

        if (!$warga) {
            return response()->json([
                'success' => false,
                'message' => 'Data warga tidak ditemukan.',
            ], 404);
        }

        $petugas = $request->user();

        $warga->status_verifikasi = 'ditolak';
        $warga->catatan_verifikasi = $request->alasan;
        $warga->verified_at = now();
        $warga->verified_by = $petugas ? $petugas->id_pengguna : null;
        $warga->save();

        return response()->json([
            'success' => true,
            'message' => "Pendaftaran warga {$warga->user->nama_lengkap} telah ditolak.",
            'data'    => [
                'id_pengguna'        => $warga->id_pengguna,
                'status_verifikasi'  => $warga->status_verifikasi,
                'catatan_verifikasi' => $warga->catatan_verifikasi,
            ],
        ]);
    }
}
