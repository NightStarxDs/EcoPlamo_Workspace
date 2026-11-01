import 'package:flutter/material.dart';

/// Palet Eco Plamo — disesuaikan ke WCAG 2.1 AA.
///  • Teks normal (< 18sp / < 14sp bold) : kontras minimal 4.5 : 1
///  • Ikon, border input, komponen UI    : kontras minimal 3 : 1
/// Rasio di komentar dihitung terhadap putih (#FFFFFF) kecuali disebutkan lain.
class AppColors {
  // =========================================================================
  // 1. OFFICIAL FIGMA DESIGN HANDOFF PALETTE (Drive Source: #005E3F)
  // =========================================================================
  static const Color figmaPrimary = Color(0xFF005E3F); // Warna utama Figma (#005E3F)
  static const Color figmaPrimaryHover = Color(0xFF00422D); // Hover
  static const Color figmaPrimaryDark = Color(0xFF005136); // Lencana / Badge
  static const Color figmaHeroFrom = Color(0xFF00573B); // Gradasi Hero awal
  static const Color figmaHeroTo = Color(0xFF006544); // Gradasi Hero akhir
  static const Color figmaSurface = Color(0xFFF6FAF7); // Menu bawah & ikon (#F6FAF7)
  static const Color figmaHeader = Color(0xFFFAFAFA); // Header
  static const Color figmaChipSelesai = Color(0xFFE8F7F1); // Chip status selesai
  static const Color figmaLine = Color(0xFFE5E7EB); // Garis pemisah
  static const Color figmaTextPrimary = Color(0xFF111827); // Teks judul utama Figma
  static const Color figmaTextSecondary = Color(0xFF414B45); // Teks sekunder Figma
  static const Color figmaBorderInput = Color(0xFF77857D); // Border input terkalibrasi
  static const Color figmaNavInactive = Color(0xFF26302B); // Menu nav tidak aktif
  static const Color figmaAccent = Color(0xFFB0F0D6); // Bar progres
  static const Color figmaLink = Color(0xFF115E39); // Tautan, nominal positif (+)
  static const Color figmaDisabled = Color(0xFFE1E4E3); // State nonaktif
  static const Color figmaFocus = Color(0xFF0095FF); // Focus border input
  static const Color figmaError = Color(0xFFA31515); // Danger / Error (#A31515)

  // =========================================================================
  // 2. PRIMARY GREENS & STARBUCKS RETAIL HARMONY
  // =========================================================================
  static const Color primary = figmaPrimary; // #005E3F (Warna utama resmi)
  static const Color primaryDark = figmaPrimaryDark; // #005136
  static const Color primaryLight = figmaChipSelesai; // #E8F7F1
  static const Color primaryAccent = Color(0xFF10B981); // Fill/dekorasi
  static const Color accentDark = figmaLink; // #115E39
  static const Color accentLight = figmaAccent; // #B0F0D6

  // Starbucks Calibrated Tiers
  static const Color houseGreen = Color(0xFF1E3932); // Deep Near-Black Forest (Hero & Statement)
  static const Color brandEmerald = figmaPrimary; // #005E3F
  static const Color accentGreen = Color(0xFF00754A); // Luminous Green (Full-pill CTA & FAB)
  static const Color upliftSlate = Color(0xFF2B5148); // Mid-dark slate green
  static const Color mintWash = figmaChipSelesai; // #E8F7F1 (Breathable wash)

  // Background & Surfaces (Warm Neutral Flagship Canvas)
  static const Color canvasWarm = Color(0xFFF7F5F0); // Starbucks-style warm cream base
  static const Color surfaceCeramic = Color(0xFFEFECE6); // Soft zone divider & input containers
  static const Color background = Color(0xFFF9FAFB); // Sesuai Figma (#F9FAFB)
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Prestige & Rewards (Starbucks Gold Ceremony - Gamifikasi Plamo Garden)
  static const Color prestigeGold = Color(0xFFCBA258); // Gold tier, top 1 contributor, reward stars
  static const Color goldLightTint = Color(0xFFFAF6EE); // Background wash untuk badge reward emas

  // Text Colors
  static const Color textPrimary = figmaTextPrimary; // #111827 (~16:1 WCAG AAA)
  static const Color textSecondary = figmaTextSecondary; // #414B45 (8.4:1 WCAG AAA)
  static const Color textMuted = Color(0xFF5A6778); // 5.8:1
  static const Color textHint = Color(0xFF6B7280); // 4.8:1
  static const Color textOnPrimary = Colors.white;

  // Borders & Dividers
  static const Color border = figmaBorderInput; // #77857D (3.3:1)
  static const Color borderLight = figmaLine; // #E5E7EB
  static const Color borderFocused = figmaPrimary; // #005E3F

  // Status Colors
  static const Color success = Color(0xFF10B981); // Ikon besar / badge
  static const Color error = figmaError; // #A31515
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = figmaFocus; // #0095FF

  // Varian gelap status
  static const Color warningDark = Color(0xFFB45309);
  static const Color infoDark = Color(0xFF1D4ED8);
}