import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_button.dart';
import '../../widgets/eco_logo.dart';
import '../../widgets/eco_text_field.dart';

/// ============================================================================
/// Screen: Login (Figma Halaman 3) dengan Animasi In & Out yang Halus
///
/// Fitur Animasi:
/// 1. Animasi In (Entrance):
///    - Header hijau meluncur masuk dari atas dengan subtle floating hover
///    - Bottom sheet form putih meluncur dari bawah dengan spring curve
///    - Staggered item reveal (Judul -> Input WA -> Password -> Tombol -> Link)
/// 2. Animasi Out (Exit):
///    - Saat berpindah ke layar Register atau Login berhasil, formulir
///      meluncur turun perlahan dan fade out sebelum perpindahan halaman
///    - Saat kembali dari Register, form menganimasikan masuk kembali (In)
/// 3. Interaksi:
///    - Animasi toggle visibilitas kata sandi (rotate/fade)
///    - Animated error alert banner yang muncul dengan efek slide & fade
/// ============================================================================
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _whatsappController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ── 1. Animasi Masuk (In Animation) ──
  late AnimationController _inController;
  late Animation<Offset> _headerSlideIn;
  late Animation<double> _headerFadeIn;
  late Animation<Offset> _cardSlideIn;
  late Animation<double> _cardFadeIn;

  // ── 2. Animasi Keluar (Out Animation) ──
  late AnimationController _outController;
  late Animation<Offset> _cardSlideOut;
  late Animation<double> _cardFadeOut;
  late Animation<Offset> _headerSlideOut;
  late Animation<double> _headerFadeOut;

  // ── 3. Animasi Floating Ambient Emblem (CSS @keyframes hover) ──
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initAnimations();
    _playInAnimation();
  }

  void _initAnimations() {
    // 1. In Animation Controller (durasi 850ms)
    _inController = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );

    _headerSlideIn = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _inController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _headerFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _inController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _cardSlideIn = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _inController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _cardFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _inController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
      ),
    );

    // 2. Out Animation Controller (durasi 320ms)
    _outController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    _cardSlideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.25),
    ).animate(
      CurvedAnimation(parent: _outController, curve: Curves.easeInOutCubic),
    );

    _cardFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _outController, curve: Curves.easeInOut),
    );

    _headerSlideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.15),
    ).animate(
      CurvedAnimation(parent: _outController, curve: Curves.easeInOutCubic),
    );

    _headerFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _outController, curve: Curves.easeInOut),
    );

    // 3. Hover Loop Controller (CSS bobbing float)
    _hoverController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _playInAnimation() {
    _outController.reset();
    _inController.forward(from: 0.0);
  }

  Future<void> _playOutAnimation() async {
    await _outController.forward();
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _passwordController.dispose();
    _inController.dispose();
    _outController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  /// Navigasi keluar ke halaman pendaftaran akun dengan animasi Out
  Future<void> _navigateToRegister() async {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();

    // Jalankan animasi form meluncur keluar
    await _playOutAnimation();
    if (!mounted) return;

    // Buka halaman Register
    await Navigator.pushNamed(context, '/register');

    // Saat pengguna kembali (back), jalankan animasi masuk lagi (In)
    if (mounted) {
      _playInAnimation();
    }
  }

  /// Proses masuk ke aplikasi
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _authService.login(
        noWhatsapp: _whatsappController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (res['success'] == true) {
        HapticFeedback.mediumImpact();

        // Arahkan ke dashboard berdasarkan role user
        final role = res['user']['role'] as String? ?? 'warga';

        // Jika user adalah Petugas DLH, sarankan membuka Web Dashboard
        if (role == 'dlh') {
          _showDlhWebRedirectDialog(Map<String, dynamic>.from(res['user']));
          return;
        }

        // Jalankan animasi Out sebelum masuk ke Dashboard
        await _playOutAnimation();
        if (!mounted) return;

        final dashboardRoute = role == 'pengurus'
            ? '/pengurus-dashboard'
            : '/warga-dashboard';
        Navigator.pushReplacementNamed(context, dashboardRoute);
      } else {
        setState(() {
          _errorMessage = res['message'] ?? 'Nomor WhatsApp atau kata sandi tidak valid.';
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan koneksi server: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDlhWebRedirectDialog(Map<String, dynamic> user) {
    final dlhUrl = AuthService.getDlhWebUrl();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mintWash,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.desktop_windows_rounded,
                color: AppColors.houseGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Web Portal DLH',
                style: AppTypography.h3(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${user['nama_lengkap'] ?? 'Petugas DLH'}!',
              style: AppTypography.bodyLarge().copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Untuk kemudahan pengelolaan wilayah, data rekapitulasi, dan monitoring menyeluruh, dashboard Dinas Lingkungan Hidup (DLH) disediakan dalam versi Web.',
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.canvasWarm,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    size: 18,
                    color: AppColors.brandEmerald,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dlhUrl,
                      style: AppTypography.caption(color: AppColors.brandEmerald).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _playOutAnimation();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/dlh-dashboard');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(
                    'Versi Mobile',
                    style: AppTypography.button(color: AppColors.textSecondary).copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final uri = Uri.parse(dlhUrl);
                    try {
                      final canLaunch = await canLaunchUrl(uri);
                      if (canLaunch) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Tidak dapat membuka browser. URL: $dlhUrl'),
                            action: SnackBarAction(
                              label: 'Salin URL',
                              onPressed: () {
                                // Copy URL to clipboard
                              },
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Error: Pastikan Laragon web server berjalan'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                  label: Text(
                    'Buka Web',
                    style: AppTypography.button(color: Colors.white).copyWith(
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.houseGreen,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.houseGreen,   // #1E3932 deep near-black forest
                AppColors.brandEmerald, // #005E3F official figma primary
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // ── BAGIAN ATAS (HERO) - LOGO, PILL BADGE & BRANDING ──
                          _buildAnimatedHeader(),

                          // ── BAGIAN BAWAH (SURFACE) - FORM CARD DENGAN ANIMASI ──
                          _buildAnimatedFormCard(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------------------------------------------------------------
  /// Header House Green Brand dengan Animasi In/Out + Floating Hover
  /// -------------------------------------------------------------------------
  Widget _buildAnimatedHeader() {
    return Expanded(
      child: AnimatedBuilder(
        animation: Listenable.merge([_inController, _outController, _hoverController]),
        builder: (context, child) {
          final inOffset = _headerSlideIn.value;
          final outOffset = _headerSlideOut.value;
          final totalOffset = inOffset + outOffset;

          final inOpacity = _headerFadeIn.value;
          final outOpacity = _headerFadeOut.value;
          final totalOpacity = (inOpacity * outOpacity).clamp(0.0, 1.0);

          // Subtle float hover offset
          final hoverY = (1.0 - _hoverController.value) * 6.0 - 3.0;

          return Transform.translate(
            offset: Offset(totalOffset.dx * 100, (totalOffset.dy * 100) + hoverY),
            child: Opacity(
              opacity: totalOpacity,
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Daun Sirkular Eco Plamo dengan ambient glow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withValues(alpha: 0.28),
                      blurRadius: 24,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const EcoPlamoLogo(
                  size: 74,
                  withBackground: false,
                ),
              ),
              const SizedBox(height: 14),

              // Pill Chip Badge: "Bank Sampah • Plamo Garden"
              Container(
                constraints: const BoxConstraints(maxWidth: 260),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      size: 13,
                      color: AppColors.accentLight,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Bank Sampah • Plamo Garden',
                        style: AppTypography.caption(color: Colors.white).copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Judul Brand "Eco Plamo" (Figma Display Bold)
              Text(
                'Eco Plamo',
                style: AppTypography.displayBold(color: Colors.white).copyWith(
                  fontSize: 28,
                  letterSpacing: -0.16,
                ),
              ),
              const SizedBox(height: 6),

              // Slogan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Wujudkan Lingkungan Bersih Dan Ekonomi\nSirkular Bersama Eco Plamo',
                  textAlign: TextAlign.center,
                  style: AppTypography.slogan(
                    color: Colors.white.withValues(alpha: 0.88),
                  ).copyWith(
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// -------------------------------------------------------------------------
  /// Form Container Putih Melengkung dengan Animasi In & Out yang Mewah
  /// -------------------------------------------------------------------------
  Widget _buildAnimatedFormCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_inController, _outController]),
      builder: (context, child) {
        final inOffset = _cardSlideIn.value;
        final outOffset = _cardSlideOut.value;
        final currentOffset = inOffset + outOffset;

        final inOpacity = _cardFadeIn.value;
        final outOpacity = _cardFadeOut.value;
        final currentOpacity = (inOpacity * outOpacity).clamp(0.0, 1.0);

        return SlideTransition(
          position: AlwaysStoppedAnimation(currentOffset),
          child: Opacity(
            opacity: currentOpacity,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 28,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 1. Judul Halaman "Masuk" (Stagger 1)
              _buildStaggeredItem(
                intervalStart: 0.2,
                intervalEnd: 0.55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.brandEmerald,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Masuk',
                          style: AppTypography.h2(color: AppColors.textPrimary).copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Silakan masuk ke akun Anda untuk mengelola setoran & saldo sampah.',
                      style: AppTypography.bodyMedium(color: AppColors.textSecondary).copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Banner Pesan Kesalahan (jika login gagal)
              if (_errorMessage != null) ...[
                _buildAnimatedErrorBanner(),
                const SizedBox(height: 16),
              ],

              // 2. Input Nomor WhatsApp (Stagger 2)
              _buildStaggeredItem(
                intervalStart: 0.35,
                intervalEnd: 0.70,
                child: EcoTextField(
                  label: 'Nomor WhatsApp / Username',
                  hintText: 'Contoh: 08123456789 atau username',
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.phone_android_rounded,
                    color: AppColors.brandEmerald,
                    size: 20,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nomor WhatsApp tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 3. Input Kata Sandi (Stagger 3)
              _buildStaggeredItem(
                intervalStart: 0.48,
                intervalEnd: 0.82,
                child: EcoTextField(
                  label: 'Kata Sandi',
                  hintText: 'Masukkan kata sandi',
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.brandEmerald,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        key: ValueKey(_isPasswordVisible),
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Kata sandi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 4. Tombol Masuk Starbucks-Style Full-Pill (Stagger 4)
              _buildStaggeredItem(
                intervalStart: 0.60,
                intervalEnd: 0.92,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: EcoPrimaryButton(
                    text: 'Masuk',
                    isLoading: _isLoading,
                    height: 52,
                    borderRadius: 50, // Signature Starbucks Full-Pill
                    backgroundColor: AppColors.accentGreen,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _handleLogin,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Teks Link Daftar Akun (Stagger 5)
              _buildStaggeredItem(
                intervalStart: 0.72,
                intervalEnd: 1.0,
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: _isLoading ? null : _navigateToRegister,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum memiliki akun warga? ',
                          style: AppTypography.bodyMedium(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Daftar di sini',
                              style: AppTypography.bodyMedium(
                                color: AppColors.brandEmerald,
                              ).copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 6. Security & Trust Footnote
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 13,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Sistem Resmi Bank Sampah Plamo Garden',
                          style: AppTypography.caption(color: AppColors.textHint).copyWith(
                            fontSize: 11.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper untuk animasi bertahap (staggered delay) pada item form
  Widget _buildStaggeredItem({
    required double intervalStart,
    required double intervalEnd,
    required Widget child,
  }) {
    final staggerAnimation = CurvedAnimation(
      parent: _inController,
      curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: staggerAnimation,
      builder: (context, child) {
        final val = staggerAnimation.value;
        return Transform.translate(
          offset: Offset(0, 18 * (1.0 - val)),
          child: Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Banner pesan kesalahan interaktif dengan slide animation
  Widget _buildAnimatedErrorBanner() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, val, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * val),
          child: Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage ?? '',
                style: AppTypography.caption(color: AppColors.error).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
