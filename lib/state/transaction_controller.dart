import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Application state untuk transaksi (state management sederhana
/// memakai ChangeNotifier bawaan Flutter, tanpa package tambahan).
///
/// Alur: UI memanggil method -> state berubah -> notifyListeners()
/// -> semua ListenableBuilder yang mendengarkan akan rebuild.
class TransactionController extends ChangeNotifier {
  TransactionController({TransactionRepository? repository})
      : _repository = repository ?? TransactionRepository();

  final TransactionRepository _repository;

  List<Transaction> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ---------- Getter (UI hanya membaca, tidak mengubah langsung) ----------
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Diurutkan dari yang terbaru.
  List<Transaction> get items {
    final sorted = [..._items]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  List<Transaction> recent([int count = 5]) => items.take(count).toList();

  int get totalIncome => _items
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  int get totalExpense => _items
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  int get balance => totalIncome - totalExpense;

  int get expenseThisMonth {
    final now = DateTime.now();
    return _items
        .where((t) =>
            !t.isIncome &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // ---------- Operasi asynchronous (CRUD) ----------
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // UI -> loading

    try {
      _items = await _repository.loadAll();
    } catch (e) {
      _errorMessage = 'Gagal memuat data transaksi: $e';
    } finally {
      _isLoading = false;
      notifyListeners(); // UI -> success / error
    }
  }

  Future<void> add(Transaction transaction) async {
    _items = [..._items, transaction];
    notifyListeners();
    await _repository.saveAll(_items);
  }

  Future<void> update(Transaction transaction) async {
    _items = _items
        .map((t) => t.id == transaction.id ? transaction : t)
        .toList();
    notifyListeners();
    await _repository.saveAll(_items);
  }

  Future<void> delete(String id) async {
    _items = _items.where((t) => t.id != id).toList();
    notifyListeners();
    await _repository.saveAll(_items);
  }

  Future<void> clearAll() async {
    _items = [];
    notifyListeners();
    await _repository.saveAll(_items);
  }
}
