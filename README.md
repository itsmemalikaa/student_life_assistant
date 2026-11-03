# Student Life Assistant — Versi Malika

**Mobile Programming — Application Milestone I (UTS)**
Malika Larasati  • NIM 32602500037 • UNISSULA

## Problem Statement

Mahasiswa sering kewalahan mengatur tugas dari banyak mata kuliah, lupa jadwal dan ruang
kuliah, serta tidak sadar ke mana uang saku habis setiap bulan.
**Student Life Assistant** membantu mahasiswa mengelola ketiganya dalam satu aplikasi,
dan memberi rekomendasi tugas mana yang harus dikerjakan lebih dulu.

**Target pengguna:** mahasiswa S1 yang aktif kuliah dan mengelola keuangan sendiri.

**Kebutuhan awal:**

1. Mencatat tugas beserta mata kuliah, deadline, dan prioritas, lalu menandainya selesai.
2. Mendapat rekomendasi tugas yang harus dikerjakan terlebih dahulu.
3. Melihat jadwal kuliah lengkap dengan ruang dan dosen.
4. Mencatat pemasukan dan pengeluaran agar saldo terpantau *(ciri khas versi ini)*.
5. Data tetap tersimpan walaupun aplikasi ditutup.

## Fitur per Bab

| Bab | Implementasi | Lokasi |
|---|---|---|
| 1 — Ekosistem & Git | Project Flutter + repository GitHub | seluruh repo |
| 2 — Dart | `class Task`, null safety, collection, fungsi rekomendasi (`dart run dart_logic/main.dart`); logika yang sama dipakai di aplikasi | `dart_logic/`, `lib/logic/task_logic.dart` |
| 3 — UI Flutter | Beranda Material 3 dengan palet warna sendiri, reusable widget (`TaskCard`, `PillNavBar`, `InfoRow`), form dengan validasi | `lib/widgets/`, `lib/screens/*_form_screen.dart` |
| 4 — Responsive & Navigation | Beranda 1/2 kolom (`LayoutBuilder`), navigasi bawah 4 tab, Jadwal model kalender yang adaptif (list→detail di HP, *master-detail* berdampingan di layar lebar), `push`/`pop`, kirim data ke detail lewat constructor, terima hasil form lewat `Navigator.pop(result)` | `home_screen.dart`, `schedule_screen.dart` |
| 5 — State, Async & Local Data | `setState` (checkbox, filter, pilihan jadwal), `ChangeNotifier` + `ListenableBuilder`, `Future`/`async`/`await`, loading/saving/error state, `shared_preferences` untuk preferensi (nama, tampilkan tugas selesai, dark mode) dan CRUD tugas & transaksi (JSON) | `lib/state/`, `lib/repositories/` |
| 6 — REST API & JSON | `http` GET ke JSONPlaceholder, cek status code, `jsonDecode`, `ExternalTodo.fromJson`, service layer, state loading/success/empty/error + retry, menu uji kondisi gagal | `lib/services/`, `external_task_screen.dart` |

## Struktur

```text
lib/
├── main.dart                          # root app + application state + tema
├── models/                            # TaskItem, ScheduleItem, Transaction, UserPreferences, ExternalTodo
├── data/                              # sample_data, kategori keuangan
├── logic/task_logic.dart              # rekomendasi tugas (dari Bab 2)
├── repositories/                      # akses shared_preferences
├── services/external_todo_service.dart# akses REST API
├── state/                             # TaskController, TransactionController, PreferencesController
├── screens/
│   ├── main_shell.dart                # navigasi bawah (pill)
│   ├── home_screen.dart               # beranda
│   ├── task_*.dart                    # list, detail, form tugas
│   ├── schedule_*.dart                # jadwal adaptif + detail
│   ├── external_task_screen.dart      # REST API
│   ├── profile_screen.dart            # preferensi
│   └── finance/                       # keuangan
├── theme/app_theme.dart               # palet warna & tema
├── widgets/                           # TaskCard, PillNavBar, state views, tile
└── utils/formatters.dart
dart_logic/main.dart                   # Dart Logic Challenge (Bab 2)
test/widget_test.dart                  # widget test + unit test
```

Alur data:

```text
Lokal  : UI -> Controller (state) -> Repository -> shared_preferences
REST   : UI (initState) -> Service -> HTTP GET -> JSON -> Model -> State -> UI
```

## Menjalankan

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome      # atau: flutter run (emulator/HP)
dart run dart_logic/main.dart
```

Endpoint REST: `GET https://jsonplaceholder.typicode.com/todos`.
Dokumentasi uji: [`VERIFICATION.md`](VERIFICATION.md).
