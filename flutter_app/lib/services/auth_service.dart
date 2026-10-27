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

  /// Mendapatkan URL Web Dashboard DLH
  static String getDlhWebUrl() {
    // Use the same base URL as the API server for consistency
    // This ensures the DLH web is accessible from the same server
    String apiUrl = '';

    if (kIsWeb) {
      apiUrl = 'http://localhost:8000';
    } else if (!kIsWeb && Platform.isAndroid) {
      // 10.0.2.2 adalah localhost khusus untuk emulator Android
      apiUrl = 'http://10.0.2.2:8000';
    } else {
      // Windows Desktop, iOS Simulator, macOS, Linux
      apiUrl = 'http://127.0.0.1:8000';
    }

    // DLH web is now served from Laravel's public directory
    return '$apiUrl/dlh_web/';
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
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// Fungsi Registrasi akun warga ke backend Laravel (FR-01)
  Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String noWhatsapp,
    required String tipeHunian,
    required String alamat,
    String? nomorHunian,
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
              'tipe_hunian': tipeHunian,
              'alamat': alamat.trim(),
              'nomor_hunian': nomorHunian?.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          (data['success'] == true || data['data'] != null)) {
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
        String message =
            data['message'] ?? 'Nomor WhatsApp atau kata sandi tidak valid.';
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            }
          }
        }

      // Gagal validasi, contoh: "Nomor WhatsApp sudah digunakan."
      return {
        'success': false,
        'message':
            data['message'] ?? 'Pendaftaran gagal. Periksa kembali data Anda.',
        'statusCode': response.statusCode,
      };
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
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  /// Fungsi Register warga ke backend Laravel (Generalisasi Superclass User + Subclass Warga)
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

      if (response.statusCode == 200 &&
          (data['success'] == true || data['data'] != null)) {
        final token = data['data']['token'] as String;
        final user = data['data']['user'] as Map<String, dynamic>;

        // Simpan token dan data user dengan safe storage
        await _setString(_keyToken, token);
        await _setString(_keyUser, jsonEncode(user));

        return {
          'success': true,
          'message': data['message'] ?? 'Pendaftaran berhasil!',
          'user': user,
          'token': token,
        };
      } else {
        String message =
            data['message'] ?? 'Nomor WhatsApp atau kata sandi tidak valid.';
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
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  /// Ambil data user yang sedang tersimpan
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userString = await _getString(_keyUser);
    if (userString != null) {
      try {
        final map = jsonDecode(userString) as Map<String, dynamic>;
        // Pastikan key 'peran' dan 'role' selalu konsisten
        final roleVal = (map['peran'] ?? map['role'])?.toString();
        if (roleVal != null) {
          map['peran'] = roleVal;
          map['role'] = roleVal;
        }
        return map;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Cek peran pengguna yang aktif (pengurus, dlh, warga)
  Future<String> getUserRole() async {
    final user = await getCurrentUser();
    if (user == null) return 'warga';
    final role = (user['peran'] ?? user['role'])?.toString().toLowerCase();
    if (role == 'pengurus' ||
        user['pengurus'] != null ||
        (user['role_data'] != null && user['role_data']['jabatan'] != null)) {
      return 'pengurus';
    }
    if (role == 'dlh' || user['dlh'] != null) {
      return 'dlh';
    }
    return role ?? 'warga';
  }

  /// Cek apakah pengguna saat ini adalah pengurus
  Future<bool> isPengurus() async {
    return (await getUserRole()) == 'pengurus';
  }

  /// Segarkan profil dari GET /api/me
  Future<Map<String, dynamic>?> refreshCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return getCurrentUser();

      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/me');
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is Map) {
          final user = Map<String, dynamic>.from(data['data']);
          await saveUser(user);
          return user;
        }
      }
      return getCurrentUser();
    } catch (_) {
      return getCurrentUser();
    }
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
        await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 4));
      }
    } catch (_) {
      // Abaikan network error saat logout, tetap bersihkan data lokal
    } finally {
      await _remove(_keyToken);
      await _remove(_keyUser);
    }
  }

  /// Ambil data real dashboard Warga dari backend database
  Future<Map<String, dynamic>?> getWargaDashboard() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/warga/dashboard');

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Mengajukan pencairan saldo tunai warga ke database
  Future<Map<String, dynamic>> ajukanPencairan(num nominal) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Sesi telah berakhir, silakan login kembali.',
        };
      }

      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/warga/pencairan');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'nominal': nominal}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201 && (data['success'] == true),
        'message':
            data['message'] ??
            (response.statusCode == 201
                ? 'Berhasil mengajukan pencairan!'
                : 'Gagal mengajukan pencairan.'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// Ambil data real dashboard Pengurus RT/RW dari backend database
  Future<Map<String, dynamic>?> getPengurusDashboard() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/dashboard');

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Ambil data real dashboard DLH dari backend database
  Future<Map<String, dynamic>?> getDlhDashboard() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/dlh/dashboard');

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Ambil daftar pengumuman & informasi posko
  Future<List<Map<String, dynamic>>> getPengumumanList() async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengumuman');
      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Simpan / perbarui data user lokal
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _setString(_keyUser, jsonEncode(user));
  }

  /// Update data profil pengguna (nama lengkap, alamat)
  Future<Map<String, dynamic>> updateProfile({
    required String namaLengkap,
    String? alamat,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Sesi login telah berakhir.'};
      }

      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/profile/update');

      final body = <String, dynamic>{'nama_lengkap': namaLengkap};
      if (alamat != null) body['alamat'] = alamat;

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Simpan update ke local user cache jika ada
        if (data['data']?['user'] != null) {
          await saveUser(Map<String, dynamic>.from(data['data']['user']));
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Profil berhasil diperbarui.',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui profil.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  /// Ubah kata sandi pengguna
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Sesi login telah berakhir.'};
      }

      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/profile/change-password');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'current_password': currentPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Kata sandi berhasil diperbarui.',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengubah kata sandi.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PENGURUS API METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Cari warga – mendukung QR string (ECP-123) dan pencarian manual (nama/WA/alamat)
  Future<List<Map<String, dynamic>>> searchWarga(String q) => wargaSearch(q);

  Future<List<Map<String, dynamic>>> wargaSearch(String q) async {
    try {
      final token = await getToken();
      if (token == null) return [];
      final baseUrl = await getBaseUrl();
      final url = Uri.parse(
        '$baseUrl/pengurus/warga-search?q=${Uri.encodeQueryComponent(q)}',
      );
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Ambil daftar seluruh warga (pengurus)
  Future<List<Map<String, dynamic>>> getWargaList() async {
    try {
      final token = await getToken();
      if (token == null) return [];
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/warga-list');
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Catat setoran sampah warga (pengurus)
  /// [idWarga] = id_pengguna warga; [items] = [{id_kategori, berat_kg}, ...]
  Future<Map<String, dynamic>> catatSetoran({
    required int idWarga,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login ulang.',
        };
      }
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/setoran');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'id_warga': idWarga, 'items': items}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      return {
        'success': (response.statusCode == 201) && (data['success'] == true),
        'message':
            data['message'] ??
            (response.statusCode == 201
                ? 'Berhasil!'
                : 'Gagal menyimpan setoran.'),
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Ambil daftar pengajuan pencairan (pengurus)
  Future<List<Map<String, dynamic>>> getPencairanList({String? status}) async {
    try {
      final token = await getToken();
      if (token == null) return [];
      final baseUrl = await getBaseUrl();
      final query = status != null ? '?status=$status' : '';
      final url = Uri.parse('$baseUrl/pengurus/pencairan$query');
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Validasi pengajuan pencairan (setujui / tolak)
  Future<Map<String, dynamic>> validasiPencairan({
    required int idPencairan,
    required String aksi, // 'setujui' atau 'tolak'
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login ulang.',
        };
      }
      final baseUrl = await getBaseUrl();
      final url = Uri.parse(
        '$baseUrl/pengurus/pencairan/$idPencairan/validasi',
      );

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'aksi': aksi}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && (data['success'] == true),
        'message': data['message'] ?? 'Selesai.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Ajukan pencairan dana tunai oleh warga
  Future<Map<String, dynamic>> ajukanPencairanWarga({
    required double nominal,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Sesi habis, silakan login ulang.',
        };
      }
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/warga/pencairan');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'nominal': nominal}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success':
            (response.statusCode == 200 || response.statusCode == 201) &&
            data['success'] == true,
        'message': data['message'] ?? 'Pengajuan selesai.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Ambil riwayat mutasi saldo / ledger kas warga
  Future<Map<String, dynamic>> getMutasiSaldoWarga() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'data': <Map<String, dynamic>>[]};
      }
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/warga/mutasi');

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'saldo_sekarang':
                (data['saldo_sekarang'] as num?)?.toDouble() ?? 0.0,
            'data': List<Map<String, dynamic>>.from(data['data'] ?? []),
          };
        }
      }
      return {'success': false, 'data': <Map<String, dynamic>>[]};
    } catch (_) {
      return {'success': false, 'data': <Map<String, dynamic>>[]};
    }
  }

  /// Terbitkan pengumuman posko baru oleh pengurus
  Future<Map<String, dynamic>> buatPengumuman({
    required String judul,
    required String isi,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi habis.'};
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/pengumuman');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'judul': judul.trim(), 'isi': isi.trim()}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201 && data['success'] == true,
        'message': data['message'] ?? 'Selesai.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan: $e'};
    }
  }

  /// Ambil rekapitulasi laporan bulanan bank sampah
  Future<Map<String, dynamic>?> getLaporanRekap({
    int? bulan,
    int? tahun,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return null;
      final baseUrl = await getBaseUrl();
      final q = [
        if (bulan != null) 'bulan=$bulan',
        if (tahun != null) 'tahun=$tahun',
      ].join('&');
      final url = Uri.parse(
        '$baseUrl/pengurus/laporan${q.isNotEmpty ? '?$q' : ''}',
      );

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Ambil daftar verifikasi laporan oleh DLH
  Future<List<Map<String, dynamic>>> getDlhVerifikasiList() async {
    try {
      final token = await getToken();
      if (token == null) return [];
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/dlh/verifikasi');

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Simpan atau konfirmasi verifikasi laporan bulanan oleh DLH
  Future<Map<String, dynamic>> simpanDlhVerifikasi({
    required int bulan,
    required int tahun,
    required String status,
    String? catatan,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi habis.'};
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/dlh/verifikasi');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'bulan': bulan,
              'tahun': tahun,
              'status': status,
              'catatan': catatan,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Verifikasi berhasil disimpan.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan: $e'};
    }
  }

  /// Ambil katalog harga sampah (bisa all=true untuk pengurus)
  Future<List<Map<String, dynamic>>> getKatalogList({bool all = false}) async {
    try {
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/katalog${all ? '?all=1' : ''}');
      final token = await getToken();

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Tambah kategori sampah baru (Pengurus)
  Future<Map<String, dynamic>> tambahKategoriSampah({
    String? kode,
    required String nama,
    required double harga,
    String? satuan,
    String? jenis,
    String? deskripsi,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi habis.'};
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/katalog');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'kode': kode?.trim(),
              'nama_kategori': nama.trim(),
              'harga_per_kg': harga,
              'satuan': (satuan ?? 'kg').trim(),
              'jenis': (jenis ?? 'Plastik').trim(),
              'deskripsi': deskripsi?.trim() ?? '',
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201 && data['success'] == true,
        'message': data['message'] ?? 'Kategori berhasil ditambahkan.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Update kategori sampah (Pengurus)
  Future<Map<String, dynamic>> updateKategoriSampah({
    required int id,
    String? kode,
    required String nama,
    required double harga,
    String? satuan,
    String? jenis,
    String? deskripsi,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi habis.'};
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/katalog/$id');

      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'kode': kode?.trim(),
              'nama_kategori': nama.trim(),
              'harga_per_kg': harga,
              'satuan': (satuan ?? 'kg').trim(),
              'jenis': (jenis ?? 'Plastik').trim(),
              'deskripsi': deskripsi?.trim() ?? '',
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Kategori berhasil diperbarui.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Toggle status aktif/nonaktif kategori sampah
  Future<Map<String, dynamic>> toggleStatusKategoriSampah(int id) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi habis.'};
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/katalog/$id/toggle-status');

      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Status berhasil diubah.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Hapus kategori sampah
  Future<Map<String, dynamic>> hapusKategoriSampah(int id) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi habis.'};
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/katalog/$id');

      final response = await http
          .delete(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Kategori berhasil dihapus.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Hapus pengumuman
  Future<Map<String, dynamic>> hapusPengumuman(int id) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi habis.'};
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/pengumuman/$id');

      final response = await http
          .delete(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Pengumuman berhasil dihapus.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Ambil aturan pengaturan pencairan
  Future<Map<String, dynamic>> getPengaturanPencairan() async {
    try {
      final baseUrl = await getBaseUrl();
      final token = await getToken();
      final url = Uri.parse('$baseUrl/pengurus/pengaturan-pencairan');

      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'] ?? {};
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Simpan aturan pengaturan pencairan
  Future<Map<String, dynamic>> simpanPengaturanPencairan({
    required double targetMinimal,
    String? tanggalMulai,
    String? tanggalSelesai,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Sesi habis.'};
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl/pengurus/pengaturan-pencairan');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'target_minimal': targetMinimal,
              'tanggal_mulai': tanggalMulai,
              'tanggal_selesai': tanggalSelesai,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['success'] == true,
        'message': data['message'] ?? 'Pengaturan berhasil disimpan.',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }
}
