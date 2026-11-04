import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/task_item.dart';
import 'storage_scope.dart';

/// Menyimpan daftar tugas sebagai JSON string di shared_preferences.
class TaskRepository {
  // Key diberi awalan sesuai pengguna aktif (lihat StorageScope).
  String get _storageKey => StorageScope.key('tasks.v1');

  Future<List<TaskItem>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) {
      final seed = SampleData.tasks();
      await saveAll(seed);
      return seed;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Data tugas lokal rusak.');
    }

    return decoded
        .map((item) => TaskItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
