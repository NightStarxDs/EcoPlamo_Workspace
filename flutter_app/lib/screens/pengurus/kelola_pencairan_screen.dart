import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// ──────────────────────────────────────────────────────────────────────────
///  Layar Kelola Pencairan Saldo – Pengurus RT/RW
///  Menampilkan daftar pengajuan pencairan warga dan aksi setujui/tolak
/// ──────────────────────────────────────────────────────────────────────────
class KelolaPencairanScreen extends StatefulWidget {
  const KelolaPencairanScreen({super.key});

  @override
  State<KelolaPencairanScreen> createState() => _KelolaPencairanScreenState();
}

class _KelolaPencairanScreenState extends State<KelolaPencairanScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _api = AuthService();
  late final TabController _tabCtrl;

  List<Map<String, dynamic>> _menunggu = [];
  List<Map<String, dynamic>> _disetujui = [];
  List<Map<String, dynamic>> _ditolak = [];
  bool _isLoading = true;
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final all = await _api.getPencairanList();
    if (!mounted) return;
    setState(() {
      _menunggu = all.where((p) => p['status'] == 'menunggu').toList();
      _disetujui = all.where((p) => p['status'] == 'disetujui').toList();
      _ditolak = all.where((p) => p['status'] == 'ditolak').toList();
      _isLoading = false;
    });
  }

  Future<void> _validasi(Map<String, dynamic> pencairan, String aksi) async {
    final id = pencairan['id_pencairan'] as int;
    final nama = pencairan['nama_warga']?.toString() ?? 'Warga';
    final nominal = (pencairan['nominal_pencairan'] as num?)?.toDouble() ?? 0;
    final label = aksi == 'setujui' ? 'Setujui' : 'Tolak';
    final color = aksi == 'setujui' ? AppColors.primary : AppColors.error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                aksi == 'setujui'
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text('$label Pencairan', style: AppTypography.h3()),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: AppTypography.bodyMedium(),
            children: [
              TextSpan(
                  text: aksi == 'setujui'
                      ? 'Setujui pencairan sebesar '
                      : 'Tolak pengajuan pencairan sebesar '),
              TextSpan(
                  text: _fmtRp(nominal),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
              const TextSpan(text: ' oleh '),
              TextSpan(
                  text: nama,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: AppTypography.button(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: color),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(label),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _processingIds.add(id));
    HapticFeedback.mediumImpact();

    final result =
        await _api.validasiPencairan(idPencairan: id, aksi: aksi);

    if (!mounted) return;
    setState(() => _processingIds.remove(id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']?.toString() ?? 'Selesai.'),
        backgroundColor:
            result['success'] == true ? AppColors.primary : AppColors.error,
      ),
    );

    if (result['success'] == true) {
      await _loadData();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text('Kelola Pencairan', style: AppTypography.h2(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat ulang',
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: AppTypography.caption().copyWith(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Menunggu (${_menunggu.length})'),
            Tab(text: 'Disetujui (${_disetujui.length})'),
            Tab(text: 'Ditolak (${_ditolak.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(_menunggu, showActions: true),
                _buildList(_disetujui, showActions: false),
                _buildList(_ditolak, showActions: false),
              ],
            ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list, {required bool showActions}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              showActions
                  ? Icons.hourglass_empty_rounded
                  : Icons.history_rounded,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text('Tidak ada data.', style: AppTypography.h3()),
            const SizedBox(height: 6),
            Text(
              showActions ? 'Semua pengajuan telah diproses.' : 'Belum ada riwayat.',
              style: AppTypography.caption(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _pencairanCard(list[i], showActions: showActions),
      ),
    );
  }

  Widget _pencairanCard(Map<String, dynamic> p, {required bool showActions}) {
    final id = p['id_pencairan'] as int;
    final nama = p['nama_warga']?.toString() ?? 'Warga';
    final alamat = p['alamat']?.toString() ?? '-';
    final wa = p['no_whatsapp']?.toString() ?? '-';
    final nominal = (p['nominal_pencairan'] as num?)?.toDouble() ?? 0;
    final status = p['status']?.toString() ?? '-';
    final tgl = p['tanggal_pengajuan']?.toString() ?? '-';
    final isProcessing = _processingIds.contains(id);

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'disetujui':
        statusColor = AppColors.primary;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'ditolak':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.warningDark;
        statusIcon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Icon(Icons.person_rounded, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama,
                        style: AppTypography.bodyMedium()
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text(alamat, style: AppTypography.caption()),
                    Text(wa,
                        style: AppTypography.caption(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(height: 4),
                  Text(status.toUpperCase(),
                      style: AppTypography.caption(color: statusColor)
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nominal Pencairan', style: AppTypography.caption()),
                    const SizedBox(height: 2),
                    Text(_fmtRp(nominal),
                        style: AppTypography.h3(color: AppColors.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Tanggal Pengajuan', style: AppTypography.caption()),
                    const SizedBox(height: 2),
                    Text(tgl,
                        style: AppTypography.caption(color: AppColors.textSecondary)
                            .copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (showActions) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: isProcessing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.error),
                          )
                        : const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed:
                        isProcessing ? null : () => _validasi(p, 'tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: isProcessing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Setujui'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed:
                        isProcessing ? null : () => _validasi(p, 'setujui'),
                  ),
                ),
              ],
            ),
          ],
          if (!showActions && p['validasi_oleh'] != null) ...[
            const SizedBox(height: 10),
            Text(
              'Divalidasi oleh: ${p['validasi_oleh']} · ${p['tanggal_validasi'] ?? '-'}',
              style: AppTypography.caption(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
