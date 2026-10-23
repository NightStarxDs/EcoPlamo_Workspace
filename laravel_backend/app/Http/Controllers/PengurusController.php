<?php

namespace App\Http\Controllers;

use App\Models\Warga;
use App\Models\Setoran;
use App\Models\DetailSetoran;
use App\Models\Pencairan;
use App\Models\KategoriSampah;
use App\Models\Pengumuman;
use App\Models\MutasiSaldo;
use App\Models\User;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class PengurusController extends Controller
{
    /**
     * Mengambil data real-time dashboard pengurus RT/RW dari database.
     */
    public function dashboard(Request $request)
    {
        $user = $request->user();
        $pengurus = $user->pengurus;

        // 1. Overview Badges
        $totalWarga = Warga::count();
        $totalSampahKg = (float) Setoran::sum('total_berat_kg');
        $totalSetoran = Setoran::count();
        $pencairanMenunggu = Pencairan::where('status', 'menunggu')->count();

        // 2. Aktivitas Terkini (Gabungan Setoran Terbaru dan Warga Baru)
        $recentSetorans = Setoran::with(['warga.user'])
            ->orderByDesc('tanggal')
            ->orderByDesc('id_setoran')
            ->limit(4)
            ->get();

        $aktivitas = [];
        foreach ($recentSetorans as $s) {
            $wargaNama = $s->warga && $s->warga->user ? $s->warga->user->nama_lengkap : 'Warga';
            $aktivitas[] = [
                'type' => 'setoran',
                'title' => 'Setoran Sampah',
                'description' => $wargaNama . ' (' . number_format($s->total_berat_kg, 1, ',', '.') . ' Kg)',
                'value' => '+Rp ' . number_format($s->total_nilai_rp, 0, ',', '.'),
                'time' => Carbon::parse($s->tanggal)->diffForHumans(),
                'icon' => 'delete_outline_rounded',
            ];
        }

        // Tambahkan warga baru terdaftar jika ada
        $recentWarga = Warga::with('user')->orderByDesc('id_pengguna')->limit(2)->get();
        foreach ($recentWarga as $rw) {
            if ($rw->user) {
                $aktivitas[] = [
                    'type' => 'warga_baru',
                    'title' => 'Warga Baru Terdaftar',
                    'description' => $rw->user->nama_lengkap . ' (' . ($rw->alamat ?? 'Warga') . ')',
                    'value' => 'Terverifikasi',
                    'time' => $rw->created_at ? Carbon::parse($rw->created_at)->diffForHumans() : 'Baru saja',
                    'icon' => 'person_add',
                ];
            }
        }

        // 3. Statistik Breakdown Per Kategori Sampah
        $kategoriStats = DetailSetoran::select('id_kategori', DB::raw('SUM(berat_kg) as total_berat'), DB::raw('SUM(subtotal_rp) as total_rp'))
            ->groupBy('id_kategori')
            ->with('kategori')
            ->get()
            ->map(function ($item) use ($totalSampahKg) {
                $nama = $item->kategori ? $item->kategori->nama_kategori : 'Lainnya';
                $berat = (float) $item->total_berat;
                $persen = $totalSampahKg > 0 ? round(($berat / $totalSampahKg) * 100, 1) : 0;
                return [
                    'kategori' => $nama,
                    'total_kg' => $berat,
                    'total_rp' => (float) $item->total_rp,
                    'persentase' => $persen,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'nama_lengkap' => $user->nama_lengkap,
                    'jabatan' => $pengurus ? $pengurus->jabatan : 'Ketua RT 05 / RW 03',
                ],
                'overview' => [
                    'total_warga' => $totalWarga,
                    'total_sampah_kg' => $totalSampahKg,
                    'total_setoran' => $totalSetoran,
                    'pencairan_menunggu' => $pencairanMenunggu,
                ],
                'aktivitas' => $aktivitas,
                'statistik_kategori' => $kategoriStats,
            ],
        ]);
    }

    /**
     * Mengambil daftar seluruh warga dari database.
     */
    public function wargaList()
    {
        $wargas = Warga::with(['user', 'setoran'])->get()->map(function ($w) {
            return [
                'id_pengguna' => $w->id_pengguna,
                'nama_lengkap' => $w->user ? $w->user->nama_lengkap : 'Warga',
                'no_whatsapp' => $w->user ? $w->user->no_whatsapp : '-',
                'alamat' => $w->alamat ?? '-',
                'total_saldo' => (float) $w->total_saldo,
                'total_setoran_kg' => (float) $w->setoran->sum('total_berat_kg'),
                'jumlah_setoran' => $w->setoran->count(),
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $wargas,
        ]);
    }

    /**
     * Pencarian warga: baik lewat teks manual maupun decode scan QR (ID atau WhatsApp).
     */
    public function wargaSearch(Request $request)
    {
        $q = trim((string) $request->get('q', ''));

        if ($q === '') {
            return response()->json(['success' => true, 'data' => []]);
        }

        $resolvedId = null;
        if (preg_match('/^ECOPLAMO:WARGA:(\d+)/i', $q, $matches)) {
            $resolvedId = (int) $matches[1];
        } elseif (preg_match('/^ECP-(\d+)/i', $q, $matches)) {
            $resolvedId = (int) $matches[1];
        }

        if ($resolvedId) {
            $warga = Warga::with('user')->find($resolvedId);
            if ($warga && $warga->user) {
                return response()->json([
                    'success' => true,
                    'data' => [[
                        'id_pengguna' => $warga->id_pengguna,
                        'nama_lengkap' => $warga->user->nama_lengkap,
                        'no_whatsapp' => $warga->user->no_whatsapp,
                        'alamat' => $warga->alamat ?? '-',
                        'total_saldo' => (float) $warga->total_saldo,
                    ]],
                ]);
            }
        }

        $wargas = Warga::with('user')
            ->where(function ($outer) use ($q) {
                $outer->whereHas('user', function ($query) use ($q) {
                    $query->where('nama_lengkap', 'like', "%{$q}%")
                          ->orWhere('no_whatsapp', 'like', "%{$q}%");
                })->orWhere('alamat', 'like', "%{$q}%");
            })
            ->limit(15)
            ->get()
            ->map(function ($w) {
                return [
                    'id_pengguna' => $w->id_pengguna,
                    'nama_lengkap' => $w->user ? $w->user->nama_lengkap : 'Warga',
                    'no_whatsapp' => $w->user ? $w->user->no_whatsapp : '-',
                    'alamat' => $w->alamat ?? '-',
                    'total_saldo' => (float) $w->total_saldo,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $wargas,
        ]);
    }

    /**
     * Pengurus mencatat setoran penimbangan sampah warga (ERD: SETORAN -> DETAIL SETORAN -> MUTASI SALDO).
     */
    public function catatSetoran(Request $request)
    {
        $user = $request->user();
        $pengurus = $user->pengurus;

        $request->validate([
            'id_warga' => 'required|exists:warga,id_pengguna',
            'items' => 'required|array|min:1',
            'items.*.id_kategori' => 'required|exists:kategori_sampah,id_kategori',
            'items.*.berat_kg' => 'required|numeric|min:0.01',
        ], [
            'id_warga.required' => 'Warga wajib dipilih.',
            'items.required' => 'Minimal harus ada 1 item sampah yang ditimbang.',
            'items.*.berat_kg.min' => 'Berat sampah minimal 0.01 Kg.',
        ]);

        return DB::transaction(function () use ($request, $user) {
            $warga = Warga::findOrFail($request->id_warga);

            $totalBerat = 0;
            $totalNilai = 0;
            $detailsData = [];

            foreach ($request->items as $item) {
                $kategori = KategoriSampah::findOrFail($item['id_kategori']);
                $berat = (float) $item['berat_kg'];
                $harga = (float) $kategori->harga_per_kg;
                $subtotal = round($berat * $harga, 2);

                $totalBerat += $berat;
                $totalNilai += $subtotal;

                $detailsData[] = [
                    'id_kategori' => $kategori->id_kategori,
                    'berat_kg' => $berat,
                    'harga_saat_setor' => $harga,
                    'subtotal_rp' => $subtotal,
                ];
            }

            // 1. Simpan Header Setoran
            $setoran = Setoran::create([
                'id_warga' => $warga->id_pengguna,
                'id_pengurus' => $user->id_pengguna,
                'tanggal' => Carbon::today(),
                'total_berat_kg' => $totalBerat,
                'total_nilai_rp' => $totalNilai,
            ]);

            // 2. Simpan Detail Setoran
            foreach ($detailsData as $d) {
                DetailSetoran::create([
                    'id_setoran' => $setoran->id_setoran,
                    'id_kategori' => $d['id_kategori'],
                    'berat_kg' => $d['berat_kg'],
                    'harga_saat_setor' => $d['harga_saat_setor'],
                    'subtotal_rp' => $d['subtotal_rp'],
                ]);
            }

            // 3. Tambah Saldo Warga
            $warga->total_saldo = (float) $warga->total_saldo + $totalNilai;
            $warga->save();

            // 4. Catat Mutasi Saldo (Kredit)
            MutasiSaldo::create([
                'id_warga' => $warga->id_pengguna,
                'id_setoran' => $setoran->id_setoran,
                'id_pencairan' => null,
                'tipe' => 'kredit',
                'nominal' => $totalNilai,
                'saldo_setelah_mutasi' => $warga->total_saldo,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Setoran sampah berhasil disimpan! Saldo warga bertambah Rp ' . number_format($totalNilai, 0, ',', '.'),
                'data' => [
                    'id_setoran' => $setoran->id_setoran,
                    'total_berat_kg' => $totalBerat,
                    'total_nilai_rp' => $totalNilai,
                    'saldo_terbaru' => (float) $warga->total_saldo,
                ],
            ], 201);
        });
    }

    /**
     * Mengambil daftar antrean pengajuan pencairan saldo warga.
     */
    public function pencairanList(Request $request)
    {
        $status = $request->get('status');

        $query = Pencairan::with(['warga.user', 'pengurusValidasi.user'])
            ->orderByDesc('created_at');

        if ($status && in_array($status, ['menunggu', 'disetujui', 'ditolak'])) {
            $query->where('status', $status);
        }

        $pencairans = $query->limit(30)->get()->map(function ($p) {
            return [
                'id_pencairan' => $p->id_pencairan,
                'id_warga' => $p->id_warga,
                'nama_warga' => $p->warga && $p->warga->user ? $p->warga->user->nama_lengkap : 'Warga',
                'no_whatsapp' => $p->warga && $p->warga->user ? $p->warga->user->no_whatsapp : '-',
                'alamat' => $p->warga ? ($p->warga->alamat ?? '-') : '-',
                'nominal_pencairan' => (float) $p->nominal_pencairan,
                'status' => $p->status,
                'tanggal_pengajuan' => $p->tanggal_pengajuan ? Carbon::parse($p->tanggal_pengajuan)->translatedFormat('d M Y, H:i') : '-',
                'tanggal_validasi' => $p->tanggal_validasi ? Carbon::parse($p->tanggal_validasi)->translatedFormat('d M Y, H:i') : null,
                'validasi_oleh' => $p->pengurusValidasi && $p->pengurusValidasi->user ? $p->pengurusValidasi->user->nama_lengkap : null,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $pencairans,
        ]);
    }

    /**
     * Memvalidasi pengajuan pencairan saldo warga (Setujui / Tolak).
     */
    public function validasiPencairan(Request $request, $id)
    {
        $user = $request->user();

        $request->validate([
            'aksi' => 'required|in:setujui,tolak',
        ], [
            'aksi.required' => 'Aksi validasi (setujui / tolak) wajib ditentukan.',
        ]);

        return DB::transaction(function () use ($request, $user, $id) {
            $pencairan = Pencairan::with('warga')->findOrFail($id);

            if ($pencairan->status !== 'menunggu') {
                return response()->json([
                    'success' => false,
                    'message' => 'Pengajuan pencairan ini sudah diproses sebelumnya (' . $pencairan->status . ').',
                ], 422);
            }

            $warga = $pencairan->warga;

            if ($request->aksi === 'setujui') {
                // Pastikan saldo warga saat ini cukup
                if ($warga->total_saldo < $pencairan->nominal_pencairan) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Saldo warga tidak mencukupi (Tersisa: Rp ' . number_format($warga->total_saldo, 0, ',', '.') . ').',
                    ], 422);
                }

                // 1. Kurangi Saldo Warga
                $warga->total_saldo = (float) $warga->total_saldo - (float) $pencairan->nominal_pencairan;
                $warga->save();

                // 2. Update Status Pencairan
                $pencairan->status = 'disetujui';
                $pencairan->id_pengurus_validasi = $user->id_pengguna;
                $pencairan->tanggal_validasi = Carbon::now();
                $pencairan->save();

                // 3. Catat Mutasi Saldo (Debit)
                MutasiSaldo::create([
                    'id_warga' => $warga->id_pengguna,
                    'id_setoran' => null,
                    'id_pencairan' => $pencairan->id_pencairan,
                    'tipe' => 'debit',
                    'nominal' => $pencairan->nominal_pencairan,
                    'saldo_setelah_mutasi' => $warga->total_saldo,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Pencairan dana sebesar Rp ' . number_format($pencairan->nominal_pencairan, 0, ',', '.') . ' disetujui.',
                    'data' => $pencairan,
                ]);
            } else {
                // Aksi Tolak
                $pencairan->status = 'ditolak';
                $pencairan->id_pengurus_validasi = $user->id_pengguna;
                $pencairan->tanggal_validasi = Carbon::now();
                $pencairan->save();

                return response()->json([
                    'success' => true,
                    'message' => 'Pengajuan pencairan dana ditolak.',
                    'data' => $pencairan,
                ]);
            }
        });
    }

    /**
     * Menerbitkan Pengumuman baru oleh Pengurus.
     */
    public function buatPengumuman(Request $request)
    {
        $user = $request->user();
        $pengurus = $user->pengurus;

        if (!$pengurus) {
            return response()->json(['success' => false, 'message' => 'Hanya pengurus yang dapat menerbitkan pengumuman.'], 403);
        }

        $request->validate([
            'judul' => 'required|string|max:255',
            'isi' => 'required|string',
        ]);

        $pengumuman = Pengumuman::create([
            'id_pengurus' => $user->id_pengguna,
            'judul' => $request->judul,
            'isi' => $request->isi,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengumuman posko berhasil diterbitkan!',
            'data' => [
                'id' => $pengumuman->id_pengumuman,
                'judul' => $pengumuman->judul,
                'isi' => $pengumuman->isi,
                'tanggal' => Carbon::parse($pengumuman->created_at)->translatedFormat('d M Y, H:i'),
            ],
        ], 201);
    }

    /**
     * Rekapitulasi Laporan Bulanan untuk diserahkan/diverifikasi oleh DLH.
     */
    public function laporanRekap(Request $request)
    {
        $bulan = (int) ($request->bulan ?? Carbon::now()->month);
        $tahun = (int) ($request->tahun ?? Carbon::now()->year);

        $totalSetoran = Setoran::whereMonth('tanggal', $bulan)
            ->whereYear('tanggal', $tahun)
            ->count();

        $totalKg = (float) Setoran::whereMonth('tanggal', $bulan)
            ->whereYear('tanggal', $tahun)
            ->sum('total_berat_kg');

        $totalNilaiRp = (float) Setoran::whereMonth('tanggal', $bulan)
            ->whereYear('tanggal', $tahun)
            ->sum('total_nilai_rp');

        $totalPencairan = (float) Pencairan::whereMonth('tanggal_pengajuan', $bulan)
            ->whereYear('tanggal_pengajuan', $tahun)
            ->where('status', 'disetujui')
            ->sum('nominal_pencairan');

        // Rincian per kategori
        $rincianKategori = DB::table('detail_setoran')
            ->join('setoran', 'detail_setoran.id_setoran', '=', 'setoran.id_setoran')
            ->join('kategori_sampah', 'detail_setoran.id_kategori', '=', 'kategori_sampah.id_kategori')
            ->whereMonth('setoran.tanggal', $bulan)
            ->whereYear('setoran.tanggal', $tahun)
            ->groupBy('kategori_sampah.id_kategori', 'kategori_sampah.nama_kategori')
            ->select(
                'kategori_sampah.nama_kategori',
                DB::raw('SUM(detail_setoran.berat_kg) as total_berat'),
                DB::raw('SUM(detail_setoran.subtotal_rp) as total_subtotal')
            )
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'periode' => [
                    'bulan' => $bulan,
                    'tahun' => $tahun,
                    'nama_bulan' => Carbon::createFromDate($tahun, $bulan, 1)->translatedFormat('F Y'),
                ],
                'ringkasan' => [
                    'total_transaksi' => $totalSetoran,
                    'total_berat_kg' => $totalKg,
                    'total_nilai_rp' => $totalNilaiRp,
                    'total_pencairan_rp' => $totalPencairan,
                ],
                'rincian_kategori' => $rincianKategori,
            ],
        ]);
    }

    /**
     * Hapus Pengumuman oleh Pengurus
     */
    public function hapusPengumuman(Request $request, $id)
    {
        $user = $request->user();
        if (!$user || !$user->pengurus) {
            return response()->json(['success' => false, 'message' => 'Hanya pengurus yang dapat menghapus pengumuman.'], 403);
        }

        $p = Pengumuman::find($id);
        if (!$p) {
            return response()->json(['success' => false, 'message' => 'Pengumuman tidak ditemukan.'], 404);
        }

        $p->delete();
        return response()->json([
            'success' => true,
            'message' => 'Pengumuman berhasil dihapus!',
        ]);
    }

    /**
     * Mengambil Pengaturan Pencairan Terkini (Target Minimal & Periode)
     */
    public function getPengaturanPencairan(Request $request)
    {
        $aturan = \App\Models\PengaturanPencairan::latest('id_pengaturan')->first();

        return response()->json([
            'success' => true,
            'data' => [
                'target_minimal' => $aturan ? (float) $aturan->target_minimal : 50000.0,
                'tanggal_mulai' => $aturan && $aturan->tanggal_mulai ? Carbon::parse($aturan->tanggal_mulai)->format('Y-m-d') : Carbon::now()->startOfMonth()->format('Y-m-d'),
                'tanggal_selesai' => $aturan && $aturan->tanggal_selesai ? Carbon::parse($aturan->tanggal_selesai)->format('Y-m-d') : Carbon::now()->endOfMonth()->format('Y-m-d'),
            ],
        ]);
    }

    /**
     * Menyimpan atau Memperbarui Aturan Pengaturan Pencairan oleh Pengurus
     */
    public function simpanPengaturanPencairan(Request $request)
    {
        $user = $request->user();
        if (!$user || !$user->pengurus) {
            return response()->json(['success' => false, 'message' => 'Hanya pengurus yang dapat mengatur pencairan saldo.'], 403);
        }

        $request->validate([
            'target_minimal' => 'required|numeric|min:5000',
            'tanggal_mulai' => 'nullable|date',
            'tanggal_selesai' => 'nullable|date',
        ]);

        $aturan = \App\Models\PengaturanPencairan::create([
            'id_pengurus' => $user->id_pengguna,
            'target_minimal' => $request->target_minimal,
            'tanggal_mulai' => $request->tanggal_mulai ?? Carbon::now(),
            'tanggal_selesai' => $request->tanggal_selesai ?? Carbon::now()->endOfMonth(),
            'created_at' => Carbon::now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Aturan pencairan dana berhasil diperbarui!',
            'data' => [
                'id_pengaturan' => $aturan->id_pengaturan,
                'target_minimal' => (float) $aturan->target_minimal,
                'tanggal_mulai' => $aturan->tanggal_mulai,
                'tanggal_selesai' => $aturan->tanggal_selesai,
            ],
        ]);
    }
}
