import '../models/schedule_item.dart';
import '../models/task_item.dart';
import '../models/transaction.dart';

/// Data awal. Tugas & transaksi dimasukkan ke penyimpanan lokal saat
/// aplikasi pertama kali dibuka; jadwal bersifat statis.
class SampleData {
  static List<TaskItem> tasks() {
    final now = DateTime.now();
    return [
      TaskItem(
        id: 'task-1',
        title: 'Demo UTS Application Milestone I',
        course: 'Mobile Programming',
        deadline: now,
        priority: TaskPriority.high,
        description: 'Demonstrasi aplikasi dan penjelasan alur kode.',
      ),
      TaskItem(
        id: 'task-2',
        title: 'Laporan praktikum enkripsi AES',
        course: 'Kriptografi',
        deadline: now.add(const Duration(days: 3)),
        priority: TaskPriority.medium,
        description: 'Bandingkan mode ECB dan CBC beserta contoh output.',
      ),
      TaskItem(
        id: 'task-3',
        title: 'Resume materi algoritma A*',
        course: 'Kecerdasan Buatan',
        deadline: now.add(const Duration(days: 6)),
        priority: TaskPriority.low,
      ),
      TaskItem(
        id: 'task-4',
        title: 'Install Flutter SDK & flutter doctor',
        course: 'Mobile Programming',
        deadline: now.subtract(const Duration(days: 40)),
        priority: TaskPriority.medium,
        isDone: true,
      ),
    ];
  }

  static const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  static const schedules = <ScheduleItem>[
    ScheduleItem(
      course: 'Mobile Programming',
      day: 'Senin',
      time: '08.00–09.40',
      room: 'Lab Komputer 2',
      lecturer: 'Dosen Pengampu',
      note: 'Bawa laptop dengan Flutter SDK siap.',
    ),
    ScheduleItem(
      course: 'Pengolahan Citra Digital',
      day: 'Senin',
      time: '10.00–11.40',
      room: 'Ruang 204',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      course: 'Kriptografi',
      day: 'Selasa',
      time: '10.00–11.40',
      room: 'Ruang 302',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      course: 'Keamanan Komputer',
      day: 'Selasa',
      time: '13.00–14.40',
      room: 'Ruang 301',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      course: 'Kecerdasan Buatan',
      day: 'Rabu',
      time: '13.00–14.40',
      room: 'Ruang 205',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      course: 'Cloud Computing',
      day: 'Kamis',
      time: '08.00–09.40',
      room: 'Lab Jaringan',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      course: 'Praktikum Mobile Programming',
      day: 'Kamis',
      time: '13.00–14.40',
      room: 'Lab Komputer 2',
      lecturer: 'Asisten Praktikum',
      note: 'Kumpulkan evidence praktikum di sinau.',
    ),
    ScheduleItem(
      course: 'Praktikum Citra Digital',
      day: 'Jumat',
      time: '08.00–09.40',
      room: 'Lab Multimedia',
      lecturer: 'Asisten Praktikum',
    ),
  ];

  static List<Transaction> transactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: 'trx-1',
        title: 'Uang saku bulanan',
        amount: 2000000,
        type: TransactionType.income,
        category: 'Uang Saku',
        date: DateTime(now.year, now.month, 1),
      ),
      Transaction(
        id: 'trx-2',
        title: 'Makan siang kantin',
        amount: 18000,
        type: TransactionType.expense,
        category: 'Makan & Minum',
        date: now.subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: 'trx-3',
        title: 'Print laporan praktikum',
        amount: 12500,
        type: TransactionType.expense,
        category: 'Kuliah',
        date: now,
      ),
    ];
  }
}
