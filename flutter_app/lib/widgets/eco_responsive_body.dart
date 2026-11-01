import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'eco_bottom_nav.dart';

class EcoResponsiveBody extends StatelessWidget {
  static const double breakpoint = ecoResponsiveBreakpoint;

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onScanTap;

  const EcoResponsiveBody({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) return child;

        final extended = constraints.maxWidth >= 1200;
        return Row(
          children: [
            _EcoSideNavigation(
              currentIndex: currentIndex,
              onTap: onTap,
              onScanTap: onScanTap,
              extended: extended,
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EcoSideNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onScanTap;
  final bool extended;

  const _EcoSideNavigation({
    required this.currentIndex,
    required this.onTap,
    required this.onScanTap,
    required this.extended,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Katalog'),
    (Icons.notifications_none, Icons.notifications, 'Info'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: extended ? 232 : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: extended ? 20 : 0,
                vertical: 22,
              ),
              child: extended
                  ? Row(
                      children: [
                        const Icon(Icons.eco_rounded, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          'Eco Plamo',
                          style: AppTypography.h3(color: AppColors.primary),
                        ),
                      ],
                    )
                  : const Icon(
                      Icons.eco_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),
            for (var index = 0; index < _items.length; index++)
              _buildItem(index, _items[index]),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: extended ? 16 : 12,
              ),
              child: Tooltip(
                message: 'Scan & QR',
                child: extended
                    ? SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onScanTap ?? () => onTap(2),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan & QR'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      )
                    : IconButton.filled(
                        onPressed: onScanTap ?? () => onTap(2),
                        icon: const Icon(Icons.qr_code_scanner),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(int index, (IconData, IconData, String) item) {
    final selected = currentIndex == index;
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: extended ? 12 : 8, vertical: 3),
      child: Tooltip(
        message: item.$3,
        child: Material(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onTap(index < 2 ? index : index + 1),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 52,
              child: Row(
                mainAxisAlignment: extended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 14),
                  Icon(selected ? item.$2 : item.$1, color: color, size: 23),
                  if (extended) ...[
                    const SizedBox(width: 14),
                    Text(
                      item.$3,
                      style: AppTypography.bodyMedium(color: color).copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
