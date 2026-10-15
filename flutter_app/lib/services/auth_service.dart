import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyBaseUrl = 'custom_base_url';

  // Fallback in-memory storage jika plugin native SharedPreferences
  // belum terpasang sempurna saat hot reload atau dalam unit test
  static final Map<String, String> _memoryStorage = {};

  static Future<String?> _getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key) ?? _memoryStorage[key];
    } catch (_) {
      return _memoryStorage[key];
    }
  }

  static Future<void> _setString(String key, String value) async {
    _memoryStorage[key] = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {
      // Graceful fallback to memory storage
    }
  }

  static Future<void> _remove(String key) async {
    _memoryStorage.remove(key);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (_) {
      // Graceful fallback to memory storage
    }
  }

  /// Mendapatkan Default Base URL sesuai platform yang digunakan
  static String getDefaultBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (!kIsWeb && Platform.isAndroid) {
      // 10.0.2.2 adalah localhost khusus untuk emulator Android
      return 'http://10.0.2.2:8000/api';
    } else {
      // Windows Desktop, iOS Simulator, macOS, Linux
      return 'http://127.0.0.1:8000/api';
    }
  }

  /// Mendapatkan Base URL saat ini (bisa custom atau default)
  Future<String> getBaseUrl() async {
    final customUrl = await _getString(_keyBaseUrl);
    if (customUrl != null && customUrl.trim().isNotEmpty) {
      return customUrl.trim();
    }
    return getDefaultBaseUrl();
  }

  /// Mengatur custom Base URL (misalnya jika testing di HP fisik via Wi-Fi)
  Future<void> setBaseUrl(String url) async {
    if (url.trim().isEmpty) {
      await _remove(_keyBaseUrl);
    } else {
      String cleaned = url.trim();
      if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
        cleaned = 'http://$cleaned';
      }
      if (!cleaned.endsWith('/api') && !cleaned.endsWith('/api/')) {
        if (cleaned.endsWith('/')) {
          cleaned = '${cleaned}api';
        } else {
          cleaned = '$cleaned/api';
        }
      }
      if (cleaned.endsWith('/')) {
        cleaned = cleaned.substring(0, cleaned.length - 1);
      }
      await _setString(_keyBaseUrl, cleaned);
    }
  }

  /// Reset Base URL ke default sistem
  Future<void> resetBaseUrl() async {
    await _remove(_keyBaseUrl);
  }

  /// Tes koneksi ke backend Laravel
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/tes-koneksi');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['pesan'] ?? 'Koneksi ke Laravel berhasil!',
          'status': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': 'Server merespons kode: ${response.statusCode}',
          'status': response.statusCode,
        };
      }
    } on SocketException catch (_) {
      return {
        'success': false,
        'message':
            'Gagal terhubung ke server Laravel. Pastikan "php artisan serve" sudah aktif.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: $e',
      };
    }
  }
  /// Fungsi Registrasi akun warga ke backend Laravel (FR-01)
  Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String noWhatsapp,
    required String alamat,
    required String password,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/register');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'nama_lengkap': namaLengkap.trim(),
              'no_whatsapp': noWhatsapp.trim(),
              'alamat': alamat.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Pendaftaran berhasil. Silakan masuk.',
        };
      }

      // Gagal validasi, contoh: "Nomor WhatsApp sudah digunakan."
      return {
        'success': false,
        'message': data['message'] ?? 'Pendaftaran gagal. Periksa kembali data Anda.',
        'statusCode': response.statusCode,
      };
    } on SocketException catch (_) {
      return {
        'success': false,
        'message':
            'Tidak dapat menghubungi server Laravel. Pastikan backend berjalan ("php artisan serve").',
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Koneksi jaringan gagal: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Fungsi Login ke backend Laravel
  Future<Map<String, dynamic>> login({
    required String noWhatsapp,
    required String password,
  }) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/login');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'no_whatsapp': noWhatsapp.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && (data['success'] == true || data['data'] != null)) {
        final token = data['data']['token'] as String;
        final user = data['data']['user'] as Map<String, dynamic>;

        // Simpan token dan data user dengan safe storage
        await _setString(_keyToken, token);
        await _setString(_keyUser, jsonEncode(user));

        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil!',
          'user': user,
          'token': token,
        };
      } else {
        String message = data['message'] ?? 'Nomor WhatsApp atau kata sandi tidak valid.';
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            }
          }
        }

        return {
          'success': false,
          'message': message,
          'statusCode': response.statusCode,
        };
      }
    } on SocketException catch (_) {
      return {
        'success': false,
        'message':
            'Tidak dapat menghubungi server Laravel. Pastikan backend berjalan ("php artisan serve") dan URL IP server benar.',
      };
    } on http.ClientException catch (e) {
      return {
        'success': false,
        'message': 'Koneksi jaringan gagal: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// Ambil data user yang sedang tersimpan
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userString = await _getString(_keyUser);
    if (userString != null) {
      try {
        return jsonDecode(userString) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Ambil token otentikasi Sanctum
  Future<String?> getToken() async {
    return _getString(_keyToken);
  }

  /// Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout dan hapus sesi di Laravel dan local storage
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final baseUrl = await getBaseUrl();
        final url = Uri.parse('$baseUrl/logout');
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 4));
      }
    } catch (_) {
      // Abaikan network error saat logout, tetap bersihkan data lokal
    } finally {
      await _remove(_keyToken);
      await _remove(_keyUser);
    }
  }
}
