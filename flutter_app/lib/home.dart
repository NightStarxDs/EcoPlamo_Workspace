import 'package:flutter/material.dart';
import 'screens/warga/warga_dashboard.dart';

/// ============================================================================
/// HomePage: Mengarahkan langsung ke Dashboard Warga sesuai desain Figma Halaman 7.
/// Memastikan saat aplikasi berjalan dan hot-reload dipanggil, layar langsung
/// menampilkan WargaDashboard (Halaman 7 & 17).
/// ============================================================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WargaDashboard();
  }
}
