import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Layar Verifikasi Warga – Pengurus RT/RW
//  Alur: lihat daftar pendaftaran → filter status → setujui / tolak
//  Backend: GET  /api/pengurus/verifikasi-warga?status=&search=
//           POST /api/pengurus/verifikasi-warga/{id}/setujui
//           POST /api/pengurus/verifikasi-warga/{id}/tolak
// ─────────────────────────────────────────────────────────────────────────────

class VerifikasiWargaScreen extends StatefulWidget {
  const VerifikasiWargaScreen({super.key});

  @override
  State<VerifikasiWargaScreen> createState() => _VerifikasiWargaScreenState();
}

class _VerifikasiWargaScreenState extends State<VerifikasiWargaScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _api = AuthService();

  // ── Tab / Filter ───────────────────────────────────────────────────────────
  late final TabController _tabCtrl;
  static const _tabs = ['menunggu', 'terverifikasi', 'ditolak'];
  static const _tabLabels = ['Menunggu', 'Terverifikasi', 'Ditolak'];

  // ── Search ─────────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  // ── Data ───────────────────────────────────────────────────────────────────
  bool _isLoading = true;
  List<Map<String, dynamic>> _wargaList = [];
  Map<String, dynamic> _counts = {'menunggu': 0, 'terverifikasi': 0, 'ditolak': 0};

  // ── Action Loading ─────────────────────────────────────────────────────────
  final Set<int> _actionInProgress = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _loadData();
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── API Calls ──────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final result = await _api.getDaftarVerifikasi(
      status: _tabs[_tabCtrl.index],
      search: _searchCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _wargaList = List<Map<String, dynamic>>.from(result['data'] as List);
        if (result['counts'] != null) {
          _counts = Map<String, dynamic>.from(result['counts']);
        }
      } else {
        _wargaList = [];
      }
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _loadData);
  }

  Future<void> _setujui(Map<String, dynamic> warga) async {
    final id = warga['id_pengguna'] as int;
    final nama = warga['nama_lengkap'] as String? ?? 'Warga';
    final defaultBiaya = (warga['uang_pendaftaran'] as num?)?.toDouble() ?? 10000.0;
    final tiket = warga['nomor_tiket'] as String? ?? '-';

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SetujuiDialog(
        nama: nama,
        tiket: tiket,
        defaultBiaya: defaultBiaya,
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _actionInProgress.add(id));
    final res = await _api.setujuiWarga(
      id,
      uangPendaftaran: result['biaya'] as double,
      catatan: result['catatan'] as String? ?? '',
    );
    if (!mounted) return;
    setState(() => _actionInProgress.remove(id));

    _snack(
      res['message'] as String? ?? (res['success'] == true ? 'Berhasil!' : 'Gagal.'),
      success: res['success'] == true,
    );
    if (res['success'] == true) _loadData();
  }

  Future<void> _tolak(Map<String, dynamic> warga) async {
    final id = warga['id_pengguna'] as int;
    final nama = warga['nama_lengkap'] as String? ?? 'Warga';
    final tiket = warga['nomor_tiket'] as String? ?? '-';

    final alasan = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TolakDialog(nama: nama, tiket: tiket),
    );
    if (alasan == null || !mounted) return;

    setState(() => _actionInProgress.add(id));
    final res = await _api.tolakWarga(id, alasan: alasan);
    if (!mounted) return;
    setState(() => _actionInProgress.remove(id));

    _snack(
      res['message'] as String? ?? (res['success'] == true ? 'Berhasil!' : 'Gagal.'),
      success: res['success'] == true,
    );
    if (res['success'] == true) _loadData();
  }

  void _snack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppColors.primary : AppColors.error,
        duration: const Duration(seconds: 5),
      ));
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        scrolledUnderElevation: 0,
        title: Text('Verifikasi Warga', style: AppTypography.h2(color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildTabBar(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: List.generate(_tabs.length, (_) => _buildList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabCtrl,
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
      labelStyle: AppTypography.bodyMedium(color: Colors.white)
          .copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTypography.bodyMedium(),
      tabs: List.generate(_tabs.length, (i) {
        final count = (_counts[_tabs[i]] as num?)?.toInt() ?? 0;
        return Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_tabLabels[i]),
              if (count > 0) ...[
                const SizedBox(width: 6),
                _CountChip(count: count),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Cari nama, nomor tiket, atau alamat…',
          hintStyle: AppTypography.bodyMedium(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    _loadData();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_wargaList.isEmpty) {
      return _EmptyState(status: _tabs[_tabCtrl.index]);
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _wargaList.length,
        itemBuilder: (_, i) => _WargaCard(
          warga: _wargaList[i],
          isInProgress: _actionInProgress.contains(_wargaList[i]['id_pengguna']),
          onSetujui: _tabCtrl.index == 0 ? () => _setujui(_wargaList[i]) : null,
          onTolak: _tabCtrl.index == 0 ? () => _tolak(_wargaList[i]) : null,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WARGA CARD
// ─────────────────────────────────────────────────────────────────────────────

class _WargaCard extends StatelessWidget {
  const _WargaCard({
    required this.warga,
    required this.isInProgress,
    this.onSetujui,
    this.onTolak,
  });

  final Map<String, dynamic> warga;
  final bool isInProgress;
  final VoidCallback? onSetujui;
  final VoidCallback? onTolak;

  @override
  Widget build(BuildContext context) {
    final status = warga['status_verifikasi'] as String? ?? 'menunggu';
    final pembayaran = warga['status_pembayaran'] as String? ?? 'belum_lunas';
    final catatan = warga['catatan_verifikasi'] as String?;
    final biaya = (warga['uang_pendaftaran'] as num?)?.toDouble() ?? 10000;
    final tipeHunian = warga['tipe_hunian'] as String? ?? 'rumah_biasa';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Name + ticket
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        warga['nama_lengkap'] as String? ?? 'Warga Plamo',
                        style: AppTypography.bodyLarge(color: AppColors.textPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        warga['nomor_tiket'] as String? ?? '-',
                        style: AppTypography.caption(color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                // Status badge
                _StatusBadge(status: status),
              ],
            ),
          ),

          // ── Info Grid ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Alamat',
                  value: warga['alamat'] as String? ?? '-',
                ),
                _InfoRow(
                  icon: Icons.phone_android_rounded,
                  label: 'WhatsApp',
                  value: warga['no_whatsapp'] as String? ?? '-',
                ),
                _InfoRow(
                  icon: Icons.home_outlined,
                  label: 'Tipe Hunian',
                  value: _fmtHunian(tipeHunian),
                ),
                _InfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Biaya Pendaftaran',
                  value: 'Rp ${_fmtRp(biaya)}',
                  valueColor: pembayaran == 'lunas'
                      ? AppColors.success
                      : AppColors.warning,
                ),
                if (warga['created_at'] != null)
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Daftar',
                    value: warga['created_at'] as String,
                  ),
                if (catatan != null && catatan.isNotEmpty)
                  _InfoRow(
                    icon: Icons.notes_rounded,
                    label: 'Catatan',
                    value: catatan,
                  ),
              ],
            ),
          ),

          // ── Action Buttons (only for 'menunggu') ──────────────────────────
          if (onSetujui != null || onTolak != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 20, color: AppColors.borderLight),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: isInProgress
                  ? const Center(
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        // Tolak
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onTolak,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: Text(
                              'Tolak',
                              style: AppTypography.button(color: AppColors.error),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Setujui
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: onSetujui,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: Text(
                              'Setujui & Konfirmasi',
                              style: AppTypography.button(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ] else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  static String _fmtHunian(String raw) {
    switch (raw) {
      case 'rumah_biasa':
        return 'Rumah Biasa';
      case 'rumah_kos':
        return 'Rumah Kos / Kontrakan';
      default:
        return raw.replaceAll('_', ' ');
    }
  }

  static String _fmtRp(double val) {
    // Simple thousands separator
    final intVal = val.toInt();
    final s = intVal.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTypography.caption(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.caption(
                color: valueColor ?? AppColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'terverifikasi':
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        label = 'Terverifikasi';
        break;
      case 'ditolak':
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        label = 'Ditolak';
        break;
      default:
        bg = AppColors.warning.withValues(alpha: 0.12);
        fg = AppColors.warning;
        label = 'Menunggu';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.caption(color: fg).copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: AppTypography.caption(color: Colors.white)
            .copyWith(fontWeight: FontWeight.w700, height: 1),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    String msg;
    IconData ic;
    switch (status) {
      case 'terverifikasi':
        ic = Icons.verified_user_outlined;
        msg = 'Belum ada warga yang diverifikasi.';
        break;
      case 'ditolak':
        ic = Icons.cancel_outlined;
        msg = 'Belum ada pendaftaran yang ditolak.';
        break;
      default:
        ic = Icons.inbox_outlined;
        msg = 'Tidak ada pendaftaran yang menunggu verifikasi.\nTarik layar ke bawah untuk refresh.';
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ic, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DIALOGS
// ─────────────────────────────────────────────────────────────────────────────

class _SetujuiDialog extends StatefulWidget {
  const _SetujuiDialog({
    required this.nama,
    required this.tiket,
    required this.defaultBiaya,
  });
  final String nama;
  final String tiket;
  final double defaultBiaya;

  @override
  State<_SetujuiDialog> createState() => _SetujuiDialogState();
}

class _SetujuiDialogState extends State<_SetujuiDialog> {
  late final TextEditingController _biayaCtrl;
  final TextEditingController _catatanCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _biayaCtrl = TextEditingController(
      text: widget.defaultBiaya.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _biayaCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Konfirmasi Verifikasi', style: AppTypography.h3()),
                Text(
                  widget.tiket,
                  style: AppTypography.caption(color: AppColors.primary)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info warga
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.nama,
                        style: AppTypography.bodyMedium(color: AppColors.textPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Biaya Pendaftaran
              Text(
                'Biaya Kas Posko (Rp)',
                style: AppTypography.caption(color: AppColors.textSecondary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _biayaCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: AppTypography.bodyMedium(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi.';
                  final val = int.tryParse(v);
                  if (val == null || val < 0) return 'Masukkan nominal valid.';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Catatan (opsional)
              Text(
                'Catatan Verifikasi (opsional)',
                style: AppTypography.caption(color: AppColors.textSecondary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _catatanCtrl,
                maxLines: 2,
                maxLength: 255,
                style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Contoh: Warga sah, KTP sesuai domisili.',
                  hintStyle:
                      AppTypography.caption(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: AppTypography.button(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'biaya': double.parse(_biayaCtrl.text),
                'catatan': _catatanCtrl.text.trim(),
              });
            }
          },
          icon: const Icon(Icons.check_rounded, size: 18),
          label: Text('Setujui', style: AppTypography.button(color: Colors.white)),
        ),
      ],
    );
  }
}

class _TolakDialog extends StatefulWidget {
  const _TolakDialog({required this.nama, required this.tiket});
  final String nama;
  final String tiket;

  @override
  State<_TolakDialog> createState() => _TolakDialogState();
}

class _TolakDialogState extends State<_TolakDialog> {
  final TextEditingController _alasanCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _alasanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cancel_outlined,
                color: AppColors.error, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tolak Pendaftaran', style: AppTypography.h3()),
                Text(
                  widget.tiket,
                  style: AppTypography.caption(color: AppColors.error)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warga info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded,
                      color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.nama,
                      style: AppTypography.bodyMedium(color: AppColors.textPrimary)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Alasan Penolakan *',
              style: AppTypography.caption(color: AppColors.textSecondary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _alasanCtrl,
              maxLines: 3,
              maxLength: 255,
              style: AppTypography.bodyMedium(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Contoh: Bukan warga RT 05 RW 02 berdasarkan KTP.',
                hintStyle:
                    AppTypography.caption(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.error, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.error, width: 2),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Alasan penolakan wajib diisi agar warga mendapat kejelasan.';
                }
                if (v.trim().length < 10) {
                  return 'Alasan terlalu singkat. Minimal 10 karakter.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: AppTypography.button(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _alasanCtrl.text.trim());
            }
          },
          icon: const Icon(Icons.close_rounded, size: 18),
          label: Text('Tolak', style: AppTypography.button(color: Colors.white)),
        ),
      ],
    );
  }
}
