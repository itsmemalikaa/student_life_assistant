import 'package:flutter/foundation.dart';

import '../models/schedule_item.dart';
import '../repositories/schedule_repository.dart';

/// Application state untuk jadwal kuliah.
class ScheduleController extends ChangeNotifier {
  ScheduleController({ScheduleRepository? repository})
      : _repository = repository ?? ScheduleRepository();

  final ScheduleRepository _repository;

  List<ScheduleItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCount => _items.length;

  /// Jadwal pada hari tertentu, diurutkan dari jam paling pagi.
  List<ScheduleItem> itemsOfDay(String day) {
    final list = _items.where((item) => item.day == day).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  int countOfDay(String day) => _items.where((i) => i.day == day).length;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _repository.loadAll();
    } catch (e) {
      _errorMessage = 'Gagal memuat jadwal: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(ScheduleItem item) async {
    _items = [..._items, item];
    await _persist();
  }

  Future<void> update(ScheduleItem item) async {
    _items = _items.map((i) => i.id == item.id ? item : i).toList();
    await _persist();
  }

  Future<void> delete(String id) async {
    _items = _items.where((i) => i.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    await _repository.saveAll(_items);
  }
}
