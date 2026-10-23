import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_bottom_nav.dart';

Color _onGreen([double alpha = 0.85]) => Colors.white.withValues(alpha: alpha);

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.cardBg,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppColors.borderLight),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

class DlhDashboard extends StatefulWidget {
  const DlhDashboard({super.key});

  @override
  State<DlhDashboard> createState() => _DlhDashboardState();
}

class _DlhDashboardState extends State<DlhDashboard>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _currentUser;
  bool _isLoadingUser = true;
  int _currentNavIndex = 0;

  late final AnimationController _entranceController;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  Map<String, dynamic> _overview = {
    'total_rt_rw': 0,
    'total_warga': 0,
    'total_sampah_kg': 0,
    'co2_reduced_kg': 0,
  };
  List<Map<String, dynamic>> _monitoring = [];
  Map<String, dynamic> _dataTerkini = {
    'laporan': 0,
    'warga': 0,
    'kategori': 0,
  };

  String get _displayName => _isLoadingUser
      ? 'Memuat...'
      : (_currentUser?['nama_lengkap'] ?? 'Pegawai DLH');

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadUserData();
  }

  void _initAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _bodyFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.05, 0.75, curve: Curves.easeOut),
    );
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.05, 0.75, curve: Curves.easeOutCubic),
          ),
        );
    _entranceController.forward();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    final dash = await _authService.getDlhDashboard();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      if (dash != null) {
        if (dash['overview'] != null) {
          _overview = Map<String, dynamic>.from(dash['overview']);
        }
        if (dash['monitoring'] != null) {
          _monitoring = List<Map<String, dynamic>>.from(dash['monitoring']);
        }
        if (dash['data_terkini'] != null) {
          _dataTerkini = Map<String, dynamic>.from(dash['data_terkini']);
        }
      }
      _isLoadingUser = false;
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text('Keluar Akun', style: AppTypography.h3()),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun Eco Plamo?',
          style: AppTypography.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: AppTypography.button(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(96, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadUserData,
          child: FadeTransition(
            opacity: _bodyFade,
            child: SlideTransition(
              position: _bodySlide,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _buildWebPortalBanner(),
                  const SizedBox(height: 18),
                  _buildOverviewCard(),
                  const SizedBox(height: 16),
                  _buildMonitoringSection(),
                  const SizedBox(height: 16),
                  _buildDataSection(),
                  const SizedBox(height: 16),
                  _buildActionSection(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: EcoBottomNavBar(
          currentIndex: _currentNavIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentNavIndex = index);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
        child: Image.asset(
          'assets/images/Logo-Without-BG.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
        ),
      ),
      titleSpacing: 6,
      title: Text('Eco Plamo', style: AppTypography.h2(color: Colors.white)),
      actions: [
        IconButton(
          tooltip: 'Notifikasi',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 26,
              ),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tidak ada notifikasi baru saat ini.'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            tooltip: 'Menu Profil',
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (v) {
              if (v == 'logout') _handleLogout();
            },
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?['nama_lengkap'] ?? 'Pegawai DLH',
                      style: AppTypography.h3(),
                    ),
                    Text(
                      'NIP: ${_currentUser?['role_data']?['nip_pegawai'] ?? '-'}',
                      style: AppTypography.caption(),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Keluar',
                      style: AppTypography.bodyMedium(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final nip = _currentUser?['role_data']?['nip_pegawai'] ?? '-';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Halo, ',
                        style: AppTypography.bodyLarge(
                          color: AppColors.textSecondary,
                        ).copyWith(fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: '$_displayName!',
                        style: AppTypography.h3(),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.badge,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'NIP: $nip',
                        style: AppTypography.caption(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebPortalBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D1F15), Color(0xFF005232)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006D44).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.desktop_windows_rounded,
                    color: Color(0xFF5EE3A0),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Web Portal DLH',
                            style: AppTypography.bodyLarge(color: Colors.white).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Disarankan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Akses layar penuh untuk kelola data & monitoring',
                        style: AppTypography.caption(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(AuthService.getDlhWebUrl());
                  try {
                    final canLaunch = await canLaunchUrl(uri);
                    if (canLaunch) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Tidak dapat membuka web. Pastikan Laragon berjalan.',
                          ),
                          action: SnackBarAction(
                            label: 'Lihat URL',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('URL Web Dashboard'),
                                  content: SelectableText(AuthService.getDlhWebUrl()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Error: Pastikan Laragon web server berjalan di port 80',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                label: const Text('Buka Web Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006D44),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sistem Monitoring',
              style: AppTypography.caption(color: _onGreen())),
          const SizedBox(height: 4),
          Text(
            'DLH & Lingkungan',
            style: AppTypography.displayBold(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _pocketBadge(
                icon: Icons.settings,
                iconColor: Colors.white,
                label: 'RT/RW',
                value: '${_overview['total_rt_rw'] ?? 0}',
              ),
              const SizedBox(width: 12),
              _pocketBadge(
                icon: Icons.person,
                iconColor: Colors.white,
                label: 'Warga',
                value: '${_overview['total_warga'] ?? 0}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pocketBadge({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.h2(color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption(color: Colors.white).copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Monitoring Lingkungan',
            icon: Icons.monitor,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: _cardDecoration(),
            child: _monitoring.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Memuat data monitoring...',
                        style: AppTypography.caption(),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final m in _monitoring)
                        _monitorItem(
                          icon: m['title'].toString().contains('Air')
                              ? Icons.water_drop
                              : (m['title'].toString().contains('Daur')
                                  ? Icons.recycling_rounded
                                  : Icons.eco),
                          title: m['title'] ?? '',
                          status: m['status'] ?? '',
                          color: m['color'] == 'accentDark'
                              ? AppColors.accentDark
                              : (m['color'] == 'warningDark'
                                  ? AppColors.warningDark
                                  : AppColors.primary),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _monitorItem({
    required IconData icon,
    required String title,
    required String status,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: AppTypography.caption(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: AppTypography.caption(color: color).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'Data Terkini',
            icon: Icons.table_chart_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _dataChip(
                icon: Icons.insert_drive_file_rounded,
                label: 'Laporan',
                count: '${_dataTerkini['laporan'] ?? 0}',
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _dataChip(
                icon: Icons.people_rounded,
                label: 'Warga',
                count: '${_dataTerkini['warga'] ?? 0}',
                color: AppColors.accentDark,
              ),
              const SizedBox(width: 12),
              _dataChip(
                icon: Icons.category_rounded,
                label: 'Kategori',
                count: '${_dataTerkini['kategori'] ?? 0}',
                color: AppColors.warningDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataChip({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
  }) {
    return Expanded(
      child: FilledButton.tonalIcon(
        icon: Icon(icon, color: color),
        label: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption(color: AppColors.textSecondary),
            ),
            Text(
              count,
              style: AppTypography.h3(color: AppColors.textPrimary),
            ),
          ],
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fitur $label')),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(
    String title, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(title, style: AppTypography.h3()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: _cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aksi Cepat',
                style: AppTypography.bodyMedium().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _quickAction(
                icon: Icons.add_rounded,
                label: 'Tambah Warga',
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              _quickAction(
                icon: Icons.description_rounded,
                label: 'Buat Laporan',
                color: AppColors.accentDark,
              ),
              const SizedBox(height: 12),
              _quickAction(
                icon: Icons.filter_alt_rounded,
                label: 'Filter Data',
                color: AppColors.warningDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aksi: $label')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.bodyMedium().copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}