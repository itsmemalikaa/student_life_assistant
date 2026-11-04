import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';

/// Menyimpan daftar akun & akun yang terakhir dipakai.
/// Key di sini TIDAK diberi prefix karena dipakai bersama semua pengguna.
class AccountRepository {
  static const _listKey = 'accounts.list';
  static const _currentKey = 'accounts.current';

  // Key data lama (sebelum ada fitur akun), untuk migrasi.
  static const _legacyNameKey = 'profile.display_name';
  static const _legacyTasksKey = 'tasks.v1';

  Future<List<Account>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_listKey);

    if (raw == null) {
      // Migrasi: kalau sudah ada data lama, jadikan akun pertama.
      final oldName = prefs.getString(_legacyNameKey);
      final hasOldData = prefs.getString(_legacyTasksKey) != null;
      if ((oldName != null && oldName.trim().isNotEmpty) || hasOldData) {
        final legacy = Account(
          id: Account.legacyId,
          name: (oldName != null && oldName.trim().isNotEmpty)
              ? oldName.trim()
              : 'Pengguna',
        );
        await saveAll([legacy]);
        await saveCurrentId(legacy.id);
        return [legacy];
      }
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Account.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Account> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _listKey,
      jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
  }

  Future<String?> loadCurrentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentKey);
  }

  Future<void> saveCurrentId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentKey, id);
  }
}
