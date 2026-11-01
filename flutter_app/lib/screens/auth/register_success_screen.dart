import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_button.dart';
import '../../widgets/eco_logo.dart';

/// Screen: Tiket Registrasi Warga & Instruksi Posko (Revisi Alur Pendaftaran)
/// Menampilkan bukti pendaftaran sementara, instruksi pembayaran kas posko,
/// dan verifikasi domisili oleh pengurus RT/RW.
class RegisterSuccessScreen extends StatelessWidget {
  final String namaLengkap;
  final String noWhatsapp;
  final String tipeHunian;
  final String alamat;
  final String? rtRw;
  final String nomorTiket;
  final String biayaPendaftaran;

  const RegisterSuccessScreen({
    super.key,
    required this.namaLengkap,
    required this.noWhatsapp,
    required this.tipeHunian,
    required this.alamat,
    this.rtRw,
    required this.nomorTiket,
    this.biayaPendaftaran = 'Rp 10.000',
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: nomorTiket));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Nomor tiket berhasil disalin!'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.canvasWarm, // Warm Cream Starbucks canvas
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Header Hijau Forest (House Green)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, statusBarHeight + 20, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.houseGreen, AppColors.brandEmerald],
                  ),
                ),
                child: Column(
                  children: [
                    const EcoPlamoLogo(size: 64, withBackground: false),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.goldLightTint.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppColors.prestigeGold.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.access_time_filled_rounded,
                              color: AppColors.prestigeGold, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Menunggu Verifikasi & Pembayaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pendaftaran Diterima!',
                      textAlign: TextAlign.center,
                      style: AppTypography.displayBold(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Satu langkah lagi untuk mengaktifkan akun warga Anda.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Kartu Tiket Digital (Receipt Style)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    _buildTicketCard(context),
                    const SizedBox(height: 20),
                    _buildInstructionCard(),
                    const SizedBox(height: 28),

                    // Tombol Aksi
                    EcoPrimaryButton(
                      text: 'Kembali ke Halaman Masuk',
                      borderRadius: 50,
                      backgroundColor: AppColors.accentGreen,
                      onPressed: () => _goToLogin(context),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderLight, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text(
                        'Salin Nomor Tiket',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _copyToClipboard(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Tiket
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCeramic,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TIKET PENDAFTARAN',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nomorTiket,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandEmerald,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Salin nomor tiket',
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),

          // Dashed divider visual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                _buildInfoRow('Nama Lengkap', namaLengkap),
                const Divider(height: 20, color: AppColors.borderLight),
                _buildInfoRow('Nomor WhatsApp', noWhatsapp),
                const Divider(height: 20, color: AppColors.borderLight),
                _buildInfoRow(
                  'Tempat Tinggal',
                  tipeHunian == 'kos_kontrakan' ? 'Kontrakan / Kos' : 'Rumah Biasa',
                ),
                const Divider(height: 20, color: AppColors.borderLight),
                _buildInfoRow('Alamat / Hunian', alamat),
                if (rtRw != null && rtRw!.isNotEmpty) ...[
                  const Divider(height: 20, color: AppColors.borderLight),
                  _buildInfoRow('Wilayah RT/RW', rtRw!),
                ],
                const Divider(height: 20, color: AppColors.borderLight),
                _buildInfoRow(
                  'Uang Pendaftaran',
                  biayaPendaftaran,
                  valueColor: AppColors.primary,
                  isBold: true,
                ),
              ],
            ),
          ),

          // Barcode dummy dekoratif elegan
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.mintWash.withValues(alpha: 0.25),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(17)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.qr_code_2_rounded, size: 22, color: AppColors.brandEmerald),
                SizedBox(width: 8),
                Text(
                  'Tunjukkan nomor ini kepada Pengurus di Posko',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandEmerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: isBold ? 'Poppins' : 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.assignment_turned_in_rounded,
                  color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'Langkah Selanjutnya',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepItem(
            stepNumber: '1',
            title: 'Kunjungi Posko RT/RW',
            description:
                'Datang ke Posko Bank Sampah Eco Plamo pada jadwal operasional posko lingkungan setempat.',
          ),
          const SizedBox(height: 14),
          _buildStepItem(
            stepNumber: '2',
            title: 'Bayar Uang Pendaftaran',
            description:
                'Bayar uang kas pendaftaran (Rp 10.000) secara tunai kepada pengurus posko.',
          ),
          const SizedBox(height: 14),
          _buildStepItem(
            stepNumber: '3',
            title: 'Validasi & Aktivasi Akun',
            description:
                'Pengurus memverifikasi data domisili warga dan mengaktifkan akun Anda. Setelah aktif, Anda dapat langsung login.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.mintWash,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brandEmerald, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.brandEmerald,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
