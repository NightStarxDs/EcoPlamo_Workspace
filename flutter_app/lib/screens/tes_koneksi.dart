import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import package HTTP
import 'dart:convert'; // Untuk mengubah JSON menjadi format yang bisa dibaca Dart

class TesKoneksiScreen extends StatefulWidget {
  const TesKoneksiScreen({super.key});

  @override
  State<TesKoneksiScreen> createState() => _TesKoneksiScreenState();
}

class _TesKoneksiScreenState extends State<TesKoneksiScreen> {
  String _pesanDariLaravel = "Belum ada data";
  bool _isLoading = false;

  // Fungsi untuk mengambil data dari Laravel
  Future<void> _ambilData() async {
    setState(() {
      _isLoading = true; // Munculkan animasi loading
    });

    try {
      /* 
       * PERHATIAN ATURAN URL (SANGAT KRUSIAL):
       * Jika pakai Emulator Android, gunakan '10.0.2.2' (bukan localhost)
       * Jika pakai Emulator iOS / Web, gunakan '127.0.0.1' atau 'localhost'
       * Jika pakai HP Fisik, gunakan IP Address Wi-Fi laptop Anda (misal: '192.168.1.15')
       */
      var url = Uri.parse('http://10.0.2.2:8000/api/tes-koneksi');

      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Jika sukses (Kode 200)
        var dataJSON = jsonDecode(response.body); // Ubah teks JSON jadi objek
        setState(() {
          _pesanDariLaravel = dataJSON['pesan']; // Ambil isi variabel 'pesan'
        });
      } else {
        setState(() {
          _pesanDariLaravel = "Gagal. Kode Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _pesanDariLaravel = "Error jaringan: $e";
      });
    } finally {
      setState(() {
        _isLoading = false; // Matikan loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koneksi Eco Plamo'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan tulisan pesan atau indikator loading
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    _pesanDariLaravel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 30),

            // Tombol untuk memicu fungsi ambil data
            ElevatedButton(
              onPressed: _ambilData,
              child: const Text('Tarik Data dari Laravel'),
            ),
          ],
        ),
      ),
    );
  }
}
