import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_bottom_nav.dart';
import '../../widgets/eco_button.dart';
import '../../widgets/eco_scan_modal.dart';
import '../../widgets/eco_text_field.dart';

/// Halaman Profil Saya (Figma Halaman 13, 19, 20)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();
    final dash = await _authService.getWargaDashboard();
    if (!mounted) return;
    setState(() {
      _user = user;
      _dashboardData = dash;
      _isLoading = false;
    });
  }

  bool get _isPengurus {
    final role = (_user?['role'] ?? _user?['peran'])?.toString().toLowerCase();
    return role == 'pengurus' ||
        _user?['pengurus'] != null ||
        (_user?['role_data'] != null && _user?['role_data']['jabatan'] != null);
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    if (index == 4) return;

    final isPengurus = _isPengurus;

    if (index == 0) {
      Navigator.pushReplacementNamed(
        context,
        isPengurus ? '/pengurus-dashboard' : '/warga-dashboard',
      );
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/katalog');
    } else if (index == 2) {
      if (isPengurus) {
        Navigator.pushNamed(context, '/pengurus-dashboard');
      } else {
        EcoScanModal.show(context);
      }
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/info');
    }
  }
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
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
            child: Text('Batal', style: AppTypography.button(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(96, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showEditProfileSheet() {
    final namaController = TextEditingController(text: _user?['nama_lengkap'] ?? '');
    final alamatController = TextEditingController(text: _user?['role_data']?['alamat'] ?? '');
    bool isSaving = false;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0D5DD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Profil', style: AppTypography.h2().copyWith(fontSize: 19)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Perbarui informasi data diri akun warga Anda.',
                    style: AppTypography.bodySmall(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(errorMsg!, style: AppTypography.caption(color: AppColors.error)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  EcoTextField(
                    label: 'Nama Lengkap',
                    hintText: 'Masukkan nama lengkap',
                    controller: namaController,
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 16),
                  EcoTextField(
                    label: 'Alamat (Blok & No. Rumah)',
                    hintText: 'Contoh: Blok A2 / No. 14',
                    controller: alamatController,
                    prefixIcon: const Icon(Icons.home_outlined, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 24),
                  EcoPrimaryButton(
                    text: 'Simpan Perubahan',
                    isLoading: isSaving,
                    onPressed: () async {
                      if (namaController.text.trim().isEmpty) {
                        setSheetState(() => errorMsg = 'Nama lengkap wajib diisi.');
                        return;
                      }
                      setSheetState(() {
                        isSaving = true;
                        errorMsg = null;
                      });

                      final navigator = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);

                      final res = await _authService.updateProfile(
                        namaLengkap: namaController.text.trim(),
                        alamat: alamatController.text.trim(),
                      );
                      if (!mounted) return;
                      if (res['success'] == true) {
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(content: Text(res['message'] ?? 'Profil diperbarui.')),
                        );
                        _loadProfileData();
                      } else {
                        setSheetState(() {
                          isSaving = false;
                          errorMsg = res['message'] ?? 'Gagal memperbarui profil.';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  void _showChangePasswordSheet() {
    final curController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool isSaving = false;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0D5DD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ganti Kata Sandi', style: AppTypography.h2().copyWith(fontSize: 19)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kata sandi baru minimal 8 karakter.',
                    style: AppTypography.bodySmall(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  if (errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(errorMsg!, style: AppTypography.caption(color: AppColors.error)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  EcoTextField(
                    label: 'Kata Sandi Saat Ini',
                    hintText: 'Masukkan kata sandi lama',
                    obscureText: true,
                    controller: curController,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 14),
                  EcoTextField(
                    label: 'Kata Sandi Baru',
                    hintText: 'Minimal 8 karakter',
                    obscureText: true,
                    controller: newController,
                    prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 14),
                  EcoTextField(
                    label: 'Konfirmasi Kata Sandi Baru',
                    hintText: 'Ulangi kata sandi baru',
                    obscureText: true,
                    controller: confirmController,
                    prefixIcon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 24),
                  EcoPrimaryButton(
                    text: 'Perbarui Kata Sandi',
                    isLoading: isSaving,
                    onPressed: () async {
                      if (curController.text.isEmpty || newController.text.isEmpty) {
                        setSheetState(() => errorMsg = 'Semua bidang kata sandi wajib diisi.');
                        return;
                      }
                      if (newController.text.length < 8) {
                        setSheetState(() => errorMsg = 'Kata sandi baru minimal 8 karakter.');
                        return;
                      }
                      if (newController.text != confirmController.text) {
                        setSheetState(() => errorMsg = 'Konfirmasi kata sandi tidak cocok.');
                        return;
                      }

                      setSheetState(() {
                        isSaving = true;
                        errorMsg = null;
                      });

                      final navigator = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);

                      final res = await _authService.changePassword(
                        currentPassword: curController.text,
                        newPassword: newController.text,
                      );
                      if (!mounted) return;
                      if (res['success'] == true) {
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(content: Text(res['message'] ?? 'Kata sandi berhasil diubah.')),
                        );
                      } else {
                        setSheetState(() {
                          isSaving = false;
                          errorMsg = res['message'] ?? 'Gagal mengubah kata sandi.';
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFaqSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pusat Bantuan & FAQ', style: AppTypography.h2().copyWith(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildFaqItem(
                    'Bagaimana cara setor sampah di posko?',
                    'Bawa sampah terpilah ke Posko Eco Plamo. Buka menu Scan & QR Saya di aplikasi lalu tunjukkan kepada petugas posko.',
                  ),
                  _buildFaqItem(
                    'Berapa minimal saldo untuk pencairan?',
                    'Pencairan tabungan minimal Rp 50.000 dan dapat diajukan langsung melalui Dashboard Warga.',
                  ),
                  _buildFaqItem(
                    'Kapan jadwal posko penimbangan dibuka?',
                    'Posko buka setiap hari Sabtu pukul 08:00 - 11:00 WIB di Balai Warga RT 05 / RW 03.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ExpansionTile(
        title: Text(question, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Text(answer, style: AppTypography.bodySmall(color: AppColors.textSecondary))],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final nama = _user?['nama_lengkap'] as String? ?? 'Warga Eco Plamo';
    final wa = _user?['no_whatsapp'] as String? ?? '-';
    final alamat = _user?['role_data']?['alamat'] as String? ?? 'Blok A2 / No. 14';
    final initial = nama.isNotEmpty ? nama[0].toUpperCase() : 'W';

    final saldo = (_dashboardData?['saldo'] as num?)?.toDouble() ?? 25000.0;
    final totalSampah = (_dashboardData?['kontribusi']?['total_sampah_kg'] as num?)?.toDouble() ?? 0.0;
    final saldoFmt = saldo.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              // Header Profil Emerald Green
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 28,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF005232), Color(0xFF006D44)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Profil Saya', style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 20)),
                        IconButton(
                          icon: const Icon(Icons.qr_code_rounded, color: Colors.white),
                          tooltip: 'QR Code Saya',
                          onPressed: () => EcoScanModal.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showEditProfileSheet,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(nama, style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text('$wa • $alamat', style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.85))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF5EE3A0), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _isPengurus
                                ? (_user?['role_data']?['jabatan'] ?? 'Pengurus Posko RT 05 / RW 03')
                                : 'Warga Posko RT 05 / RW 03',
                            style: AppTypography.caption(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pocket Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isPengurus ? 'Hak Akses Sistem' : 'Saldo Tabungan',
                              style: AppTypography.caption(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isPengurus ? 'Pengurus Posko' : 'Rp $saldoFmt',
                              style: AppTypography.h2(color: AppColors.primary).copyWith(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: AppColors.borderLight),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPengurus ? 'Area Tugas' : 'Total Setoran',
                                style: AppTypography.caption(color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isPengurus ? 'RT 05 / RW 03' : '${totalSampah.toStringAsFixed(1)} Kg',
                                style: AppTypography.h3().copyWith(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Group 1: Akun & Keamanan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Akun & Keamanan', style: AppTypography.sectionTitle()),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Data Profil',
                            subtitle: 'Perbarui nama lengkap dan blok rumah',
                            onTap: _showEditProfileSheet,
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.lock_outline_rounded,
                            title: 'Keamanan & Kata Sandi',
                            subtitle: 'Ubah kata sandi akun Eco Plamo',
                            onTap: _showChangePasswordSheet,
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.qr_code_2_rounded,
                            title: 'Tampilkan QR Code Saya',
                            subtitle: 'ID Warga digital untuk penimbangan posko',
                            onTap: () => EcoScanModal.show(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Group 2: Posko & Bantuan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi & Posko', style: AppTypography.sectionTitle()),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.menu_book_outlined,
                            title: 'Katalog Harga Sampah',
                            subtitle: 'Daftar harga kategori sampah terupdate',
                            onTap: () => Navigator.pushReplacementNamed(context, '/katalog'),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.campaign_outlined,
                            title: 'Informasi & Pengumuman',
                            subtitle: 'Kabar dan agenda penimbangan posko',
                            onTap: () => Navigator.pushReplacementNamed(context, '/info'),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Pusat Bantuan & FAQ',
                            subtitle: 'Panduan memilah dan jadwal posko',
                            onTap: _showFaqSheet,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                    label: Text('Keluar dari Akun', style: AppTypography.button(color: AppColors.error).copyWith(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EcoBottomNavBar(
        currentIndex: 4,
        onTap: _onNavTap,
        onScanTap: () => EcoScanModal.show(context),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(subtitle, style: AppTypography.caption(color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 68, endIndent: 16, color: AppColors.borderLight);
  }
}
