import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/schedule_item.dart';

/// Menyimpan daftar jadwal sebagai JSON string di shared_preferences.
class ScheduleRepository {
  static const _storageKey = 'schedules.v1';

  Future<List<ScheduleItem>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    // Pertama kali dibuka: isi dengan jadwal contoh.
    if (raw == null) {
      final seed = SampleData.schedules.toList();
      await saveAll(seed);
      return seed;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Data jadwal lokal rusak.');
    }

    return decoded
        .map((item) => ScheduleItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<ScheduleItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
