import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/transaction.dart';

/// Repository = lapisan yang menyembunyikan detail penyimpanan lokal.
/// UI tidak perlu tahu data disimpan di shared_preferences sebagai JSON.
class TransactionRepository {
  static const _storageKey = 'transactions.v1';

  /// READ: membaca semua transaksi dari penyimpanan lokal (asynchronous).
  Future<List<Transaction>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    // Pertama kali dibuka: isi dengan data contoh.
    if (raw == null) {
      final seed = SampleData.transactions();
      await saveAll(seed);
      return seed;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Data lokal rusak.');
    }

    return decoded
        .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// CREATE / UPDATE / DELETE semuanya berakhir di sini:
  /// list terbaru di-encode menjadi JSON lalu ditulis ulang.
  Future<void> saveAll(List<Transaction> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
