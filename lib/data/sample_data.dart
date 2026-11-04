import '../models/schedule_item.dart';
import '../models/task_item.dart';
import '../models/transaction.dart';

/// Data awal. Tugas & transaksi dimasukkan ke penyimpanan lokal saat
/// aplikasi pertama kali dibuka.
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

  static const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

  static const schedules = <ScheduleItem>[
    ScheduleItem(
      id: 'sch-1',
      course: 'Mobile Programming',
      day: 'Senin',
      start: '08.00',
      end: '09.40',
      room: 'Lab Komputer 2',
      lecturer: 'Dosen Pengampu',
      note: 'Bawa laptop dengan Flutter SDK siap.',
    ),
    ScheduleItem(
      id: 'sch-2',
      course: 'Pengolahan Citra Digital',
      day: 'Senin',
      start: '10.00',
      end: '11.40',
      room: 'Ruang 204',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      id: 'sch-3',
      course: 'Kriptografi',
      day: 'Selasa',
      start: '10.00',
      end: '11.40',
      room: 'Ruang 302',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      id: 'sch-4',
      course: 'Keamanan Komputer',
      day: 'Selasa',
      start: '13.00',
      end: '14.40',
      room: 'Ruang 301',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      id: 'sch-5',
      course: 'Kecerdasan Buatan',
      day: 'Rabu',
      start: '13.00',
      end: '14.40',
      room: 'Ruang 205',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      id: 'sch-6',
      course: 'Cloud Computing',
      day: 'Kamis',
      start: '08.00',
      end: '09.40',
      room: 'Lab Jaringan',
      lecturer: 'Dosen Pengampu',
    ),
    ScheduleItem(
      id: 'sch-7',
      course: 'Praktikum Mobile Programming',
      day: 'Kamis',
      start: '13.00',
      end: '14.40',
      room: 'Lab Komputer 2',
      lecturer: 'Asisten Praktikum',
      note: 'Kumpulkan evidence praktikum di sinau.',
    ),
    ScheduleItem(
      id: 'sch-8',
      course: 'Praktikum Citra Digital',
      day: 'Jumat',
      start: '08.00',
      end: '09.40',
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
