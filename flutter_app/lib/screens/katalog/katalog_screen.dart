import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/katalog_item.dart';
import '../../services/auth_service.dart';
import '../../services/katalog_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_bottom_nav.dart';
import '../../widgets/eco_responsive_body.dart';
import '../../widgets/eco_scan_modal.dart';
import '../pengurus/catat_setoran_screen.dart';

/// Pilihan urutan di tombol filter.
enum _Urutan { bawaan, termurah, termahal }

/// Screen: Katalog Harga Sampah
/// - Untuk Warga: Melihat daftar harga sampah aktif
/// - Untuk Pengurus: Mengelola kategori sampah dengan tata letak rapi, cepat, dan modern
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

  @override
  void initState() {
    super.initState();
    _checkRoleAndLoad();
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
    final jenis =
        _items
            .map((item) => item.jenis)
            .whereType<String>()
            .where((j) => j.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['Semua', ...jenis];
  }

  int _countKategori(String kategori) {
    if (kategori == 'Semua') return _items.length;
    return _items.where((item) => item.jenis == kategori).length;
  }

  List<KatalogItem> get _itemsTampil {
    final keyword = _keyword.trim().toLowerCase();

    final hasil = _items.where((item) {
      final cocokKategori =
          _kategoriAktif == 'Semua' || item.jenis == _kategoriAktif;
      final cocokKeyword =
          keyword.isEmpty ||
          item.nama.toLowerCase().contains(keyword) ||
          item.kode.toLowerCase().contains(keyword);
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

  /// Warna aksen identitas material
  Color _kodeColor(String kode) {
    final prefix = kode.isEmpty ? '' : kode[0].toUpperCase();
    switch (prefix) {
      case 'P':
        return const Color(0xFF0284C7); // Plastik – Ocean Cyan
      case 'C':
        return const Color(0xFFD97706); // Logam/Kaleng – Warm Amber
      case 'K':
        return const Color(0xFF16A34A); // Kertas – Forest Emerald
      case 'M':
        return const Color(0xFFCA8A04); // Minyak – Golden Ochre
      default:
        return const Color(0xFF475569); // Lainnya – Slate Neutral
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
    final hargaCtrl = TextEditingController(
      text: item != null ? item.harga.toStringAsFixed(0) : '',
    );
    final satuanCtrl = TextEditingController(text: item?.satuan ?? 'kg');
    final jenisCtrl = TextEditingController(text: item?.jenis ?? 'Plastik');
    final deskripsiCtrl = TextEditingController(text: item?.deskripsi ?? '');
    bool isSaving = false;

    InputDecoration inputDec({required String label, required String hint}) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTypography.caption(color: AppColors.textSecondary),
        hintStyle: AppTypography.caption(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surfaceCeramic.withValues(alpha: 0.35),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brandEmerald, width: 1.5),
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
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
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                        color: AppColors.brandEmerald,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit
                                ? 'Edit Kategori Sampah'
                                : 'Tambah Kategori Baru',
                            style: AppTypography.h3(color: AppColors.textPrimary),
                          ),
                          Text(
                            isEdit
                                ? 'Perbarui harga atau rincian spesifikasi sampah'
                                : 'Daftarkan jenis sampah baru ke katalog posko',
                            style: AppTypography.caption(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    SizedBox(
                      width: 95,
                      child: TextField(
                        controller: kodeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600),
                        decoration: inputDec(label: 'Kode', hint: 'P1, C1'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: namaCtrl,
                        style: AppTypography.bodyMedium(),
                        decoration: inputDec(
                          label: 'Nama Sampah',
                          hint: 'Contoh: Kardus Tebal',
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
                        style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600),
                        decoration: inputDec(
                          label: 'Harga per Satuan (Rp)',
                          hint: '3000',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: satuanCtrl,
                        style: AppTypography.bodyMedium(),
                        decoration: inputDec(label: 'Satuan', hint: 'kg / liter'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: jenisCtrl,
                  style: AppTypography.bodyMedium(),
                  decoration: inputDec(
                    label: 'Kelompok Kategori',
                    hint: 'Kertas / Plastik / Minyak / Logam',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deskripsiCtrl,
                  maxLines: 2,
                  style: AppTypography.bodyMedium(),
                  decoration: inputDec(
                    label: 'Deskripsi / Kondisi',
                    hint: 'Bersih, kering, tidak tercampur minyak atau tanah',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandEmerald,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50), // Starbucks signature full-pill
                      ),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            final nama = namaCtrl.text.trim();
                            final harga =
                                double.tryParse(hargaCtrl.text.trim()) ?? 0;
                            if (nama.isEmpty || harga <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Nama dan harga valid wajib diisi.',
                                  ),
                                ),
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
                                content: Text(
                                  res['message']?.toString() ?? 'Selesai.',
                                ),
                                backgroundColor: res['success'] == true
                                    ? AppColors.primary
                                    : AppColors.error,
                              ),
                            );
                            if (res['success'] == true) _loadKatalog();
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambah Sekarang',
                            style: AppTypography.button(color: Colors.white),
                          ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          item.status == 'aktif'
              ? 'Nonaktifkan Kategori?'
              : 'Aktifkan Kategori?',
          style: AppTypography.h3(),
        ),
        content: Text(
          'Ubah status "${item.nama}" menjadi $nextStatus? Kategori nonaktif tidak akan muncul di katalog warga.',
          style: AppTypography.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: AppTypography.button(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: item.status == 'aktif' ? AppColors.warningDark : AppColors.brandEmerald,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
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
        backgroundColor: res['success'] == true
            ? AppColors.primary
            : AppColors.error,
      ),
    );
    if (res['success'] == true) _loadKatalog();
  }

  Future<void> _hapusKategori(KatalogItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Kategori Sampah?', style: AppTypography.h3()),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${item.nama}" secara permanen?',
          style: AppTypography.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: AppTypography.button(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.figmaError,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus Permanen'),
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
        backgroundColor: res['success'] == true
            ? AppColors.primary
            : AppColors.error,
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CatatSetoranScreen()),
        );
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        Widget opsi(_Urutan nilai, String label) {
          return ListTile(
            title: Text(label, style: AppTypography.bodyLarge()),
            trailing: Icon(
              _urutan == nilai ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: _urutan == nilai ? AppColors.brandEmerald : AppColors.border,
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('Urutkan Berdasarkan Harga', style: AppTypography.h3()),
              ),
              opsi(_Urutan.bawaan, 'Bawaan / Abjad'),
              opsi(_Urutan.termurah, 'Harga terendah ke tertinggi'),
              opsi(_Urutan.termahal, 'Harga tertinggi ke terendah'),
              const SizedBox(height: 12),
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
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Starbucks signature full-pill
              ),
              icon: const Icon(Icons.add_rounded, size: 22),
              label: Text(
                'Tambah Sampah',
                style: AppTypography.button(color: Colors.white).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: _tambahKategoriModal,
            )
          : null,
      body: EcoResponsiveBody(
        currentIndex: 1,
        onTap: _onNavTap,
        onScanTap: () {
          if (_isPengurus) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CatatSetoranScreen()),
            );
          } else {
            EcoScanModal.show(context);
          }
        },
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildUnifiedHeader(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brandEmerald,
                  onRefresh: _loadKatalog,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isPengurus) _buildPengurusStats(),
                            _buildPencarian(),
                            const SizedBox(height: 12),
                            _buildChipKategori(),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      ..._buildIsi(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: EcoBottomNavBar(
        currentIndex: 1,
        onTap: _onNavTap,
        onScanTap: () {
          if (_isPengurus) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CatatSetoranScreen()),
            );
          } else {
            EcoScanModal.show(context);
          }
        },
      ),
    );
  }

  /// Header tunggal, elegan, dan bersih
  Widget _buildUnifiedHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Material(
            color: AppColors.surfaceCeramic,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _kembali,
              child: const SizedBox(
                width: 38,
                height: 38,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Katalog Sampah',
                      style: AppTypography.h3(color: AppColors.textPrimary),
                    ),
                    if (_isPengurus) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Pengurus',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandEmerald,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _isPengurus
                      ? 'Kelola spesifikasi & harga sampah posko'
                      : 'Daftar harga daur ulang terpilah',
                  style: AppTypography.caption(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Segarkan',
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
            onPressed: _loadKatalog,
          ),
        ],
      ),
    );
  }

  /// Strip KPI ringkas untuk Pengurus (menggantikan kotak biru monoton)
  Widget _buildPengurusStats() {
    final total = _items.length;
    final aktif = _items.where((i) => i.status == 'aktif').length;
    final nonaktif = total - aktif;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statPill(label: 'Total Jenis', value: '$total', color: AppColors.textPrimary),
          Container(height: 24, width: 1, color: AppColors.borderLight),
          _statPill(label: 'Status Aktif', value: '$aktif', color: AppColors.brandEmerald),
          Container(height: 24, width: 1, color: AppColors.borderLight),
          _statPill(
            label: 'Nonaktif',
            value: '$nonaktif',
            color: nonaktif > 0 ? AppColors.warningDark : AppColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _statPill({required String label, required String value, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.bodyLarge(color: color).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildPencarian() {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _keyword = value),
              style: AppTypography.formInput(),
              decoration: InputDecoration(
                hintText: 'Cari jenis atau kode sampah (misal: Kardus, P1)...',
                hintStyle: AppTypography.caption(color: AppColors.textHint),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _keyword.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _keyword = '');
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                enabledBorder: border(AppColors.borderLight),
                focusedBorder: border(AppColors.brandEmerald),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _bukaFilter,
              child: SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 20),
                    if (_urutan != _Urutan.bawaan)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.brandEmerald,
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
      ),
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
          final count = _countKategori(nama);
          final aktif = nama == _kategoriAktif;

          return Material(
            color: aktif ? AppColors.brandEmerald : Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _kategoriAktif = nama),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: aktif ? AppColors.brandEmerald : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nama,
                      style: AppTypography.bodySmall(
                        color: aktif ? Colors.white : AppColors.textPrimary,
                      ).copyWith(
                        fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: aktif
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.surfaceCeramic,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: aktif ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildIsi() {
    if (_isLoading) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.brandEmerald),
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
                ? 'Belum ada data harga sampah di posko.'
                : 'Coba kata kunci atau filter kategori lain.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, _isPengurus ? 88 : 24),
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
    final kodeColor = _kodeColor(item.kode);

    return Container(
      decoration: BoxDecoration(
        color: isNonaktif ? const Color(0xFFF9F9F8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNonaktif
              ? const Color(0xFFE5E5E2)
              : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isNonaktif ? 0.01 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isPengurus ? () => _editKategoriModal(item) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildGambar(item, kodeColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          if (item.kode.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: kodeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.kode,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: kodeColor,
                                  letterSpacing: 0.4,
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
                              style: AppTypography.bodyMedium(
                                color: isNonaktif
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (isNonaktif)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Nonaktif',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.deskripsi.isNotEmpty
                            ? item.deskripsi
                            : (item.jenis ?? 'Sampah daur ulang terpilah'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            formatRupiah(item.harga),
                            style: AppTypography.bodyLarge(
                              color: isNonaktif
                                  ? AppColors.textMuted
                                  : AppColors.brandEmerald,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '/ ${item.satuan}',
                            style: AppTypography.caption(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isPengurus) ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 140),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (aksi) {
                      if (aksi == 'edit') {
                        _editKategoriModal(item);
                      } else if (aksi == 'toggle') {
                        _toggleStatus(item);
                      } else if (aksi == 'hapus') {
                        _hapusKategori(item);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'edit',
                        height: 38,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 10),
                            Text('Edit', style: AppTypography.bodySmall()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        height: 38,
                        child: Row(
                          children: [
                            Icon(
                              isNonaktif
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 16,
                              color: isNonaktif
                                  ? AppColors.brandEmerald
                                  : AppColors.warningDark,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isNonaktif ? 'Aktifkan' : 'Nonaktifkan',
                              style: AppTypography.bodySmall(
                                color: isNonaktif
                                    ? AppColors.brandEmerald
                                    : AppColors.warningDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(height: 1),
                      PopupMenuItem(
                        value: 'hapus',
                        height: 38,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 16,
                              color: AppColors.figmaError,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Hapus',
                              style: AppTypography.bodySmall(
                                color: AppColors.figmaError,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGambar(KatalogItem item, Color kodeColor) {
    const double ukuran = 48;
    final placeholder = Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        color: kodeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.recycling_rounded,
          color: kodeColor,
          size: 24,
        ),
      ),
    );

    if (item.gambarUrl == null || item.gambarUrl!.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
            Icon(icon, size: 52, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(judul, style: AppTypography.h3(), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              keterangan,
              style: AppTypography.bodySmall(),
              textAlign: TextAlign.center,
            ),
            if (tombolUlang) ...[
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandEmerald,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
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
