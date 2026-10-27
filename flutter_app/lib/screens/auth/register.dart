import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_button.dart';
import '../../widgets/eco_logo.dart';
import '../../widgets/eco_text_field.dart';

enum _TipeHunian { kosKontrakan, rumahBiasa }

/// Screen: Registrasi Akun Warga (FR-01)
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
          : 'Alamat rumah wajib diisi';
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

    final alamat = _alamatController.text.trim();
    final res = await _authService.register(
      namaLengkap: _namaController.text,
      noWhatsapp: _whatsappController.text,
      tipeHunian: _tipeHunian == _TipeHunian.kosKontrakan
          ? 'kos_kontrakan'
          : 'rumah_biasa',
      alamat: _tipeHunian == _TipeHunian.rumahBiasa ? alamat : '',
      nomorHunian: _tipeHunian == _TipeHunian.kosKontrakan ? alamat : null,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final berhasil = res['success'] == true;
    _showMessage(res['message'] ?? '', isError: !berhasil);

    if (berhasil) {
      _goToLogin();
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
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
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
      padding: EdgeInsets.fromLTRB(24, statusBarHeight + 28, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        children: [
          const EcoPlamoLogo(size: 72, withBackground: false),
          const SizedBox(height: 12),
          Text(
            'Buat Akun Baru',
            textAlign: TextAlign.center,
            style: AppTypography.displayBold(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai perjalanan ekonomi sirkular Anda di Plamo Garden.',
            textAlign: TextAlign.center,
            style: AppTypography.slogan(
              color: Colors.white,
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
                  : 'Alamat Rumah',
              hintText: _tipeHunian == _TipeHunian.kosKontrakan
                  ? 'Contoh: Pintu 3 atau Kontrakan No. 2'
                  : 'Contoh: Blok A No. 2',
              controller: _alamatController,
              validator: _validateAlamat,
            ),
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
          const SizedBox(height: 28),
          EcoPrimaryButton(
            text: 'Buat Akun',
            isLoading: _isLoading,
            onPressed: _handleRegister,
          ),
          const SizedBox(height: 16),
          _buildLoginLink(),
        ],
      ),
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
