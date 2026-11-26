# Eco Plamo — DESIGN.md (v2)

> **Tema:** Minimalis, ringan, dan bertumbuh. Bersih seperti kertas, hijau seperti daun, dengan sedikit kejutan kecil yang bikin senyum.
> **Platform:** Aplikasi mobile (Flutter) dan portal web (HTML/CSS).
> **Proyek:** PBL Bank Sampah Digital, Politeknik Negeri Batam.

---

## 0. Sumber kebenaran

Urutan acuan kalau ada nilai yang berbeda:

1. **Dokumen Design Handoff v1.0 (25 Okt 2026)** dan mockup Figma. Semua token di dokumen ini mengikuti keduanya.
2. **Usulan** (bagian 12). Belum berlaku sampai disetujui Product Manager.
3. **Inspirasi Starbucks.** Hanya perilaku dan pola, bukan token (lihat 1.2).

Aturan praktis: jangan menambah warna, radius, atau ukuran huruf baru tanpa mencatatnya di bagian 12.

---

## 1. Filosofi: Bersih, Ringan, Bertumbuh

### 1.1. Tiga prinsip

1. **Minimalis dulu.** Satu elemen utama per layar, ruang kosong lapang, satu warna aksen. Hierarki dibuat dengan ukuran dan ketebalan huruf, bukan dengan warna atau garis tambahan.
2. **Fun di momen yang tepat.** Kejutan kecil hanya muncul di saat kosong, berhasil, memuat, dan naik peringkat. Tidak pernah di formulir, nominal uang, atau pesan error.
3. **Tumbuh sebagai metafora.** Setoran sampah membuat sesuatu tumbuh: bibit, tunas, pohon. Metafora ini dipakai di progres, peringkat, dan ilustrasi.

### 1.2. Yang diambil dari Starbucks (perilaku saja)

| Diambil | Dipakai sebagai |
|---|---|
| Tombol bulat melayang 56 px dengan area tap diperluas 8 px | Tombol "Scan & QR Saya" di tengah menu bawah |
| Efek tekan menyusut | Semua tombol dan kartu yang bisa disentuh |
| Bayangan berlapis, lembut | Tombol melayang dan modal |
| Progres ala Rewards | Bar menuju minimum pencairan (Rp 50.000) |
| Aksen perayaan yang dijaga langka | Warna Sun hanya untuk bintang dan peringkat #1 |

**Tidak diambil:** kanvas krem, House Green `#1E3932`, hijau `#00754A`, tombol pil 50 px, emas sebagai warna teks. Semuanya bertentangan dengan handoff atau gagal kontras.

---

## 2. Warna

### 2.1. Token resmi (handoff bagian 2)

| Token | Hex | Peran |
|---|---|---|
| `primary` | `#005E3F` | Warna utama: tombol aktif, ikon aktif, header brand |
| `primary-hover` | `#00422D` | Hover/ditekan pada tombol primer |
| `primary-dark` | `#005136` | Lencana |
| `hero-from` | `#00573B` | Awal gradasi kartu saldo |
| `hero-to` | `#006544` | Akhir gradasi kartu saldo |
| `background` | `#F9FAFB` | Latar halaman, latar kolom isian |
| `surface` | `#F6FAF7` | Menu bawah, latar ikon, penomoran klasemen |
| `header` | `#FAFAFA` | Top bar |
| `chip-selesai` | `#E8F7F1` | Chip status "Selesai" |
| `line` | `#E5E7EB` | Garis pemisah |
| `text-primary` | `#111827` | Judul dan teks utama |
| `text-secondary` | `#414B45` | Teks pendamping, placeholder |
| `border-input` | `#77857D` | Garis tepi kolom isian |
| `nav-inactive` | `#26302B` | Label menu tidak aktif |
| `accent` | `#B0F0D6` | Bar progres, momen fun |
| `link` | `#115E39` | Tautan dan nominal bertanda + |
| `disabled` | `#E1E4E3` | Tombol dan elemen nonaktif |
| `focus` | `#0095FF` | Garis tepi fokus input dan fokus keyboard |
| `error` | `#A31515` | Pesan error, tombol hapus/tolak |

### 2.2. Warna status dari mockup

| Token | Hex | Dipakai |
|---|---|---|
| `warning-bg` / `warning-text` | `#FFF4DD` / `#724A00` | Banner "Saldo belum cukup", status "Diproses" |
| `info-bg` / `info-border` | `#E6F4FF` / `#0EA5E9` | Banner info harga |
| `success-bg` | `#ECFBF4` | Banner sukses, "Menunggu Pengambilan" |

### 2.3. Satu tambahan untuk suasana fun (usulan)

| Token | Hex | Aturan |
|---|---|---|
| `sun` | `#FFD84D` | **Hanya sebagai isian** (bintang, lencana peringkat #1, konfeti). Teks di atasnya wajib `text-primary`. Tidak untuk tombol, tautan, atau teks. |

`sun` menggantikan emas `#CBA258` dari v1. Emas gagal kontras sebagai teks (2,2:1) dan terlihat formal. Usulan ini dicatat di bagian 12.

### 2.4. Aturan minimalis untuk warna

- Maksimal tiga warna di satu layar: netral (`background`, putih), `primary`, dan satu aksen (`accent` atau `sun`).
- Teks di atas `accent`: pakai `text-primary` (13,75:1). `primary` di atas `accent` hanya 6,09:1, jadi tidak boleh untuk teks kecil.
- Tidak ada gradasi selain `hero-from` ke `hero-to`.

### 2.5. Kontras terverifikasi

Target proyek adalah minimal 7:1 (AAA) untuk teks. Elemen non-teks (garis tepi, cincin fokus) minimal 3:1.

| Kombinasi | Rasio | Hasil |
|---|---|---|
| Putih di atas `primary` | 7,86:1 | Lulus AAA |
| Putih di atas `hero-from` / `hero-to` | 8,65:1 / 7,13:1 | Lulus AAA |
| Putih di atas `primary-hover` | 11,56:1 | Lulus AAA |
| Putih di atas `primary-dark` | 9,42:1 | Lulus AAA |
| `primary` di atas `background` | 7,52:1 | Lulus AAA |
| `text-secondary` di atas `surface` | 8,60:1 | Lulus AAA |
| `text-secondary` di atas `chip-selesai` | 8,20:1 | Lulus AAA |
| `link` di atas putih | 7,82:1 | Lulus AAA |
| `error` di atas `background` | 7,51:1 | Lulus AAA |
| `warning-text` di atas `warning-bg` | 7,14:1 | Lulus AAA |
| `nav-inactive` di atas `surface` | 12,94:1 | Lulus AAA |
| `text-primary` di atas `sun` | 12,82:1 | Lulus AAA |
| `text-primary` di atas `accent` | 13,75:1 | Lulus AAA |
| `border-input` vs `background` (non-teks) | 3,70:1 | Lulus 3:1 |
| `focus` vs putih (non-teks) | 3,11:1 | Lulus 3:1 |

**Dilarang:** `#10B981` dan `#F59E0B` sebagai warna teks di atas putih (2,5:1 dan 2,2:1), serta border input yang lebih terang dari `border-input`.

---

## 3. Tipografi

Poppins untuk judul dan tombol, Plus Jakarta Sans untuk isi teks.

| Peran | Font | Bobot | Ukuran |
|---|---|---|---|
| Judul aplikasi | Poppins | Bold 700 | 32 px |
| Angka saldo | Poppins | Bold 700 | 28 px (ukuran di mockup) |
| Judul bagian | Poppins | SemiBold 600 | 20 px |
| Nama / judul kartu | Poppins | SemiBold 600 | 15–18 px |
| Tombol dan label formulir | Poppins | SemiBold / Bold / Regular | 16 px |
| Isi teks | Plus Jakarta Sans | Regular 400 | 12–15 px |
| Teks bantuan | Plus Jakarta Sans | Regular 400 | 14–15 px |
| Label menu bawah | Plus Jakarta Sans | Bold 700 | 12 px |
| Pesan error | Plus Jakarta Sans | Regular 400 | 12 px |

Aturan minimalis untuk teks:
- Ukuran terkecil 12 px. Tidak ada 11 px.
- Hierarki lewat ukuran dan bobot, bukan warna baru.
- Tracking judul `-0.01em` (penyempurnaan visual, tidak mengubah ukuran).

---

## 4. Bentuk, jarak, bayangan, gerak

### 4.1. Jarak

- Kelipatan 4: 4, 8, 12, 16, 20, 24.
- Margin halaman 16 px. Jarak antarkartu 12 px.
- **Jarak antarbagian minimal 24 px.** Ruang kosong adalah bagian dari desain, jangan diisi.

### 4.2. Radius (handoff bagian 12)

| Elemen | Radius |
|---|---|
| Kolom isian, tombol Masuk/Daftar | 10 px |
| Kartu, tombol CTA pencairan | 16 px |
| Kartu form, lencana | 20 px |
| Kartu hero saldo | 30 px |
| Chip filter, avatar, tombol melayang | Bulat penuh |

### 4.3. Bentuk daun (tanda tangan visual)

Radius diagonal: kiri-atas 20, kanan-atas 4, kanan-bawah 20, kiri-bawah 4. Hasilnya seperti daun. Dipakai **hanya** untuk:

- lencana peringkat dan tier,
- bingkai ilustrasi,
- aksen kartu peringkat #1.

Tidak dipakai di tombol, kolom isian, atau kartu data utama.

### 4.4. Bayangan

| Elemen | Bayangan |
|---|---|
| Kartu | `0 2px 4px rgba(0,0,0,0.08)`; hover `0 6px 12px rgba(0,0,0,0.12)` |
| Tombol Masuk/Daftar (hover) | `0 8px 9px rgba(0,94,63,0.15)` |
| Tombol melayang | `0 4px 6px rgba(0,94,63,0.20), 0 10px 24px rgba(0,94,63,0.28)` |
| Modal / bottom sheet | `0 -4px 16px rgba(0,0,0,0.06), 0 20px 40px rgba(0,0,0,0.12)` |

Satu permukaan: bayangan **atau** garis tepi, tidak keduanya.

### 4.5. Gerak

- Durasi standar 200–400 ms (handoff). Modal slide dari bawah 300 ms. Toast 3 detik di atas layar.
- **Tekan:** menyusut ke `scale(0.97)` dalam 100 ms, kembali dalam 200 ms.
- Kurva halus: `cubic-bezier(0.16, 1, 0.3, 1)`.
- Semua animasi dekoratif mati saat pengguna mengaktifkan "kurangi gerakan".

---

## 5. Komponen

Nilai di bawah mengikuti handoff bagian 3 dan 4.

### 5.1. Tombol

| Komponen | Spesifikasi |
|---|---|
| CTA Pencairan | Tinggi 48, radius 16, Poppins SemiBold 16. Nonaktif: `disabled`, teks `text-secondary`, ikon gembok 17. Aktif: `primary`, teks putih, ikon ATM 24. Hover: `primary-hover`. |
| Masuk / Daftar | Tinggi 48, radius 10, `primary`, teks putih Poppins Bold 16. Hover: bayangan hijau lembut. |
| Tombol melayang (Scan & QR Saya) | Lingkaran 56, `primary`, ikon putih. Area tap 72. Muncul di atas menu bawah. |

Area sentuh minimal 48 x 48 untuk semua tombol, chip, dan tombol kembali.

### 5.2. Kolom isian

Tinggi 48, radius 10, latar `background`, garis tepi 1 px `border-input`, placeholder `text-secondary`. Fokus: garis tepi `focus`. Error: pesan 12 px `error` di bawah kolom.

### 5.3. Kartu saldo "In Pocket"

- Gradasi `hero-from` ke `hero-to`, radius 30.
- Isi: nama dan status, label "In Pocket", angka saldo (Poppins Bold 28, putih), "Minimum redeem", bar progres, "Next Redeem".
- Bar progres: jalur putih 20 persen, isian `accent`. Teks persentase tetap ditampilkan (bukan hanya visual).
- **Momen fun:** lihat "Tunas Progres" di 6.2.

### 5.4. Kartu umum

Putih, radius 16, bayangan kartu. Tanpa garis tepi. Ikon di kotak `surface` hanya untuk kartu statistik yang punya angka nyata di sebelahnya.

### 5.5. Chip kategori dan nominal

- Aktif: isian `primary`, teks putih, Poppins SemiBold.
- Tidak aktif: putih, garis tepi 1 px `border-input`, teks `text-primary`.
- Tinggi 48. Bar bisa digeser ke samping.
- Chip nominal terpilih diberi tanda centang kecil. Nominal cepat: Rp 50.000, Rp 100.000, Rp 150.000.

### 5.6. Menu bawah

Latar `surface`. Item aktif `primary` dengan garis penanda 20 x 3 px. Item tidak aktif: label `nav-inactive`. Lima item: Home, Katalog, Scan & QR Saya, Info, Profile.

### 5.7. Tab, modal, toast, header

| Komponen | Spesifikasi |
|---|---|
| Tab Scan QR / QR Saya | Garis indikator aktif 44 x 3 px |
| Modal konfirmasi | 272 x 113, tombol Cancel dan Delete, slide dari bawah 300 ms |
| Toast sukses | 199 x 38, di atas layar, 3 detik |
| Header | Latar `header`, tinggi 64, titik merah (`error`) pada lonceng bila ada notifikasi |
| Skeleton | Placeholder `disabled`, animasi shimmer |

---

## 6. Lapisan Fun (Playful Layer)

### 6.1. Aturan

1. **Maksimal satu momen fun aktif per layar.**
2. Boleh di: layar kosong, berhasil, memuat, naik peringkat, selamat datang.
3. **Dilarang di:** formulir, konfirmasi nominal uang, biaya, pesan error validasi, layar keamanan.
4. Fun tidak boleh menghalangi tugas. Semua animasi bisa dilewati dan mati bila gerakan dikurangi.

### 6.2. Momen fun

| # | Momen | Spesifikasi |
|---|---|---|
| 1 | **Eco Loop Spinner** | Pemuatan: cincin panah pada logo berputar 360 derajat, 1,2 detik linear tanpa henti, daun di tengah diam. Ganti "Memuat…" yang kaku. |
| 2 | **Tunas Progres** | Di ujung bar progres menuju minimum pencairan ada ikon tanaman 20 px yang berubah: 0–24% biji, 25–49% tunas, 50–74% bibit dua daun, 75–99% tanaman kecil, 100% daun mekar (denyut sekali). |
| 3 | **Konfeti daun** | Layar "Pengajuan Berhasil": 10–14 daun kecil (warna `accent`, `primary`, `sun`) menyebar 1,2 detik lalu jatuh 1,6 detik. Sekali per kejadian. |
| 4 | **Bentuk daun** | Lencana tier dan bingkai ilustrasi memakai radius diagonal (4.3). |
| 5 | **Peringkat #1** | Kartu peringkat 1 diberi bintang `sun` dan satu sapuan garis lengkung `accent` di bawah nama. Hanya di peringkat 1. |
| 6 | **Ilustrasi datar** | Satu ilustrasi per layar kosong atau berhasil, dari paket aset: `empty-state`, `hero-planet`, `recycle-bin`, `success`. Warna hijau dan mint saja. |
| 7 | **Sapaan harian** | Judul dashboard menyapa dengan nama. Teks pendampingnya berganti-ganti ringan (lihat 6.3). |
| 8 | **Tekan taktil** | Efek tekan menyusut (4.5) dan getar ringan di tombol melayang. |

### 6.3. Suara tulisan

Gaya: hangat, singkat, memakai "kamu". Pakai "kamu" konsisten (handoff saat ini mencampur "Anda" dan "kamu").

| Sebelumnya (kaku) | Sesudahnya (hangat) |
|---|---|
| Belum ada aktivitas. Mulai setorkan sampah pilahan Anda... | Belum ada setoran nih. Yuk, bawa sampah pilahan pertamamu ke posko! |
| belum ada klasemen. | Klasemen masih kosong. Jadilah yang pertama menumbuhkan tunas! |
| Memuat data Eco Plamo... | Lagi mengumpulkan harga terbaru… |
| Terjadi kesalahan jaringan. Coba lagi nanti. | Sinyalmu putus. Tenang, setoranmu aman dan akan tersinkron otomatis. |
| Warga tidak ditemukan. | Belum ketemu. Coba cek ejaan nama atau blok rumahnya ya. |

**Tetap netral dan jelas** (tanpa humor): pesan error validasi, nominal uang dan biaya, konfirmasi pencairan, keamanan kata sandi. Contoh: "Saldo belum mencapai minimum Rp 50.000" tetap persis begitu.

---

## 7. Aturan Minimalis (Anti-Slop)

1. **Satu hero per layar.** Kartu saldo di dashboard, ilustrasi di layar kosong, ikon centang di layar sukses.
2. **Tidak ada pelangi atau neon.** Hanya hijau dan mint, dengan `sun` di momen langka.
3. **Tidak ada ikon tanpa tujuan.** Ikon di kotak pastel hanya jika menyertai angka atau aksi nyata.
4. **Angka nyata.** Dashboard menampilkan angka riil (kilogram, saldo, setoran, peringkat). Tidak ada angka hiasan.
5. **Ruang lapang.** Minimal 24 px antarbagian di mobile. Jika terasa sesak, hapus elemen, jangan perkecil.
6. **Satu permukaan, satu pemisah.** Bayangan atau garis, tidak keduanya.

---

## 8. Layar

Format: gaya minimalis di setiap layar, ditambah satu momen fun yang diizinkan (nomor merujuk ke 6.2).

| Layar | Gaya minimalis | Momen fun |
|---|---|---|
| Splash | Latar hijau, logo Eco Loop putih | #1 spinner halus |
| Login | Header hijau, kartu putih radius 20 | (tidak ada: formulir) |
| Buat Akun | Empat kolom, tombol Buat Akun | (tidak ada: formulir) |
| Dashboard Warga | Kartu saldo, empat kartu statistik, aktivitas, klasemen | #2 Tunas Progres, #7 sapaan |
| Dashboard (pengguna baru) | Saldo Rp 0, dua tombol | #6 ilustrasi `empty-state` |
| Katalog Harga | Pencarian, chip, daftar harga | (tidak ada) |
| Katalog (memuat) | Skeleton | #1 spinner |
| Info & Pengumuman | Chip, kartu berita | (tidak ada) |
| Detail Informasi | Foto, judul Poppins, isi | (tidak ada) |
| Pencairan Tunai | Saldo, nominal, ringkasan | (tidak ada: uang) |
| Konfirmasi Pencairan | Rincian biaya jelas | (tidak ada: uang) |
| Pengajuan Berhasil | Centang, nomor referensi | #3 konfeti daun |
| Scan & QR Saya | Tab ganda, kamera | (tidak ada) |
| Riwayat Transaksi | Filter, daftar bertanggal | #6 bila kosong |
| Profil | Avatar, statistik, menu | (tidak ada) |
| Edit Profil | Formulir | (tidak ada: formulir) |
| Keamanan & Kata Sandi | Formulir | (tidak ada: keamanan) |
| Klasemen Plamo Garden | Daftar 1–5 | #5 peringkat #1 |
| Dashboard Pengurus | Antrean pencairan, tombol Tolak / Setujui & Bayar | (tidak ada: uang) |
| Koneksi Terputus | Pesan, Coba Lagi, Cek Status Server | #6 ilustrasi |
| Offline | Label "Mode Luar Jaringan" | (tidak ada) |

---

## 9. Kondisi layar

| Kondisi | Perilaku |
|---|---|
| **Error jaringan** | Frame "Koneksi Terputus": label offline, pesan, tombol Coba Lagi dan Cek Status Server, langkah periksa cepat, catatan draf tersimpan lokal. |
| **Error formulir** | Garis tepi dan pesan 12 px `error` di bawah kolom. Pesan tepat seperti di handoff bagian 5. |
| **Kosong** | Satu ilustrasi, satu kalimat hangat, satu atau dua tombol aksi. |
| **Memuat** | Skeleton `disabled` dengan shimmer, plus Eco Loop Spinner dan teks singkat. |

---

## 10. Responsif dan aksesibilitas

### 10.1. Responsif

| Ukuran | Perilaku |
|---|---|
| Mobile (≤600 px) | Satu kolom, margin 16 px, kartu statistik 2 kolom (174,5 px), menu bawah tetap |
| Tablet (601–1024 px) | Konten maksimal 640 px di tengah, kartu statistik 4 kolom |
| Desktop (≥1025 px) | Dua kolom (saldo dan statistik di kiri, aktivitas dan klasemen di kanan), menu bawah menjadi sidebar kiri |

Frame ponsel acuan 393 x 852 px.

### 10.2. Aksesibilitas

- Kontras minimal 7:1 untuk teks (tabel 2.5).
- Area sentuh minimal 48 x 48 px.
- Semua gambar dan ikon punya teks alternatif ("Logo Eco Plamo", "Ikon pindai kode QR").
- Fokus keyboard ditandai garis `focus`, urutan Tab dari atas ke bawah.
- Animasi dekoratif mati saat "kurangi gerakan" aktif.
- Progres, peringkat, dan status tidak hanya disampaikan lewat warna atau animasi: selalu ada teks.

---

## 11. Token teknis

### 11.1. Flutter

```dart
class AppColors {
  static const primary       = Color(0xFF005E3F);
  static const primaryHover  = Color(0xFF00422D);
  static const primaryDark   = Color(0xFF005136);
  static const heroFrom      = Color(0xFF00573B);
  static const heroTo        = Color(0xFF006544);
  static const background    = Color(0xFFF9FAFB);
  static const surface       = Color(0xFFF6FAF7);
  static const header        = Color(0xFFFAFAFA);
  static const chipSelesai   = Color(0xFFE8F7F1);
  static const line          = Color(0xFFE5E7EB);
  static const textPrimary   = Color(0xFF111827);
  static const textSecondary = Color(0xFF414B45);
  static const borderInput   = Color(0xFF77857D);
  static const navInactive   = Color(0xFF26302B);
  static const accent        = Color(0xFFB0F0D6);
  static const link          = Color(0xFF115E39);
  static const disabled      = Color(0xFFE1E4E3);
  static const focus         = Color(0xFF0095FF);
  static const error         = Color(0xFFA31515);
  static const sun           = Color(0xFFFFD84D); // usulan, hanya isian
}

class AppRadius {
  static const input = 10.0, card = 16.0, formCard = 20.0, hero = 30.0;
  static const leaf = BorderRadius.only(
    topLeft: Radius.circular(20), topRight: Radius.circular(4),
    bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4));
}
```

Atur `scaffoldBackgroundColor: AppColors.background`. Tombol Masuk/Daftar memakai radius 10, tombol CTA radius 16, tinggi 48.

### 11.2. Tailwind (web DLH)

```js
colors: {
  primary: { DEFAULT: '#005E3F', dark: '#00422D', deeper: '#005136' },
  hero: { from: '#00573B', to: '#006544' },
  accent: '#B0F0D6', surface: '#F6FAF7', page: '#F9FAFB',
  ink: '#111827', muted: '#414B45', line: '#E5E7EB',
  field: '#77857D', disabled: '#E1E4E3', focus: '#0095FF', danger: '#A31515',
  sun: '#FFD84D',
},
fontFamily: {
  heading: ['Poppins', 'sans-serif'],
  body: ['Plus Jakarta Sans', 'sans-serif'],
},
boxShadow: {
  card: '0 2px 4px rgba(0,0,0,0.08)',
  cta: '0 8px 9px rgba(0,94,63,0.15)',
  fab: '0 4px 6px rgba(0,94,63,0.20), 0 10px 24px rgba(0,94,63,0.28)',
},
```

---

## 12. Usulan dan keputusan yang masih terbuka

Butuh persetujuan Product Manager sebelum masuk handoff.

### 12.1. Berbeda antara v1 dan handoff (diputuskan: ikut handoff)

| Item | v1 | Handoff / mockup | Dipakai |
|---|---|---|---|
| Biaya admin pencairan | Rp 0 | Rp 2.500 | **Rp 2.500** |
| Nominal cepat | 50k, 100k, 200k | 50k, 100k, 150k | **50k, 100k, 150k** |
| Pilihan nominal | Slider | Chip nominal | **Chip** |
| Latar halaman | Krem `#F7F5F0` | `#F9FAFB` | **`#F9FAFB`** |
| Warna tombol | `#00754A` | `#005E3F` | **`#005E3F`** |
| Hero saldo | `#1E3932` | Gradasi `#00573B` ke `#006544` | **Gradasi** |

### 12.2. Fitur dan visual baru (usulan, belum berlaku)

| Usulan | Catatan |
|---|---|
| Warna `sun` `#FFD84D` | Pengganti emas, hanya isian |
| Tier warga: Bibit (<25 kg), Tunas (25–100 kg), Pohon (>100 kg) | Nama dan batas kilogram perlu disetujui |
| Estimasi karbon terselamatkan (kg CO2) | Perlu rumus resmi dari DLH |
| Tiket registrasi `REG-PLM-…` dan biaya kas posko Rp 10.000 | Tidak ada di handoff |
| Tombol unduh bukti, tren harga, senter pada scan | Tidak ada di handoff |
| Momen fun 6.2 nomor 1–8 | Spesifikasi gerak perlu diuji di perangkat |
| "Kamu" konsisten di seluruh UI | Perlu menyeragamkan teks mockup yang masih memakai "Anda" |

---

## 13. Perubahan dari v1

- Seluruh token warna, radius, bayangan, ukuran huruf, dan durasi disamakan dengan handoff.
- Dihapus: kanvas krem, House Green, `#00754A`, tombol pil 50 px, emas sebagai teks, fokus hijau, border input pucat.
- Tabel kontras diperbarui. Semua pasangan teks lulus 7:1.
- Bagian 2.2 yang duplikat dihapus.
- Ditambah: Lapisan Fun (bagian 6), aturan minimalis (bagian 7), kondisi layar (bagian 9), responsif dan aksesibilitas (bagian 10).
- Fitur yang tidak ada di handoff dipindahkan ke bagian 12.