/// Satu jenis sampah di katalog (data dari API Laravel GET /api/katalog).
class KatalogItem {
  final int id;
  final String kode; // Kode sampah, contoh: P1, C1, K1, Mj
  final String nama;
  final String deskripsi;
  final double harga;
  final String satuan; // 'Kg' atau 'Liter'
  final String? jenis; // dipakai chip filter, contoh: 'Plastik', 'Logam', 'Kertas', 'Minyak'
  final String? gambarUrl; // null = tampilkan placeholder
  final String status; // 'aktif' atau 'nonaktif'

  const KatalogItem({
    required this.id,
    this.kode = '',
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.satuan,
    this.jenis,
    this.gambarUrl,
    this.status = 'aktif',
  });

  factory KatalogItem.fromJson(Map<String, dynamic> json) {
    return KatalogItem(
      id: json['id_kategori'] as int,
      kode: json['kode'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      harga: (json['harga'] as num?)?.toDouble() ?? 0,
      satuan: json['satuan'] as String? ?? 'Kg',
      jenis: json['jenis'] as String?,
      gambarUrl: json['gambar_url'] as String?,
      status: json['status'] as String? ?? 'aktif',
    );
  }

  /// Contoh: "Rp 2.500 / Kg"
  String get hargaLabel => '${formatRupiah(harga)} / $satuan';
}

/// Ubah angka menjadi format Rupiah, contoh: 2500 -> "Rp 2.500".
String formatRupiah(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final sisa = digits.length - i;
    buffer.write(digits[i]);
    if (sisa > 1 && sisa % 3 == 1) buffer.write('.');
  }
  return 'Rp $buffer';
}