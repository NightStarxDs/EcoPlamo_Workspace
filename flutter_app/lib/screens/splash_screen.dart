import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_typography.dart';
import '../services/auth_service.dart';

/// ============================================================================
/// Splash Screen Eco Plamo dengan Animasi Bergaya CSS & HTML (Keyframes & Canvas)
///
/// Efek & Animasi:
/// 1. Floating Eco Particles (CSS-like background ambient floating orbs)
/// 2. Double Breathing Aura Pulse (Radial glow breathing effect)
/// 3. Rotating Eco Orbital Ring (CSS @keyframes spin-orbit 360deg effect)
/// 4. Elastic Logo Reveal with Subtle Hover Bobbing (@keyframes float)
/// 5. Staggered Text Slide-up & Expanding Gradient Divider
/// 6. Shimmering Neon Progress Bar Capsule (@keyframes shimmer-wave)
/// 7. Smooth Outro Fade & Zoom-dissolve to Next Route
/// ============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── 1. Infinite ambient animations (CSS-like continuous loops) ──
  late AnimationController _ambientController;   // Floating particles & hover
  late AnimationController _spinController;      // Orbital ring spin (360 deg)
  late AnimationController _pulseController;     // Glow aura breathing pulse
  late AnimationController _shimmerController;   // Progress bar shimmer sweep

  // ── 2. Entrance sequence animations (Timeline) ──
  late AnimationController _entranceController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _dividerWidth;
  late Animation<double> _taglineOpacity;
  late Animation<double> _loadingFade;

  // ── 3. Exit animation ──
  late AnimationController _exitController;
  late Animation<double> _exitFade;
  late Animation<double> _exitScale;

  // Progress counter simulation (0.0 -> 1.0)
  double _loadingProgress = 0.0;
  String _statusText = 'Menyiapkan ekosistem...';

  // Floating background particle items
  final List<_EcoParticle> _particles = List.generate(
    14,
    (index) => _EcoParticle(
      initialX: (index * 0.075 + 0.03) % 1.0,
      initialY: (index * 0.085 + 0.1) % 1.0,
      radius: 3.0 + (index % 5) * 2.2,
      speed: 0.25 + (index % 4) * 0.15,
      opacity: 0.12 + (index % 3) * 0.1,
    ),
  );

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initControllers();
    _startSequence();
  }

  void _initControllers() {
    // 1. Ambient continuous controllers (CSS equivalent of infinite keyframes)
    _ambientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _spinController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat();

    // 2. Entrance sequence
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Elastic bounce scale for central logo
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // Title reveal
    _titleSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.75, curve: Curves.easeIn),
      ),
    );

    // Expanding accent divider (CSS width: 0 -> 100%)
    _dividerWidth = Tween<double>(begin: 0.0, end: 60.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOutBack),
      ),
    );

    // Tagline fade
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
      ),
    );

    // Loading bar container fade
    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // 3. Exit animation
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSequence() async {
    // 1. Mulai animasi entrance
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _entranceController.forward();

    // 2. Simulasi progress loading dengan update pesan bertahap
    const steps = [
      (0.30, 'Memuat komponen...'),
      (0.65, 'Menghubungkan layanan...'),
      (0.90, 'Memeriksa sesi pengguna...'),
      (1.00, 'Selamat datang di Eco Plamo!'),
    ];

    for (final step in steps) {
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() {
        _loadingProgress = step.$1;
        _statusText = step.$2;
      });
    }

    // 3. Verifikasi status autentikasi pengguna
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // 4. Outro exit animation (CSS zoom-fade dissolve)
    await _exitController.forward();
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? '/home' : '/login',
    );
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _spinController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _entranceController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.36;

    return Scaffold(
      backgroundColor: const Color(0xFF004D30),
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return Opacity(
            opacity: _exitFade.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: child,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF006D44), // Primary Emerald Green
                Color(0xFF004E31), // Deep Forest Green
                Color(0xFF00331F), // Dark Botanical Base
              ],
              stops: [0.0, 0.65, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Layer 1: Ambient Floating Eco Particles (CSS @keyframes floatUp) ──
              AnimatedBuilder(
                animation: _ambientController,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(size.width, size.height),
                    painter: _EcoParticlePainter(
                      particles: _particles,
                      progress: _ambientController.value,
                    ),
                  );
                },
              ),

              // ── Layer 2: Radial Aura Glow Pulses (CSS @keyframes pulse-glow) ──
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final pulse = _pulseController.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer soft ambient glow
                      Container(
                        width: logoSize * (2.2 + pulse * 0.3),
                        height: logoSize * (2.2 + pulse * 0.3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF10B981).withValues(alpha: 0.16 * (1.0 - pulse * 0.3)),
                              const Color(0xFF006D44).withValues(alpha: 0.08 * (1.0 - pulse * 0.3)),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                      // Inner pulsating ring
                      Container(
                        width: logoSize * (1.6 + pulse * 0.2),
                        height: logoSize * (1.6 + pulse * 0.2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18 * (1.0 - pulse * 0.4)),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // ── Layer 3: Konten Inti Logo & Teks ──
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Logo Emblem dengan Spin Orbit + Elastic Scale + Hover Bobbing
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _entranceController,
                        _ambientController,
                        _spinController,
                      ]),
                      builder: (context, child) {
                        // Subtle CSS float hover (bobbing up and down)
                        final hoverOffset = math.sin(_ambientController.value * 2 * math.pi) * 6.0;

                        return Transform.translate(
                          offset: Offset(0, hoverOffset),
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Rotating Orbit Dashes (CSS @keyframes spin 360deg)
                                  Transform.rotate(
                                    angle: _spinController.value * 2 * math.pi,
                                    child: CustomPaint(
                                      size: Size(logoSize * 1.35, logoSize * 1.35),
                                      painter: _OrbitDashesPainter(),
                                    ),
                                  ),

                                  // Central Logo Glass Circle
                                  _buildGlassLogoContainer(logoSize),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Typography Reveal: "Eco Plamo" + Expanding Divider + Tagline
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _titleSlide.value),
                          child: Opacity(
                            opacity: _titleOpacity.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // Judul Brand "Eco Plamo"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Eco',
                                style: AppTypography.displayBold(
                                  color: Colors.white,
                                ).copyWith(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [
                                    Color(0xFF5EE3A0),
                                    Color(0xFFB9F6CA),
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Plamo',
                                  style: AppTypography.displayBold(
                                    color: Colors.white,
                                  ).copyWith(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Animated Expanding Divider (CSS width transition)
                          AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, _) {
                              return Container(
                                width: _dividerWidth.value,
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF10B981),
                                      Color(0xFF5EE3A0),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          // Slogan & Tagline
                          AnimatedBuilder(
                            animation: _entranceController,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _taglineOpacity.value,
                                child: child,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 42),
                              child: Text(
                                'Wujudkan Lingkungan Yang Bersih\nDan Ekonomi Sirkular Bersama Kami',
                                textAlign: TextAlign.center,
                                style: AppTypography.slogan(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ).copyWith(
                                  fontSize: 13,
                                  height: 1.55,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Layer 4: Shimmer Neon Progress Capsule ──
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _loadingFade.value,
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56),
                        child: Column(
                          children: [
                            _buildShimmerProgressCapsule(),
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _statusText,
                                key: ValueKey(_statusText),
                                style: AppTypography.caption(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ).copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Version tag
                    Text(
                      'v1.0.0 • Posko Plamo Garden',
                      style: AppTypography.caption(
                        color: Colors.white.withValues(alpha: 0.35),
                      ).copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Logo Container dengan efek Glassmorphism & Drop Shadow halus
  Widget _buildGlassLogoContainer(double logoSize) {
    return Container(
      width: logoSize + 18,
      height: logoSize + 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.28),
            blurRadius: 24,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            'assets/images/Logo-Without-BG.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.eco_rounded,
              color: Colors.white,
              size: 72,
            ),
          ),
        ),
      ),
    );
  }

  /// Progress capsule dengan efek gelombang kilau shimmer (CSS @keyframes shimmer)
  Widget _buildShimmerProgressCapsule() {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * _loadingProgress;

          return Stack(
            children: [
              // Filled progress
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: barWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF10B981),
                      Color(0xFF5EE3A0),
                      Colors.white,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5EE3A0).withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),

              // Shimmer wave traveling across progress
              if (barWidth > 0)
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    final shimmerOffset =
                        (_shimmerController.value * (barWidth + 40)) - 40;

                    return Positioned(
                      left: shimmerOffset,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================================
// Helper Custom Painters untuk Animasi CSS-Style
// =============================================================================

/// Melukis partikel alam yang melayang perlahan ke atas (CSS @keyframes floatUp)
class _EcoParticle {
  final double initialX;
  final double initialY;
  final double radius;
  final double speed;
  final double opacity;

  _EcoParticle({
    required this.initialX,
    required this.initialY,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class _EcoParticlePainter extends CustomPainter {
  final List<_EcoParticle> particles;
  final double progress;

  _EcoParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = ((p.initialY - (progress * p.speed)) % 1.0) * size.height;
      final x = (p.initialX * size.width) +
          (math.sin(progress * 2 * math.pi + p.initialX * 10) * 12);

      final paint = Paint()
        ..color = const Color(0xFF5EE3A0).withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EcoParticlePainter oldDelegate) => true;
}

/// Melukis garis orbit lingkaran berputar dengan aksen titik & strip (CSS @keyframes spin)
class _OrbitDashesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Gambar 8 arc dashes mengelilingi lingkaran
    const int dashCount = 8;
    const double sweepAngle = (2 * math.pi) / dashCount * 0.45;
    const double gapAngle = (2 * math.pi) / dashCount * 0.55;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (sweepAngle + gapAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        dashPaint,
      );
    }

    // Aksen titik kecil menyala di salah satu segmen
    final dotPaint = Paint()
      ..color = const Color(0xFF5EE3A0)
      ..style = PaintingStyle.fill;

    final dotAngle = sweepAngle / 2;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);
    canvas.drawCircle(Offset(dotX, dotY), 3.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
