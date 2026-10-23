import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// ──────────────────────────────────────────────────────────────────────────
///  Layar Catat Setoran Sampah – Pengurus RT/RW
///  Alur: cari warga (QR / manual) → pilih kategori & timbang → simpan
/// ──────────────────────────────────────────────────────────────────────────
class CatatSetoranScreen extends StatefulWidget {
  const CatatSetoranScreen({super.key});

  @override
  State<CatatSetoranScreen> createState() => _CatatSetoranScreenState();
}

class _CatatSetoranScreenState extends State<CatatSetoranScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _api = AuthService();

  // ── Step State ─────────────────────────────────────────────────────────
  int _step = 0; // 0 = cari warga, 1 = isi setoran

  // ── Step 0 – Cari Warga ────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedWarga;
  Timer? _debounce;

  // ── Step 1 – Catat Setoran ─────────────────────────────────────────────
  List<Map<String, dynamic>> _katalog = [];
  final List<Map<String, dynamic>> _items = [];
  bool _isKatalogLoading = false;
  bool _isSaving = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadKatalog();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadKatalog() async {
    setState(() => _isKatalogLoading = true);
    try {
      final baseUrl = await _api.getBaseUrl();
      final uri = Uri.parse('$baseUrl/katalog');
      final token = await _api.getToken();
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          if (mounted) setState(() => _katalog = List<Map<String, dynamic>>.from(data['data']));
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isKatalogLoading = false);
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => _doSearch(val.trim()));
  }

  Future<void> _doSearch(String q) async {
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await _api.wargaSearch(q);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectWarga(Map<String, dynamic> w) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedWarga = w;
      _items.clear();
      _step = 1;
    });
    _fadeCtrl
      ..reset()
      ..forward();
  }

  void _showAddItemSheet() {
    int? selectedKategoriId;
    String selectedNama = '';
    double selectedHarga = 0;
    final TextEditingController beratCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Tambah Item Sampah', style: AppTypography.h3()),
                const SizedBox(height: 16),
                Text('Kategori Sampah',
                    style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _isKatalogLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<int>(
                        value: selectedKategoriId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          hintText: 'Pilih kategori',
                        ),
                        items: _katalog.map((k) {
                          final harga = (k['harga'] as num?)?.toDouble() ?? 0;
                          return DropdownMenuItem<int>(
                            value: k['id_kategori'] as int?,
                            child: Text('${k['nama']} – Rp ${_fmt(harga)}/${k['satuan'] ?? 'Kg'}',
                                style: AppTypography.bodyMedium()),
                          );
                        }).toList(),
                        onChanged: (v) {
                          final k = _katalog.firstWhere(
                              (x) => x['id_kategori'] == v,
                              orElse: () => {});
                          setSheetState(() {
                            selectedKategoriId = v;
                            selectedNama = k['nama']?.toString() ?? '';
                            selectedHarga = (k['harga'] as num?)?.toDouble() ?? 0;
                          });
                        },
                      ),
                const SizedBox(height: 16),
                Text('Berat (Kg)',
                    style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: beratCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'cth: 2.5',
                    suffixText: 'Kg',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (selectedKategoriId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pilih kategori sampah terlebih dahulu.')),
                        );
                        return;
                      }
                      final berat = double.tryParse(beratCtrl.text.trim());
                      if (berat == null || berat <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Masukkan berat yang valid (> 0 Kg).')),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      setState(() {
                        _items.add({
                          'id_kategori': selectedKategoriId,
                          'nama': selectedNama,
                          'harga': selectedHarga,
                          'berat_kg': berat,
                        });
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: Text('Tambahkan', style: AppTypography.button(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _totalNilai => _items.fold(
      0, (s, i) => s + ((i['berat_kg'] as double) * (i['harga'] as double)));
  double get _totalBerat => _items.fold(0, (s, i) => s + (i['berat_kg'] as double));

  Future<void> _saveSetoran() async {
    if (_selectedWarga == null || _items.isEmpty) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final result = await _api.catatSetoran(
      idWarga: _selectedWarga!['id_pengguna'] as int,
      items: _items
          .map((i) => {'id_kategori': i['id_kategori'], 'berat_kg': i['berat_kg']})
          .toList(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Setoran Berhasil!', style: AppTypography.h2(), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                result['message']?.toString() ?? 'Setoran berhasil disimpan.',
                style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _step = 0;
                  _selectedWarga = null;
                  _items.clear();
                  _searchCtrl.clear();
                  _searchResults = [];
                });
                _fadeCtrl..reset()..forward();
              },
              child: Text('Setoran Baru',
                  style: AppTypography.button(color: AppColors.primary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Terjadi kesalahan.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toStringAsFixed(0);
  }

  String _fmtRp(double v) {
    final parts = v.toStringAsFixed(0).split('');
    final buf = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write('.');
      buf.write(parts[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          _step == 0 ? 'Cari Warga' : 'Catat Setoran',
          style: AppTypography.h2(color: Colors.white),
        ),
        leading: _step == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() {
                  _step = 0;
                  _items.clear();
                  _selectedWarga = null;
                  _fadeCtrl
                    ..reset()
                    ..forward();
                }),
              )
            : const BackButton(),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: _step == 0 ? _buildSearchStep() : _buildSetoranStep(),
      ),
      floatingActionButton: _step == 1 && _items.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Menyimpan…' : 'Simpan Setoran'),
              onPressed: _isSaving ? null : _saveSetoran,
            )
          : null,
    );
  }

  // ── Step 0: Cari Warga ──────────────────────────────────────────────────
  Widget _buildSearchStep() {
    return Column(
      children: [
        Container(
          color: AppColors.primary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Cari nama, WhatsApp, atau alamat warga…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchResults = []);
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (_searchResults.isEmpty && !_isSearching && _searchCtrl.text.isEmpty)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded,
                        size: 52, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  Text('Cari Warga', style: AppTypography.h2()),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Scan QR warga atau ketik nama, nomor WhatsApp, atau alamat untuk mencari data warga.',
                      style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                    label: Text('Scan QR Warga',
                        style: AppTypography.button(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _openQrScannerModal,
                  ),
                ],
              ),
            ),
          ),
        if (_isSearching)
          const Expanded(
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        if (!_isSearching && _searchResults.isNotEmpty)
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _wargaCard(_searchResults[i]),
            ),
          ),
        if (!_isSearching &&
            _searchResults.isEmpty &&
            _searchCtrl.text.isNotEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_search_rounded,
                      size: 60, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('Warga tidak ditemukan', style: AppTypography.h3()),
                  const SizedBox(height: 6),
                  Text('Coba kata kunci lain.', style: AppTypography.caption()),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _wargaCard(Map<String, dynamic> w) {
    final saldo = (w['total_saldo'] as num?)?.toDouble() ?? 0;
    return InkWell(
      onTap: () => _selectWarga(w),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w['nama_lengkap']?.toString() ?? 'Warga',
                      style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(w['alamat']?.toString() ?? '-', style: AppTypography.caption()),
                  Text(w['no_whatsapp']?.toString() ?? '-',
                      style: AppTypography.caption(color: AppColors.textMuted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_fmtRp(saldo),
                    style: AppTypography.bodyMedium(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Pilih',
                      style: AppTypography.caption(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Isi Setoran ─────────────────────────────────────────────────
  Widget _buildSetoranStep() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedWarga!['nama_lengkap']?.toString() ?? 'Warga',
                      style: AppTypography.bodyLarge(color: Colors.white)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _selectedWarga!['alamat']?.toString() ?? '-',
                      style: AppTypography.caption(
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saldo: ${_fmtRp((_selectedWarga!['total_saldo'] as num?)?.toDouble() ?? 0)}',
                      style: AppTypography.caption(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Item Sampah', style: AppTypography.h3()),
                  TextButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Tambah'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    onPressed: _showAddItemSheet,
                  ),
                ],
              ),
              if (_items.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.delete_outline_rounded,
                          size: 44, color: AppColors.textMuted),
                      const SizedBox(height: 10),
                      Text('Belum ada item',
                          style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Tap "Tambah" untuk memasukkan sampah.',
                          style: AppTypography.caption()),
                    ],
                  ),
                )
              else
                for (int idx = 0; idx < _items.length; idx++) ...[
                  _itemTile(_items[idx], idx),
                  const SizedBox(height: 10),
                ],
              if (_items.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                          'Total Berat', '${_totalBerat.toStringAsFixed(2)} Kg'),
                      const SizedBox(height: 6),
                      _summaryRow('Total Nilai', _fmtRp(_totalNilai),
                          highlight: true),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemTile(Map<String, dynamic> item, int idx) {
    final berat = item['berat_kg'] as double;
    final harga = item['harga'] as double;
    final subtotal = berat * harga;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.recycling_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama']?.toString() ?? '-',
                    style: AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600)),
                Text(
                    '${berat.toStringAsFixed(2)} Kg × ${_fmtRp(harga)}/Kg',
                    style: AppTypography.caption()),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmtRp(subtotal),
                  style: AppTypography.bodyMedium(color: AppColors.primary)
                      .copyWith(fontWeight: FontWeight.w700)),
              IconButton(
                icon: const Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _items.removeAt(idx)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium()),
        Text(
          value,
          style: highlight
              ? AppTypography.h3(color: AppColors.primary)
              : AppTypography.bodyMedium().copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _openQrScannerModal() {
    final qrInputCtrl = TextEditingController();
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          Future<void> processQrString(String raw) async {
            final cleaned = raw.trim();
            if (cleaned.isEmpty) return;

            setModalState(() => isProcessing = true);

            // Parsing format: ECOPLAMO:WARGA:<id>:<no_wa>
            String searchTerm = cleaned;
            if (cleaned.startsWith('ECOPLAMO:WARGA:')) {
              final parts = cleaned.split(':');
              if (parts.length >= 4) {
                // Gunakan no_wa atau ID
                searchTerm = parts[3].isNotEmpty ? parts[3] : parts[2];
              } else if (parts.length >= 3) {
                searchTerm = parts[2];
              }
            }

            final results = await _api.searchWarga(searchTerm);
            if (!ctx.mounted) return;
            setModalState(() => isProcessing = false);

            if (results.isNotEmpty) {
              Navigator.pop(ctx);
              _selectWarga(results.first);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Warga "${results.first['nama_lengkap']}" ditemukan!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data warga dari QR tidak ditemukan di database.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }

          return Container(
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
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
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
                      child: const Icon(Icons.qr_code_scanner_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text('Pemindai QR Warga', style: AppTypography.h3()),
                  ],
                ),
                const SizedBox(height: 20),

                // Frame Viewfinder Simulasi Scanner
                Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Positioned(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_outlined,
                                color: Colors.white70, size: 36),
                            const SizedBox(height: 8),
                            Text(
                              'Arahkan kamera ke QR Warga',
                              style: AppTypography.caption(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      if (isProcessing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Atau masukkan / tempel hasil scan QR manual:',
                  style: AppTypography.caption(),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: qrInputCtrl,
                  decoration: InputDecoration(
                    hintText: 'Contoh: ECOPLAMO:WARGA:1 atau no. WhatsApp',
                    prefixIcon: const Icon(Icons.input_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                      onPressed: () => processQrString(qrInputCtrl.text),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: processQrString,
                ),
                const SizedBox(height: 12),

                // Quick test warga scan simulation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pilih Warga Cepat (Tes Posko):', style: AppTypography.caption()),
                    TextButton(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _searchCtrl.text = '';
                        _doSearch('A'); // memunculkan daftar warga
                      },
                      child: const Text('Buka Manual'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.qr_code, size: 16),
                      label: const Text('Warga #1'),
                      onPressed: () => processQrString('ECOPLAMO:WARGA:1:081234567890'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.qr_code, size: 16),
                      label: const Text('Warga #2'),
                      onPressed: () => processQrString('ECOPLAMO:WARGA:2:081298765432'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
