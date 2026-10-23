import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/eco_app_bar.dart';
import '../../widgets/eco_bottom_nav.dart';
import '../../widgets/eco_scan_modal.dart';
import '../pengurus/catat_setoran_screen.dart';
import 'info_detail_screen.dart';

/// Halaman Informasi & Pengumuman (Figma Halaman 9)
class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  bool _isPengurus = false;
  String _activeCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = ['Semua', 'Agenda', 'Pengumuman', 'Edukasi'];

  @override
  void initState() {
    super.initState();
    _checkRoleAndFetch();
  }

  Future<void> _checkRoleAndFetch() async {
    final isPengurus = await _authService.isPengurus();
    if (mounted) {
      setState(() => _isPengurus = isPengurus);
    }
    await _fetchPengumuman();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPengumuman() async {
    setState(() => _isLoading = true);
    final data = await _authService.getPengumumanList();
    if (!mounted) return;
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredItems {
    return _items.where((item) {
      final kategori = item['kategori'] as String? ?? 'Pengumuman';
      final judul = (item['judul'] as String? ?? '').toLowerCase();
      final isi = (item['isi'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesCategory = _activeCategory == 'Semua' || kategori == _activeCategory;
      final matchesSearch = query.isEmpty || judul.contains(query) || isi.contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    if (index == 3) return; // Currently on Info

    if (index == 0) {
      Navigator.pushReplacementNamed(
        context,
        _isPengurus ? '/pengurus-dashboard' : '/warga-dashboard',
      );
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/katalog');
    } else if (index == 2) {
      if (_isPengurus) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CatatSetoranScreen()));
      } else {
        EcoScanModal.show(context);
      }
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _buatPengumumanModal() {
    final judulCtrl = TextEditingController();
    final isiCtrl = TextEditingController();
    bool isSending = false;

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
                    child: const Icon(Icons.campaign_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text('Buat Pengumuman Baru', style: AppTypography.h3()),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: judulCtrl,
                decoration: InputDecoration(
                  labelText: 'Judul Informasi / Pengumuman',
                  hintText: 'Contoh: Jadwal Penimbangan Rutin Hari Minggu',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: isiCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Isi Informasi',
                  hintText: 'Tuliskan rincian pengumuman untuk seluruh warga…',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: isSending
                      ? null
                      : () async {
                          final j = judulCtrl.text.trim();
                          final i = isiCtrl.text.trim();
                          if (j.isEmpty || i.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Judul dan isi wajib diisi.')),
                            );
                            return;
                          }
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);
                          setMState(() => isSending = true);
                          final res = await _authService.buatPengumuman(judul: j, isi: i);
                          if (!mounted) return;
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(res['message']?.toString() ?? 'Terkirim.'),
                              backgroundColor: res['success'] == true
                                  ? AppColors.primary
                                  : AppColors.error,
                            ),
                          );
                          if (res['success'] == true) _fetchPengumuman();
                        },
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Terbitkan Pengumuman'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _hapusPengumuman(dynamic id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengumuman?'),
        content: const Text('Apakah Anda yakin ingin menghapus pengumuman ini?'),
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

    final idInt = (id is int) ? id : int.tryParse(id.toString()) ?? 0;
    final res = await _authService.hapusPengumuman(idInt);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message']?.toString() ?? ''),
        backgroundColor: res['success'] == true ? AppColors.primary : AppColors.error,
      ),
    );
    if (res['success'] == true) _fetchPengumuman();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const EcoAppBar(title: 'Informasi Posko'),
      floatingActionButton: _isPengurus
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Info'),
              onPressed: _buatPengumumanModal,
            )
          : null,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetchPengumuman,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header Info & Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi & Pengumuman', style: AppTypography.h2()),
                    const SizedBox(height: 4),
                    Text(
                      'Agenda kegiatan posko, pengumuman warga, dan edukasi lingkungan hidup.',
                      style: AppTypography.bodySmall(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // Search Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: AppTypography.formInput(),
                        decoration: InputDecoration(
                          hintText: 'Cari agenda, pengumuman, atau tips...',
                          hintStyle: AppTypography.formHint(),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 22),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _activeCategory == cat;

                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _activeCategory = cat);
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.borderLight,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Featured Banner (Halaman 9 Highlight)
            if (_activeCategory == 'Semua' && _searchQuery.isEmpty && _items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildFeaturedBanner(_items.first),
                ),
              ),

            if (_activeCategory == 'Semua' && _searchQuery.isEmpty && _items.isNotEmpty)
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // List Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daftar Kabar Posko', style: AppTypography.sectionTitle()),
                    Text(
                      '${_filteredItems.length} Informasi',
                      style: AppTypography.caption(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Announcements List
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              )
            else if (_filteredItems.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const Icon(Icons.article_outlined, size: 52, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text('Tidak Ada Informasi', style: AppTypography.h3()),
                      const SizedBox(height: 4),
                      Text(
                        'Belum ada agenda atau pengumuman yang sesuai dengan pencarian Anda.',
                        style: AppTypography.bodySmall(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _filteredItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildInfoCard(item),
                      );
                    },
                    childCount: _filteredItems.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      bottomNavigationBar: EcoBottomNavBar(
        currentIndex: 3,
        onTap: _onNavTap,
        onScanTap: () => EcoScanModal.show(context),
      ),
    );
  }

  Widget _buildFeaturedBanner(Map<String, dynamic> item) {
    final judul = item['judul'] as String? ?? 'Agenda Posko';
    final isi = item['isi'] as String? ?? '';
    final tanggal = item['tanggal'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005232), Color(0xFF006D44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006D44).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InfoDetailScreen(item: item)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Paling Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tanggal,
                      style: AppTypography.caption(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  judul,
                  style: AppTypography.h3(color: Colors.white).copyWith(fontSize: 17),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  isi,
                  style: AppTypography.caption(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Baca Selengkapnya',
                      style: AppTypography.button(color: const Color(0xFF5EE3A0)).copyWith(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Color(0xFF5EE3A0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> item) {
    final judul = item['judul'] as String? ?? 'Informasi';
    final isi = item['isi'] as String? ?? '';
    final kategori = item['kategori'] as String? ?? 'Pengumuman';
    final tanggal = item['tanggal'] as String? ?? '';

    Color badgeBg;
    Color badgeColor;
    IconData icon;

    switch (kategori) {
      case 'Agenda':
        badgeBg = const Color(0xFFEFF6FF);
        badgeColor = const Color(0xFF1D4ED8);
        icon = Icons.event_rounded;
        break;
      case 'Edukasi':
        badgeBg = const Color(0xFFECFDF5);
        badgeColor = const Color(0xFF047857);
        icon = Icons.school_outlined;
        break;
      default:
        badgeBg = AppColors.primaryLight;
        badgeColor = AppColors.primary;
        icon = Icons.campaign_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InfoDetailScreen(item: item)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Thumbnail
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: badgeColor, size: 26),
                ),
                const SizedBox(width: 14),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              kategori,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          Text(
                            tanggal,
                            style: AppTypography.caption(color: AppColors.textMuted),
                          ),
                          if (_isPengurus)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: AppColors.error, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Hapus Pengumuman',
                              onPressed: () => _hapusPengumuman(item['id']),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        judul,
                        style: AppTypography.bodyLarge().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isi,
                        style: AppTypography.bodySmall(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
