import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'eco_logo.dart';

/// Top App Bar Spec sesuai Figma Halaman 17:
/// - Logo Eco Plamo & Title
/// - Lonceng Notifikasi dengan Red Dot
/// - Avatar Profil Pengguna (bisa diklik menuju Halaman Profil)
class EcoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;
  final bool showAvatar;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final List<Widget>? actions;
  final Widget? leading;

  const EcoAppBar({
    super.key,
    this.title = 'Eco Plamo',
    this.showNotification = true,
    this.showAvatar = true,
    this.onNotificationTap,
    this.onAvatarTap,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: leading != null ? 56 : 52,
      leading: leading ??
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            child: const EcoPlamoLogo(
              size: 34,
              withBackground: false,
            ),
          ),
      titleSpacing: 8,
      title: Text(
        title,
        style: AppTypography.h2(color: Colors.white).copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: actions ??
          [
            if (showNotification)
              IconButton(
                tooltip: 'Notifikasi Posko',
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    Positioned(
                      right: 1,
                      top: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: onNotificationTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Belum ada notifikasi baru dari Posko.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
              ),
            if (showAvatar)
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 4),
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: AuthService().getCurrentUser(),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    final name = user?['nama_lengkap'] as String? ?? 'Warga';
                    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'W';

                    return InkWell(
                      onTap: onAvatarTap ??
                          () {
                            Navigator.pushNamed(context, '/profile');
                          },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
    );
  }
}
