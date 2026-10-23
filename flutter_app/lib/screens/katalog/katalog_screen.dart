import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/katalog_item.dart';
import '../../services/auth_service.dart';
import '../../services/katalog_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_bottom_nav.dart';
import '../../widgets/eco_logo.dart';
import '../../widgets/eco_scan_modal.dart';
import '../pengurus/catat_setoran_screen.dart';

/// Pilihan urutan di tombol filter.
enum _Urutan { bawaan, termurah, termahal }

/// Screen: Katalog Harga Sampah
/// - Untuk Warga: Melihat daftar harga sampah aktif
/// - Untuk Pengurus: Dilengkapi tombol aksi Tambah, Edit, Nonaktifkan/Aktifkan, dan Hapus
class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final _katalogService = KatalogService();
  final _authService = AuthService();
  final _searchController = TextEditingController();

  List<KatalogItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPengurus = false;

  String _keyword = '';
  String _kategoriAktif = 'Semua';
  _Urutan _urutan = _Urutan.bawaan;

  static const Color _infoBg = Color(0xFFEAF4FD);
  static const Color _infoBorder = Color(0xFFBFDDF7);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _isPengurus = user?['role'] == 'pengurus';
      });
    }
    await _loadKatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------- Data ----------------

  Future<void> _checkRoleAndLoad() async {
    final isPengurus = await _authService.isPengurus();
    if (!mounted) return;
    setState(() => _isPengurus = isPengurus);
    await _loadKatalog();
  }

  Future<void> _loadKatalog() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _katalogService.fetchKatalog(all: _isPengurus);
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

  // ---------------- Aksi Pengurus (Tambah / Edit / Nonaktifkan / Hapus) ----------------

  /// Warna badge kode sesuai kategori (P = Plastik, C = Logam, K = Kertas, Mj = Minyak)
  Color _kodeColor(String kode) {
    final prefix = kode.isEmpty ? '' : kode[0].toUpperCase();
    switch (prefix) {
      case 'P':
        return const Color(0xFF1565C0); // biru – Plastik
      case 'C':
        return const Color(0xFFE65100); // oranye – Logam/Kaleng
      case 'K':
        return const Color(0xFF2E7D32); // hijau – Kertas
      case 'M':
        return const Color(0xFFF57F17); // kuning – Minyak
      default:
        return const Color(0xFF455A64); // abu-abu – lainnya
    }
  }

  void _tambahKategoriModal() {
    _formKategoriModal(null);
  }

  void _editKategoriModal(KatalogItem item) {
    _formKategoriModal(item);
  }

  void _formKategoriModal(KatalogItem? item) {
    final isEdit = item != null;
    final kodeCtrl = TextEditingController(text: item?.kode ?? '');
    final namaCtrl = TextEditingController(text: item?.nama ?? '');
    final hargaCtrl = TextEditingController(text: item != null ? item.harga.toStringAsFixed(0) : '');
    final satuanCtrl = TextEditingController(text: item?.satuan ?? 'kg');
    final jenisCtrl = TextEditingController(text: item?.jenis ?? 'Plastik');
    final deskripsiCtrl = TextEditingController(text: item?.deskripsi ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_rounded : Icons.add_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEdit ? 'Edit Kategori Sampah' : 'Tambah Kategori Sampah',
                      style: AppTypography.h3(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: kodeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Kode',
                          hintText: 'P1, C1...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: namaCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nama Kategori / Sampah',
                          hintText: 'Contoh: Kardus Tebal',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: hargaCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga (Rp)',
                          hintText: 'Contoh: 3000',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: satuanCtrl,
                        decoration: InputDecoration(
                          labelText: 'Satuan',
                          hintText: 'kg / liter',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: jenisCtrl,
                  decoration: InputDecoration(
                    labelText: 'Jenis / Kelompok',
                    hintText: 'Kardus / Plastik / Minyak / Logam',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deskripsiCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi / Kondisi Sampah',
                    hintText: 'Contoh: Bersih, kering, tidak basah/berminyak',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: isSaving
                        ? null
                        : () async {
                            final nama = namaCtrl.text.trim();
                            final harga = double.tryParse(hargaCtrl.text.trim()) ?? 0;
                            if (nama.isEmpty || harga <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nama dan harga valid wajib diisi.')),
                              );
                              return;
                            }
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(ctx);
                            setMState(() => isSaving = true);
                            Map<String, dynamic> res;
                            if (isEdit) {
                              res = await _authService.updateKategoriSampah(
                                id: item.id,
                                kode: kodeCtrl.text.trim(),
                                nama: nama,
                                harga: harga,
                                satuan: satuanCtrl.text,
                                jenis: jenisCtrl.text,
                                deskripsi: deskripsiCtrl.text,
                              );
                            } else {
                              res = await _authService.tambahKategoriSampah(
                                kode: kodeCtrl.text.trim(),
                                nama: nama,
                                harga: harga,
                                satuan: satuanCtrl.text,
                                jenis: jenisCtrl.text,
                                deskripsi: deskripsiCtrl.text,
                              );
                            }
                            if (!mounted) return;
                            nav.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(res['message']?.toString() ?? 'Selesai.'),
                                backgroundColor:
                                    res['success'] == true ? AppColors.primary : AppColors.error,
                              ),
                            );
                            if (res['success'] == true) _loadKatalog();
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Sekarang'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleStatus(KatalogItem item) async {
    final nextStatus = item.status == 'aktif' ? 'nonaktif' : 'aktif';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.status == 'aktif' ? 'Nonaktifkan Kategori?' : 'Aktifkan Kategori?'),
        content: Text('Ubah status "${item.nama}" menjadi $nextStatus?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(item.status == 'aktif' ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final res = await _authService.toggleStatusKategoriSampah(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']?.toString() ?? ''),
        backgroundColor: res['success'] == true ? AppColors.primary : AppColors.error,
      ),
    );
    if (res['success'] == true) _loadKatalog();
  }

  Future<void> _hapusKategori(KatalogItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori Sampah?'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.nama}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final res = await _authService.hapusKategoriSampah(item.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']?.toString() ?? ''),
        backgroundColor: res['success'] == true ? AppColors.primary : AppColors.error,
      ),
    );
    if (res['success'] == true) _loadKatalog();
  }

  // ---------------- Navigasi ----------------

  void _kembali() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        _isPengurus ? '/pengurus-dashboard' : '/warga-dashboard',
      );
    }
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    if (index == 1) return;
    if (index == 0) {
      Navigator.pushReplacementNamed(
        context,
        _isPengurus ? '/pengurus-dashboard' : '/warga-dashboard',
      );
    } else if (index == 2) {
      if (_isPengurus) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatSetoranScreen()));
      } else {
        EcoScanModal.show(context);
      }
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/info');
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
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
      floatingActionButton: _isPengurus
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Sampah'),
              onPressed: _tambahKategoriModal,
            )
          : null,
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
      floatingActionButton: _isPengurus
          ? FloatingActionButton.extended(
              onPressed: _tambahKategoriModal,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Tambah Kategori', style: TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: EcoBottomNavBar(
        currentIndex: 1,
        onTap: _onNavTap,
        onScanTap: () {
          if (_isPengurus) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatSetoranScreen()));
          } else {
            EcoScanModal.show(context);
          }
        },
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
          if (_isPengurus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Mode Pengurus',
                style: AppTypography.caption(color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
              ),
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
                _isPengurus
                    ? 'Kelola data harga sampah, tambah baru, edit, dan nonaktifkan'
                    : 'Harga sampah sesuai dengan kondisi dan jenisnya',
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
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _bukaFilter,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.tune, color: AppColors.textPrimary),
                  if (_urutan != _Urutan.bawaan)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipKategori() {
    final kategori = _daftarKategori;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: kategori.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final nama = kategori[index];
          final aktif = nama == _kategoriAktif;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _kategoriAktif = nama),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: aktif ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: aktif ? AppColors.primary : AppColors.borderLight,
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
              _isPengurus
                  ? 'Pengurus dapat menambah, mengedit, menonaktifkan, atau menghapus kategori harga sampah.'
                  : 'Harga dapat berubah sesuai dengan kebijakan Pengurus dan Pihak Terkait.',
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
                ? 'Belum ada data harga sampah.'
                : 'Coba kata kunci atau kategori lain.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, _isPengurus ? 84 : 24),
        sliver: SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _buildKartu(items[index]),
        ),
      ),
    ];
  }

  Widget _buildKartu(KatalogItem item) {
    final isNonaktif = item.status == 'nonaktif';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNonaktif ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNonaktif ? Colors.grey.shade300 : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildGambar(item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Kode badge (P1, C1, K1, Mj, dll.)
                        if (item.kode.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: _kodeColor(item.kode).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _kodeColor(item.kode).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              item.kode,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _kodeColor(item.kode),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            item.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.h3().copyWith(
                              fontSize: 14,
                              color: isNonaktif ? AppColors.textMuted : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_isPengurus)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isNonaktif
                                  ? Colors.grey.shade300
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isNonaktif ? 'Nonaktif' : 'Aktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isNonaktif ? Colors.grey.shade700 : AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.deskripsi.isNotEmpty ? item.deskripsi : 'Sampah terpilah siap daur ulang',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.hargaLabel,
                      style: AppTypography.bodyMedium(
                        color: isNonaktif ? AppColors.textMuted : AppColors.primary,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isPengurus) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.textSecondary,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  onPressed: () => _editKategoriModal(item),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: isNonaktif ? AppColors.primary : AppColors.warningDark,
                  ),
                  icon: Icon(
                    isNonaktif ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    size: 16,
                  ),
                  label: Text(isNonaktif ? 'Aktifkan' : 'Nonaktifkan'),
                  onPressed: () => _toggleStatus(item),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.error,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Hapus'),
                  onPressed: () => _hapusKategori(item),
                ),
              ],
            ),
          ],
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
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.recycling_rounded, color: AppColors.primary, size: 24),
    );

    if (item.gambarUrl == null || item.gambarUrl!.isEmpty) {
      return placeholder;
    }

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(judul, style: AppTypography.h3(), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(keterangan, style: AppTypography.bodySmall(), textAlign: TextAlign.center),
            if (tombolUlang) ...[
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: _loadKatalog,
                child: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}