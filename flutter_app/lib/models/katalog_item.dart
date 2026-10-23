/// Satu jenis sampah di katalog (data dari API Laravel GET /api/katalog).
class KatalogItem {
  final int id;
  final String nama;
  final String deskripsi;
  final double harga;
  final String satuan; // 'Kg' atau 'Liter'
  final String? jenis; // dipakai chip filter, contoh: 'Botol'
  final String? gambarUrl; // null = tampilkan placeholder
<<<<<<< Updated upstream
=======
  final String status; // 'aktif' atau 'nonaktif'
>>>>>>> Stashed changes

  const KatalogItem({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.satuan,
    this.jenis,
    this.gambarUrl,
<<<<<<< Updated upstream
=======
    this.status = 'aktif',
>>>>>>> Stashed changes
  });

  factory KatalogItem.fromJson(Map<String, dynamic> json) {
    return KatalogItem(
      id: json['id_kategori'] as int,
      nama: json['nama'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      harga: (json['harga'] as num?)?.toDouble() ?? 0,
      satuan: json['satuan'] as String? ?? 'Kg',
      jenis: json['jenis'] as String?,
      gambarUrl: json['gambar_url'] as String?,
<<<<<<< Updated upstream
=======
      status: json['status'] as String? ?? 'aktif',
>>>>>>> Stashed changes
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