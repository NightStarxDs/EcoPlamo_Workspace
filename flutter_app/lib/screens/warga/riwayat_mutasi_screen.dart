import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// ──────────────────────────────────────────────────────────────────────────
///  Layar Riwayat Mutasi Saldo (Buku Kas / Ledger Transaksi Warga)
///  Sesuai ERD: Menampilkan riwayat kredit (setoran) & debit (pencairan)
/// ──────────────────────────────────────────────────────────────────────────
class RiwayatMutasiScreen extends StatefulWidget {
  const RiwayatMutasiScreen({super.key});

  @override
  State<RiwayatMutasiScreen> createState() => _RiwayatMutasiScreenState();
}

class _RiwayatMutasiScreenState extends State<RiwayatMutasiScreen> {
  final AuthService _api = AuthService();
  bool _isLoading = true;
  double _saldoSekarang = 0.0;
  List<Map<String, dynamic>> _mutasiList = [];

  @override
  void initState() {
    super.initState();
    _loadMutasi();
  }

  Future<void> _loadMutasi() async {
    setState(() => _isLoading = true);
    final res = await _api.getMutasiSaldoWarga();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _saldoSekarang = (res['saldo_sekarang'] as num?)?.toDouble() ?? 0.0;
      _mutasiList = List<Map<String, dynamic>>.from(res['data'] ?? []);
    });
  }

  String _fmtRp(double v) {
    final s = v.abs().toStringAsFixed(0);
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
        title: Text('Buku Mutasi Saldo', style: AppTypography.h2(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: _loadMutasi,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadMutasi,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.all(16),
                children: [
                  // Card Saldo Terkini
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Saldo Tersimpan Saat Ini',
                            style: AppTypography.caption(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text(
                          _fmtRp(_saldoSekarang),
                          style: AppTypography.displayBold(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_outlined, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Data ledger tercatat otomatis',
                                style: AppTypography.caption(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Riwayat Pergerakan Saldo', style: AppTypography.h3()),
                      Text('${_mutasiList.length} transaksi', style: AppTypography.caption()),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_mutasiList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 54, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('Belum ada riwayat mutasi.', style: AppTypography.h3()),
                          const SizedBox(height: 4),
                          Text(
                            'Mutasi akan muncul setiap Anda menyetor sampah atau mencairkan saldo.',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption(),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._mutasiList.map(_buildMutasiCard),
                ],
              ),
            ),
    );
  }

  Widget _buildMutasiCard(Map<String, dynamic> item) {
    final isKredit = item['tipe'] == 'kredit';
    final nominal = (item['nominal'] as num?)?.toDouble() ?? 0.0;
    final saldoSetelah = (item['saldo_setelah'] as num?)?.toDouble() ?? 0.0;
    final ket = item['keterangan']?.toString() ?? 'Transaksi Saldo';
    final tgl = item['tanggal']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Bulat
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isKredit
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isKredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isKredit ? AppColors.primary : AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Deskripsi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ket,
                  style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(tgl, style: AppTypography.caption(color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Text(
                  'Saldo akhir: ${_fmtRp(saldoSetelah)}',
                  style: AppTypography.caption(color: AppColors.textSecondary)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Nominal +/-
          Text(
            '${isKredit ? '+' : '-'}${_fmtRp(nominal)}',
            style: AppTypography.bodyMedium().copyWith(
              color: isKredit ? AppColors.primary : AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
