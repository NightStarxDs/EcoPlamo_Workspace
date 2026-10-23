<?php

namespace App\Http\Controllers;

use App\Models\Pengurus;
use App\Models\Warga;
use App\Models\Setoran;
use App\Models\KategoriSampah;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class DlhController extends Controller
{
    /**
     * Mengambil data real-time dashboard DLH (Dinas Lingkungan Hidup) dari database.
     */
    public function dashboard(Request $request)
    {
        $user = $request->user();
        $dlh = $user->dlh;

        $totalRtRw = Pengurus::count();
        $totalWarga = Warga::count();
        $totalSampahKg = (float) Setoran::sum('total_berat_kg');
        $totalKategori = KategoriSampah::where('status', 'aktif')->count();
        $totalLaporan = \App\Models\VerifikasiLaporan::count();
        $estimasiCo2Reduction = round($totalSampahKg * 1.5, 1);

        $minyakKg = (float) DB::table('detail_setoran')
            ->join('kategori_sampah', 'detail_setoran.id_kategori', '=', 'kategori_sampah.id_kategori')
            ->where('kategori_sampah.nama_kategori', 'like', '%jelantah%')
            ->sum('detail_setoran.berat_kg');

        $verifikasiMenunggu = \App\Models\VerifikasiLaporan::where('status', 'menunggu')->count();

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'nama_lengkap' => $user->nama_lengkap,
                    'nip_pegawai' => $dlh ? $dlh->nip_pegawai : '-',
                ],
                'overview' => [
                    'total_rt_rw' => $totalRtRw,
                    'total_warga' => $totalWarga,
                    'total_sampah_kg' => $totalSampahKg,
                    'co2_reduced_kg' => $estimasiCo2Reduction,
                ],
                'monitoring' => [
                    [
                        'title' => 'Reduksi Emisi',
                        'status' => number_format($estimasiCo2Reduction, 1, ',', '.') . ' kg CO2eq',
                        'description' => 'Estimasi dari ' . number_format($totalSampahKg, 1, ',', '.') . ' kg sampah terkelola',
                        'color' => 'primary',
                    ],
                    [
                        'title' => 'Pengolahan Minyak Jelantah',
                        'status' => number_format($minyakKg, 1, ',', '.') . ' Liter',
                        'description' => $minyakKg > 0 ? 'Terkumpul melalui bank sampah warga' : 'Belum ada setoran jelantah',
                        'color' => 'accentDark',
                    ],
                    [
                        'title' => 'Tingkat Daur Ulang',
                        'status' => number_format($totalSampahKg, 1, ',', '.') . ' Kg Terkelola',
                        'description' => $totalKategori . ' kategori aktif · ' . $verifikasiMenunggu . ' laporan menunggu verifikasi',
                        'color' => 'warningDark',
                    ],
                ],
                'data_terkini' => [
                    'laporan' => $totalLaporan,
                    'warga' => $totalWarga,
                    'kategori' => $totalKategori,
                ],
            ],
        ]);
    }

    /**
     * Mengambil daftar riwayat verifikasi laporan bulanan bank sampah oleh DLH.
     */
    public function verifikasiList(Request $request)
    {
        $verifikasis = \App\Models\VerifikasiLaporan::orderByDesc('tahun')
            ->orderByDesc('bulan')
            ->get()
            ->map(function ($v) {
                return [
                    'id_verifikasi' => $v->id_verifikasi,
                    'bulan' => $v->bulan,
                    'tahun' => $v->tahun,
                    'periode' => Carbon::createFromDate($v->tahun, $v->bulan, 1)->translatedFormat('F Y'),
                    'nip_pegawai' => $v->nip_pegawai,
                    'status' => $v->status,
                    'total_volume_kg' => (float) $v->total_volume_kg,
                    'total_insentif_rp' => (float) $v->total_insentif_rp,
                    'catatan' => $v->catatan,
                    'tanggal_verifikasi' => $v->tanggal_verifikasi ? Carbon::parse($v->tanggal_verifikasi)->translatedFormat('d M Y, H:i') : null,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $verifikasis,
        ]);
    }

    /**
     * Menyimpan atau mengonfirmasi verifikasi laporan bulanan oleh pegawai DLH.
     */
    public function simpanVerifikasi(Request $request)
    {
        $user = $request->user();
        $dlh = $user->dlh;

        if (!$dlh) {
            return response()->json(['success' => false, 'message' => 'Hanya petugas DLH yang memiliki akses verifikasi.'], 403);
        }

        $request->validate([
            'bulan' => 'required|integer|between:1,12',
            'tahun' => 'required|integer|min:2020',
            'status' => 'required|in:menunggu,diverifikasi,ditolak',
            'catatan' => 'nullable|string',
        ]);

        $bulan = (int) $request->bulan;
        $tahun = (int) $request->tahun;

        // Hitung real volume sampah bulan tersebut dari tabel setoran
        $totalVolume = (float) Setoran::whereMonth('tanggal', $bulan)
            ->whereYear('tanggal', $tahun)
            ->sum('total_berat_kg');

        // Standar insentif daur ulang pemerintah: Rp 500 per Kg terselamatkan
        $totalInsentif = (float) ($totalVolume * 500);

        $verifikasi = \App\Models\VerifikasiLaporan::updateOrCreate(
            [
                'bulan' => $bulan,
                'tahun' => $tahun,
            ],
            [
                'id_dlh' => $user->id_pengguna,
                'nip_pegawai' => $dlh->nip_pegawai ?? '198705122010011005',
                'status' => $request->status,
                'total_volume_kg' => $totalVolume,
                'total_insentif_rp' => $totalInsentif,
                'catatan' => $request->catatan ?? 'Laporan terverifikasi sesuai data timbangan bank sampah warga.',
                'tanggal_verifikasi' => Carbon::now(),
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Laporan periode ' . Carbon::createFromDate($tahun, $bulan, 1)->translatedFormat('F Y') . ' berhasil diverifikasi!',
            'data' => $verifikasi,
        ]);
    }
}
