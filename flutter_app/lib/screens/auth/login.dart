import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

        // Jalankan animasi Out sebelum masuk ke Dashboard
        await _playOutAnimation();
        if (!mounted) return;

        // Arahkan ke dashboard warga
        Navigator.pushReplacementNamed(context, '/warga-dashboard');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF006D44),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF006D44),
              Color(0xFF005232),
              Color(0xFF003D25),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // ── BAGIAN ATAS (HIJAU) - LOGO & BRANDING ──
                        _buildAnimatedHeader(),

                        // ── BAGIAN BAWAH (PUTIH) - FORM LOGIN DENGAN ANIMASI IN & OUT ──
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
    );
  }

  /// -------------------------------------------------------------------------
  /// Header Hijau Brand dengan Animasi In/Out + Floating Hover
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Daun Sirkular Eco Plamo
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const EcoPlamoLogo(
                  size: 76,
                  withBackground: false,
                ),
              ),
              const SizedBox(height: 16),

              // Judul Brand "Eco Plamo" (Figma Display Bold)
              Text(
                'Eco Plamo',
                style: AppTypography.displayBold(color: Colors.white).copyWith(
                  fontSize: 28,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Slogan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Wujudkan Lingkungan Yang Bersih Dan Ekonomi\nSirkular Bersama Eco Plamo',
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
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Judul Halaman "Masuk" (Stagger 1)
              _buildStaggeredItem(
                intervalStart: 0.2,
                intervalEnd: 0.55,
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Masuk',
                      style: AppTypography.h2(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                  hintText: 'Contoh: 08123456789',
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(
                    Icons.phone_android_rounded,
                    color: AppColors.primary,
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
                    color: AppColors.primary,
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

              // 4. Tombol Masuk (Stagger 4)
              _buildStaggeredItem(
                intervalStart: 0.60,
                intervalEnd: 0.92,
                child: EcoPrimaryButton(
                  text: 'Masuk',
                  isLoading: _isLoading,
                  height: 52,
                  borderRadius: 12,
                  onPressed: _handleLogin,
                ),
              ),
              const SizedBox(height: 20),

              // 5. Teks Link Daftar Akun (Stagger 5)
              _buildStaggeredItem(
                intervalStart: 0.72,
                intervalEnd: 1.0,
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _isLoading ? null : _navigateToRegister,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun? ',
                          style: AppTypography.bodyMedium(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Daftar di sini',
                              style: AppTypography.bodyMedium(
                                color: AppColors.primary,
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
              const SizedBox(height: 8),
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
            opacity: val,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
