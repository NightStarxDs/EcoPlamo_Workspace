<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Warga;
use App\Models\Setoran;
use App\Models\DetailSetoran;
use App\Models\Pencairan;
use App\Models\KategoriSampah;
use App\Models\Pengumuman;
use App\Models\MutasiSaldo;
use App\Models\PengaturanPencairan;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PengurusController extends Controller
{
    /**
     * Mengambil data real-time dashboard pengurus RT/RW dari database.
     * GET /api/pengurus/dashboard
     */
    public function dashboard(Request $request)
    {
        $user = $request->user();
        $pengurus = $user ? $user->pengurus : null;

        // 1. Overview Badges
        $totalWarga = Warga::count();
        $totalSampahKg = (float) Setoran::sum('total_berat_kg');
        $totalSetoran = Setoran::count();
        $pencairanMenunggu = Pencairan::where('status', 'menunggu')->count();

        // 2. Aktivitas Terkini (Gabungan Setoran Terbaru dan Pendaftaran Warga Baru)
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
                'time' => $s->tanggal ? Carbon::parse($s->tanggal)->diffForHumans() : 'Baru saja',
                'icon' => 'delete_outline_rounded',
            ];
        }

        // Tambahkan warga baru terdaftar jika aktivitas setoran masih sedikit
        $recentWarga = Warga::with('user')->orderByDesc('id_pengguna')->limit(2)->get();
        foreach ($recentWarga as $rw) {
            if ($rw->user) {
                $aktivitas[] = [
                    'type' => 'warga_baru',
                    'title' => 'Warga Terdaftar',
                    'description' => $rw->user->nama_lengkap . ' (' . ($rw->alamat ?? 'Warga') . ')',
                    'value' => ucfirst($rw->status_verifikasi ?? 'menunggu'),
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
                    'nama_lengkap' => $user ? $user->nama_lengkap : 'Pengurus RT/RW',
                    'jabatan' => $pengurus ? $pengurus->jabatan : 'Pengurus RT/RW',
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
     * Mengambil daftar warga untuk verifikasi pendaftaran & pembayaran kas posko.
     * GET /api/pengurus/verifikasi-warga
     */
    public function getDaftarVerifikasi(Request $request)
    {
        $status = $request->query('status', 'menunggu');
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

    /**
     * Mengambil daftar seluruh warga beserta ringkasan saldo & setoran.
     * GET /api/pengurus/warga-list
     */
    public function wargaList()
    {
        $wargas = Warga::with(['user', 'setoran'])->get()->map(function ($w) {
            $totalSetoran = $w->setoran->count();
            $totalBerat = (float) $w->setoran->sum('total_berat_kg');
            return [
                'id_warga' => $w->id_pengguna,
                'nama_lengkap' => $w->user ? $w->user->nama_lengkap : 'Warga',
                'no_whatsapp' => $w->user ? $w->user->no_whatsapp : '-',
                'alamat' => $w->alamat ?? '-',
                'total_saldo' => (float) $w->total_saldo,
                'total_setoran' => $totalSetoran,
                'total_berat_kg' => $totalBerat,
                'status_verifikasi' => $w->status_verifikasi ?? 'terverifikasi',
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $wargas,
        ]);
    }

    /**
     * Pencarian warga secara cepat berdasarkan nama / alamat / whatsapp.
     * GET /api/pengurus/warga-search?q=
     */
    public function wargaSearch(Request $request)
    {
        $q = trim((string) $request->get('q', ''));
        if (empty($q)) {
            return response()->json(['success' => true, 'data' => []]);
        }

        $results = Warga::with('user')
            ->whereHas('user', function ($query) use ($q) {
                $query->where('nama_lengkap', 'like', "%{$q}%")
                      ->orWhere('no_whatsapp', 'like', "%{$q}%");
            })
            ->orWhere('alamat', 'like', "%{$q}%")
            ->limit(10)
            ->get()
            ->map(function ($w) {
                return [
                    'id_warga' => $w->id_pengguna,
                    'nama_lengkap' => $w->user ? $w->user->nama_lengkap : 'Warga',
                    'no_whatsapp' => $w->user ? $w->user->no_whatsapp : '-',
                    'alamat' => $w->alamat ?? '-',
                    'total_saldo' => (float) $w->total_saldo,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $results,
        ]);
    }

    /**
     * Mencatat transaksi setoran sampah warga.
     * POST /api/pengurus/setoran
     */
    public function catatSetoran(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'id_warga' => 'required|exists:warga,id_pengguna',
            'items' => 'required|array|min:1',
            'items.*.id_kategori' => 'required|exists:kategori_sampah,id_kategori',
            'items.*.berat_kg' => 'required|numeric|min:0.1',
        ]);

        return DB::transaction(function () use ($request, $user) {
            $totalBerat = 0.0;
            $totalNilai = 0.0;
            $detailData = [];

            foreach ($request->items as $item) {
                $kategori = KategoriSampah::findOrFail($item['id_kategori']);
                $berat = (float) $item['berat_kg'];
                $subtotal = $berat * (float) $kategori->harga_per_satuan;

                $totalBerat += $berat;
                $totalNilai += $subtotal;

                $detailData[] = [
                    'id_kategori' => $kategori->id_kategori,
                    'berat_kg' => $berat,
                    'subtotal_rp' => $subtotal,
                ];
            }

            $setoran = Setoran::create([
                'id_warga' => $request->id_warga,
                'id_pengurus' => $user->id_pengguna,
                'tanggal' => Carbon::now(),
                'total_berat_kg' => $totalBerat,
                'total_nilai_rp' => $totalNilai,
            ]);

            foreach ($detailData as $d) {
                $d['id_setoran'] = $setoran->id_setoran;
                DetailSetoran::create($d);
            }

            // Tambah saldo warga
            $warga = Warga::findOrFail($request->id_warga);
            $saldoSebelumnya = (float) $warga->total_saldo;
            $saldoSesudahnya = $saldoSebelumnya + $totalNilai;
            $warga->total_saldo = $saldoSesudahnya;
            $warga->save();

            // Catat ke mutasi saldo (kredit)
            MutasiSaldo::create([
                'id_warga' => $warga->id_pengguna,
                'id_setoran' => $setoran->id_setoran,
                'tipe' => 'kredit',
                'nominal' => $totalNilai,
                'saldo_sebelumnya' => $saldoSebelumnya,
                'saldo_sesudahnya' => $saldoSesudahnya,
                'keterangan' => 'Setor Sampah (' . number_format($totalBerat, 1, ',', '.') . ' Kg)',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Setoran sampah berhasil dicatat!',
                'data' => [
                    'id_setoran' => $setoran->id_setoran,
                    'total_berat_kg' => $totalBerat,
                    'total_nilai_rp' => $totalNilai,
                    'total_saldo_sekarang' => $saldoSesudahnya,
                ],
            ], 201);
        });
    }

    /**
     * Mengambil daftar pencairan dana warga untuk validasi pengurus.
     * GET /api/pengurus/pencairan
     */
    public function pencairanList(Request $request)
    {
        $status = $request->get('status');

        $query = Pencairan::with(['warga.user', 'pengurusValidasi.user']);
        if ($status && in_array($status, ['menunggu', 'disetujui', 'ditolak'])) {
            $query->where('status', $status);
        }

        $pencairan = $query->orderByDesc('tanggal_pengajuan')->get()->map(function ($p) {
            return [
                'id_pencairan' => $p->id_pencairan,
                'id_warga' => $p->id_warga,
                'nama_warga' => $p->warga && $p->warga->user ? $p->warga->user->nama_lengkap : 'Warga',
                'no_whatsapp' => $p->warga && $p->warga->user ? $p->warga->user->no_whatsapp : '-',
                'alamat' => $p->warga ? $p->warga->alamat : '-',
                'nominal_pencairan' => (float) $p->nominal_pencairan,
                'status' => $p->status,
                'tanggal_pengajuan' => $p->tanggal_pengajuan ? Carbon::parse($p->tanggal_pengajuan)->format('d M Y, H:i') : '-',
                'tanggal_validasi' => $p->tanggal_validasi ? Carbon::parse($p->tanggal_validasi)->format('d M Y, H:i') : null,
                'validasi_oleh' => $p->pengurusValidasi && $p->pengurusValidasi->user ? $p->pengurusValidasi->user->nama_lengkap : null,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $pencairan,
        ]);
    }

    /**
     * Memvalidasi pengajuan pencairan (setujui / tolak).
     * POST /api/pengurus/pencairan/{id}/validasi
     */
    public function validasiPencairan(Request $request, $id)
    {
        $user = $request->user();

        $request->validate([
            'aksi' => 'required|in:setujui,tolak',
        ]);

        return DB::transaction(function () use ($request, $user, $id) {
            $pencairan = Pencairan::findOrFail($id);

            if ($pencairan->status !== 'menunggu') {
                return response()->json([
                    'success' => false,
                    'message' => 'Pengajuan pencairan ini sudah diproses sebelumnya.',
                ], 422);
            }

            $warga = Warga::findOrFail($pencairan->id_warga);
            $aksi = $request->aksi;

            if ($aksi === 'setujui') {
                if ($warga->total_saldo < $pencairan->nominal_pencairan) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Saldo warga tidak mencukupi untuk disetujui.',
                    ], 422);
                }

                $saldoSebelumnya = (float) $warga->total_saldo;
                $saldoSesudahnya = $saldoSebelumnya - (float) $pencairan->nominal_pencairan;
                $warga->total_saldo = $saldoSesudahnya;
                $warga->save();

                // Catat ke mutasi debit
                MutasiSaldo::create([
                    'id_warga' => $warga->id_pengguna,
                    'id_pencairan' => $pencairan->id_pencairan,
                    'tipe' => 'debit',
                    'nominal' => $pencairan->nominal_pencairan,
                    'saldo_sebelumnya' => $saldoSebelumnya,
                    'saldo_sesudahnya' => $saldoSesudahnya,
                    'keterangan' => 'Pencairan Saldo Tunai',
                ]);

                $pencairan->status = 'disetujui';
            } else {
                $pencairan->status = 'ditolak';
            }

            $pencairan->id_pengurus_validasi = $user->id_pengguna;
            $pencairan->tanggal_validasi = Carbon::now();
            $pencairan->save();

            return response()->json([
                'success' => true,
                'message' => 'Pengajuan pencairan berhasil ' . ($aksi === 'setujui' ? 'disetujui' : 'ditolak') . '.',
                'data' => [
                    'id_pencairan' => $pencairan->id_pencairan,
                    'status' => $pencairan->status,
                ],
            ]);
        });
    }

    /**
     * Menerbitkan Pengumuman baru oleh Pengurus.
     * POST /api/pengumuman atau POST /api/pengurus/pengumuman
     */
    public function buatPengumuman(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'judul' => 'required|string|max:200',
            'isi' => 'required|string',
            'kategori' => 'nullable|string|max:50',
        ]);

        $kategori = $request->kategori;
        if (empty($kategori)) {
            $lower = strtolower($request->judul);
            if (str_contains($lower, 'jadwal') || str_contains($lower, 'agenda') || str_contains($lower, 'kegiatan') || str_contains($lower, 'pencairan')) {
                $kategori = 'Agenda';
            } elseif (str_contains($lower, 'tips') || str_contains($lower, 'cara') || str_contains($lower, 'edukasi') || str_contains($lower, 'daur ulang')) {
                $kategori = 'Edukasi';
            } else {
                $kategori = 'Pengumuman';
            }
        }

        $pengumuman = Pengumuman::create([
            'id_pengurus' => $user->id_pengguna,
            'judul' => $request->judul,
            'kategori' => $kategori,
            'isi' => $request->isi,
            'created_at' => Carbon::now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengumuman posko berhasil diterbitkan!',
            'data' => [
                'id' => $pengumuman->id_pengumuman,
                'judul' => $pengumuman->judul,
                'kategori' => $pengumuman->kategori,
                'isi' => $pengumuman->isi,
                'tanggal' => Carbon::parse($pengumuman->created_at)->translatedFormat('d M Y'),
                'created_at' => $pengumuman->created_at,
            ],
        ], 201);
    }

    /**
     * Hapus Pengumuman oleh Pengurus
     * DELETE /api/pengumuman/{id} atau DELETE /api/pengurus/pengumuman/{id}
     */
    public function hapusPengumuman(Request $request, $id)
    {
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
     * Mengambil Pengaturan Pencairan Terkini (Target Minimal, Maksimal per Warga, Kuota, Plafon, & Periode)
     * GET /api/pengurus/pengaturan-pencairan
     */
    public function getPengaturanPencairan(Request $request)
    {
        $aturan = PengaturanPencairan::latest('id_pengaturan')->first();

        $targetMinimal = $aturan ? (float) $aturan->target_minimal : 50000.0;
        $maksimalPerWarga = $aturan && $aturan->maksimal_per_warga !== null ? (float) $aturan->maksimal_per_warga : 200000.0;
        $kuotaWarga = $aturan && $aturan->kuota_warga !== null ? (int) $aturan->kuota_warga : 25;
        $maksimalTotalJadwal = $aturan && $aturan->maksimal_total_jadwal !== null ? (float) $aturan->maksimal_total_jadwal : 2500000.0;
        $catatanAturan = $aturan ? $aturan->catatan_aturan : null;

        $tglMulai = $aturan && $aturan->tanggal_mulai ? Carbon::parse($aturan->tanggal_mulai)->format('Y-m-d') : Carbon::now()->startOfMonth()->format('Y-m-d');
        $tglSelesai = $aturan && $aturan->tanggal_selesai ? Carbon::parse($aturan->tanggal_selesai)->format('Y-m-d') : Carbon::now()->endOfMonth()->format('Y-m-d');

        // Hitung real-time pendaftar dan total dana pada periode jadwal ini
        $pencairanQuery = Pencairan::where('id_pengaturan', $aturan ? $aturan->id_pengaturan : 0)
            ->whereIn('status', ['menunggu', 'disetujui']);

        $totalPendaftar = (int) (clone $pencairanQuery)->count();
        $totalDanaTerpakai = (float) (clone $pencairanQuery)->sum('nominal_pencairan');

        $today = Carbon::today();
        $start = Carbon::parse($tglMulai)->startOfDay();
        $end = Carbon::parse($tglSelesai)->endOfDay();
        $isActive = $today->betweenIncluded($start, $end);

        $sisaKuota = $kuotaWarga > 0 ? max(0, $kuotaWarga - $totalPendaftar) : null;
        $sisaPlafon = $maksimalTotalJadwal > 0 ? max(0, $maksimalTotalJadwal - $totalDanaTerpakai) : null;

        return response()->json([
            'success' => true,
            'data' => [
                'id_pengaturan' => $aturan ? $aturan->id_pengaturan : null,
                'target_minimal' => $targetMinimal,
                'maksimal_per_warga' => $maksimalPerWarga,
                'kuota_warga' => $kuotaWarga,
                'maksimal_total_jadwal' => $maksimalTotalJadwal,
                'tanggal_mulai' => $tglMulai,
                'tanggal_selesai' => $tglSelesai,
                'catatan_aturan' => $catatanAturan,
                'is_active' => $isActive,
                'statistik' => [
                    'total_pendaftar' => $totalPendaftar,
                    'kuota_terpakai' => $totalPendaftar,
                    'sisa_kuota' => $sisaKuota,
                    'total_dana_terpakai' => $totalDanaTerpakai,
                    'sisa_plafon_dana' => $sisaPlafon,
                ],
            ],
        ]);
    }

    /**
     * Menyimpan atau Memperbarui Aturan Pengaturan Pencairan oleh Pengurus.
     * POST /api/pengurus/pengaturan-pencairan
     */
    public function simpanPengaturanPencairan(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'target_minimal' => 'required|numeric|min:5000',
            'maksimal_per_warga' => 'nullable|numeric|min:5000',
            'kuota_warga' => 'nullable|integer|min:1',
            'maksimal_total_jadwal' => 'nullable|numeric|min:5000',
            'tanggal_mulai' => 'nullable|date',
            'tanggal_selesai' => 'nullable|date',
            'catatan_aturan' => 'nullable|string|max:500',
            'buat_pengumuman_otomatis' => 'nullable|boolean',
        ]);

        $aturan = PengaturanPencairan::create([
            'id_pengurus' => $user->id_pengguna,
            'target_minimal' => $request->target_minimal,
            'maksimal_per_warga' => $request->maksimal_per_warga,
            'kuota_warga' => $request->kuota_warga,
            'maksimal_total_jadwal' => $request->maksimal_total_jadwal,
            'tanggal_mulai' => $request->tanggal_mulai ?? Carbon::now(),
            'tanggal_selesai' => $request->tanggal_selesai ?? Carbon::now()->endOfMonth(),
            'catatan_aturan' => $request->catatan_aturan,
            'created_at' => Carbon::now(),
        ]);

        // Jika opsi buat pengumuman otomatis dicentang
        if ($request->boolean('buat_pengumuman_otomatis')) {
            $tglMulaiFmt = Carbon::parse($aturan->tanggal_mulai)->translatedFormat('d M Y');
            $tglSelesaiFmt = Carbon::parse($aturan->tanggal_selesai)->translatedFormat('d M Y');
            $maxPerWargaFmt = $aturan->maksimal_per_warga ? 'Rp ' . number_format($aturan->maksimal_per_warga, 0, ',', '.') : 'Sesuai saldo';
            $kuotaFmt = $aturan->kuota_warga ? "{$aturan->kuota_warga} warga" : 'Tidak dibatasi';

            $judulPengumuman = "Jadwal & Aturan Pencairan Kas Posko ({$tglMulaiFmt} - {$tglSelesaiFmt})";
            $isiPengumuman = "Diberitahukan kepada seluruh warga bank sampah Eco Plamo:\n"
                . "Periode pengajuan pencairan saldo kas dibuka mulai {$tglMulaiFmt} s/d {$tglSelesaiFmt}.\n\n"
                . "Ketentuan & Aturan Pencairan:\n"
                . "• Saldo minimal penarikan: Rp " . number_format($aturan->target_minimal, 0, ',', '.') . "\n"
                . "• Batas maksimal per warga: {$maxPerWargaFmt}\n"
                . "• Kuota antrean jadwal ini: {$kuotaFmt}\n"
                . ($aturan->maksimal_total_jadwal ? "• Total plafon kas posko periode ini: Rp " . number_format($aturan->maksimal_total_jadwal, 0, ',', '.') . "\n" : "")
                . ($aturan->catatan_aturan ? "\nCatatan Tambahan: {$aturan->catatan_aturan}\n" : "\n")
                . "Warga yang memenuhi syarat dapat langsung mengajukan klaim melalui aplikasi pada menu Tarik Saldo.";

            Pengumuman::create([
                'id_pengurus' => $user->id_pengguna,
                'judul' => $judulPengumuman,
                'kategori' => 'Agenda',
                'isi' => $isiPengumuman,
                'created_at' => Carbon::now(),
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Aturan pencairan dana berhasil diperbarui' . ($request->boolean('buat_pengumuman_otomatis') ? ' & pengumuman posko diterbitkan!' : '!'),
            'data' => [
                'id_pengaturan' => $aturan->id_pengaturan,
                'target_minimal' => (float) $aturan->target_minimal,
                'maksimal_per_warga' => $aturan->maksimal_per_warga ? (float) $aturan->maksimal_per_warga : null,
                'kuota_warga' => $aturan->kuota_warga ? (int) $aturan->kuota_warga : null,
                'maksimal_total_jadwal' => $aturan->maksimal_total_jadwal ? (float) $aturan->maksimal_total_jadwal : null,
                'tanggal_mulai' => $aturan->tanggal_mulai,
                'tanggal_selesai' => $aturan->tanggal_selesai,
                'catatan_aturan' => $aturan->catatan_aturan,
            ],
        ]);
    }

    /**
     * Laporan rekapitulasi data bulanan untuk pengurus posko.
     * GET /api/pengurus/laporan
     */
    public function laporanRekap(Request $request)
    {
        $bulan = (int) $request->get('bulan', Carbon::now()->month);
        $tahun = (int) $request->get('tahun', Carbon::now()->year);

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
}
