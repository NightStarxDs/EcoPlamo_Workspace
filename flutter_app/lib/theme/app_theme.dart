import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    final RoundedRectangleBorder r12 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white, // 6.4:1
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary, // ~16:1
        error: AppColors.error,
        onError: Colors.white, // 4.8:1
        outline: AppColors.border, // 3.3:1 — batas komponen
        outlineVariant: AppColors.borderLight, // dekoratif
      ),

      // Text Theme with Poppins Headings + Jakarta Sans Body
      textTheme: baseTextTheme.copyWith(
        displayLarge: AppTypography.displayBold(),
        displayMedium: AppTypography.h1(),
        headlineMedium: AppTypography.h2(),
        headlineSmall: AppTypography.h3(),
        titleMedium: AppTypography.h3(),
        bodyLarge: AppTypography.bodyLarge(),
        bodyMedium: AppTypography.bodyMedium(),
        bodySmall: AppTypography.caption(),
        labelLarge: AppTypography.button(),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Input Decoration Theme (Figma Spec)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: AppTypography.formHint(), // 4.8:1
        labelStyle: AppTypography.formLabel(color: AppColors.textSecondary),
        floatingLabelStyle: AppTypography.formLabel(
          color: AppColors.textSecondary,
        ),
        // Pesan galat: merah 4.8:1 di atas putih, 12sp, selalu berupa teks.
        errorStyle: AppTypography.caption(color: AppColors.error),
        errorMaxLines: 3,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderFocused,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      // Elevated Button Theme (Figma Spec)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          // Disabled tetap terbaca (default M3 ≈ 2:1). Wajib dibaca sebagai
          // "tidak aktif" tapi tetap bisa dibaca isinya.
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textSecondary,
          elevation: 0,
          shape: r12,
          textStyle: AppTypography.button(),
          minimumSize: const Size.fromHeight(52),
        ),
      ),

      // Dipakai dashboard: FilledButton (Tutup / OK) mengikuti gaya yang sama.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textSecondary,
          shape: r12,
          textStyle: AppTypography.button(),
          minimumSize: const Size.fromHeight(52),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: r12,
          textStyle: AppTypography.button(),
          minimumSize: const Size(64, 52),
        ),
      ),

      // Target sentuh ≥48dp (WCAG 2.5.8 / Material).
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button(),
          minimumSize: const Size(64, 48),
        ),
      ),

      // Snackbar gelap + teks putih (≈16:1). Sebelumnya warna latar diberikan
      // per-pemanggilan (mis. amber #F59E0B dengan teks putih = 2.2:1 ✗).
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.bodyMedium(color: Colors.white),
        actionTextColor: AppColors.primaryAccent, // ≈6.6:1 di atas #1E1E1E
        behavior: SnackBarBehavior.floating,
        shape: r12,
      ),
    );
  }
}
