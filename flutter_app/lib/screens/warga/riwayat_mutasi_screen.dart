import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// ──────────────────────────────────────────────────────────────────────────
///  Layar Riwayat Mutasi Saldo (Buku Kas / Ledger Transaksi Warga)
///  Sesuai ERD: Menampilkan riwayat kredit (setoran) & debit (pencairan)
///  Dilengkapi dengan filtering: Semua, Setor Sampah, dan Tarik Tunai
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
  String _activeFilter = 'semua'; // 'semua' | 'kredit' | 'debit'

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

  List<Map<String, dynamic>> get _filteredMutasiList {
    if (_activeFilter == 'semua') return _mutasiList;
    return _mutasiList.where((item) => item['tipe'] == _activeFilter).toList();
  }

  int get _countSetor => _mutasiList.where((m) => m['tipe'] == 'kredit').length;
  int get _countTarik => _mutasiList.where((m) => m['tipe'] == 'debit').length;

  double get _totalSetor => _mutasiList
      .where((m) => m['tipe'] == 'kredit')
      .fold(0.0, (sum, m) => sum + ((m['nominal'] as num?)?.toDouble() ?? 0.0));

  double get _totalTarik => _mutasiList
      .where((m) => m['tipe'] == 'debit')
      .fold(0.0, (sum, m) => sum + ((m['nominal'] as num?)?.toDouble() ?? 0.0));

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
    final filteredList = _filteredMutasiList;

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
                  // Card Saldo Terkini & Ringkasan Perputaran
                  _buildSaldoCard(),

                  const SizedBox(height: 20),

                  // Section Header & Filter Chips
                  _buildFilterSection(filteredCount: filteredList.length),

                  const SizedBox(height: 12),

                  // Konten List atau Empty State
                  if (_mutasiList.isEmpty)
                    _buildEmptyStateGlobal()
                  else if (filteredList.isEmpty)
                    _buildEmptyStateFiltered()
                  else
                    ...filteredList.map(_buildMutasiCard),
                ],
              ),
            ),
    );
  }

  Widget _buildSaldoCard() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo Tersimpan Saat Ini',
                style: AppTypography.caption(color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_outlined, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Buku Kas Digital',
                      style: AppTypography.caption(color: Colors.white).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _fmtRp(_saldoSekarang),
            style: AppTypography.displayBold(color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Baris Akumulasi Setor (+) & Tarik (-)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          size: 14,
                          color: Color(0xFF6EE7B7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Setor',
                              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
                            ),
                            Text(
                              '+${_fmtRp(_totalSetor)}',
                              style: AppTypography.caption(color: Colors.white).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.white24),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          size: 14,
                          color: Color(0xFFFCA5A5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Tarik',
                              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
                            ),
                            Text(
                              '-${_fmtRp(_totalTarik)}',
                              style: AppTypography.caption(color: Colors.white).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({required int filteredCount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Riwayat Pergerakan Saldo', style: AppTypography.h3()),
            Text(
              '$filteredCount transaksi',
              style: AppTypography.caption(color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Filter Tabs / Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip(
                id: 'semua',
                label: 'Semua',
                count: _mutasiList.length,
                icon: Icons.receipt_long_rounded,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                id: 'kredit',
                label: 'Setor Sampah',
                count: _countSetor,
                icon: Icons.arrow_downward_rounded,
                selectedColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                id: 'debit',
                label: 'Tarik Tunai',
                count: _countTarik,
                icon: Icons.arrow_upward_rounded,
                selectedColor: AppColors.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String id,
    required String label,
    required int count,
    required IconData icon,
    Color? selectedColor,
  }) {
    final isSelected = _activeFilter == id;
    final themeColor = selectedColor ?? AppColors.primary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label, $count transaksi',
      child: Material(
        color: isSelected ? themeColor.withValues(alpha: 0.12) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _activeFilter = id);
          },
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? themeColor : AppColors.borderLight,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? themeColor : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.bodySmall().copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? themeColor : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateGlobal() {
    return Container(
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
    );
  }

  Widget _buildEmptyStateFiltered() {
    final isKredit = _activeFilter == 'kredit';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (isKredit ? AppColors.primary : AppColors.error).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isKredit ? Icons.delete_outline_rounded : Icons.account_balance_wallet_outlined,
              size: 28,
              color: isKredit ? AppColors.primary : AppColors.error,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isKredit ? 'Belum Ada Setoran Sampah' : 'Belum Ada Tarik Tunai',
            style: AppTypography.h3(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isKredit
                ? 'Setoran sampah yang ditimbang pengurus posko akan tercatat di sini sebagai saldo masuk.'
                : 'Pencairan saldo tunai yang telah divalidasi akan tercatat di sini sebagai saldo keluar.',
            textAlign: TextAlign.center,
            style: AppTypography.caption(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _activeFilter = 'semua');
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Tampilkan Semua Transaksi'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isKredit
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isKredit ? 'SETOR' : 'TARIK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isKredit ? AppColors.primary : AppColors.error,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tgl,
                        style: AppTypography.caption(color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  ket,
                  style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w700),
                ),
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
