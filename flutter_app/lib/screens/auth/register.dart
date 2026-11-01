import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_button.dart';
import '../../widgets/eco_logo.dart';
import '../../widgets/eco_text_field.dart';
import 'register_success_screen.dart';

enum _TipeHunian { kosKontrakan, rumahBiasa }

/// Screen: Registrasi Akun Warga (FR-01) - Alur Baru dengan Verifikasi Posko RT/RW
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  _TipeHunian? _tipeHunian;
  String? _selectedRt = 'RT 01';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _whatsappController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------- Validasi ----------------

  String? _validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    return null;
  }

  String? _validateWhatsapp(String? value) {
    final nomor = value?.trim() ?? '';
    if (nomor.isEmpty) {
      return 'Nomor WhatsApp wajib diisi';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(nomor)) {
      return 'Nomor WhatsApp hanya boleh berisi angka';
    }
    if (!nomor.startsWith('08')) {
      return 'Nomor WhatsApp harus diawali 08';
    }
    if (nomor.length < 10 || nomor.length > 13) {
      return 'Nomor WhatsApp harus 10–13 digit';
    }
    return null;
  }

  String? _validateAlamat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _tipeHunian == _TipeHunian.kosKontrakan
          ? 'Nomor pintu atau nomor kontrakan wajib diisi'
          : 'Blok dan nomor rumah wajib diisi';
    }
    return null;
  }

  String? _validateTipeHunian(_TipeHunian? value) {
    if (value == null) {
      return 'Tipe tempat tinggal wajib dipilih';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    return null;
  }

  // ---------------- Aksi ----------------

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    setState(() => _isLoading = true);

    final rawAlamat = _alamatController.text.trim();
    final fullAlamat = _selectedRt != null && _selectedRt!.isNotEmpty
        ? '$rawAlamat, $_selectedRt / RW 08'
        : rawAlamat;

    final res = await _authService.register(
      namaLengkap: _namaController.text,
      noWhatsapp: _whatsappController.text,
      tipeHunian: _tipeHunian == _TipeHunian.kosKontrakan
          ? 'kos_kontrakan'
          : 'rumah_biasa',
      alamat: _tipeHunian == _TipeHunian.rumahBiasa ? fullAlamat : '',
      nomorHunian: _tipeHunian == _TipeHunian.kosKontrakan ? fullAlamat : null,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final berhasil = res['success'] == true;

    if (berhasil) {
      HapticFeedback.mediumImpact();

      // Ekstrak nomor tiket dari backend atau buat tiket referensi unik
      final data = res['data'] is Map ? res['data'] : null;
      final nomorTiket = res['nomor_tiket'] ??
          data?['nomor_tiket'] ??
          'REG-PLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // Alihkan langsung ke Layar Tiket Registrasi Warga
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterSuccessScreen(
            namaLengkap: _namaController.text.trim(),
            noWhatsapp: _whatsappController.text.trim(),
            tipeHunian: _tipeHunian == _TipeHunian.kosKontrakan
                ? 'kos_kontrakan'
                : 'rumah_biasa',
            alamat: _alamatController.text.trim(),
            rtRw: _selectedRt != null ? '$_selectedRt / RW 08' : 'RW 08 Plamo Garden',
            nomorTiket: nomorTiket.toString(),
            biayaPendaftaran: 'Rp 10.000',
          ),
        ),
      );
    } else {
      _showMessage(res['message'] ?? 'Pendaftaran gagal.', isError: true);
    }
  }

  void _goToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ---------------- Tampilan ----------------

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.canvasWarm, // Warm neutral background
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: _buildForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, statusBarHeight + 24, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.houseGreen, AppColors.brandEmerald],
        ),
      ),
      child: Column(
        children: [
          const EcoPlamoLogo(size: 68, withBackground: false),
          const SizedBox(height: 12),
          Text(
            'Pendaftaran Warga Baru',
            textAlign: TextAlign.center,
            style: AppTypography.displayBold(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Bank Sampah Digital — Lingkungan RT/RW Plamo Garden',
            textAlign: TextAlign.center,
            style: AppTypography.slogan(
              color: Colors.white.withValues(alpha: 0.9),
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Alur Verifikasi Posko & Uang Pendaftaran
          _buildVerificationNoticeBanner(),
          const SizedBox(height: 20),

          EcoTextField(
            label: 'Nama Lengkap',
            hintText: 'Sesuai KTP / Nama panggilan',
            controller: _namaController,
            validator: _validateNama,
          ),
          const SizedBox(height: 16),
          EcoTextField(
            label: 'Nomor Whatsapp',
            hintText: 'Contoh: 08123456789',
            controller: _whatsappController,
            keyboardType: TextInputType.phone,
            validator: _validateWhatsapp,
          ),
          const SizedBox(height: 16),
          _buildTipeHunianField(),
          if (_tipeHunian != null) ...[
            const SizedBox(height: 16),
            EcoTextField(
              key: ValueKey(_tipeHunian),
              label: _tipeHunian == _TipeHunian.kosKontrakan
                  ? 'Nomor Pintu / Nomor Kontrakan'
                  : 'Blok & Nomor Rumah',
              hintText: _tipeHunian == _TipeHunian.kosKontrakan
                  ? 'Contoh: Pintu 3 atau Kontrakan No. 2'
                  : 'Contoh: Blok B No. 12',
              controller: _alamatController,
              validator: _validateAlamat,
            ),
            const SizedBox(height: 16),
            _buildRtField(),
          ],
          const SizedBox(height: 16),
          EcoTextField(
            label: 'Kata Sandi',
            hintText: 'Buat kata sandi (min. 8 karakter)',
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleRegister(),
            validator: _validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
              onPressed: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Ringkasan Biaya Registrasi
          _buildRegistrationFeeCard(),
          const SizedBox(height: 24),

          // Tombol Full-Pill Aksi Starbucks
          EcoPrimaryButton(
            text: 'Daftar & Ambil Tiket Posko',
            borderRadius: 50,
            backgroundColor: AppColors.accentGreen,
            isLoading: _isLoading,
            onPressed: _handleRegister,
          ),
          const SizedBox(height: 16),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildVerificationNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCeramic,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.mintWash,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.brandEmerald,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alur Verifikasi RT/RW',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Setelah mengisi formulir, Anda akan mendapatkan nomor tiket untuk verifikasi domisili & pembayaran kas pendaftaran di posko pengurus.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationFeeCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.payments_outlined, size: 18, color: AppColors.brandEmerald),
              SizedBox(width: 8),
              Text(
                'Biaya Kas Pendaftaran Posko:',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Text(
            'Rp 10.000',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.brandEmerald,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRtField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wilayah RT (Rukun Tetangga)', style: AppTypography.formLabel()),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedRt,
          decoration: InputDecoration(
            hintText: 'Pilih Wilayah RT',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          style: AppTypography.formInput(),
          items: const [
            DropdownMenuItem(value: 'RT 01', child: Text('RT 01 / RW 08')),
            DropdownMenuItem(value: 'RT 02', child: Text('RT 02 / RW 08')),
            DropdownMenuItem(value: 'RT 03', child: Text('RT 03 / RW 08')),
            DropdownMenuItem(value: 'RT 04', child: Text('RT 04 / RW 08')),
            DropdownMenuItem(value: 'RT 05', child: Text('RT 05 / RW 08')),
          ],
          onChanged: (val) {
            setState(() => _selectedRt = val);
          },
        ),
      ],
    );
  }

  Widget _buildTipeHunianField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipe Tempat Tinggal', style: AppTypography.formLabel()),
        const SizedBox(height: 8),
        DropdownButtonFormField<_TipeHunian>(
          initialValue: _tipeHunian,
          decoration: InputDecoration(
            hintText: 'Pilih tipe tempat tinggal',
            hintStyle: AppTypography.formHint(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.white,
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
          style: AppTypography.formInput(),
          validator: _validateTipeHunian,
          items: const [
            DropdownMenuItem(
              value: _TipeHunian.kosKontrakan,
              child: Text('Kontrakan / Kos'),
            ),
            DropdownMenuItem(
              value: _TipeHunian.rumahBiasa,
              child: Text('Rumah Biasa'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _tipeHunian = value;
              _alamatController.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _isLoading ? null : _goToLogin,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: RichText(
            text: TextSpan(
              text: 'Sudah punya akun? ',
              style: AppTypography.bodyMedium(color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: 'Masuk di sini',
                  style: AppTypography.bodyMedium(
                    color: AppColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
