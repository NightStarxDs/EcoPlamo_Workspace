import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// =============================================================================
/// Sheet Pengaturan & Aturan Pencairan Saldo (Starbucks Retail Harmony)
/// Memungkinkan pengurus RT/RW menentukan:
/// 1. Target minimal saldo warga untuk berhak mencairkan
/// 2. Batas maksimal pencairan per orang (mencegah penarikan serentak / habis)
/// 3. Kuota maksimal jumlah orang dalam satu jadwal pencairan
/// 4. Plafon total anggaran kas posko pada jadwal tersebut
/// 5. Rentang tanggal mulai & selesai jadwal klaim
/// 6. Opsi publikasi otomatis ke pengumuman posko
/// =============================================================================
class PengaturanPencairanSheet extends StatefulWidget {
  final AuthService authService;

  const PengaturanPencairanSheet({
    super.key,
    required this.authService,
  });

  @override
  State<PengaturanPencairanSheet> createState() => _PengaturanPencairanSheetState();
}

class _PengaturanPencairanSheetState extends State<PengaturanPencairanSheet> {
  // Controllers
  final TextEditingController _minSaldoCtrl = TextEditingController();
  final TextEditingController _maxPerWargaCtrl = TextEditingController();
  final TextEditingController _kuotaWargaCtrl = TextEditingController();
  final TextEditingController _maxTotalJadwalCtrl = TextEditingController();
  final TextEditingController _mulaiCtrl = TextEditingController();
  final TextEditingController _selesaiCtrl = TextEditingController();
  final TextEditingController _catatanCtrl = TextEditingController();

  DateTime? _mulai;
  DateTime? _selesai;
  bool _buatPengumumanOtomatis = true;

  // Real-time statistics from backend
  Map<String, dynamic>? _statistik;
  bool _isActive = false;

  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _minSaldoCtrl.dispose();
    _maxPerWargaCtrl.dispose();
    _kuotaWargaCtrl.dispose();
    _maxTotalJadwalCtrl.dispose();
    _mulaiCtrl.dispose();
    _selesaiCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  String _fmtTanggal(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  String _iso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _fmtRp(double v) {
    final s = v.toStringAsFixed(0);
    final parts = s.split('');
    final buf = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write('.');
      buf.write(parts[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  void _setMulai(DateTime d) {
    _mulai = d;
    _mulaiCtrl.text = _fmtTanggal(d);
  }

  void _setSelesai(DateTime d) {
    _selesai = d;
    _selesaiCtrl.text = _fmtTanggal(d);
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });

    try {
      final res = await widget.authService.getPengaturanPencairan();
      if (!mounted) return;

      final now = DateTime.now();
      final min = (res['target_minimal'] as num?)?.toInt() ?? 50000;
      final maxWarga = (res['maksimal_per_warga'] as num?)?.toInt() ?? 200000;
      final kuota = (res['kuota_warga'] as num?)?.toInt() ?? 25;
      final maxTotal = (res['maksimal_total_jadwal'] as num?)?.toInt() ?? 2500000;
      final catatan = res['catatan_aturan']?.toString() ?? '';

      setState(() {
        _minSaldoCtrl.text = min.toString();
        _maxPerWargaCtrl.text = maxWarga > 0 ? maxWarga.toString() : '';
        _kuotaWargaCtrl.text = kuota > 0 ? kuota.toString() : '';
        _maxTotalJadwalCtrl.text = maxTotal > 0 ? maxTotal.toString() : '';
        _catatanCtrl.text = catatan;

        _setMulai(
          DateTime.tryParse(res['tanggal_mulai']?.toString() ?? '') ??
              DateTime(now.year, now.month, 1),
        );
        _setSelesai(
          DateTime.tryParse(res['tanggal_selesai']?.toString() ?? '') ??
              DateTime(now.year, now.month + 1, 0),
        );

        if (res['statistik'] is Map) {
          _statistik = Map<String, dynamic>.from(res['statistik']);
        }
        _isActive = res['is_active'] == true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  // ---- Validasi Input -------------------------------------------------------
  int? get _minSaldo => int.tryParse(_minSaldoCtrl.text.trim());
  int? get _maxPerWarga => int.tryParse(_maxPerWargaCtrl.text.trim());
  int? get _kuotaWarga => int.tryParse(_kuotaWargaCtrl.text.trim());
  int? get _maxTotalJadwal => int.tryParse(_maxTotalJadwalCtrl.text.trim());

  String? get _minSaldoError {
    if (_minSaldoCtrl.text.trim().isEmpty) return 'Wajib diisi';
    final n = _minSaldo;
    if (n == null || n < 5000) return 'Minimal Rp 5.000';
    return null;
  }

  String? get _maxPerWargaError {
    final max = _maxPerWarga;
    final min = _minSaldo;
    if (max != null && min != null && max < min) {
      return 'Batas per warga harus ≥ target minimal';
    }
    return null;
  }

  String? get _tanggalError {
    if (_mulai != null && _selesai != null && _selesai!.isBefore(_mulai!)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai';
    }
    return null;
  }

  bool get _canSave =>
      !_saving &&
      _mulai != null &&
      _selesai != null &&
      _minSaldoError == null &&
      _maxPerWargaError == null &&
      _tanggalError == null;

  Future<void> _pickDate({required bool isMulai}) async {
    final initial = (isMulai ? _mulai : _selesai) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: isMulai ? 'Pilih tanggal mulai klaim' : 'Pilih batas akhir jadwal',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isMulai) {
        _setMulai(picked);
      } else {
        _setSelesai(picked);
      }
    });
  }

  void _applyDatePreset(int type) {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    setState(() {
      switch (type) {
        case 0: // Bulan ini
          _setMulai(DateTime(now.year, now.month, 1));
          _setSelesai(DateTime(now.year, now.month + 1, 0));
          break;
        case 1: // 14 hari ke depan
          _setMulai(now);
          _setSelesai(now.add(const Duration(days: 14)));
          break;
        case 2: // Akhir pekan terdekat (Jumat s/d Minggu)
          final daysToFriday = (DateTime.friday - now.weekday + 7) % 7;
          final friday = now.add(Duration(days: daysToFriday));
          _setMulai(friday);
          _setSelesai(friday.add(const Duration(days: 2)));
          break;
      }
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saveError = null;
    });
    HapticFeedback.mediumImpact();

    try {
      final res = await widget.authService.simpanPengaturanPencairan(
        targetMinimal: _minSaldo!.toDouble(),
        tanggalMulai: _iso(_mulai!),
        tanggalSelesai: _iso(_selesai!),
        maksimalPerWarga: _maxPerWarga != null ? _maxPerWarga!.toDouble() : null,
        kuotaWarga: _kuotaWarga,
        maksimalTotalJadwal: _maxTotalJadwal != null ? _maxTotalJadwal!.toDouble() : null,
        catatanAturan: _catatanCtrl.text.trim(),
        buatPengumumanOtomatis: _buatPengumumanOtomatis,
      );

      if (!mounted) return;

      if (res['success'] == true) {
        Navigator.pop(
          context,
          res['message']?.toString() ?? 'Aturan pencairan dana berhasil diperbarui.',
        );
      } else {
        setState(() {
          _saving = false;
          _saveError = res['message']?.toString() ?? 'Gagal menyimpan aturan.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = 'Gagal terhubung ke server. Periksa koneksi jaringan Anda.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvasWarm,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Drag Bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sheet Header
              _buildSheetHeader(),
              const SizedBox(height: 18),

              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: AppColors.accentGreen,
                    ),
                  ),
                )
              else if (_loadFailed)
                _buildLoadFailed()
              else ...[
                // Banner Status Jadwal & Kuota Saat Ini
                _buildLiveStatusBanner(),
                const SizedBox(height: 18),

                // Form Kontrol & Batasan
                _buildFormSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.mintWash,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accentLight.withValues(alpha: 0.5)),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: AppColors.accentGreen,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelola Aturan Pencairan',
                style: AppTypography.h3(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                'Batas penarikan, kuota antrean warga, & plafon kas posko',
                style: AppTypography.caption(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveStatusBanner() {
    final totalPendaftar = _statistik?['total_pendaftar'] ?? 0;
    final danaTerpakai = (_statistik?['total_dana_terpakai'] as num?)?.toDouble() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.houseGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isActive ? const Color(0xFF34D399) : AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isActive ? 'JADWAL AKTIF BERJALAN' : 'JADWAL DITUTUP / MENDATANG',
                    style: AppTypography.caption(
                      color: _isActive ? const Color(0xFF34D399) : AppColors.warning,
                    ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${_mulaiCtrl.text} – ${_selesaiCtrl.text}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Antrean Pendaftar',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _kuotaWarga != null && _kuotaWarga! > 0
                          ? '$totalPendaftar / $_kuotaWarga org'
                          : '$totalPendaftar org (Bebas)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: Colors.white24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plafon Kas Terpakai',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fmtRp(danaTerpakai),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB0F0D6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── BAGIAN 1: RENTANG JADWAL ─────────────────────────────────────────
        _sectionLabel('1. Periode Jadwal Pencairan', Icons.calendar_month_rounded),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _boxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _dateField(
                      label: 'Tanggal Mulai',
                      controller: _mulaiCtrl,
                      onTap: () => _pickDate(isMulai: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateField(
                      label: 'Tanggal Selesai',
                      controller: _selesaiCtrl,
                      onTap: () => _pickDate(isMulai: false),
                      errorText: _tanggalError,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Preset Cepat Tanggal
              Row(
                children: [
                  Text('Preset:', style: AppTypography.caption()),
                  const SizedBox(width: 8),
                  _presetPill('Bulan Ini', () => _applyDatePreset(0)),
                  const SizedBox(width: 6),
                  _presetPill('14 Hari', () => _applyDatePreset(1)),
                  const SizedBox(width: 6),
                  _presetPill('Weekend', () => _applyDatePreset(2)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── BAGIAN 2: SYARAT SALDO & BATAS PER ORANG ────────────────────────
        _sectionLabel('2. Syarat & Batas Maksimal Pencairan Warga', Icons.shield_outlined),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _boxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Minimal Saldo
              TextField(
                controller: _minSaldoCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                style: AppTypography.h3(),
                decoration: InputDecoration(
                  labelText: 'Target Minimal Saldo Warga',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixText: 'Rp  ',
                  prefixStyle: AppTypography.h3(color: AppColors.accentGreen),
                  hintText: '50000',
                  errorText: _minSaldoError,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _presetPill('Rp 20.000', () => _setVal(_minSaldoCtrl, '20000')),
                  const SizedBox(width: 6),
                  _presetPill('Rp 50.000', () => _setVal(_minSaldoCtrl, '50000')),
                  const SizedBox(width: 6),
                  _presetPill('Rp 100.000', () => _setVal(_minSaldoCtrl, '100000')),
                ],
              ),
              const SizedBox(height: 16),

              // Maksimal Per Orang
              TextField(
                controller: _maxPerWargaCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                style: AppTypography.h3(),
                decoration: InputDecoration(
                  labelText: 'Batas Maksimal Pencairan Per Orang',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixText: 'Rp  ',
                  prefixStyle: AppTypography.h3(color: AppColors.accentGreen),
                  hintText: 'Kosongkan jika tanpa batas',
                  helperText: 'Warga tidak boleh mencairkan seluruh saldo atau banyak sekaligus',
                  errorText: _maxPerWargaError,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _presetPill('Rp 100.000', () => _setVal(_maxPerWargaCtrl, '100000')),
                  const SizedBox(width: 6),
                  _presetPill('Rp 200.000', () => _setVal(_maxPerWargaCtrl, '200000')),
                  const SizedBox(width: 6),
                  _presetPill('Rp 500.000', () => _setVal(_maxPerWargaCtrl, '500000')),
                  const SizedBox(width: 6),
                  _presetPill('Bebas', () => _setVal(_maxPerWargaCtrl, '')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── BAGIAN 3: KUOTA ORANG & PLAFON KAS JADWAL ─────────────────────────
        _sectionLabel('3. Kuota Antrean & Plafon Kas Posko', Icons.people_outline_rounded),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _boxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kuota Orang Sekali Jadwal
              TextField(
                controller: _kuotaWargaCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                style: AppTypography.h3(),
                decoration: const InputDecoration(
                  labelText: 'Maksimal Kuota Orang Dalam Jadwal Ini',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixText: 'Orang',
                  hintText: 'Contoh: 25',
                  helperText: 'Batas jumlah warga yang boleh mengajukan di sesi jadwal ini',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _presetPill('15 Warga', () => _setVal(_kuotaWargaCtrl, '15')),
                  const SizedBox(width: 6),
                  _presetPill('25 Warga', () => _setVal(_kuotaWargaCtrl, '25')),
                  const SizedBox(width: 6),
                  _presetPill('50 Warga', () => _setVal(_kuotaWargaCtrl, '50')),
                  const SizedBox(width: 6),
                  _presetPill('Tak Terbatas', () => _setVal(_kuotaWargaCtrl, '')),
                ],
              ),
              const SizedBox(height: 16),

              // Plafon Kas Total Jadwal
              TextField(
                controller: _maxTotalJadwalCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                style: AppTypography.h3(),
                decoration: const InputDecoration(
                  labelText: 'Plafon Total Dana Kas Posko Jadwal Ini',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixText: 'Rp  ',
                  prefixStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentGreen,
                  ),
                  hintText: 'Contoh: 2500000',
                  helperText: 'Total alokasi uang tunai yang disediakan posko',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _presetPill('Rp 1 Jt', () => _setVal(_maxTotalJadwalCtrl, '1000000')),
                  const SizedBox(width: 6),
                  _presetPill('Rp 2.5 Jt', () => _setVal(_maxTotalJadwalCtrl, '2500000')),
                  const SizedBox(width: 6),
                  _presetPill('Rp 5 Jt', () => _setVal(_maxTotalJadwalCtrl, '5000000')),
                  const SizedBox(width: 6),
                  _presetPill('Fleksibel', () => _setVal(_maxTotalJadwalCtrl, '')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── BAGIAN 4: CATATAN & OTOMASI PENGUMUMAN ───────────────────────────
        _sectionLabel('4. Catatan & Publikasi ke Warga', Icons.campaign_outlined),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _boxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _catatanCtrl,
                maxLines: 2,
                style: AppTypography.bodyMedium(),
                decoration: const InputDecoration(
                  labelText: 'Pesan / Catatan Khusus untuk Warga (Opsional)',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  hintText: 'Misal: Harap bawa KTP/buku tabungan saat pencairan...',
                ),
              ),
              const SizedBox(height: 14),
              // Switch Buat Pengumuman Otomatis
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.canvasWarm,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.mintWash,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.accentGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kirim Pengumuman Posko',
                            style: AppTypography.bodySmall(color: AppColors.textPrimary)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Otomatis terbitkan jadwal & aturan baru di info posko warga',
                            style: AppTypography.caption(color: AppColors.textSecondary)
                                .copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _buatPengumumanOtomatis,
                      activeColor: AppColors.accentGreen,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        setState(() => _buatPengumumanOtomatis = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (_saveError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _saveError!,
                    style: AppTypography.bodySmall(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── TOMBOL SIMPAN (STARBUCKS FULL-PILL) ───────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _canSave ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.borderLight,
              disabledForegroundColor: AppColors.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Full Pill Starbucks
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Simpan Aturan Pencairan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _setVal(TextEditingController ctrl, String v) {
    HapticFeedback.selectionClick();
    setState(() => ctrl.text = v);
  }

  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.caption(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _presetPill(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: IgnorePointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          style: AppTypography.bodyMedium(color: AppColors.textPrimary)
              .copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: 'Pilih tanggal',
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.accentGreen,
            ),
            errorText: errorText,
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildLoadFailed() {
    return Column(
      children: [
        const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Text('Gagal memuat aturan pencairan', style: AppTypography.h3()),
        const SizedBox(height: 6),
        Text('Periksa koneksi lalu coba kembali.', style: AppTypography.caption()),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadData,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          ),
          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

