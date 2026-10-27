import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/katalog_item.dart';
import 'auth_service.dart';

/// Mengambil data katalog harga sampah dari API Laravel.
class KatalogService {
  /// GET /api/katalog
  /// Melempar Exception berisi pesan yang siap ditampilkan jika gagal.
  Future<List<KatalogItem>> fetchKatalog({bool all = false}) async {
    // Pakai base URL yang sama dengan AuthService (otomatis sesuai platform)
    final baseUrl = await AuthService().getBaseUrl();
    final url = all ? '$baseUrl/katalog?all=1' : '$baseUrl/katalog';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Server merespons kode ${response.statusCode}.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? [];
      return list
          .map((json) => KatalogItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException catch (_) {
      throw Exception(
        'Tidak dapat terhubung ke server. Pastikan "php artisan serve" berjalan.',
      );
    } on http.ClientException catch (e) {
      throw Exception('Koneksi jaringan gagal: ${e.message}');
    } on FormatException catch (_) {
      throw Exception('Data dari server tidak valid.');
    }
  }
}