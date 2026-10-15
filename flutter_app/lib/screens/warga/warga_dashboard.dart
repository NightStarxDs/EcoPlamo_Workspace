import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_bottom_nav.dart';

/// =========================================================================
/// Screen: Dashboard Warga (Figma Page 7) — mengikuti DESIGN_SYSTEM.md
///
///   AppBar (Page 17) → Greeting → Pocket Card → CTA → Kontribusi
///   → Aktivitas Terakhir → Klasemen → BottomNav (Page 16)
///
/// Catatan: butuh `AppTypography.sectionTitle()` (Poppins 14 / w500).
/// =========================================================================

String _rupiah(int v) =>
    'Rp ${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

// Teks putih di atas hijau: alpha >= 0.85 agar kontras tetap >= 4.5:1.
Color _onGreen([double alpha = 0.85]) => Colors.white.withValues(alpha: alpha);

// Fill progress di atas hijau: 4.2:1 terhadap #006D44 (min. 3:1 untuk komponen UI).
const Color _progressFill = Color(0xFF6EE7B7);

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.cardBg,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppColors.borderLight),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

class WargaDashboard extends StatefulWidget {
  const WargaDashboard({super.key});

  @override
  State<WargaDashboard> createState() => _WargaDashboardState();
}

class _WargaDashboardState extends State<WargaDashboard>
    with TickerProviderStateMixin {
  // --- Data sementara (ganti dengan data API) --------------------------------
  static const int _saldo = 25000;
  static const int _minPencairan = 50000;
  static const String _fallbackName = 'Dwi Agung Willy';
  double get _progress => (_saldo / _minPencairan).clamp(0.0, 1.0);

  final AuthService _authService = AuthService();
  Map<String, dynamic>? _currentUser;
  bool _isLoadingUser = true;
  int _currentNavIndex = 0;
  bool _balanceVisible = true;

  late final AnimationController _entranceController;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;
  late final AnimationController _progressController;
  late final Animation<double> _progressValue;

  String get _displayName => _isLoadingUser
      ? 'Memuat...'
      : (_currentUser?['nama_lengkap'] ?? _fallbackName);

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
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _progressValue = Tween<double>(begin: 0, end: _progress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _progressController.forward();
    });
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _isLoadingUser = false;
    });
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
            Text('Keluar Akun', style: AppTypography.h3()),
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
              backgroundColor: AppColors.error,
              // Override minimumSize theme (fromHeight) agar aman di dialog.
              minimumSize: const Size(96, 44),
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
    _progressController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
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
                  _buildGreeting(),
                  _buildPocketCard(),
                  const SizedBox(height: 14),
                  _buildCta(),
                  const SizedBox(height: 28),
                  _buildKontribusi(),
                  const SizedBox(height: 28),
                  _buildAktivitas(),
                  const SizedBox(height: 28),
                  _buildKlasemen(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: EcoBottomNavBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentNavIndex = index);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP APP BAR (Figma Page 17)
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
        // Tanpa frame hijau; BoxFit.contain menampilkan logo utuh (tidak terpotong).
        // Logo putih tampil utuh di atas AppBar hijau.
        child: Image.asset(
          'assets/images/Logo-Without-BG.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
        ),
      ),
      titleSpacing: 6,
      title: Text('Eco Plamo', style: AppTypography.h2(color: Colors.white)),
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
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tidak ada notifikasi baru saat ini.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
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
                      _currentUser?['nama_lengkap'] ?? 'Eco Warrior',
                      style: AppTypography.h3(),
                    ),
                    Text(
                      _currentUser?['no_whatsapp'] ?? '',
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
                      size: 18,
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
  // GREETING
  // ---------------------------------------------------------------------------
  Widget _buildGreeting() {
    final String blok = _currentUser?['blok_rumah'] ?? 'Blok A2 / No. 14';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
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
                      TextSpan(
                        text: '$_displayName!',
                        style: AppTypography.h3(),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        blok,
                        style: AppTypography.caption(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Warga Aktif',
                        style: AppTypography.caption(
                          color: AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Streak badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.warningDark,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '3 Hari',
                      style: AppTypography.caption(
                        color: AppColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w700, height: 1.1),
                    ),
                    Text(
                      'Streak',
                      style: AppTypography.caption().copyWith(height: 1.1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // POCKET CARD
  // ---------------------------------------------------------------------------
  Widget _buildPocketCard() {
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
          // Badges row
          Row(
            children: [
              _pocketBadge(
                icon: Icons.workspace_premium_rounded,
                iconColor: AppColors.warning,
                label: 'Kontributor Terbaik #1',
              ),
              const Spacer(),
              _pocketBadge(
                icon: Icons.recycling_rounded,
                iconColor: _onGreen(0.9),
                label: '100 Kg tahun ini',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Balance
          Text('In Pocket', style: AppTypography.caption(color: _onGreen())),
          const SizedBox(height: 4),
          Semantics(
            button: true,
            label: _balanceVisible ? 'Sembunyikan saldo' : 'Tampilkan saldo',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _balanceVisible = !_balanceVisible);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _balanceVisible
                          ? '${_rupiah(_saldo)}.-'
                          : 'Rp \u25CF\u25CF\u25CF\u25CF\u25CF\u25CF',
                      key: ValueKey(_balanceVisible),
                      style: AppTypography.displayBold(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _balanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _onGreen(0.85),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minimum pencairan',
                style: AppTypography.caption(color: _onGreen()),
              ),
              Text(
                '${_rupiah(_minPencairan)}.-',
                style: AppTypography.caption(
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (_, _) => LinearProgressIndicator(
                value: _progressValue.value,
                backgroundColor: _onGreen(0.18),
                valueColor: const AlwaysStoppedAnimation<Color>(_progressFill),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: _onGreen(0.14)),
          const SizedBox(height: 14),

          // Next redeem
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: _onGreen(0.85),
              ),
              const SizedBox(width: 6),
              Text(
                'Next Redeem: ',
                style: AppTypography.caption(color: _onGreen()),
              ),
              Text(
                '15 Oktober 2026',
                style: AppTypography.caption(
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pocketBadge({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.caption(
              color: Colors.white,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CTA — gaya tombol diambil dari ElevatedButtonTheme (52px, r12, Poppins 16)
  // ---------------------------------------------------------------------------
  Widget _buildCta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
        label: const Text('Ajukan Pencairan Tunai'),
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showPencairanBottomSheet();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------------
  Widget _sectionHeader(
    String title, {
    String? subtitle,
    Widget? trailing,
    TextStyle? style,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: style ?? AppTypography.h3()),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.caption()),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KONTRIBUSI — grid 2x2
  // ---------------------------------------------------------------------------
  Widget _buildKontribusi() {
    const items = [
      _KontribusiItem(
        icon: Icons.delete_outline_rounded,
        title: 'Total Sampah',
        value: '100',
        unit: 'Kilogram',
        accent: AppColors.primary,
      ),
      _KontribusiItem(
        icon: Icons.payments_outlined,
        title: 'Total Dicairkan',
        value: 'Rp 100rb',
        unit: 'Keseluruhan',
        accent: AppColors.infoDark,
      ),
      _KontribusiItem(
        icon: Icons.swap_horiz_rounded,
        title: 'Jumlah Setoran',
        value: '12',
        unit: 'Transaksi',
        accent: AppColors.accentDark,
      ),
      _KontribusiItem(
        icon: Icons.emoji_events_outlined,
        title: 'Peringkat Saat Ini',
        value: '#1',
        unit: 'Bulan Ini',
        accent: AppColors.warningDark,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Kontribusi Kamu',
          icon: Icons.volunteer_activism_rounded,
          trailing: Text('Oktober 2026', style: AppTypography.caption()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 110,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: item.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.icon, color: item.accent, size: 17),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTypography.caption(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(item.value, style: AppTypography.h2()),
                        ),
                        Text(item.unit, style: AppTypography.caption()),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // AKTIVITAS TERAKHIR
  // ---------------------------------------------------------------------------
  Widget _buildAktivitas() {
    const activities = [
      _AktivitasData(
        title: 'Plastik PET',
        weight: '2.5 Kg',
        date: '10 Okt',
        nominal: '+Rp 5.000',
        icon: Icons.water_drop_outlined,
      ),
      _AktivitasData(
        title: 'Kardus Bekas',
        weight: '1.5 Kg',
        date: '5 Okt',
        nominal: '+Rp 3.500',
        icon: Icons.inventory_2_outlined,
      ),
      _AktivitasData(
        title: 'Kaleng Bekas',
        weight: '4 Kg',
        date: '3 Okt',
        nominal: '+Rp 1.600',
        icon: Icons.recycling_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Aktivitas Terakhir',
          trailing: GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Text(
              'Lihat Semua',
              style: AppTypography.caption(
                color: AppColors.primary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: _cardDecoration(),
            child: Column(
              children: [
                for (int i = 0; i < activities.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            activities[i].icon,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activities[i].title,
                                style: AppTypography.bodyMedium(
                                  color: AppColors.textPrimary,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${activities[i].weight}  \u00B7  ${activities[i].date} 2026',
                                style: AppTypography.caption(),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            activities[i].nominal,
                            style: AppTypography.caption(
                              color: AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i != activities.length - 1)
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
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // KLASEMEN PLAMO GARDEN
  // ---------------------------------------------------------------------------
  Widget _buildKlasemen() {
    const entries = [
      _LeaderboardItem(
        rank: 1,
        name: 'Dwi Agung Willy Anto',
        weight: '100 Kg',
        isMe: true,
      ),
      _LeaderboardItem(rank: 2, name: 'Fauzan Najib Ali', weight: '98 Kg'),
      _LeaderboardItem(rank: 3, name: 'Ayu Diana Tasya', weight: '91 Kg'),
      _LeaderboardItem(rank: 4, name: 'Bryan Abisai Sitorus', weight: '87 Kg'),
      _LeaderboardItem(rank: 5, name: 'Muhammad Ivan', weight: '82 Kg'),
    ];
    const medal = {
      1: Color(0xFFA16207), // emas gelap 4.9:1
      2: Color(0xFF64748B), // perak gelap 4.8:1
      3: Color(0xFF9A3412), // perunggu gelap 7.3:1
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Klasemen Plamo Garden',
          subtitle: 'Oktober 2026',
          style: AppTypography.sectionTitle(),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Top 5',
              style: AppTypography.caption(
                color: AppColors.primary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: _cardDecoration(),
            child: Column(
              children: [
                for (int i = 0; i < entries.length; i++) ...[
                  Container(
                    color: entries[i].isMe
                        ? AppColors.primaryLight.withValues(alpha: 0.5)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 26,
                          child: medal[entries[i].rank] != null
                              ? Icon(
                                  Icons.military_tech_rounded,
                                  color: medal[entries[i].rank],
                                  size: 22,
                                  semanticLabel: 'Peringkat ${entries[i].rank}',
                                )
                              : Text(
                                  '${entries[i].rank}',
                                  style: AppTypography.bodyMedium(
                                    color: AppColors.textMuted,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: entries[i].isMe
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          child: Text(
                            entries[i].name[0],
                            style: AppTypography.caption(
                              color: entries[i].isMe
                                  ? AppColors.textOnPrimary
                                  : AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  entries[i].name,
                                  style:
                                      AppTypography.bodyMedium(
                                        color: AppColors.textPrimary,
                                      ).copyWith(
                                        fontWeight: entries[i].isMe
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (entries[i].isMe) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Saya',
                                    style:
                                        AppTypography.caption(
                                          color: AppColors.textOnPrimary,
                                        ).copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          entries[i].weight,
                          style: AppTypography.bodyMedium(
                            color: AppColors.textPrimary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (i != entries.length - 1)
                    const Divider(
                      height: 1,
                      indent: 52,
                      color: AppColors.borderLight,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PENCAIRAN BOTTOM SHEET (Figma Halaman 10 & 11)
  // ---------------------------------------------------------------------------
  void _showPencairanBottomSheet() {
    final int kurang = (_minPencairan - _saldo).clamp(0, _minPencairan);
    final int persen = (_progress * 100).round();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Pencairan Tunai', style: AppTypography.h2()),
                const SizedBox(height: 4),
                Text(
                  'Ajukan saldo tabungan ke kas posko',
                  style: AppTypography.bodyMedium(),
                ),
                const SizedBox(height: 16),

                // Saldo card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.wallet_outlined,
                                color: _onGreen(),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Saldo tersedia',
                                style: AppTypography.caption(color: _onGreen()),
                              ),
                            ],
                          ),
                          if (kurang > 0)
                            Text(
                              'Kurang ${_rupiah(kurang)}',
                              style: AppTypography.caption(color: Colors.white),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _rupiah(_saldo),
                        style: AppTypography.h1(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$persen% menuju minimum',
                            style: AppTypography.caption(color: _onGreen()),
                          ),
                          Text(
                            'Min. ${_rupiah(_minPencairan)}',
                            style: AppTypography.caption(color: _onGreen()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: _onGreen(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            _progressFill,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                if (kurang > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.warningDark,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Saldo belum cukup. Kumpulkan ${_rupiah(kurang)} lagi untuk mengajukan pencairan.',
                            style: AppTypography.caption(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Text('Pilihan Cepat Nominal', style: AppTypography.formLabel()),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final v in const [50000, 100000, 150000]) ...[
                      _buildQuickChip(_rupiah(v)),
                      if (v != 150000) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Metode
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Metode Pencairan',
                              style: AppTypography.caption(),
                            ),
                            Text(
                              'Ambil ke Posko Plamo Garden',
                              style: AppTypography.bodyMedium(
                                color: AppColors.textPrimary,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol mengikuti ElevatedButtonTheme; nonaktif sampai saldo cukup.
                ElevatedButton.icon(
                  icon: Icon(
                    kurang > 0
                        ? Icons.lock_outline_rounded
                        : Icons.check_rounded,
                    size: 18,
                  ),
                  label: const Text('Ajukan Pencairan'),
                  onPressed: kurang > 0 ? null : () => Navigator.pop(ctx),
                ),
                if (kurang > 0) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tombol aktif setelah saldo mencapai ${_rupiah(_minPencairan)}',
                      style: AppTypography.caption(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.caption(
              color: AppColors.textSecondary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Data models
// =============================================================================

class _KontribusiItem {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color accent;

  const _KontribusiItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.accent,
  });
}

class _AktivitasData {
  final String title;
  final String weight;
  final String date;
  final String nominal;
  final IconData icon;

  const _AktivitasData({
    required this.title,
    required this.weight,
    required this.date,
    required this.nominal,
    required this.icon,
  });
}

class _LeaderboardItem {
  final int rank;
  final String name;
  final String weight;
  final bool isMe;

  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.weight,
    this.isMe = false,
  });
}
