import 'package:flutter/material.dart';

/// Palet Eco Plamo — disesuaikan ke WCAG 2.1 AA.
///  • Teks normal (< 18sp / < 14sp bold) : kontras minimal 4.5 : 1
///  • Ikon, border input, komponen UI    : kontras minimal 3 : 1
/// Rasio di komentar dihitung terhadap putih (#FFFFFF) kecuali disebutkan lain.
class AppColors {
  // Primary Greens
  static const Color primary = Color(0xFF006D44); // 6.4:1 (teks putih di atasnya juga 6.4:1)
  static const Color primaryDark = Color(0xFF005232);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color primaryAccent = Color(0xFF10B981); // HANYA untuk fill/dekorasi (2.5:1)
  static const Color accentDark = Color(0xFF047857); // varian aksen untuk ikon/teks (5.4:1)
  static const Color accentLight = Color(0xFFD1FAE5); // tint aksen hijau muda

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAF8);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E1E); // ~16:1
  static const Color textSecondary = Color(0xFF4A5568); // 8.4:1
  static const Color textMuted = Color(0xFF5A6778); // 5.8:1 (sebelumnya #718096 = 4.0:1 ✗)
  static const Color textHint = Color(0xFF6B7280); // 4.8:1 (sebelumnya #9CA3AF = 2.5:1 ✗)
  static const Color textOnPrimary = Colors.white;

  // Borders & Dividers
  static const Color border = Color(0xFF868E9C); // 3.3:1 — batas input (sebelumnya #D0D5DD = 1.4:1 ✗)
  static const Color borderLight = Color(0xFFE2E8F0); // dekoratif (card/divider)
  static const Color borderFocused = Color(0xFF006D44);

  // Status Colors
  static const Color success = Color(0xFF10B981); // fill/ikon besar saja
  static const Color error = Color(0xFFDC2626); // 4.8:1 (sebelumnya #EF4444 = 3.8:1 ✗)
  static const Color warning = Color(0xFFF59E0B); // fill saja (2.2:1)
  static const Color info = Color(0xFF3B82F6); // fill saja (3.7:1)

  // Varian gelap status — pakai ini untuk TEKS / IKON di atas putih atau tint terang
  static const Color warningDark = Color(0xFFB45309); // 5.5:1
  static const Color infoDark = Color(0xFF1D4ED8); // 6.7:1
}