# Aturan Git (cabang dan commit)

## Cabang
- `main`: rilis, hanya diperbarui di akhir Sprint.
- `develop`: integrasi.
- `feature/US-xx-nama-singkat`: satu cabang per user story.
  Contoh: `feature/US-04-transaksi-penyetoran`
- `fix/US-xx-nama-bug`: perbaikan bug.
  Contoh: `fix/US-08-saldo-terpotong-ganda`
- Cabang dibuat dari `develop`. Nama huruf kecil, dipisah tanda hubung, tanpa spasi.
- Jangan commit atau push langsung ke `main` dan `develop`.
  Jika cabang aktif salah, berhenti dan beri tahu saya.

## Pesan commit
Format: `jenis(cakupan): deskripsi singkat`

Jenis: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

Aturan:
- Judul maksimal 72 karakter, huruf kecil, tanpa titik di akhir.
- Deskripsi dalam bahasa Indonesia dengan kata kerja aktif
  (tambah, perbaiki, ubah, hapus).
- Cakupan wajib untuk feat, fix, refactor, test. Contoh cakupan:
  registrasi, auth, kategori, setoran, pengaturan, pengumuman,
  dashboard, klaim, laporan, verifikasi, db, api, ui.
- Satu commit satu perubahan.
- Tambahkan `Refs: US-xx` di baris terakhir jika terkait user story.

Contoh:
feat(setoran): tambah perhitungan subtotal per jenis sampah
fix(klaim): perbaiki pemotongan saldo ganda saat klaim disetujui
test(klaim): tambah uji saldo di bawah target minimal
chore: perbarui .gitignore