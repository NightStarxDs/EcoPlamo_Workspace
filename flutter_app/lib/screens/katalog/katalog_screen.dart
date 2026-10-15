import 'package:flutter/material.dart';
import '../../models/katalog_item.dart';
import '../../services/katalog_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_bottom_nav.dart';
import '../../widgets/eco_logo.dart';

/// Pilihan urutan di tombol filter.
enum _Urutan { bawaan, termurah, termahal }

/// Screen: Katalog Harga Sampah
/// - Data diambil dari API Laravel (GET /api/katalog).
/// - Pencarian & filter kategori dilakukan lokal pada data yang sudah diterima.
class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final _katalogService = KatalogService();
  final _searchController = TextEditingController();

  List<KatalogItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _keyword = '';
  String _kategoriAktif = 'Semua';
  _Urutan _urutan = _Urutan.bawaan;

  static const Color _infoBg = Color(0xFFEAF4FD);
  static const Color _infoBorder = Color(0xFFBFDDF7);

  @override
  void initState() {
    super.initState();
    _loadKatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------- Data ----------------

  Future<void> _loadKatalog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _katalogService.fetchKatalog();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> get _daftarKategori {
    final jenis = _items
        .map((item) => item.jenis)
        .whereType<String>()
        .where((j) => j.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Semua', ...jenis];
  }

  List<KatalogItem> get _itemsTampil {
    final keyword = _keyword.trim().toLowerCase();

    final hasil = _items.where((item) {
      final cocokKategori =
          _kategoriAktif == 'Semua' || item.jenis == _kategoriAktif;
      final cocokKeyword =
          keyword.isEmpty || item.nama.toLowerCase().contains(keyword);
      return cocokKategori && cocokKeyword;
    }).toList();

    if (_urutan == _Urutan.termurah) {
      hasil.sort((a, b) => a.harga.compareTo(b.harga));
    } else if (_urutan == _Urutan.termahal) {
      hasil.sort((a, b) => b.harga.compareTo(a.harga));
    }
    return hasil;
  }

  // ---------------- Aksi ----------------

  void _kembali() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/warga-dashboard');
    }
  }

  void _onNavTap(int index) {
    if (index == 1) return;
    if (index == 0) {
      _kembali();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Halaman ini belum tersedia.')),
    );
  }

  void _bukaFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        Widget opsi(_Urutan nilai, String label) {
          return ListTile(
            title: Text(label, style: AppTypography.bodyLarge()),
            trailing: Icon(
              _urutan == nilai ? Icons.check_circle : Icons.circle_outlined,
              color: _urutan == nilai ? AppColors.primary : AppColors.border,
            ),
            onTap: () {
              setState(() => _urutan = nilai);
              Navigator.pop(ctx);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Urutkan Harga', style: AppTypography.h3()),
              ),
              opsi(_Urutan.bawaan, 'Bawaan'),
              opsi(_Urutan.termurah, 'Harga terendah'),
              opsi(_Urutan.termahal, 'Harga tertinggi'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ---------------- Tampilan ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadKatalog,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildJudul(),
                            const SizedBox(height: 16),
                            _buildPencarian(),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildChipKategori()),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      sliver: SliverToBoxAdapter(child: _buildInfo()),
                    ),
                    ..._buildIsi(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EcoBottomNavBar(
        currentIndex: 1,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const EcoPlamoLogo(size: 40, withBackground: true),
          const SizedBox(width: 10),
          Text('Eco Plamo', style: AppTypography.h2(color: AppColors.primary)),
          const Spacer(),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru.')),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 26,
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildJudul() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppColors.borderLight,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _kembali,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.chevron_left, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Katalog Harga Sampah', style: AppTypography.h3()),
              const SizedBox(height: 2),
              Text(
                'Harga sampah sesuai dengan kondisi dan jenisnya',
                style: AppTypography.bodySmall(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPencarian() {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _keyword = value),
            style: AppTypography.formInput(),
            decoration: InputDecoration(
              hintText: 'Cari jenis sampah (Misal: Kardus)',
              hintStyle: AppTypography.formHint(),
              prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
              suffixIcon: _keyword.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _keyword = '');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: border(AppColors.border),
              focusedBorder: border(AppColors.borderFocused),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _urutan == _Urutan.bawaan
                  ? AppColors.border
                  : AppColors.primary,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _bukaFilter,
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.tune, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipKategori() {
    final kategori = _daftarKategori;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kategori.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final nama = kategori[index];
          final aktif = nama == _kategoriAktif;

          return GestureDetector(
            onTap: () => setState(() => _kategoriAktif = nama),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: aktif ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: aktif ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                nama,
                style: AppTypography.bodyMedium(
                  color: aktif ? Colors.white : AppColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _infoBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _infoBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.infoDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Harga dapat berubah sesuai dengan kebijakan Pengurus dan Pihak Terkait.',
              style: AppTypography.bodySmall(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIsi() {
    if (_isLoading) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ];
    }

    if (_errorMessage != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildPesan(
            icon: Icons.wifi_off_rounded,
            judul: 'Gagal memuat katalog',
            keterangan: _errorMessage!,
            tombolUlang: true,
          ),
        ),
      ];
    }

    final items = _itemsTampil;
    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildPesan(
            icon: Icons.search_off_rounded,
            judul: _items.isEmpty
                ? 'Katalog masih kosong'
                : 'Jenis sampah tidak ditemukan',
            keterangan: _items.isEmpty
                ? 'Belum ada data harga sampah dari pengurus.'
                : 'Coba kata kunci atau kategori lain.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _buildKartu(items[index]),
        ),
      ),
    ];
  }

  Widget _buildKartu(KatalogItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildGambar(item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3().copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  item.deskripsi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall(),
                ),
                const SizedBox(height: 6),
                Text(
                  item.hargaLabel,
                  style: AppTypography.bodyMedium(color: AppColors.primary)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGambar(KatalogItem item) {
    const double ukuran = 48;
    final placeholder = Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    if (item.gambarUrl == null) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        item.gambarUrl!,
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }

  Widget _buildPesan({
    required IconData icon,
    required String judul,
    required String keterangan,
    bool tombolUlang = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.textHint),
          const SizedBox(height: 8),
          Text(judul, style: AppTypography.h3(), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            keterangan,
            style: AppTypography.bodySmall(),
            textAlign: TextAlign.center,
          ),
          if (tombolUlang) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadKatalog,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}