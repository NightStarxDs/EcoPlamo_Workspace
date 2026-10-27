import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_button.dart';

/// Detail Informasi & Pengumuman Posko (Figma Halaman 12)
class InfoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const InfoDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final judul = item['judul'] as String? ?? 'Informasi Posko';
    final isi = item['isi'] as String? ?? '';
    final kategori = item['kategori'] as String? ?? 'Pengumuman';
    final tanggal = item['tanggal'] as String? ?? 'Hari ini';

    Color badgeBg;
    Color badgeColor;
    IconData heroIcon;

    switch (kategori) {
      case 'Agenda':
        badgeBg = const Color(0xFFEFF6FF);
        badgeColor = const Color(0xFF1D4ED8);
        heroIcon = Icons.event_note_rounded;
        break;
      case 'Edukasi':
        badgeBg = const Color(0xFFECFDF5);
        badgeColor = const Color(0xFF047857);
        heroIcon = Icons.school_rounded;
        break;
      default:
        badgeBg = AppColors.primaryLight;
        badgeColor = AppColors.primary;
        heroIcon = Icons.campaign_rounded;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Detail Informasi',
          style: AppTypography.h3(),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Bagikan',
            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '$judul\n\n$isi\n\n— Posko Eco Plamo'));
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Teks pengumuman disalin ke papan klip.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Visual Banner
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: -20,
                    bottom: -30,
                    child: Icon(
                      heroIcon,
                      size: 160,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                    ),
                    child: Icon(
                      heroIcon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content Container
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Tags Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          kategori,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        tanggal,
                        style: AppTypography.caption(color: AppColors.textMuted),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Heading
                  Text(
                    judul,
                    style: AppTypography.h1().copyWith(fontSize: 21, height: 1.35),
                  ),

                  const SizedBox(height: 16),

                  // Author Info Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengurus Posko Eco Plamo',
                                style: AppTypography.bodyMedium().copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Diverifikasi oleh Posko RT 05 / RW 03',
                                style: AppTypography.caption(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Narrative Content
                  Text(
                    isi,
                    style: AppTypography.bodyLarge().copyWith(
                      height: 1.7,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional Guidance Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFF16A34A),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tips Warga Eco Plamo',
                                style: AppTypography.bodyMedium().copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF166534),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pilahlah sampah dari rumah sebelum dibawa ke posko untuk mempercepat proses penimbangan dan penghitungan poin tabungan Anda.',
                                style: AppTypography.bodySmall(
                                  color: const Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Action Button
                  EcoPrimaryButton(
                    text: 'Kembali ke Daftar Informasi',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
