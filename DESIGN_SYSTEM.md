# 🌿 Eco Plamo - Design System & UI/UX Guidelines (Figma Spec)

Dokumen ini merupakan panduan sistem desain dan arsitektur UI/UX aplikasi **Eco Plamo** yang diadaptasi langsung dari desain Figma resmi.

---

## 1. Fondasi Tipografi (Typography Hierarchy)

Sesuai standar desain Figma, tipe huruf menggunakan perpaduan **Poppins** untuk elemen judul (*Heading*) dan **Plus Jakarta Sans** untuk seluruh teks konten (*Body & Input*).

| Tipe Gaya | Font Family | Weight | Ukuran (sp) | Line Height | Penggunaan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Display / Hero** | `Poppins` | Bold (700) | 28 sp | 1.2 | Judul Brand Login ("Eco Plamo"), Splash Screen |
| **Heading 1** | `Poppins` | Bold (700) | 24 sp | 1.3 | "Buat Akun Baru", "Pengajuan Berhasil!" |
| **Heading 2** | `Poppins` | SemiBold (600) | 20 sp | 1.3 | "Masuk", "Konfirmasi Pencairan", "Riwayat Transaksi" |
| **Heading 3** | `Poppins` | SemiBold (600) | 16 sp | 1.4 | "Detail pencairan", "Kontribusi Kamu:", "Aktivitas Terakhir" |
| **Section Title** | `Poppins` | Medium (500) | 14 sp | 1.4 | "Klasemen Plamo Garden", "Statistik", "Operasional Hari Ini" |
| **Body Large** | `Plus Jakarta Sans` | Medium (500) | 15 sp | 1.5 | Teks nominal besar, paragraf utama |
| **Body Medium** | `Plus Jakarta Sans` | Regular (400) | 13-14 sp | 1.4 | Slogan, Form Label, Isi artikel, Deskripsi card |
| **Body Small / Caption** | `Plus Jakarta Sans` | Regular (400) | 11-12 sp | 1.3 | Subtitle transaksi, tanggal/waktu, status badge |
| **Button Text** | `Poppins` | SemiBold (600) | 15-16 sp | 1.0 | Tombol "Masuk", "Buat Akun", "Ajukan Pencairan" |
| **Input / Hint Text** | `Plus Jakarta Sans` | Regular (400) | 14 sp | 1.0 | Placeholder: "Contoh: 08123456789" |

---

## 2. Palet Warna (Color Palette Tokens)

Palet warna terinspirasi dari tema ekonomi sirkular dan kelestarian alam:

```
[#006D44] Primary Emerald Green  ─ Warna identitas utama (Brand, Header Auth, Tombol)
[#005232] Primary Dark Green     ─ Warna aksen bayangan, gradient gelap
[#E8F5E9] Primary Light/Surface  ─ Background badge status & chip aktif
[#1E1E1E] Text Primary Dark      ─ Teks judul utama & input teks
[#4A5568] Text Secondary Grey    ─ Teks label form, subtitle, hint
[#94A3B8] Border Inactive        ─ Outline border input field default
[#E2E8F0] Divider & Card Border  ─ Garis pemisah, border card
[#F8FAF8] Screen Background      ─ Latar belakang halaman aplikasi (Home, Katalog, Profil)
[#FFFFFF] Card / Surface White   ─ Warna dasar container form, bottom sheet, cards
[#10B981] Success Mint           ─ Status "Selesai", nominal masuk (+Rp)
[#EF4444] Error / Cancel Red     ─ Validasi error, tombol Tolak, "Dibatalkan"
[#F59E0B] Warning Amber          ─ Status "Diproses", banner peringatan saldo
```

---

## 3. Sistem Elevasi & Geometri (Shapes & Radii)

- **Rounded Small (`8px`)**: Tag/badge status transaksi, chip kategori filter.
- **Rounded Medium (`12px`)**: Input field (`TextFormField`), tombol aksi utama (`ElevatedButton`), card transaksi.
- **Rounded Large (`16px-20px`)**: Card saldo utama (Pocket Card), card ringkasan dampak, dialog modal.
- **Rounded Sheet (`28px-32px`)**: Kontainer putih formulir Login dan Register (border radius bagian atas).
- **Circular (`50%`)**: Avatar profil, logo daun dengan ring panah sirkular, floating action button scan.

---

## 4. Rincian Komponen Widget Inti (Reusable Widgets)

### 4.1. `EcoPlamoLogo` (Header Emblem)
Logo khas Eco Plamo berupa lingkaran daun yang dikelilingi panah melingkar (simbol daur ulang / ekonomi sirkular):
- Varian Light (Background putih transparan, ikon putih untuk Auth).
- Varian Brand (Background hijau emerald untuk AppBar & Splash).

### 4.2. `EcoTextField` (Form Input Komponen)
Input field yang seragam untuk Login, Register, Edit Profil, dan Keamanan:
- Typography Label: `Plus Jakarta Sans`, 14sp, weight 500, warna `#333333`.
- Border Radius: `12px`.
- Border Default: `#D0D5DD` halus, 1px.
- Focused Border: `#006D44`, 1.5px.
- Hint Text: `Plus Jakarta Sans`, 14sp, warna `#9CA3AF`.

### 4.3. `EcoPrimaryButton` (Tombol Aksi Utama)
- Background: `#006D44`.
- Text: `Poppins`, 16sp, SemiBold, White.
- Height: `50px - 52px`.
- Border Radius: `12px`.
- Loading State: `CircularProgressIndicator` putih halus.

### 4.4. `EcoBottomNavBar` (Navigasi Bawah Figma Halaman 16)
Navigasi 5 menu dengan tombol aksi tengah yang melayang:
1. **Home**: Beranda warga / pengurus
2. **Katalog**: Katalog harga sampah terkini
3. **Scan & QR Saya (Center)**: Tombol hijau bulat melayang dengan ikon QR Code
4. **Info**: Informasi & pengumuman posko
5. **Profile**: Akun dan pengaturan

---

## 5. Peta 21 Layar Sesuai Desain Figma

| Halaman Figma | Nama Layar | Deskripsi UI & Komponen |
| :---: | :--- | :--- |
| **1 - 2** | `Splash Screen` | Latar hijau `#006D44`, logo daun sirkular putih di tengah layar |
| **3** | `Login (Masuk)` | Header hijau brand + Form putih melengkung (Username/WA, Kata Sandi, Tombol Masuk, Link Daftar) |
| **4** | `Buat Akun Baru (Register)` | Form registrasi warga (Nama Lengkap, Nomor WA, Blok & No. Rumah, Kata Sandi) |
| **5** | `Konfirmasi Pencairan` | Card rincian nominal penarikan tunai saldo tabungan & biaya admin |
| **6** | `Pengajuan Berhasil` | Layar sukses dengan centang hijau, nomor referensi `ECP-WD-...`, rekening/posko tujuan |
| **7** | `Dashboard Warga (Home)` | Header Profil, Saldo In Pocket `Rp 25.000`, Tombol Ajukan Pencairan, Grid Kontribusi, Aktivitas Terakhir, Klasemen |
| **8** | `Katalog Harga Sampah` | Search bar, Filter Chip (Semua, Botol, Kardus, Karton, dsb), Card daftar harga per Kg/Liter |
| **9** | `Informasi & Pengumuman` | Filter tab (Semua, Agenda, Pengumuman, Edukasi), Card artikel kegiatan posko |
| **10 - 11** | `Pencairan Tunai` | Slider/indikator progress minimum Rp 50.000, input nominal quick chips (50k, 100k, 150k), metode posko |
| **12** | `Detail Informasi` | Detail tampilan pengumuman/edukasi posko dengan gambar banner dan teks narasi |
| **13** | `Profil Saya` | Foto profil, nomor blok/WA, card statistik tabungan, menu list (Edit Profil, Riwayat, Keamanan, Keluar) |
| **14 - 15** | `Scan & QR Saya` | Tab 1: Kamera pemindai QR; Tab 2: Tampilan QR Code warga untuk dipindai petugas posko |
| **16** | `Bottom Navigation Bar Spec` | Komponen navigasi bawah dengan indikator aktif bar hijau di bawah teks |
| **17** | `Top App Bar Spec` | Komponen Header atas: Logo Eco Plamo + Notifikasi Lonceng (dengan dot merah) + Avatar Pengguna |
| **18** | `Riwayat Transaksi` | Ringkasan saldo bulanan, filter (Setoran, Penarikan), list riwayat tanggal & status selesai/proses |
| **19** | `Edit Profil` | Edit foto pengguna, nama lengkap, nomor WhatsApp, alamat blok & nomor rumah |
| **20** | `Keamanan & Kata Sandi` | Ganti kata sandi: Kata Sandi Saat Ini, Kata Sandi Baru, Konfirmasi Kata Sandi |
| **21** | `Dashboard Pengurus` | Mode Pengurus/Ketua Posko: Tombol "Pindai QR Warga & Timbang", Antrean Pencairan Dana dengan tombol Tolak / Setujui |
