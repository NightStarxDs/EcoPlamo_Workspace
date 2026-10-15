import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom Navigation Bar Eco Plamo sesuai Figma Halaman 16:
/// - 5 Item: Home, Katalog, Scan & QR Saya (Floating Center), Info, Profile
/// - Active indicator berupa garis pill hijau di bawah label menu yang aktif
class EcoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onScanTap;

  const EcoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book, 'Katalog'),
              _buildCenterScanButton(),
              _buildNavItem(3, Icons.notifications_none, Icons.notifications, 'Info'),
              _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    final bool isActive = currentIndex == index;
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: AppColors.primaryLight,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? filledIcon : outlineIcon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption(color: color).copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 3),
            // Indikator aktif garis bar hijau di bawah teks (Figma Page 16)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isActive ? 18 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterScanButton() {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (onScanTap != null) {
            onScanTap!();
          } else {
            onTap(2);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Scan & QR',
              style: AppTypography.caption(color: AppColors.primary).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
