# 🌿 Eco Plamo — Design System & UI/UX Guidelines
> **Master Specification**: Blending Starbucks Retail Warmth, Modern Circular Economy Identity, and Taste-Skill Anti-Slop Art Direction.  
> **Target Platforms**: Mobile Application (Flutter) & Administrative Web Portal (HTML5 / Vanilla CSS).  
> **Source Project**: Proyek PBL Bank Sampah Digital — Politeknik Negeri Batam.

---

## 1. Visual Theme & Brand Philosophy

Eco Plamo mengadopsi filosofi desain **Warm, Grounded Eco-Flagship**:
- **Bukan Putih Dingin / Sterile**: Menggantikan latar belakang putih klinis (`#ffffff`) dengan spektrum kanvas *Warm Neutral* krem dan keramik (`#F7F5F0` & `#EFECE6`), terinspirasi dari kehangatan signage café Starbucks dan bahan kertas daur ulang ramah lingkungan.
- **Rhythm Color-Block**: Kontras yang tegas dan elegan antara kanvas krem hangat, kartu konten putih bersih bersudut lembut (*soft rounded*), dan blok statement *House Green* gelap pekat (`#1E3932`) yang berwibawa.
- **Upacara Emas (Gold Ceremony)**: Aksen emas kustom (`#CBA258`) dikunci hanya untuk momen selebrasi pencapaian, peringkat warga di *Plamo Garden*, dan lencana kontributor terbaik — tidak pernah diobral sebagai aksen tombol umum.
- **Micro-Interactions Taktil**: Tombol aksi berbentuk *full-pill* (`50px`), kartu dengan elevasi *whisper shadow* berlapis, dan umpan balik sentuhan fisik (*press compression* `scale(0.97)`) yang memuaskan dan responsif.

---

## 2. Palet Warna Terkalibrasi (Calibrated Color System)

Sistem warna multi-tier yang presisi, dipetakan untuk token Flutter (`Color(0xFF...)`) dan Web CSS variables (`--color-...`).

### 2.1. Palet Resmi Figma Handoff (Sumber Google Drive)
Berdasarkan dokumen resmi `Color Pallete (Eco-Plamo-05-Colors.png)` & `Color Pallete Contras.png`:

| Kategori | Token Figma | Nilai Hex | Peran & Penggunaan Desain |
| :--- | :--- | :--- | :--- |
| **Primary** | `primary` | `#005E3F` | **Warna Utama Aplikasi**. Header brand, ikon aktif, tombol utama. |
| **Primary** | `primary-hover` | `#00422D` | State hover tombol primer di desktop/web. |
| **Primary** | `primary-dark` | `#005136` | Lencana (badge) dan aksen gelap terkalibrasi. |
| **Gradasi Hero** | `hero-from` | `#00573B` | Titik awal gradasi kartu hero saldo (*Pocket Card*). |
| **Gradasi Hero** | `hero-to` | `#006544` | Titik akhir gradasi kartu hero saldo. |
| **Background** | `background` | `#F9FAFB` | Latar belakang seluruh halaman (*Screen Background*). |
| **Surface** | `surface` | `#F6FAF7` | Container menu bar bawah & latar ikon. |
| **Surface** | `header` | `#FAFAFA` | Container top bar header. |
| **Surface** | `chip-selesai` | `#E8F7F1` | Background chip status selesai & tag kategori aktif. |
| **Divider** | `line` | `#E5E7EB` | Garis pemisah (*divider*) dan border card tipis. |
| **Teks** | `text-primary` | `#111827` | Teks judul utama & input field (Kontras 16:1 WCAG AAA). |
| **Teks** | `text-secondary`| `#414B45` | Teks keterangan, subtitle, form label (Kontras 8.4:1). |
| **Border** | `border-input` | `#77857D` | Border outline kolom input formulir (Kontras 3.3:1). |
| **Navigasi** | `nav-inactive` | `#26302B` | Ikon & label menu navigasi yang tidak aktif. |
| **Aksen** | `accent` | `#B0F0D6` | Bar indikator progress target setoran sampah. |
| **Aksen** | `link` | `#115E39` | Tautan interaktif, angka nominal penambahan saldo (+Rp). |
| **State** | `disabled` | `#E1E4E3` | Elemen tombol atau input nonaktif. |
| **State** | `focus` | `#0095FF` | Outline ring state fokus aksesibilitas. |
| **Danger** | `error` | `#A31515` | Status penolakan, tombol batal, peringatan galat. |

### 2.2. Harmonisasi Multi-Tier Starbucks & Retail Flagship
Diintegrasikan agar aplikasi memiliki kehangatan dan kedalaman kelas retail Starbucks:
- **House Green (`#1E3932`)**: Dipadukan dengan `#00573B` -> `#006544` untuk kartu saldo tabungan (*statement card*) agar terlihat kokoh dan berwibawa.
- **Accent Green (`#00754A`)**: Varian luminous untuk tombol aksi *full-pill* (`50px`) dan floating circular scan button (*The Plamo Frap*).
- **Prestige Gold (`#CBA258` / `#FAF6EE`)**: Khusus momen gamifikasi *Plamo Garden* (medali peringkat 1, status tier kontributor emas, dan bintang reward).
- **Warm Canvas Tints (`#F7F5F0` & `#EFECE6`)**: Memberi alternatif tekstur kertas hangat ramah lingkungan untuk kartu-kartu informatif.

### 2.2. Warm Canvas & Surfaces (Latar Belakang & Bidang Kartu)
| Token Name | Hex Code | Flutter Value | Peran & Penggunaan UI |
| :--- | :--- | :--- | :--- |
| **Canvas Warm** | `#F7F5F0` | `Color(0xFFF7F5F0)` | Latar belakang dasar seluruh layar (*Screen Background*). Lembut di mata dan hangat. |
| **Surface Ceramic** | `#EFECE6` | `Color(0xFFEFECE6)` | Separator zona, background container input form, search bar wrap, dan utility banner. |
| **Surface White** | `#FFFFFF` | `Color(0xFFFFFFFF)` | Kartu interaktif, dialog modal, bottom sheet, dan popup menu. Memberi *visual pop* di atas kanvas krem. |
| **Surface Cool Neutral** | `#F9F9F9` | `Color(0xFFF9F9F9)` | Latar container dropdown, baris riwayat berselang-seling, dan utility wrap. |

### 2.3. Rewards & Prestige Gold (Eksklusif Gamifikasi)
| Token Name | Hex Code | Flutter Value | Peran & Penggunaan UI |
| :--- | :--- | :--- | :--- |
| **Prestige Gold** | `#CBA258` | `Color(0xFFCBA258)` | Khusus bintang poin, medali klasemen *Plamo Garden*, status tier warga teladan, dan voucher reward. |
| **Gold Light Tint** | `#FAF6EE` | `Color(0xFFFAF6EE)` | Background kartu penghargaan, highlight banner peringkat top kontributor posko. |

### 2.4. Tipografi & Kontras Teks (Typography Readability)
| Token Name | Nilai RGBA / Hex | Peran & Penggunaan UI |
| :--- | :--- | :--- |
| **Text Primary Ink** | `rgba(0, 0, 0, 0.87)` / `#1E1E1E` | Teks judul utama, angka saldo besar, teks label input pada latar terang. |
| **Text Secondary Slate**| `rgba(0, 0, 0, 0.58)` / `#5F6368` | Subtitle, tanggal riwayat, hint form, satuan kg/liter pada katalog. |
| **Text On Dark Hero** | `rgba(255, 255, 255, 1.0)` | Seluruh judul & teks di atas kartu House Green pekat atau Brand Emerald. |
| **Text On Dark Muted**| `rgba(255, 255, 255, 0.72)` | Subtitle keterangan saldo, nomor referensi di layar gelap. |

### 2.5. Status Semantik Operasional
| Token Name | Hex Code | Flutter Value | Peran & Penggunaan UI |
| :--- | :--- | :--- | :--- |
| **Success Mint** | `#10B981` | `Color(0xFF10B981)` | Nominal masuk setoran (+Rp / +Kg), status badge "Selesai", verifikasi disetujui. |
| **Warning Amber** | `#F59E0B` | `Color(0xFFF59E0B)` | Status "Diproses", pengingat minimal penarikan (Rp 50.000), peringatan posko tutup. |
| **Destructive Red** | `#C82014` | `Color(0xFFC82014)` | Validasi error input, status "Dibatalkan", tombol aksi "Tolak Setoran" / "Keluar Akun". |
| **Red Wash Tint** | `rgba(200, 32, 20, 0.06)` | `Color(0x0FC82014)` | Background input state error & alert destructive container. |

---

## 3. Fondasi Tipografi (Typography Hierarchy)

Disiplin tipografi ganda: **Poppins** untuk struktur judul tegas yang ramah (*editorial friendly*), dan **Plus Jakarta Sans** untuk kenyamanan membaca konten, angka saldo, dan form.

> [!NOTE]
> Semua *letter-spacing* judul dikalibrasi ketat pada `-0.01em` hingga `-0.16px` untuk menghilangkan kesan teks renggang dan menghadirkan impresi premium seperti tipografi Starbucks SoDoSans.

| Level Hirarki | Font Family | Weight | Ukuran (sp / rem) | Line Height | Tracking | Penggunaan Utama |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Display Hero** | `Poppins` | Bold (700) | 28sp / 1.75rem | 1.2 | -0.16px | Splash brand title, nominal saldo utama pada Pocket Card |
| **Heading 1** | `Poppins` | Bold (700) | 24sp / 1.5rem | 1.3 | -0.16px | Header halaman Auth, "Pengajuan Berhasil!", Ringkasan DLH |
| **Heading 2** | `Poppins` | SemiBold (600) | 20sp / 1.25rem | 1.3 | -0.16px | Judul dialog konfirmasi pencairan, header riwayat mutasi |
| **Heading 3** | `Poppins` | SemiBold (600) | 16sp / 1.0rem | 1.4 | -0.01em | Sub-header section: "Klasemen Plamo Garden", "Detail Setoran" |
| **Body Large** | `Plus Jakarta Sans` | Medium (500) | 15sp / 0.938rem | 1.5 | normal | Kalimat pembuka hero, teks deskripsi panduan posko |
| **Body Medium** | `Plus Jakarta Sans` | Regular (400) | 13-14sp / 0.875rem | 1.5 | normal | Konten artikel berita posko, form label, deskripsi katalog sampah |
| **Body Small / Meta** | `Plus Jakarta Sans` | Regular (400) | 11-12sp / 0.75rem | 1.4 | normal | Timestamp riwayat, nomor seri posko, kategori sampah |
| **Button Label** | `Poppins` | SemiBold (600) | 15-16sp / 1.0rem | 1.0 | +0.02em | Seluruh teks tombol *pill-action*, huruf kapital awal kata (*Title Case*) |
| **Input / Placeholder**| `Plus Jakarta Sans` | Regular (400) | 14sp / 0.875rem | 1.2 | normal | Field text input: "Contoh: 08123456789" |

---

## 4. Geometri, Elevasi & Micro-Interactions

Mengikuti aturan Starbucks & Taste-Skill: **Restrained Depth + Tactile Feedback**. Hindari *drop shadow* tebal hitam buram khas template murahan.

### 4.1. Radius Sudut (Corner Geometry)
- **Full Pill (`50px` / `9999px`)**: Tombol aksi utama (*ElevatedButton*), chip quick-nominal (Rp 50k, 100k), badge status.
- **Card Radius (`16px`)**: Kartu Saldo Tabungan (*Pocket Card*), item katalog harga, ringkasan dampak lingkungan.
- **Form & Input Radius (`12px`)**: Kotak input `TextFormField`, search bar, dropdown select.
- **Surface Sheet Radius (`28px`)**: Lembaran putih melengkung atas pada halaman Login/Register dan Bottom Sheet Modal.
- **Circular (`50%`)**: Tombol mengambang (FAB), avatar warga, ikon badge circular economy.

### 4.2. Layered Whisper Shadow System
Shadow berlapis lembut (dua level: kontak dasar tipis + sebaran ambient transparan):
```css
/* Card Elevation: Lembut dan natural di atas Warm Cream Canvas */
--shadow-card: 0 1px 3px rgba(0, 0, 0, 0.05), 0 8px 16px rgba(0, 0, 0, 0.04);

/* Floating CTA / Frap Style Scan Button */
--shadow-floating-frap: 0 4px 6px rgba(0, 77, 44, 0.20), 0 10px 24px rgba(0, 117, 74, 0.28);

/* Sheet / Modal Elevation */
--shadow-modal: 0 -4px 16px rgba(0, 0, 0, 0.06), 0 20px 40px rgba(0, 0, 0, 0.12);
```

### 4.3. Tactile Motion & Press Feedback
- **Active Press Feedback**: Setiap klik/tap pada tombol utama dan kartu interaktif menyusut secara taktil dengan `scale(0.97)` dan durasi transisi `120ms ease-out`.
- **Spring Curve**: Gunakan kurva `cubic-bezier(0.16, 1, 0.3, 1)` untuk perpindahan tab dan transisi halaman.

---

## 5. Komponen Utama yang Ditingkatkan (Core Component Specs)

### 5.1. The "Green Pocket" Card (Hero Saldo & Tabungan Warga)
Mengadaptasi kartu statement Starbucks Rewards:
- **Background**: Solid *House Green* (`#1E3932`) atau gradient sangat halus ke `#112A24`.
- **Inner Pattern**: Watermark halus lingkaran panah sirkular (daun daur ulang) dengan opacity 6%.
- **Konten**:
  - Baris Atas: Label *"Saldo Tabungan Sampah"* (Text White Muted 72%) + Badge Status *"Aktif"* dalam Mint Tint pill.
  - Baris Tengah: Nominal Saldo format Rupiah tebal (`Poppins Bold 26sp`, misal: `Rp 124.500`).
  - Baris Bawah: Dua tombol pill cepat — `[+ Setor Sampah]` (Accent Green `#00754A`) dan `[Pencairan Tunai]` (Outlined White border 1.5px).

### 5.2. Floating "Plamo-Frap" Action Button (Tengah Navigasi)
Mengadaptasi tombol ikonik floating circular Starbucks Frap:
- **Ukuran**: Diameter 56px, lingkaran penuh (`borderRadius: 50%`).
- **Warna**: *Accent Green* (`#00754A`) dengan ikon putih tebal (Kamera Scan QR / Timbang Sampah).
- **Elevasi**: Layered shadow `--shadow-floating-frap`.
- **Interaksi**: Floating di atas *Bottom Navigation Bar*, bergetar halus (*haptic light*) dan mengecil `scale(0.94)` saat ditekan.

### 5.3. EcoTextField (Form Input Elegan)
- **Latar Belakang**: `#FFFFFF` di atas halaman krem.
- **Border Default**: `1px solid #EFECE6` dengan transisi mulus.
- **Focused State**: `1.5px solid #00754A` + ring bayangan mint halus `0 0 0 4px rgba(212, 233, 226, 0.40)`.
- **Label**: `Plus Jakarta Sans 13sp`, weight 500, warna `#1E1E1E`.

### 5.4. Filter Chips & Katalog Kategori Sampah
- **Chip Tidak Aktif**: Background `#FFFFFF`, border `1px solid #E2E8F0`, teks `#5F6368`.
- **Chip Aktif**: Background *Mint Surface Wash* (`#D4E9E2`), border `1.5px solid #006D44`, teks *Brand Emerald* (`#006D44`) tebal.
- **Kartu Item Sampah**: Menampilkan ilustrasi botol/kardus dengan foto/vektor natural, tag harga satuan (`Rp 3.500 / kg`), dan indikator tren harga.

### 5.5. Plamo Garden (Leaderboard & Rewards Ceremony)
- **Top 1 Contributor**: Card khusus dengan aksen garis pinggir *Prestige Gold* (`#CBA258`), badge mahkota daun emas, dan latar *Gold Lightest* (`#FAF6EE`).
- **Tiering Warga**:
  1. *Sprout (Bibit Hijau)*: < 25 kg sampah terkumpul
  2. *Guardian (Penjaga Alam)*: 25 - 100 kg sampah terkumpul
  3. *Eco Master (Pahlawan Plamo)*: > 100 kg sampah terkumpul (Status Gold Bintang)

---

## 6. Prinsip Anti-Slop (Taste-Skill House Rules)

1. **Haram Gradient Pelangi & Neon**: Tidak menggunakan ungu, biru neon, atau gradient 3 warna yang tidak memiliki kaitan dengan alam atau identitas Eco Plamo.
2. **Tidak Ada Ikon Tanpa Konteks**: Hindari meletakkan ikon generik di dalam kotak pastel membulat tanpa data atau tujuan interaksi yang jelas.
3. **Substansi Metrik Nyata**: Setiap dashboard wajib menyajikan angka riil: Total Kilogram Sampah, Saldo Rupiah Tersedia, dan Estimasi Karbon Terselamatkan (Kg CO2).
4. **Breathing Room Generous**: Spacing antar section minimal `24px - 32px` di mobile dan `40px - 64px` di web dashboard DLH untuk mencegah kesan UI sesak.

---

## 7. Pemetaan 21 Layar Sesuai Arsitektur Desain Baru

| No | Layar Figma | Implementasi Gaya Starbucks + Anti-Slop | Komponen Kunci |
| :---: | :--- | :--- | :--- |
| **1-2** | Splash Screen | Background pekat *House Green* (`#1E3932`), emblem logo daun lingkaran emas-putih elegan. | `EcoPlamoLogo`, subtle pulsing spinner |
| **3** | Login (Masuk) | Header House Green anggun dengan kurva 28px ke kanvas form krem hangat `#F7F5F0`. | `EcoTextField`, `EcoPrimaryButton` full-pill |
| **4** | Buat Akun (Register) | Form warga terstruktur (Nama, WA, Hunian, RT/RW, Kata Sandi) + Banner info verifikasi domisili & biaya kas posko Rp 10.000. | Form input berjenjang, RT selector, notice banner posko |
| **4b** | Tiket Registrasi Warga | Layar status pendaftaran digital receipt: Nomor tiket registrasi unik (`REG-PLM-...`), rincian warga, status menunggu, instruksi 3 langkah ke posko. | `RegisterSuccessScreen`, receipt card, copy ticket button |
| **5** | Konfirmasi Pencairan | Kartu faktur bersih: Saldo ditarik, biaya admin (Rp 0), posko pengambilan tunai. | Breakdown card, badge biaya admin gratis |
| **6** | Pengajuan Berhasil | Lingkaran centang sukses *Accent Green*, kode referensi unik `ECP-WD-...`, tombol unduh bukti. | Success checkmark animatif, ticket card |
| **7** | Dashboard Warga | *Green Pocket Card* saldo tabungan, quick actions, ringkasan kontribusi Kg, Klasemen Plamo Garden. | Saldo Card, Grid Kilogram, Leaderboard Top 3 |
| **8** | Katalog Harga Sampah | Search bar keramik, chip kategori (Plastik, Kertas, Logam, Minyak Jelantah), kartu harga jelas per Kg. | Category pills, price list card, price trend |
| **9** | Info & Pengumuman | Tab pill (Semua, Agenda Posko, Edukasi), kartu artikel fotografi bersih tanpa ornamen berlebih. | Article media cards, badge tanggal agenda |
| **10-11**| Pencairan Tunai | Slider interaktif + Chips nominal cepat (Rp 50k, 100k, 200k), indikator syarat minimal saldo. | Quick amount chips, balance warning banner |
| **12** | Detail Informasi | Editorial layout: Header foto penuh, judul Poppins tebal, teks narasi Plus Jakarta Sans 15sp. | Hero banner, sharing button, content body |
| **13** | Profil Warga | Header profil hangat, card statistik seumur hidup (total Kg & total Rp), menu list berjarak lapang. | User avatar card, action menu tiles |
| **14-15**| Scan & QR Saya | Tab ganda: Kamera scan setor posko & QR Barcode statis warga untuk verifikasi cepat oleh petugas. | QR generator container, flashlight button |
| **16** | Bottom Navigation | Bilah navigasi 5 menu berlatar putih dengan floating circular center button (*The Plamo Frap*). | `EcoBottomNavBar`, center FAB scanner |
| **17** | Top App Bar | Header bersih: Logo Eco Plamo, sapaan warga, lonceng notifikasi interaktif, foto profil thumbnail. | App bar responsive, notification pill |
| **18** | Riwayat Transaksi | Filter tab (Semua, Setoran Masuk, Penarikan Saldo), grouping tanggal dengan nominal warna hijau/merah. | Transaction tile, status chip (Selesai/Proses) |
| **19** | Edit Profil | Form edit foto warga, nama lengkap, kontak WhatsApp, nomor rumah dengan tombol simpan full-pill. | Photo upload picker, save changes button |
| **20** | Keamanan Akun | Form ganti kata sandi dengan indikator kekuatan password yang jelas dan aman. | Password strength meter, security notice |
| **21** | Dashboard Pengurus | Tampilan khusus petugas posko: Tombol timbang cepat, antrean persetujuan penarikan kas tunai. | Timbang cepat button, queue approval card |

---

## 8. Panduan Eksekusi Teknis Pengembang

### Di Flutter (`flutter_app/lib/theme/`):
- Definisikan `AppColors` yang mencakup `houseGreen`, `brandEmerald`, `accentGreen`, `mintWash`, `canvasWarm`, `surfaceCeramic`, dan `prestigeGold`.
- Terapkan `ThemeData` dengan `scaffoldBackgroundColor: AppColors.canvasWarm`.
- Kustomisasi `ElevatedButtonThemeData` dengan `RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))` dan padding vertikal `14px-16px`.

### Di Web Dashboard DLH (`dlh_web/`):
- Set root CSS variables sesuai token di Bab 2.
- Gunakan `font-family: 'Poppins', 'Plus Jakarta Sans', sans-serif`.
- Pastikan elemen interaktif memiliki `:hover` dan `:active` transform scale untuk merefleksikan estetika responsif kelas dunia.
