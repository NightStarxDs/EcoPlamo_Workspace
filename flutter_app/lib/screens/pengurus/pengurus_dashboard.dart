import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_bottom_nav.dart';
import 'catat_setoran_screen.dart';
import 'kelola_pencairan_screen.dart';

// =============================================================================
// ATURAN AKSESIBILITAS / KETERBACAAN YANG DIPAKAI (sama dengan WargaDashboard)
//  • WCAG 1.4.3  kontras teks >= 4.5:1      • WCAG 1.4.11 kontras komponen >= 3:1
//  • WCAG 1.4.1  warna bukan satu-satunya penanda
//  • WCAG 1.4.4  layout tahan skala teks     • WCAG 2.5.8  target sentuh >= 48dp
//  • WCAG 3.3.1/3.3.2 galat inline + label   • WCAG 4.1.2  nama/peran/nilai semantik
//  • WCAG 2.3.3  hormati "kurangi gerakan"
// =============================================================================

/// Putih di atas hijau: alpha >= 0.85 -> kontras >= 5.1:1 terhadap #006D44.
Color _onGreen([double alpha = 0.85]) => Colors.white.withValues(alpha: alpha);

const double _kTarget = 48;

const List<String> _bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _fmtTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.cardBg,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppColors.borderLight), // dekoratif, bukan kontrol
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

class PengurusDashboard extends StatefulWidget {
  const PengurusDashboard({super.key});

  @override
  State<PengurusDashboard> createState() => _PengurusDashboardState();
}

class _PengurusDashboardState extends State<PengurusDashboard>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _currentUser;
  bool _isLoadingUser = true;

  late final AnimationController _entranceController;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;
  bool _animStarted = false;

  Map<String, dynamic> _overview = {
    'total_warga': 0,
    'total_sampah_kg': 0,
    'total_setoran': 0,
    'pencairan_menunggu': 0,
  };
  List<Map<String, dynamic>> _aktivitas = [];
  List<Map<String, dynamic>> _kategoriStats = [];

  String get _displayName => _isLoadingUser
      ? 'Memuat...'
      : (_currentUser?['nama_lengkap'] ?? 'Pengurus RT/RW');

  int get _pencairanMenunggu =>
      (_overview['pencairan_menunggu'] as num?)?.toInt() ?? 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _bodyFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.05, 0.75, curve: Curves.easeOut),
    );
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.05, 0.75, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animStarted) return;
    _animStarted = true;
    // WCAG 2.3.3 — lewati animasi jika OS meminta "kurangi gerakan".
    if (MediaQuery.disableAnimationsOf(context)) {
      _entranceController.value = 1;
    } else {
      _entranceController.forward();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      final dash = await _authService.getPengurusDashboard();
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        if (dash != null) {
          if (dash['overview'] != null) {
            _overview = Map<String, dynamic>.from(dash['overview']);
          }
          if (dash['aktivitas'] != null) {
            _aktivitas = List<Map<String, dynamic>>.from(dash['aktivitas']);
          }
          if (dash['statistik_kategori'] != null) {
            _kategoriStats = List<Map<String, dynamic>>.from(
              dash['statistik_kategori'],
            );
          }
        }
        _isLoadingUser = false;
      });
    } catch (_) {
      // Sebelumnya: jika gagal, layar tertahan "Memuat..." selamanya.
      if (!mounted) return;
      setState(() => _isLoadingUser = false);
      _snack('Gagal memuat data. Tarik layar ke bawah untuk mencoba lagi.');
    }
  }

  /// Warna teks snackbar datang dari AppTheme.snackBarTheme (putih di atas gelap).
  void _snack(String message, {Color? background}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: background,
          duration: const Duration(seconds: 5), // WCAG 2.2.1
        ),
      );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Keluar Akun', style: AppTypography.h3())),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun Eco Plamo?',
          style: AppTypography.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: AppTypography.button(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error, // putih di atasnya 4.8:1
              minimumSize: const Size(96, _kTarget),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion dihapus: AppBar sudah memakai SystemUiOverlayStyle.light
    // (ikon status bar terang di atas hijau). Wrapper lama menyatakan "dark".
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadUserData,
        child: FadeTransition(
          opacity: _bodyFade,
          child: SlideTransition(
            position: _bodySlide,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildOverviewCard(),
                const SizedBox(height: 24),
                _buildManagementSection(),
                const SizedBox(height: 32),
                _buildActivitySection(),
                const SizedBox(height: 32),
                _buildStatsSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: EcoBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          HapticFeedback.selectionClick();
          if (index == 0) return;
          if (index == 1) {
            Navigator.pushNamed(
              context,
              '/katalog',
            ).then((_) => _loadUserData());
          } else if (index == 2) {
            _openCatatSetoran();
          } else if (index == 3) {
            Navigator.pushNamed(context, '/info').then((_) => _loadUserData());
          } else if (index == 4) {
            Navigator.pushNamed(
              context,
              '/profile',
            ).then((_) => _loadUserData());
          }
        },
        onScanTap: () {
          HapticFeedback.mediumImpact();
          _openCatatSetoran();
        },
      ),
    );
  }

  void _openCatatSetoran() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CatatSetoranScreen()),
    ).then((_) => _loadUserData());
  }

  // ---------------------------------------------------------------------------
  // TOP APP BAR (Figma Page 17)
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white, // 6.4:1
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
        child: Image.asset(
          'assets/images/Logo-Without-BG.png',
          fit: BoxFit.contain,
          excludeFromSemantics: true, // dekoratif; judul sudah dibaca
          errorBuilder: (_, _, _) =>
              const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
        ),
      ),
      titleSpacing: 6,
      title: Semantics(
        header: true,
        child: Text('Eco Plamo', style: AppTypography.h2(color: Colors.white)),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifikasi',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 26,
              ),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    // Ring putih memisahkan merah dari hijau (merah vs hijau saja ≈1.3:1).
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            _snack('Tidak ada notifikasi baru saat ini.');
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: PopupMenuButton<String>(
            tooltip: 'Menu Profil',
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (v) {
              if (v == 'logout') _handleLogout();
            },
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?['nama_lengkap'] ?? 'Pengurus',
                      style: AppTypography.h3(),
                    ),
                    Text(
                      _currentUser?['role_data']?['jabatan'] ?? 'Posko Warga',
                      style: AppTypography.caption(),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Keluar',
                      style: AppTypography.bodyMedium(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    final jabatan = _currentUser?['role_data']?['jabatan'] ?? 'Posko Warga';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Halo, ',
                  style: AppTypography.bodyLarge(
                    color: AppColors.textSecondary,
                  ).copyWith(fontWeight: FontWeight.w400),
                ),
                TextSpan(text: '$_displayName!', style: AppTypography.h3()),
              ],
            ),
            maxLines: 2, // tidak terpotong total saat teks diperbesar
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.work_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  jabatan,
                  style: AppTypography.caption(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OVERVIEW CARD
  //  Hierarki: ANGKA (data) paling besar, judul kartu lebih kecil.
  //  (Sebelumnya judul 28sp lebih dominan daripada angkanya, dan label 10sp.)
  // ---------------------------------------------------------------------------
  Widget _buildOverviewCard() {
    final warga = _isLoadingUser ? '…' : '${_overview['total_warga'] ?? 0}';
    final kg = _isLoadingUser
        ? '…'
        : '${((_overview['total_sampah_kg'] as num?) ?? 0).toStringAsFixed(1)} Kg';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengurus RT/RW',
            style: AppTypography.caption(color: _onGreen()),
          ),
          const SizedBox(height: 4),
          Semantics(
            header: true,
            child: Text(
              'Kelola Warga & Sampah',
              style: AppTypography.h2(color: Colors.white), // 6.4–9.5:1
            ),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _statBadge(
                  icon: Icons.people_rounded,
                  label: 'Warga Terdaftar',
                  value: warga,
                ),
                const SizedBox(width: 12),
                _statBadge(
                  icon: Icons.delete_outline_rounded,
                  label: 'Total Sampah',
                  value: kg,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBadge({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            // Putih di atas hitam 18% di atas hijau ≈ 8.7:1.
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTypography.h1(color: Colors.white),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                // Sebelumnya fontSize 10 (di bawah minimum 11–12sp pada design system).
                style: AppTypography.caption(
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MANAJEMEN SALDO & PENCAIRAN
  // ---------------------------------------------------------------------------
  Widget _buildManagementSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Manajemen Saldo & Pencairan',
            icon: Icons.tune_rounded,
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _manageTile(
                  icon: Icons.rule_rounded,
                  label: 'Pengaturan Pencairan',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showPengaturanPencairanModal();
                  },
                ),
                const SizedBox(width: 12),
                _manageTile(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Validasi Pencairan',
                  badge: _pencairanMenunggu,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KelolaPencairanScreen(),
                      ),
                    ).then((_) => _loadUserData());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pengganti FilledButton.tonalIcon. Alasan:
  ///  • Warna tonal default M3 tidak terkendali & bentrok dengan filledButtonTheme baru.
  ///  • Label panjang ("Pengaturan Pencairan") tidak muat di tombol setengah lebar.
  /// Tile: batas 3.3:1, tinggi >= 96dp, teks 14sp textPrimary (≈16:1).
  Widget _manageTile({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    int badge = 0,
  }) {
    return Expanded(
      child: Semantics(
        button: true,
        excludeSemantics: true,
        label: badge > 0 ? '$label, $badge menunggu' : label,
        onTap: onPressed,
        child: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border, width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onPressed,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 96),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(
                            color: AppColors.textPrimary,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (badge > 0)
              Positioned(top: -6, right: -6, child: _countBadge(badge)),
          ],
        ),
      ),
    );
  }

  Widget _countBadge(int count) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.error, // putih di atasnya 4.8:1
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        // Sebelumnya TextStyle mentah 10sp di luar token tipografi.
        style: AppTypography.caption(
          color: Colors.white,
        ).copyWith(fontWeight: FontWeight.w700, height: 1),
      ),
    );
  }

  Widget _sectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Semantics(
              header: true, // TalkBack/VoiceOver bisa lompat antar bagian
              child: Text(title, style: AppTypography.h3()),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AKTIVITAS TERKINI
  // ---------------------------------------------------------------------------
  Widget _buildActivitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Aktivitas Terkini', icon: Icons.history_rounded),
          Container(
            decoration: _cardDecoration(),
            child: _aktivitas.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Belum ada aktivitas baru.',
                        style: AppTypography.bodySmall(
                          color: AppColors.textSecondary,
                        ).copyWith(height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < _aktivitas.length; i++) ...[
                        _activityItem(
                          icon: _aktivitas[i]['icon'] == 'person_add'
                              ? Icons.person_add
                              : Icons.delete_outline_rounded,
                          title: _aktivitas[i]['title'] ?? 'Aktivitas',
                          value:
                              _aktivitas[i]['description'] ??
                              _aktivitas[i]['value'] ??
                              '',
                          time: _aktivitas[i]['time'] ?? 'Baru saja',
                        ),
                        if (i != _aktivitas.length - 1)
                          const Divider(
                            height: 1,
                            indent: 68,
                            endIndent: 16,
                            color: AppColors.borderLight,
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required String title,
    required String value,
    required String time,
  }) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    // Judul = teks terpenting baris -> textPrimary (≈16:1),
                    // bukan textSecondary seperti sebelumnya.
                    style: AppTypography.bodyMedium(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: AppTypography.caption()),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Batasi lebar agar waktu panjang tidak mendorong/overflow baris.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: Text(
                time,
                textAlign: TextAlign.right,
                style: AppTypography.caption(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATISTIK
  // ---------------------------------------------------------------------------
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sebelumnya judul ini berupa teks 14sp biasa di dalam kartu, berbeda
          // dari dua bagian lain (prinsip kesamaan/konsistensi Gestalt).
          _sectionHeader(
            'Statistik Kategori Sampah',
            icon: Icons.bar_chart_rounded,
          ),
          Container(
            width: double.infinity,
            decoration: _cardDecoration(),
            padding: const EdgeInsets.all(16),
            child: _kategoriStats.isEmpty
                ? Text(
                    'Belum ada data statistik.',
                    style: AppTypography.bodySmall(
                      color: AppColors.textSecondary,
                    ).copyWith(height: 1.5),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < _kategoriStats.length; i++) ...[
                        _statBar(
                          label:
                              '${_kategoriStats[i]['kategori']} (${(_kategoriStats[i]['total_kg'] as num?)?.toStringAsFixed(1) ?? '0'} Kg)',
                          value:
                              ((_kategoriStats[i]['persentase'] as num?)
                                          ?.toInt() ??
                                      0)
                                  .clamp(0, 100),
                          color: AppColors.primary,
                        ),
                        if (i != _kategoriStats.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statBar({
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // Label & persentase = data -> 14sp (sebelumnya caption 12sp).
              child: Text(
                label,
                style: AppTypography.bodyMedium(color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$value%', // angka tertulis -> nilai tidak hanya lewat panjang bar
              style: AppTypography.bodyMedium(
                color: color,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value / 100,
            // Fill hijau vs track: ≈4.9:1 (≥3:1 untuk komponen UI).
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            semanticsLabel: label,
            semanticsValue: '$value persen',
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PENGATURAN PENCAIRAN (bottom sheet)
  // ---------------------------------------------------------------------------
  Future<void> _showPengaturanPencairanModal() async {
    final message = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PengaturanPencairanSheet(authService: _authService),
    );
    if (message != null && mounted) {
      _snack(message);
      _loadUserData();
    }
  }
}

// =============================================================================
// Bottom sheet sebagai StatefulWidget sendiri.
//
// Versi lama memanggil FutureBuilder(future: getPengaturanPencairan()) dan
// membuat TextEditingController DI DALAM builder. Builder route dijalankan
// ulang saat keyboard muncul (MediaQuery.viewInsets berubah) -> data diambil
// ulang, spinner muncul lagi, dan teks yang sedang diketik HILANG. Controller
// juga tidak pernah di-dispose. Di sini: fetch sekali di initState, controller
// dimiliki State, dan dibuang di dispose().
// =============================================================================
class _PengaturanPencairanSheet extends StatefulWidget {
  final AuthService authService;
  const _PengaturanPencairanSheet({required this.authService});

  @override
  State<_PengaturanPencairanSheet> createState() =>
      _PengaturanPencairanSheetState();
}

class _PengaturanPencairanSheetState extends State<_PengaturanPencairanSheet> {
  final TextEditingController _minCtrl = TextEditingController();
  final TextEditingController _mulaiCtrl = TextEditingController();
  final TextEditingController _selesaiCtrl = TextEditingController();
  DateTime? _mulai;
  DateTime? _selesai;

  bool _loading = true;
  bool _loadFailed = false;
  bool _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _mulaiCtrl.dispose();
    _selesaiCtrl.dispose();
    super.dispose();
  }

  void _setMulai(DateTime d) {
    _mulai = d;
    _mulaiCtrl.text = _fmtTanggal(d);
  }

  void _setSelesai(DateTime d) {
    _selesai = d;
    _selesaiCtrl.text = _fmtTanggal(d);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final data = await widget.authService.getPengaturanPencairan();
      if (!mounted) return;
      final now = DateTime.now();
      final min = (data['target_minimal'] as num?)?.toInt() ?? 50000;
      setState(() {
        _minCtrl.text = min.toString();
        // Fallback = bulan berjalan (sebelumnya tanggal hardcode 2026-10-01/31).
        _setMulai(
          DateTime.tryParse(data['tanggal_mulai']?.toString() ?? '') ??
              DateTime(now.year, now.month, 1),
        );
        _setSelesai(
          DateTime.tryParse(data['tanggal_selesai']?.toString() ?? '') ??
              DateTime(now.year, now.month + 1, 0),
        );
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

  // ---- Validasi inline (WCAG 3.3.1) ----------------------------------------
  int? get _nominal => int.tryParse(_minCtrl.text.trim());

  String? get _nominalError {
    if (_minCtrl.text.trim().isEmpty) return 'Wajib diisi';
    final n = _nominal;
    if (n == null || n < 5000) return 'Minimal Rp 5.000';
    return null;
  }

  String? get _tanggalError {
    if (_mulai != null && _selesai != null && _selesai!.isBefore(_mulai!)) {
      return 'Tanggal selesai harus sama dengan atau setelah tanggal mulai';
    }
    return null;
  }

  bool get _canSave =>
      !_saving &&
      _mulai != null &&
      _selesai != null &&
      _nominalError == null &&
      _tanggalError == null;

  Future<void> _pickDate({required bool isMulai}) async {
    final initial = (isMulai ? _mulai : _selesai) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: isMulai ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
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

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saveError = null;
    });
    HapticFeedback.mediumImpact();
    try {
      final res = await widget.authService.simpanPengaturanPencairan(
        targetMinimal: _nominal!.toDouble(),
        tanggalMulai: _iso(_mulai!),
        tanggalSelesai: _iso(_selesai!),
      );
      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pop(
          context,
          res['message']?.toString() ?? 'Pengaturan pencairan tersimpan.',
        );
      } else {
        // Sheet tetap terbuka: input pengurus tidak hilang, pesan tidak lenyap.
        setState(() {
          _saving = false;
          _saveError =
              res['message']?.toString() ?? 'Gagal menyimpan pengaturan.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError =
            'Gagal menyimpan pengaturan. Periksa koneksi lalu coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors
                        .border, // 3.3:1 (sebelumnya grey.shade300 ≈1.5:1)
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.rule_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'Pengaturan Pencairan',
                            style: AppTypography.h3(),
                          ),
                        ),
                        Text(
                          'Tentukan batas minimal saldo & periode klaim warga',
                          style: AppTypography.caption(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      semanticsLabel: 'Memuat pengaturan pencairan',
                    ),
                  ),
                )
              else if (_loadFailed)
                _buildLoadFailed()
              else
                ..._buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadFailed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _messageBox(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          text: 'Pengaturan pencairan gagal dimuat.',
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('Coba Lagi'),
          ),
        ),
      ],
    );
  }

  /// Kotak pesan: ikon + teks gelap (≈16:1). Tidak mengandalkan teks merah di
  /// atas tint merah (≈4.5:1, terlalu mepet).
  Widget _messageBox({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium(
                color: AppColors.textPrimary,
              ).copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildForm() {
    return [
      // Label permanen via labelText (terhubung ke field untuk screen reader),
      // border/fokus/galat diwarisi dari AppTheme.inputDecorationTheme.
      TextField(
        controller: _minCtrl,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        enabled: !_saving,
        onChanged: (_) => setState(() {}),
        style: AppTypography.h3(),
        decoration: InputDecoration(
          labelText: 'Target minimal saldo pencairan',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixText: 'Rp  ',
          prefixStyle: AppTypography.h3(color: AppColors.primary),
          hintText: 'Contoh: 50000',
          errorText: _nominalError,
        ),
      ),
      const SizedBox(height: 20),
      // Pemilih tanggal menggantikan ketik manual "YYYY-MM-DD" (pencegahan galat,
      // Nielsen #5) dan field disusun vertikal agar tanggal tidak terpotong.
      TextField(
        controller: _mulaiCtrl,
        readOnly: true,
        enabled: !_saving,
        onTap: () => _pickDate(isMulai: true),
        style: AppTypography.h3(),
        decoration: const InputDecoration(
          labelText: 'Tanggal mulai',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: 'Pilih tanggal',
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primary,
          ),
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _selesaiCtrl,
        readOnly: true,
        enabled: !_saving,
        onTap: () => _pickDate(isMulai: false),
        style: AppTypography.h3(),
        decoration: InputDecoration(
          labelText: 'Tanggal selesai',
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: 'Pilih tanggal',
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primary,
          ),
          errorText: _tanggalError,
          errorMaxLines: 3,
        ),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Warga hanya dapat mengajukan klaim jika saldo tabungannya telah mencapai atau melampaui target minimal yang ditetapkan.',
                // Penjelasan aturan = isi penting -> 14sp, line-height 1.5, 8.4:1.
                style: AppTypography.bodyMedium(
                  color: AppColors.textSecondary,
                ).copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
      if (_saveError != null) ...[
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true, // dibacakan otomatis oleh screen reader
          child: _messageBox(
            icon: Icons.error_outline_rounded,
            iconColor: AppColors.error,
            text: _saveError!,
          ),
        ),
      ],
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _canSave ? _save : null,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                    semanticsLabel: 'Menyimpan',
                  ),
                )
              : const Text('Simpan Aturan Pencairan'),
        ),
      ),
    ];
  }
}
