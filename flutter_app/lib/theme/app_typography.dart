import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // =========================================================================
  // HEADINGS (Menggunakan Poppins sesuai instruksi)
  // =========================================================================

  /// Display / Hero Brand Title (28sp, Bold)
  static TextStyle displayBold({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.25,
      letterSpacing: -0.5,
    );
  }

  /// Heading 1 (24sp, Bold)
  static TextStyle h1({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.3,
    );
  }

  /// Heading 2 (20sp, SemiBold / Bold)
  static TextStyle h2({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.3,
    );
  }

  /// Heading 3 (16sp, SemiBold)
  static TextStyle h3({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
    );
  }

  /// Button Text (16sp, SemiBold)
  static TextStyle button({Color color = Colors.white}) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.2,
    );
  }

  // =========================================================================
  // BODY & INPUT (Menggunakan Plus Jakarta Sans sesuai instruksi)
  // =========================================================================

  /// Body Large (15-16sp, Medium)
  static TextStyle bodyLarge({Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.5,
    );
  }

  /// Body Medium (13-14sp, Regular)
  static TextStyle bodyMedium({Color color = AppColors.textSecondary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.45,
    );
  }

  /// Slogan / Subtitle Text (13sp, Regular / Medium)
  static TextStyle slogan({Color color = Colors.white}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.45,
    );
  }

  /// Form Field Label (14sp, Medium)
  static TextStyle formLabel({Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Form Field Input / Text (14sp, Regular)
  static TextStyle formInput({Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  /// Form Field Hint (14sp, Regular)
  static TextStyle formHint({Color color = AppColors.textHint}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  /// Body Small (12sp, Regular)
  static TextStyle bodySmall({Color color = AppColors.textSecondary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
  }

  /// Caption / Small Subtitle (11-12sp, Regular)
  static TextStyle caption({Color color = AppColors.textMuted}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.3,
    );
  }

  /// Section Title (14sp, Medium)
  static TextStyle sectionTitle({Color color = AppColors.textPrimary}) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.4,
    );
  }
}
