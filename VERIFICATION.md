# Verification — Application Milestone I

Target: **Connected Application** (integrasi Bab 1–6).

## Static check

```bash
flutter pub get
dart format lib test dart_logic
flutter analyze      # hasil: ...........................
flutter test         # hasil: ...........................
```

## Runtime checks

Platform yang diuji: ☐ Chrome  ☐ Emulator/HP Android

| No | Skenario | Hasil yang diharapkan | Hasil |
|---|---|---|---|
| 1 | Buka aplikasi | Beranda menampilkan sapaan, jumlah tugas, menu cepat, tugas berikutnya, dan navigasi bawah | ☐ |
| 2 | Perlebar/persempit jendela | Beranda berubah 1 ↔ 2 kolom | ☐ |
| 3 | Tugas → centang satu tugas | Progres & rekomendasi langsung berubah | ☐ |
| 4 | Tugas → tambah tugas (form kosong lalu diisi) | Validasi muncul; tugas baru tampil | ☐ |
| 5 | Tugas → detail → edit | Detail & daftar ikut berubah (data dikirim balik via `pop`) | ☐ |
| 6 | Geser tugas ke kiri → Urungkan | Terhapus lalu kembali | ☐ |
| 7 | Jadwal: pilih hari, lalu tap blok kuliah (layar sempit) | Timeline berganti; tap → halaman detail | ☐ |
| 8 | Jadwal di layar lebar (≥ 840 px) | List & detail berdampingan | ☐ |
| 9 | Keuangan → catat transaksi | Saldo di Keuangan & beranda berubah | ☐ |
| 10 | Profil → ubah nama, toggle dark mode & tampilkan tugas selesai | Tombol menampilkan "Menyimpan...", lalu UI berubah | ☐ |
| 11 | **Tutup aplikasi sepenuhnya, buka kembali** | Nama, dark mode, tugas, transaksi tetap ada | ☐ |
| 12 | Tugas Eksternal (online) | Loading → daftar data REST API | ☐ |
| 13 | Tugas Eksternal → menu ⋮ → Uji kondisi gagal | Pesan error + tombol Coba Lagi | ☐ |
| 14 | Tekan Coba Lagi | Data kembali tampil (recovery) | ☐ |
| 15 | `dart run dart_logic/main.dart` | Daftar tugas, jumlah pending, rekomendasi | ☐ |

## Catatan kendala → diagnosis → solusi

| Kendala | Diagnosis | Solusi |
|---|---|---|
| | | |
