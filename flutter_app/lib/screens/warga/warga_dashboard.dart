import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_bottom_nav.dart';
<<<<<<< Updated upstream

/// =========================================================================
/// Screen: Dashboard Warga (Figma Page 7) — mengikuti DESIGN_SYSTEM.md
///
///   AppBar (Page 17) → Greeting → Pocket Card → CTA → Kontribusi
///   → Aktivitas Terakhir → Klasemen → BottomNav (Page 16)
///
/// Catatan: butuh `AppTypography.sectionTitle()` (Poppins 14 / w500).
/// =========================================================================
=======
import '../../widgets/eco_scan_modal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'riwayat_mutasi_screen.dart';

// =============================================================================
// ACCESSIBILITY / READABILITY RULES USED IN THIS FILE
//  • WCAG 1.4.3  Text contrast  >= 4.5:1 (normal text), 3:1 (large text)
//  • WCAG 1.4.11 Non-text contrast >= 3:1 (input borders, chips, icons)
//  • WCAG 1.4.1  Colour is never the only carrier of meaning
//  • WCAG 1.4.4  Layout survives text scaling up to 200%
//  • WCAG 2.5.8 / Material / Apple HIG: touch targets >= 48dp
//  • WCAG 3.3.1  Errors are shown inline as text, not only in a transient snackbar
//  • WCAG 4.1.2 / 1.3.1  Names, roles, values and headings exposed to TalkBack/VoiceOver
//  • WCAG 2.3.3  Honour "reduce motion" (MediaQuery.disableAnimations)
// =============================================================================
>>>>>>> Stashed changes

String _rupiah(int v) =>
    'Rp ${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

<<<<<<< Updated upstream
// Teks putih di atas hijau: alpha >= 0.85 agar kontras tetap >= 4.5:1.
Color _onGreen([double alpha = 0.85]) => Colors.white.withValues(alpha: alpha);

// Fill progress di atas hijau: 4.2:1 terhadap #006D44 (min. 3:1 untuk komponen UI).
const Color _progressFill = Color(0xFF6EE7B7);

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.cardBg,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppColors.borderLight),
=======
/// Putih di atas hijau: alpha >= 0.85 -> kontras >= 5.1:1 terhadap #006D44.
Color _onGreen([double alpha = 0.85]) => Colors.white.withValues(alpha: alpha);

/// Fill progress di atas hijau: 4.2:1 terhadap #006D44 (min. 3:1 untuk komponen UI).
const Color _progressFill = Color(0xFF6EE7B7);

/// Tint amber 10% di atas putih. Teks AppColors.warningDark (#B45309) di atas
/// tint ini ≈ 4.6:1. (Tint 15% hanya ≈ 4.47:1 -> GAGAL AA, jangan dipakai.)
Color _warningTint() => AppColors.warning.withValues(alpha: 0.10);

/// Ukuran target sentuh minimum (WCAG 2.5.8 / Material 48dp).
const double _kTarget = 48;

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.cardBg,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppColors.borderLight), // dekoratif, bukan kontrol
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
  // --- Data sementara (ganti dengan data API) --------------------------------
  static const int _saldo = 25000;
  static const int _minPencairan = 50000;
  static const String _fallbackName = 'Dwi Agung Willy';
  double get _progress => (_saldo / _minPencairan).clamp(0.0, 1.0);
=======
  int _saldo = 0;
  int _minPencairan = 50000;
  String _nextRedeem = '-';
  Map<String, dynamic>? _pencairanMenunggu;
  Map<String, dynamic> _kontribusiData = {
    'total_sampah_kg': 0,
    'total_dicairkan_rp': 0,
    'jumlah_setoran': 0,
    'peringkat': '#1',
  };
  List<_AktivitasData> _aktivitasList = [];
  List<_LeaderboardItem> _klasemenList = [];
  static const String _fallbackName = 'Warga Eco Plamo';

  // Medali: putih di atasnya >= 4.7:1 (emas 4.9, perak 4.8, perunggu 7.3).
  static const Map<int, Color> _medal = {
    1: Color(0xFFA16207),
    2: Color(0xFF64748B),
    3: Color(0xFF9A3412),
  };

  double get _progress =>
      _minPencairan > 0 ? (_saldo / _minPencairan).clamp(0.0, 1.0) : 0.0;
>>>>>>> Stashed changes

  final AuthService _authService = AuthService();
  Map<String, dynamic>? _currentUser;
  bool _isLoadingUser = true;
<<<<<<< Updated upstream
  int _currentNavIndex = 0;
=======
>>>>>>> Stashed changes
  bool _balanceVisible = true;

  late final AnimationController _entranceController;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;
  late final AnimationController _progressController;
<<<<<<< Updated upstream
  late final Animation<double> _progressValue;
=======
  bool _animStarted = false;
  bool _reduceMotion = false;
>>>>>>> Stashed changes

  String get _displayName => _isLoadingUser
      ? 'Memuat...'
      : (_currentUser?['nama_lengkap'] ?? _fallbackName);

<<<<<<< Updated upstream
=======
  String get _balanceText => _isLoadingUser ? 'Memuat…' : _rupiah(_saldo);

  String get _nextRedeemLabel =>
      (_nextRedeem.trim().isEmpty || _nextRedeem.trim() == '-')
      ? 'Belum dijadwalkan'
      : _nextRedeem;

  String get _bulanTahunAktif {
    const months = [
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
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // WCAG 2.3.3 — hormati pengaturan "kurangi gerakan" milik OS.
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_animStarted) return;
    _animStarted = true;
    if (_reduceMotion) {
      _entranceController.value = 1;
      _progressController.value = 1;
    } else {
      _entranceController.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _progressController.forward();
      });
    }
  }

  void _playProgress() {
    if (_reduceMotion) {
      _progressController.value = 1;
    } else {
      _progressController.forward(from: 0);
    }
  }

  IconData _resolveIcon(String iconKey) {
    switch (iconKey) {
      case 'water_drop_outlined':
        return Icons.water_drop_outlined;
      case 'inventory_2_outlined':
        return Icons.inventory_2_outlined;
      case 'recycling_rounded':
        return Icons.recycling_rounded;
      case 'oil_barrel_rounded':
        return Icons.water_damage_outlined;
      default:
        return Icons.delete_outline_rounded;
    }
  }

  Future<void> _loadUserData() async {
    final user = await _authService.refreshCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      if (user != null && user['role_data'] != null) {
        final roleData = user['role_data'];
        if (roleData['total_saldo'] != null) {
          _saldo = (roleData['total_saldo'] as num).toInt();
        }
      }
    });

    try {
      final dash = await _authService.getWargaDashboard();
      if (!mounted) return;
      setState(() {
        if (dash != null) {
          if (dash['user'] != null) {
            _currentUser = {...?_currentUser, ...dash['user']};
          }
          _saldo = (dash['saldo'] as num?)?.toInt() ?? _saldo;
          _minPencairan = (dash['min_pencairan'] as num?)?.toInt() ?? 50000;
          _nextRedeem = dash['next_redeem'] ?? '-';
          _pencairanMenunggu = dash['pencairan_menunggu'];
          if (dash['kontribusi'] != null) {
            _kontribusiData = Map<String, dynamic>.from(dash['kontribusi']);
          }
          if (dash['aktivitas'] != null) {
            _aktivitasList = (dash['aktivitas'] as List).map((a) {
              return _AktivitasData(
                title: a['title'] ?? 'Setoran',
                weight: a['weight'] ?? '0 Kg',
                date: a['date'] ?? '-',
                nominal: a['nominal'] ?? '+Rp 0',
                icon: _resolveIcon(a['icon'] ?? ''),
              );
            }).toList();
          }
          if (dash['klasemen'] != null) {
            _klasemenList = (dash['klasemen'] as List).map((k) {
              return _LeaderboardItem(
                rank: (k['rank'] as num?)?.toInt() ?? 1,
                name: k['nama'] ?? 'Warga',
                weight:
                    '${(k['total_kg'] as num?)?.toStringAsFixed(1) ?? '0'} Kg',
                isMe: k['is_current_user'] == true,
              );
            }).toList();
          }
          _playProgress();
        }
        _isLoadingUser = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  /// Snackbar seragam. Warna teks datang dari AppTheme.snackBarTheme (putih).
  /// Durasi 5 dtk (WCAG 2.2.1: beri waktu cukup untuk membaca).
  void _snack(String message, {Color? background}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: background,
          duration: const Duration(seconds: 5),
        ),
      );
  }

  void _toggleBalance() {
    HapticFeedback.selectionClick();
    setState(() => _balanceVisible = !_balanceVisible);
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
            Text('Keluar Akun', style: AppTypography.h3()),
=======
            Expanded(child: Text('Keluar Akun', style: AppTypography.h3())),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
              backgroundColor: AppColors.error,
              // Override minimumSize theme (fromHeight) agar aman di dialog.
              minimumSize: const Size(96, 44),
=======
              backgroundColor: AppColors.error, // putih di atasnya 4.8:1
              minimumSize: const Size(96, _kTarget),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
            if (index == 1) {
              Navigator.pushNamed(context, '/katalog');
              return;
            }
            setState(() => _currentNavIndex = index);
          },
        ),
=======
    // AnnotatedRegion dihapus: AppBar sudah mengatur systemOverlayStyle.light
    // (ikon status bar terang di atas hijau). Wrapper lama menyatakan "dark"
    // sehingga membingungkan dan berisiko ikon gelap di atas hijau.
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
                _buildGreeting(),
                _buildPocketCard(),
                const SizedBox(height: 16),
                _buildCta(),
                const SizedBox(height: 32),
                _buildKontribusi(),
                const SizedBox(height: 32),
                _buildAktivitas(),
                const SizedBox(height: 32),
                _buildKlasemen(),
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
            Navigator.pushNamed(context, '/katalog');
          } else if (index == 2) {
            EcoScanModal.show(context);
          } else if (index == 3) {
            Navigator.pushNamed(context, '/info');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        onScanTap: () => EcoScanModal.show(context),
>>>>>>> Stashed changes
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP APP BAR (Figma Page 17)
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
<<<<<<< Updated upstream
      foregroundColor: Colors.white,
=======
      foregroundColor: Colors.white, // 6.4:1
>>>>>>> Stashed changes
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
<<<<<<< Updated upstream
        // Tanpa frame hijau; BoxFit.contain menampilkan logo utuh (tidak terpotong).
        // Logo putih tampil utuh di atas AppBar hijau.
        child: Image.asset(
          'assets/images/Logo-Without-BG.png',
          fit: BoxFit.contain,
=======
        child: Image.asset(
          'assets/images/Logo-Without-BG.png',
          fit: BoxFit.contain,
          excludeFromSemantics:
              true, // dekoratif; judul "Eco Plamo" sudah dibaca
>>>>>>> Stashed changes
          errorBuilder: (_, _, _) =>
              const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
        ),
      ),
      titleSpacing: 6,
<<<<<<< Updated upstream
      title: Text('Eco Plamo', style: AppTypography.h2(color: Colors.white)),
=======
      title: Semantics(
        header: true,
        child: Text('Eco Plamo', style: AppTypography.h2(color: Colors.white)),
      ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
=======
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    // Ring putih memisahkan titik merah dari hijau (merah vs hijau
                    // saja hanya ≈1.3:1 dan sulit bagi buta warna merah-hijau).
>>>>>>> Stashed changes
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
<<<<<<< Updated upstream
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
=======
            _snack('Tidak ada notifikasi baru saat ini.');
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
>>>>>>> Stashed changes
          child: PopupMenuButton<String>(
            tooltip: 'Menu Profil',
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (v) {
<<<<<<< Updated upstream
              if (v == 'logout') _handleLogout();
=======
              if (v == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (v == 'logout') {
                _handleLogout();
              }
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                    Text(
                      _currentUser?['nama_lengkap'] ?? 'Eco Warrior',
                      style: AppTypography.h3(),
                    ),
=======
                    Text(_displayName, style: AppTypography.h3()),
>>>>>>> Stashed changes
                    Text(
                      _currentUser?['no_whatsapp'] ?? '',
                      style: AppTypography.caption(),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
<<<<<<< Updated upstream
=======
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Profil Saya',
                      style: AppTypography.bodyMedium(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
>>>>>>> Stashed changes
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
<<<<<<< Updated upstream
                      size: 18,
=======
                      size: 20,
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
    final String blok = _currentUser?['blok_rumah'] ?? 'Blok A2 / No. 14';
=======
    final String blok =
        _currentUser?['role_data']?['alamat'] ??
        _currentUser?['role_data']?['blok_rumah'] ??
        _currentUser?['alamat'] ??
        _currentUser?['blok_rumah'] ??
        '-';
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
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
=======
                  // 2 baris: nama panjang / teks diperbesar tidak terpotong total.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.home_outlined,
                          size: 16,
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
                      ],
                    ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                        'Warga Aktif',
=======
                        'Warga Aktif', // primary di atas primaryLight 5.7:1
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
          // Streak badge (nilai "3 Hari" masih hardcode — lihat catatan).
          Semantics(
            label: 'Streak 3 hari berturut-turut',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _warningTint(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warningDark.withValues(alpha: 0.4),
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
                        ).copyWith(fontWeight: FontWeight.w700, height: 1.2),
                      ),
                      Text(
                        'Streak',
                        style: AppTypography.caption().copyWith(height: 1.2),
                      ),
                    ],
                  ),
                ],
              ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
    final pct = (_progress * 100).round();
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
          // Wrap (bukan Row+Spacer): tidak overflow saat teks diperbesar.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            spacing: 8,
            children: [
              _pocketBadge(
                icon: Icons.workspace_premium_rounded,
                iconColor:
                    AppColors.warning, // ≈3.8:1 di atas badge gelap (ikon ≥3:1)
                label: 'Peringkat ${_kontribusiData['peringkat'] ?? '#1'}',
              ),
              _pocketBadge(
                icon: Icons.recycling_rounded,
                iconColor: _onGreen(0.9),
                label:
                    '${((_kontribusiData['total_sampah_kg'] as num?) ?? 0).toStringAsFixed(1)} Kg terkumpul',
>>>>>>> Stashed changes
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Balance
          Text('In Pocket', style: AppTypography.caption(color: _onGreen())),
          const SizedBox(height: 4),
          Semantics(
            button: true,
<<<<<<< Updated upstream
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
=======
            excludeSemantics:
                true, // bacakan label ini, bukan "titik titik titik"
            label: _balanceVisible
                ? 'Saldo ${_rupiah(_saldo)}. Ketuk untuk menyembunyikan saldo'
                : 'Saldo disembunyikan. Ketuk untuk menampilkan saldo',
            onTap: _toggleBalance,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleBalance,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _kTarget),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: _reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        child: FittedBox(
                          key: ValueKey(_balanceVisible),
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _balanceVisible
                                ? _balanceText
                                : 'Rp \u25CF\u25CF\u25CF\u25CF\u25CF\u25CF',
                            style: AppTypography.displayBold(
                              color: Colors.white, // 6.4–9.5:1
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      _balanceVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _onGreen(0.9),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Minimum pencairan ($pct%)',
                  style: AppTypography.caption(color: _onGreen()),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _rupiah(_minPencairan),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                value: _progressValue.value,
                backgroundColor: _onGreen(0.18),
                valueColor: const AlwaysStoppedAnimation<Color>(_progressFill),
                minHeight: 8,
=======
                value: (_progressController.value * _progress).clamp(0.0, 1.0),
                backgroundColor: _onGreen(0.18),
                valueColor: const AlwaysStoppedAnimation<Color>(_progressFill),
                minHeight: 8,
                semanticsLabel: 'Progres menuju minimum pencairan',
                semanticsValue: '$pct persen',
>>>>>>> Stashed changes
              ),
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: _onGreen(0.14)),
<<<<<<< Updated upstream
          const SizedBox(height: 14),
=======
          const SizedBox(height: 16),
>>>>>>> Stashed changes

          // Next redeem
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
<<<<<<< Updated upstream
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
=======
                size: 16,
                color: _onGreen(0.9),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Next Redeem: ',
                        style: AppTypography.caption(color: _onGreen()),
                      ),
                      TextSpan(
                        text: _nextRedeemLabel,
                        style: AppTypography.caption(
                          color: Colors.white,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.caption(
              color: Colors.white,
            ).copyWith(fontWeight: FontWeight.w500),
=======
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption(
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
>>>>>>> Stashed changes
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
<<<<<<< Updated upstream
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
=======
  // CTA — 1 aksi utama (full width) + 2 aksi sekunder berlabel
  //  • Hierarki visual jelas (primer vs sekunder), muat di layar 360dp
  //  • Tidak ada tombol ikon-saja (Nielsen #6: recognition rather than recall)
  //  • Status "menunggu" jadi banner permanen, bukan snackbar 2 detik
  // ---------------------------------------------------------------------------
  Widget _buildCta() {
    final pending = _pencairanMenunggu != null;
    final pendingNominal =
        (_pencairanMenunggu?['nominal'] as num?)?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (pending) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _warningTint(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warningDark.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.hourglass_empty_rounded,
                    color: AppColors.warningDark,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pengajuan pencairan ${_rupiah(pendingNominal)} sedang menunggu validasi pengurus.',
                      style: AppTypography.bodyMedium(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(
                pending
                    ? Icons.hourglass_empty_rounded
                    : Icons.account_balance_wallet_outlined,
                size: 20,
              ),
              label: Text(pending ? 'Menunggu Validasi' : 'Cairkan Saldo'),
              onPressed: pending
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      _showPencairanBottomSheet();
                    },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _secondaryAction(
                  icon: Icons.qr_code_rounded,
                  label: 'QR Warga',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _showWargaQrModal();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _secondaryAction(
                  icon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RiwayatMutasiScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      // Border hijau 6.4:1 (≥3:1 untuk batas komponen), teks hijau 6.4:1.
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTypography.button().copyWith(fontSize: 15),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  void _showWargaQrModal() {
    final userId = _currentUser?['id_pengguna']?.toString() ?? '1';
    final nama = _currentUser?['nama_lengkap']?.toString() ?? _fallbackName;
    final wa = _currentUser?['no_whatsapp']?.toString() ?? '-';
    final blok =
        _currentUser?['role_data']?['alamat'] ??
        _currentUser?['role_data']?['blok_rumah'] ??
        _currentUser?['alamat'] ??
        '-';

    // QR Payload Format: ECOPLAMO:WARGA:<id>:<no_whatsapp>
    final qrPayload = 'ECOPLAMO:WARGA:$userId:$wa';

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
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors
                        .border, // 3.3:1 (sebelumnya grey.shade300 ≈1.5:1)
                    borderRadius: BorderRadius.circular(3),
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
                        Icons.qr_code_2_rounded,
                        color: AppColors.primary,
                        size: 24,
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
                              'Kartu QR Warga',
                              style: AppTypography.h3(),
                            ),
                          ),
                          Text(
                            'Tunjukkan QR ini ke Pengurus Posko',
                            style: AppTypography.caption(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Semantics(
                          image: true,
                          label: 'Kode QR milik $nama, ID $userId',
                          excludeSemantics: true,
                          child: QrImageView(
                            data: qrPayload,
                            version: QrVersions.auto,
                            size: 210.0,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.primary,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        nama,
                        style: AppTypography.h3(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$blok  •  $wa',
                        style: AppTypography.caption(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
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
                          'ID: #$userId',
                          style: AppTypography.caption(
                            color: AppColors.primary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pengurus dapat memindai kode ini langsung saat menimbang sampah untuk input tanpa ketik manual.',
                  // Paragraf: line-height 1.5 (WCAG 1.4.12) & warna 8.4:1.
                  style: AppTypography.bodySmall(
                    color: AppColors.textSecondary,
                  ).copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup'),
                  ),
                ),
              ],
            ),
          ),
        ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
            const SizedBox(width: 10),
=======
            const SizedBox(width: 12),
>>>>>>> Stashed changes
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< Updated upstream
                Text(title, style: style ?? AppTypography.h3()),
=======
                // header: true -> pengguna TalkBack/VoiceOver bisa lompat antar bagian.
                Semantics(
                  header: true,
                  child: Text(title, style: style ?? AppTypography.h3()),
                ),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
  // KONTRIBUSI — grid 2x2
  // ---------------------------------------------------------------------------
  Widget _buildKontribusi() {
    const items = [
      _KontribusiItem(
        icon: Icons.delete_outline_rounded,
        title: 'Total Sampah',
        value: '100',
=======
  // KONTRIBUSI — grid 2x2 (1 kolom bila teks diperbesar > 130%)
  // ---------------------------------------------------------------------------
  Widget _buildKontribusi() {
    final totalKg =
        (_kontribusiData['total_sampah_kg'] as num?)?.toStringAsFixed(1) ?? '0';
    final totalCair =
        (_kontribusiData['total_dicairkan_rp'] as num?)?.toInt() ?? 0;
    final totalSetor =
        (_kontribusiData['jumlah_setoran'] as num?)?.toInt() ?? 0;
    final rank = _kontribusiData['peringkat']?.toString() ?? '#1';

    final items = [
      _KontribusiItem(
        icon: Icons.delete_outline_rounded,
        title: 'Total Sampah',
        value: totalKg,
>>>>>>> Stashed changes
        unit: 'Kilogram',
        accent: AppColors.primary,
      ),
      _KontribusiItem(
        icon: Icons.payments_outlined,
        title: 'Total Dicairkan',
<<<<<<< Updated upstream
        value: 'Rp 100rb',
=======
        value: _rupiah(totalCair),
>>>>>>> Stashed changes
        unit: 'Keseluruhan',
        accent: AppColors.infoDark,
      ),
      _KontribusiItem(
        icon: Icons.swap_horiz_rounded,
        title: 'Jumlah Setoran',
<<<<<<< Updated upstream
        value: '12',
=======
        value: '$totalSetor',
>>>>>>> Stashed changes
        unit: 'Transaksi',
        accent: AppColors.accentDark,
      ),
      _KontribusiItem(
        icon: Icons.emoji_events_outlined,
        title: 'Peringkat Saat Ini',
<<<<<<< Updated upstream
        value: '#1',
=======
        value: rank,
>>>>>>> Stashed changes
        unit: 'Bulan Ini',
        accent: AppColors.warningDark,
      ),
    ];

<<<<<<< Updated upstream
=======
    // WCAG 1.4.4 — tinggi sel mengikuti skala teks sistem (sebelumnya fixed 110).
    final double factor = (MediaQuery.textScalerOf(context).scale(14) / 14)
        .clamp(1.0, 2.0)
        .toDouble();

>>>>>>> Stashed changes
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Kontribusi Kamu',
          icon: Icons.volunteer_activism_rounded,
<<<<<<< Updated upstream
          trailing: Text('Oktober 2026', style: AppTypography.caption()),
=======
          trailing: Text(_bulanTahunAktif, style: AppTypography.caption()),
>>>>>>> Stashed changes
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
<<<<<<< Updated upstream
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 110,
=======
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: factor > 1.3 ? 1 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 112 * factor,
>>>>>>> Stashed changes
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
<<<<<<< Updated upstream
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
=======
              return Semantics(
                container: true,
                excludeSemantics: true,
                label: '${item.title}: ${item.value} ${item.unit}',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
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
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: item.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item.icon,
                              color: item.accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTypography.caption(),
                              maxLines: 2,
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
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
    final activities = _aktivitasList;
>>>>>>> Stashed changes

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Aktivitas Terakhir',
<<<<<<< Updated upstream
          trailing: GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Text(
              'Lihat Semua',
              style: AppTypography.caption(
=======
          // Sebelumnya GestureDetector + teks 12sp (≈15dp tinggi, tanpa semantik).
          trailing: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size(_kTarget, _kTarget),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatMutasiScreen()),
              );
            },
            child: Text(
              'Lihat Semua',
              style: AppTypography.bodyMedium(
>>>>>>> Stashed changes
                color: AppColors.primary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: _cardDecoration(),
<<<<<<< Updated upstream
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
=======
            child: activities.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Belum ada setoran. Saldo dan riwayat akan muncul setelah pengurus mencatat timbangan.',
                        style: AppTypography.bodySmall(
                          color: AppColors.textSecondary,
                        ).copyWith(height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < activities.length; i++) ...[
                        MergeSemantics(
                          child: Padding(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        activities[i].title,
                                        style: AppTypography.bodyMedium(
                                          color: AppColors.textPrimary,
                                        ).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${activities[i].weight}  \u00B7  ${activities[i].date}',
                                        style: AppTypography.caption(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Nominal = data terpenting baris ini -> 14sp bold
                                // (sebelumnya 12sp). Tanda "+" membawa makna selain warna.
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
                                    style: AppTypography.bodyMedium(
                                      color: AppColors.primary,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
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
>>>>>>> Stashed changes
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // KLASEMEN PLAMO GARDEN
  // ---------------------------------------------------------------------------
<<<<<<< Updated upstream
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
=======
  Widget _rankBadge(int rank) {
    final color = _medal[rank];
    // Nomor ditampilkan di semua peringkat; medali hanya MENAMBAH warna.
    // (Sebelumnya 3 ikon identik dibedakan oleh warna saja -> gagal WCAG 1.4.1.)
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text(
            '$rank',
            style: AppTypography.caption(
              color: color != null ? Colors.white : AppColors.textMuted,
            ).copyWith(fontWeight: FontWeight.w700, height: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildKlasemen() {
    final entries = _klasemenList.isNotEmpty
        ? _klasemenList
        : [
            _LeaderboardItem(
              rank: 1,
              name: _displayName,
              weight: '0 Kg',
              isMe: true,
            ),
          ];
>>>>>>> Stashed changes

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Klasemen Plamo Garden',
<<<<<<< Updated upstream
          subtitle: 'Oktober 2026',
=======
          subtitle: _bulanTahunAktif,
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
                  MergeSemantics(
                    child: Container(
                      color: entries[i].isMe
                          ? AppColors.primaryLight.withValues(alpha: 0.5)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Semantics(
                            label: 'Peringkat ${entries[i].rank}',
                            excludeSemantics: true,
                            child: _rankBadge(entries[i].rank),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: entries[i].isMe
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            child: Text(
                              _initial(
                                entries[i].name,
                              ), // aman untuk nama kosong
                              style: AppTypography.caption(
                                color: entries[i].isMe
                                    ? AppColors.textOnPrimary
                                    : AppColors.primary,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (entries[i].isMe) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Saya', // putih di atas primary 6.4:1
                                      style: AppTypography.caption(
                                        color: AppColors.textOnPrimary,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entries[i].weight,
                            style: AppTypography.bodyMedium(
                              color: AppColors.textPrimary,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
>>>>>>> Stashed changes
                    ),
                  ),
                  if (i != entries.length - 1)
                    const Divider(
                      height: 1,
<<<<<<< Updated upstream
                      indent: 52,
=======
                      indent: 56,
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
=======
  String _initial(String name) {
    final t = name.trim();
    return t.isEmpty ? '?' : t.characters.first.toUpperCase();
  }

>>>>>>> Stashed changes
  // ---------------------------------------------------------------------------
  // PENCAIRAN BOTTOM SHEET (Figma Halaman 10 & 11)
  // ---------------------------------------------------------------------------
  void _showPencairanBottomSheet() {
    final int kurang = (_minPencairan - _saldo).clamp(0, _minPencairan);
    final int persen = (_progress * 100).round();
<<<<<<< Updated upstream
=======
    final nominalCtrl = TextEditingController(
      text: _saldo >= _minPencairan
          ? _minPencairan.toString()
          : _saldo.toString(),
    );
    int selectedNominal = _saldo >= _minPencairan ? _minPencairan : _saldo;
    bool isSubmitting = false;
>>>>>>> Stashed changes

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
<<<<<<< Updated upstream
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
=======
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMState) {
          // WCAG 3.3.1 — galat ditampilkan inline sebagai teks di bawah field.
          // (Snackbar sebelumnya muncul DI BELAKANG bottom sheet & hilang cepat.)
          String? nominalError;
          if (kurang == 0) {
            if (selectedNominal < _minPencairan) {
              nominalError = 'Minimal pencairan ${_rupiah(_minPencairan)}';
            } else if (selectedNominal > _saldo) {
              nominalError = 'Melebihi saldo tersedia (${_rupiah(_saldo)})';
            }
          }
          final bool canSubmit =
              kurang == 0 && !isSubmitting && nominalError == null;

          void pick(int value) {
            HapticFeedback.lightImpact();
            setMState(() {
              selectedNominal = value;
              nominalCtrl.text = value.toString();
              nominalCtrl.selection = TextSelection.collapsed(
                offset: nominalCtrl.text.length,
              );
            });
          }

          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
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
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      child: Text('Pencairan Tunai', style: AppTypography.h2()),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pilih nominal atau ketik manual untuk mengajukan klaim',
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
>>>>>>> Stashed changes
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.wallet_outlined,
                                color: _onGreen(),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
<<<<<<< Updated upstream
                              Text(
                                'Saldo tersedia',
=======
                              Expanded(
                                child: Text(
                                  'Saldo tersedia',
                                  style: AppTypography.caption(
                                    color: _onGreen(),
                                  ),
                                ),
                              ),
                              if (kurang > 0)
                                Text(
                                  'Kurang ${_rupiah(kurang)}',
                                  style: AppTypography.caption(
                                    color: Colors.white,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _rupiah(_saldo),
                              style: AppTypography.h1(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$persen% menuju minimum',
                                  style: AppTypography.caption(
                                    color: _onGreen(),
                                  ),
                                ),
                              ),
                              Text(
                                'Min. ${_rupiah(_minPencairan)}',
>>>>>>> Stashed changes
                                style: AppTypography.caption(color: _onGreen()),
                              ),
                            ],
                          ),
<<<<<<< Updated upstream
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
=======
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _progress,
                              backgroundColor: _onGreen(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _progressFill,
                              ),
                              minHeight: 8,
                              semanticsLabel:
                                  'Progres menuju minimum pencairan',
                              semanticsValue: '$persen persen',
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (kurang > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _warningTint(),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warningDark.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.warningDark,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Saldo belum cukup. Kumpulkan ${_rupiah(kurang)} lagi untuk mencapai syarat minimum.',
                                // Pesan penting -> 14sp (bodyMedium), bukan caption 12sp.
                                style: AppTypography.bodyMedium(
                                  color: AppColors.textPrimary,
                                ),
                              ),
>>>>>>> Stashed changes
                            ),
                          ],
                        ),
                      ),
<<<<<<< Updated upstream
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
=======
                    ],

                    const SizedBox(height: 20),
                    Text(
                      'Pilihan Cepat Nominal',
                      style: AppTypography.formLabel(),
                    ),
                    const SizedBox(height: 8),

                    // Chip 2x2, tinggi ≥48dp, label penuh "Rp 150.000" tanpa terpotong.
                    LayoutBuilder(
                      builder: (_, c) {
                        final w = (c.maxWidth - 8) / 2;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final val in const [50000, 100000, 150000])
                              SizedBox(
                                width: w,
                                child: _NominalChip(
                                  label: _rupiah(val),
                                  selected: selectedNominal == val,
                                  enabled: val <= _saldo && !isSubmitting,
                                  onTap: () => pick(val),
                                ),
                              ),
                            SizedBox(
                              width: w,
                              child: _NominalChip(
                                label: 'Semua saldo',
                                semanticLabel:
                                    'Semua saldo, ${_rupiah(_saldo)}',
                                selected:
                                    _saldo > 0 && selectedNominal == _saldo,
                                enabled: _saldo > 0 && !isSubmitting,
                                onTap: () => pick(_saldo),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Border/fokus/galat diwarisi dari AppTheme.inputDecorationTheme
                    // (border 3.3:1, fokus 1.5dp, galat merah 4.8:1).
                    TextField(
                      controller: nominalCtrl,
                      enabled: !isSubmitting,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (val) {
                        setMState(
                          () => selectedNominal = int.tryParse(val) ?? 0,
                        );
                      },
                      style: AppTypography.h3(),
                      decoration: InputDecoration(
                        // Label permanen (hint "0" hilang saat mengetik -> WCAG 3.3.2).
                        labelText: 'Atau ketik nominal manual',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixText: 'Rp  ',
                        prefixStyle: AppTypography.h3(color: AppColors.primary),
                        hintText: '0',
                        errorText: nominalError,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Metode Posko
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                              size: 20,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                kurang > 0
                                    ? Icons.lock_outline_rounded
                                    : Icons.check_rounded,
                                size: 20,
                              ),
                        label: Text(
                          isSubmitting
                              ? 'Mengirim Pengajuan…'
                              : 'Ajukan Pencairan (${_rupiah(selectedNominal)})',
                        ),
                        onPressed: canSubmit
                            ? () async {
                                setMState(() => isSubmitting = true);
                                HapticFeedback.mediumImpact();

                                final res = await _authService
                                    .ajukanPencairanWarga(
                                      nominal: selectedNominal.toDouble(),
                                    );

                                if (!ctx.mounted) return;
                                setMState(() => isSubmitting = false);
                                Navigator.pop(ctx);
                                if (!mounted) return;

                                if (res['success'] == true) {
                                  _loadUserData();
                                  _showSuksesPencairanDialog(selectedNominal);
                                } else {
                                  _snack(
                                    (res['message'] ?? 'Pengajuan gagal.')
                                        .toString(),
                                    background: AppColors.error,
                                  );
                                }
                              }
                            : null,
                      ),
                    ),

                    if (kurang > 0) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Tombol aktif setelah saldo mencapai ${_rupiah(_minPencairan)}',
                          style: AppTypography.caption(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
>>>>>>> Stashed changes
      ),
    );
  }

<<<<<<< Updated upstream
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
=======
  void _showSuksesPencairanDialog(int nominal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pengajuan Berhasil!',
                style: AppTypography.h2(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Permintaan pencairan dana tunai sebesar:',
                style: AppTypography.bodyMedium(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _rupiah(nominal),
                style: AppTypography.h1(color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status Klaim:', style: AppTypography.caption()),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            // 10% (bukan 15%) agar warningDark ≥ 4.5:1.
                            color: _warningTint(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Menunggu Validasi',
                            // Sebelumnya TextStyle mentah 11sp di luar token tipografi.
                            style: AppTypography.caption(
                              color: AppColors.warningDark,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan temui Pengurus RT/RW di Posko Bank Sampah untuk pengambilan dana tunai setelah diverifikasi.',
                      // Instruksi tindak lanjut -> 14sp, bukan caption 12sp.
                      style: AppTypography.bodyMedium(
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('OK, Mengerti'),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Reusable chip nominal — kontrol ≥48dp, batas 3.3:1, status tidak hanya warna
// =============================================================================
class _NominalChip extends StatelessWidget {
  final String label;
  final String? semanticLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _NominalChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = !enabled
        ? AppColors.textHint
        : selected
        ? AppColors
              .primary // 5.7:1 di atas primaryLight
        : AppColors.textSecondary; // 8.4:1 di atas putih
    final Color border = !enabled
        ? AppColors.borderLight
        : selected
        ? AppColors.primary
        : AppColors.border; // 3.3:1 (WCAG 1.4.11), sebelumnya borderLight 1.2:1

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: Material(
        color: selected ? AppColors.primaryLight : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border, width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _kTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon centang: status terpilih tidak bergantung pada warna saja.
                  if (selected) ...[
                    Icon(Icons.check_rounded, size: 16, color: fg),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(color: fg).copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
>>>>>>> Stashed changes
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
