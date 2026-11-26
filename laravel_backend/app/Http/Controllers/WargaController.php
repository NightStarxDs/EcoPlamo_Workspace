<?php

namespace App\Http\Controllers;

use App\Models\Warga;
use App\Models\Setoran;
use App\Models\Pencairan;
use App\Models\PengaturanPencairan;
use App\Models\Pengumuman;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class WargaController extends Controller
{
    /**
     * Mengambil seluruh data real-time dashboard warga dari database.
     */
    public function dashboard(Request $request)
    {
        $user = $request->user();
        $warga = $user->warga;

        if (!$warga) {
            return response()->json([
                'success' => false,
                'message' => 'Profil warga tidak ditemukan.',
            ], 404);
        }

        // 1. Saldo & Target Pencairan
        $saldo = (float) $warga->total_saldo;
        $pengaturan = PengaturanPencairan::latest('id_pengaturan')->first();
        $minPencairan = $pengaturan ? (float) $pengaturan->target_minimal : 50000;
        $nextRedeem = $pengaturan && $pengaturan->tanggal_selesai 
            ? Carbon::parse($pengaturan->tanggal_selesai)->translatedFormat('d F Y')
            : Carbon::now()->endOfMonth()->translatedFormat('d F Y');

        // 2. Statistik Kontribusi
        $totalSampahKg = (float) Setoran::where('id_warga', $warga->id_pengguna)->sum('total_berat_kg');
        $totalDicairkan = (float) Pencairan::where('id_warga', $warga->id_pengguna)
            ->where('status', 'disetujui')
            ->sum('nominal_pencairan');
        $jumlahSetoran = Setoran::where('id_warga', $warga->id_pengguna)->count();

        // Hitung peringkat warga berdasarkan total sampah yang disetor
        $rankings = Setoran::select('id_warga', DB::raw('SUM(total_berat_kg) as total_kg'))
            ->groupBy('id_warga')
            ->orderByDesc('total_kg')
            ->pluck('id_warga')
            ->toArray();
        $rankIndex = array_search($warga->id_pengguna, $rankings);
        $peringkat = $rankIndex !== false ? '#' . ($rankIndex + 1) : '—';

        // 3. Aktivitas Terakhir (Setoran)
        $setorans = Setoran::with(['details.kategori'])
            ->where('id_warga', $warga->id_pengguna)
            ->orderByDesc('tanggal')
            ->orderByDesc('id_setoran')
            ->limit(5)
            ->get();

        $aktivitas = [];
        foreach ($setorans as $s) {
            $firstDetail = $s->details->first();
            $kategoriNama = $firstDetail && $firstDetail->kategori 
                ? $firstDetail->kategori->nama_kategori 
                : 'Sampah Daur Ulang';

            if ($s->details->count() > 1) {
                $kategoriNama .= ' & Campuran';
            }

            $aktivitas[] = [
                'id_setoran' => $s->id_setoran,
                'title' => $kategoriNama,
                'weight' => number_format($s->total_berat_kg, 1, ',', '.') . ' Kg',
                'date' => Carbon::parse($s->tanggal)->translatedFormat('d M'),
                'nominal' => '+Rp ' . number_format($s->total_nilai_rp, 0, ',', '.'),
                'icon' => $this->getCategoryIcon($kategoriNama),
            ];
        }

        // 4. Klasemen / Leaderboard (Top Warga)
        $topWargaQuery = Setoran::select('id_warga', DB::raw('SUM(total_berat_kg) as total_kg'), DB::raw('SUM(total_nilai_rp) as total_rp'))
            ->groupBy('id_warga')
            ->orderByDesc('total_kg')
            ->limit(5)
            ->get();

        $klasemen = [];
        $rank = 1;
        foreach ($topWargaQuery as $item) {
            $wargaItem = Warga::with('user')->find($item->id_warga);
            if ($wargaItem && $wargaItem->user) {
                $klasemen[] = [
                    'rank' => $rank++,
                    'nama' => $wargaItem->user->nama_lengkap,
                    'blok' => $wargaItem->alamat ?? 'Blok A',
                    'total_kg' => (float) $item->total_kg,
                    'total_rp' => (float) $item->total_rp,
                    'is_current_user' => $wargaItem->id_pengguna === $warga->id_pengguna,
                ];
            }
        }

        // 5. Pengumuman
        $pengumuman = Pengumuman::orderByDesc('created_at')->limit(3)->get()->map(function ($p) {
            return [
                'id' => $p->id_pengumuman,
                'judul' => $p->judul,
                'isi' => $p->isi,
                'tanggal' => Carbon::parse($p->created_at)->translatedFormat('d M Y'),
            ];
        });

        // 6. Status Pencairan (cek apakah ada yang sedang diproses)
        $pencairanMenunggu = Pencairan::where('id_warga', $warga->id_pengguna)
            ->where('status', 'menunggu')
            ->latest('id_pencairan')
            ->first();

        $statusPencairan = null;
        if ($pencairanMenunggu) {
            $statusPencairan = [
                'id_pencairan' => $pencairanMenunggu->id_pencairan,
                'nominal' => (float) $pencairanMenunggu->nominal_pencairan,
                'status' => 'menunggu',
                'tanggal_pengajuan' => Carbon::parse($pencairanMenunggu->tanggal_pengajuan)->translatedFormat('d M Y, H:i'),
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id_pengguna' => $user->id_pengguna,
                    'nama_lengkap' => $user->nama_lengkap,
                    'no_whatsapp' => $user->no_whatsapp,
                    'alamat' => $warga->alamat,
                ],
                'saldo' => $saldo,
                'min_pencairan' => $minPencairan,
                'next_redeem' => $nextRedeem,
                'kontribusi' => [
                    'total_sampah_kg' => $totalSampahKg,
                    'total_dicairkan_rp' => $totalDicairkan,
                    'jumlah_setoran' => $jumlahSetoran,
                    'peringkat' => $peringkat,
                ],
                'aktivitas' => $aktivitas,
                'klasemen' => $klasemen,
                'pengumuman' => $pengumuman,
                'pencairan_menunggu' => $statusPencairan,
                'pengaturan_pencairan' => [
                    'min_pencairan' => $minPencairan,
                    'maksimal_per_warga' => $pengaturan && $pengaturan->maksimal_per_warga ? (float) $pengaturan->maksimal_per_warga : null,
                    'kuota_warga' => $pengaturan && $pengaturan->kuota_warga ? (int) $pengaturan->kuota_warga : null,
                    'maksimal_total_jadwal' => $pengaturan && $pengaturan->maksimal_total_jadwal ? (float) $pengaturan->maksimal_total_jadwal : null,
                    'tanggal_mulai' => $pengaturan ? Carbon::parse($pengaturan->tanggal_mulai)->format('Y-m-d') : null,
                    'tanggal_selesai' => $pengaturan ? Carbon::parse($pengaturan->tanggal_selesai)->format('Y-m-d') : null,
                    'is_active' => $pengaturan ? Carbon::today()->betweenIncluded(Carbon::parse($pengaturan->tanggal_mulai)->startOfDay(), Carbon::parse($pengaturan->tanggal_selesai)->endOfDay()) : true,
                    'catatan_aturan' => $pengaturan ? $pengaturan->catatan_aturan : null,
                ],
            ],
        ]);
    }

    /**
     * Mengajukan pencairan saldo tunai warga.
     */
    public function ajukanPencairan(Request $request)
    {
        $user = $request->user();
        $warga = $user->warga;

        if (!$warga) {
            return response()->json(['success' => false, 'message' => 'Profil warga tidak ditemukan.'], 404);
        }

        // Cek apakah ada pencairan yang masih menunggu persetujuan
        $pencairanMenunggu = Pencairan::where('id_warga', $warga->id_pengguna)
            ->where('status', 'menunggu')
            ->first();

        if ($pencairanMenunggu) {
            return response()->json([
                'success' => false,
                'message' => 'Anda masih memiliki pengajuan pencairan yang sedang diproses (Rp ' . number_format($pencairanMenunggu->nominal_pencairan, 0, ',', '.') . '). Harap tunggu hingga pengajuan sebelumnya disetujui atau ditolak.',
            ], 422);
        }

        $pengaturan = PengaturanPencairan::latest('id_pengaturan')->first();
        if (!$pengaturan) {
            return response()->json([
                'success' => false,
                'message' => 'Pengaturan jadwal pencairan belum ditetapkan oleh pengurus.',
            ], 422);
        }

        // Cek periode jadwal pencairan
        $today = Carbon::today();
        $start = Carbon::parse($pengaturan->tanggal_mulai)->startOfDay();
        $end = Carbon::parse($pengaturan->tanggal_selesai)->endOfDay();
        if (!$today->betweenIncluded($start, $end)) {
            $mulaiFmt = Carbon::parse($pengaturan->tanggal_mulai)->translatedFormat('d M Y');
            $selesaiFmt = Carbon::parse($pengaturan->tanggal_selesai)->translatedFormat('d M Y');
            return response()->json([
                'success' => false,
                'message' => "Pengajuan pencairan saat ini sedang ditutup. Jadwal aktif dibuka pada periode {$mulaiFmt} s/d {$selesaiFmt}.",
            ], 422);
        }

        $minPencairan = (float) $pengaturan->target_minimal;
        $maxPerWarga = $pengaturan->maksimal_per_warga ? (float) $pengaturan->maksimal_per_warga : null;

        $request->validate([
            'nominal' => 'required|numeric|min:' . $minPencairan,
        ], [
            'nominal.required' => 'Nominal pencairan wajib diisi.',
            'nominal.min' => 'Nominal pencairan minimal Rp ' . number_format($minPencairan, 0, ',', '.'),
        ]);

        $nominal = (float) $request->nominal;

        if ($warga->total_saldo < $nominal) {
            return response()->json([
                'success' => false,
                'message' => 'Saldo Anda (Rp ' . number_format($warga->total_saldo, 0, ',', '.') . ') tidak mencukupi untuk mencairkan Rp ' . number_format($nominal, 0, ',', '.'),
            ], 422);
        }

        // Cek batas maksimal per warga
        if ($maxPerWarga !== null && $nominal > $maxPerWarga) {
            return response()->json([
                'success' => false,
                'message' => 'Batas maksimal pencairan per warga untuk jadwal ini adalah Rp ' . number_format($maxPerWarga, 0, ',', '.') . '. Anda dapat mencairkan kembali pada jadwal berikutnya.',
            ], 422);
        }

        // Cek kuota pendaftar warga dalam jadwal ini
        if ($pengaturan->kuota_warga !== null && $pengaturan->kuota_warga > 0) {
            $totalPendaftar = Pencairan::where('id_pengaturan', $pengaturan->id_pengaturan)
                ->whereIn('status', ['menunggu', 'disetujui'])
                ->count();

            if ($totalPendaftar >= $pengaturan->kuota_warga) {
                return response()->json([
                    'success' => false,
                    'message' => "Mohon maaf, kuota pencairan untuk jadwal ini telah penuh ({$pengaturan->kuota_warga} warga). Silakan ajukan pada periode jadwal berikutnya.",
                ], 422);
            }
        }

        // Cek batas maksimal total dana pencairan jadwal ini (plafon kas posko)
        if ($pengaturan->maksimal_total_jadwal !== null && $pengaturan->maksimal_total_jadwal > 0) {
            $totalDanaTerpakai = (float) Pencairan::where('id_pengaturan', $pengaturan->id_pengaturan)
                ->whereIn('status', ['menunggu', 'disetujui'])
                ->sum('nominal_pencairan');

            $sisaPlafon = $pengaturan->maksimal_total_jadwal - $totalDanaTerpakai;
            if ($sisaPlafon <= 0 || $nominal > $sisaPlafon) {
                return response()->json([
                    'success' => false,
                    'message' => 'Plafon total dana kas posko untuk jadwal ini telah tercapai (sisa kuota dana Rp ' . number_format(max(0, $sisaPlafon), 0, ',', '.') . '). Silakan ajukan nominal lebih kecil atau nantikan jadwal berikutnya.',
                ], 422);
            }
        }

        $pencairan = Pencairan::create([
            'id_warga' => $warga->id_pengguna,
            'id_pengaturan' => $pengaturan->id_pengaturan,
            'nominal_pencairan' => $request->nominal,
            'status' => 'menunggu',
            'tanggal_pengajuan' => Carbon::now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan pencairan tunai berhasil dikirim! Menunggu persetujuan pengurus.',
            'data' => $pencairan,
        ], 201);
    }

    /**
     * Mengambil riwayat mutasi saldo (buku kas/ledger) warga.
     */
    public function mutasiSaldo(Request $request)
    {
        $user = $request->user();
        $warga = $user->warga;

        if (!$warga) {
            return response()->json(['success' => false, 'message' => 'Profil warga tidak ditemukan.'], 404);
        }

        $mutasi = \App\Models\MutasiSaldo::where('id_warga', $warga->id_pengguna)
            ->with(['setoran.details.kategori', 'pencairan'])
            ->orderByDesc('id_mutasi')
            ->get()
            ->map(function ($m) {
                $keterangan = 'Transaksi';
                if ($m->tipe === 'kredit' && $m->setoran) {
                    $kategoriNames = $m->setoran->details->map(fn($d) => $d->kategori->nama_kategori ?? 'Sampah')->join(', ');
                    $keterangan = 'Setoran Sampah (' . ($kategoriNames ?: 'Sampah Daur Ulang') . ')';
                } elseif ($m->tipe === 'debit' && $m->pencairan) {
                    $keterangan = 'Pencairan Saldo Tunai (' . ucfirst($m->pencairan->status) . ')';
                }

                return [
                    'id_mutasi' => $m->id_mutasi,
                    'tipe' => $m->tipe,
                    'nominal' => (float) $m->nominal,
                    'saldo_setelah' => (float) $m->saldo_setelah_mutasi,
                    'keterangan' => $keterangan,
                    'tanggal' => Carbon::parse($m->created_at)->translatedFormat('d M Y, H:i'),
                    'created_at' => $m->created_at,
                ];
            });

        return response()->json([
            'success' => true,
            'saldo_sekarang' => (float) $warga->total_saldo,
            'data' => $mutasi,
        ]);
    }

    private function getCategoryIcon(string $name): string
    {
        $nameLower = strtolower($name);
        if (str_contains($nameLower, 'plastik')) return 'water_drop_outlined';
        if (str_contains($nameLower, 'kardus') || str_contains($nameLower, 'kertas')) return 'inventory_2_outlined';
        if (str_contains($nameLower, 'kaleng') || str_contains($nameLower, 'logam')) return 'recycling_rounded';
        if (str_contains($nameLower, 'minyak')) return 'oil_barrel_rounded';
        return 'delete_outline_rounded';
    }
}
