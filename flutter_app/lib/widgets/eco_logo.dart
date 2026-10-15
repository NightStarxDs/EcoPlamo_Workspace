import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Emblem Logo Eco Plamo:
/// Menggunakan file aset resmi dari `assets/images/`
/// - [withBackground = false] : Menggunakan `Logo-Without-BG.png` (transparan untuk layar berlatar hijau)
/// - [withBackground = true]  : Menggunakan `Logo-With-BG.png` (dengan background hijau untuk AppBar/latar putih)
class EcoPlamoLogo extends StatelessWidget {
  final double size;
  final bool withBackground;
  final BoxFit fit;
  final Color? color;

  const EcoPlamoLogo({
    super.key,
    this.size = 80,
    this.withBackground = false,
    this.fit = BoxFit.contain,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = withBackground
        ? 'assets/images/Logo-With-BG.png'
        : 'assets/images/Logo-Without-BG.png';

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // Fallback ke vector painter jika aset belum termuat di environment pengujian
          return CustomPaint(
            size: Size(size, size),
            painter: _EcoPlamoLogoPainter(
              color: color ?? (withBackground ? const Color(0xFF006D44) : Colors.white),
            ),
          );
        },
      ),
    );
  }
}


class _EcoPlamoLogoPainter extends CustomPainter {
  final Color color;

  _EcoPlamoLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.055;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2.3, math.pi * 1.78, false, arcPaint);

    final arrowAngle = -math.pi / 2.3;
    final arrowX = center.dx + radius * math.cos(arrowAngle);
    final arrowY = center.dy + radius * math.sin(arrowAngle);

    final arrowPath = Path();
    final arrowSize = size.width * 0.12;

    arrowPath.moveTo(arrowX - arrowSize * 0.2, arrowY - arrowSize * 0.8);
    arrowPath.lineTo(arrowX + arrowSize * 0.9, arrowY);
    arrowPath.lineTo(arrowX - arrowSize * 0.8, arrowY + arrowSize * 0.4);
    arrowPath.close();

    final arrowFill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowFill);

    final leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    final leafWidth = size.width * 0.44;
    final leafHeight = size.height * 0.52;

    final startX = center.dx - leafWidth * 0.35;
    final startY = center.dy + leafHeight * 0.35;
    final tipX = center.dx + leafWidth * 0.35;
    final tipY = center.dy - leafHeight * 0.4;

    leafPath.moveTo(startX, startY);
    leafPath.quadraticBezierTo(
      center.dx + leafWidth * 0.6,
      center.dy + leafHeight * 0.1,
      tipX,
      tipY,
    );
    leafPath.quadraticBezierTo(
      center.dx - leafWidth * 0.55,
      center.dy - leafHeight * 0.1,
      startX,
      startY,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant _EcoPlamoLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
