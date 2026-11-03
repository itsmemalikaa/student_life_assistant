import 'package:flutter/foundation.dart';

import '../logic/task_logic.dart';
import '../models/task_item.dart';
import '../repositories/task_repository.dart';

/// Application state untuk tugas (ChangeNotifier bawaan Flutter).
/// UI memanggil method -> state berubah -> notifyListeners() -> UI rebuild.
class TaskController extends ChangeNotifier {
  TaskController({TaskRepository? repository})
      : _repository = repository ?? TaskRepository();

  final TaskRepository _repository;

  List<TaskItem> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Belum selesai di atas, lalu urut berdasarkan deadline.
  List<TaskItem> get tasks {
    final sorted = [..._tasks]
      ..sort((a, b) {
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        return a.deadline.compareTo(b.deadline);
      });
    return List.unmodifiable(sorted);
  }

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isDone).length;
  int get pendingCount => totalCount - completedCount;
  double get progress => totalCount == 0 ? 0.0 : completedCount / totalCount;

  TaskItem? get recommendation => recommendTask(_tasks);

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _repository.loadAll();
    } catch (e) {
      _errorMessage = 'Gagal memuat tugas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(TaskItem task) async {
    _tasks = [..._tasks, task];
    await _persist();
  }

  Future<void> update(TaskItem task) async {
    _tasks = _tasks.map((t) => t.id == task.id ? task : t).toList();
    await _persist();
  }

  Future<void> toggleDone(String id, bool isDone) async {
    _tasks = _tasks
        .map((t) => t.id == id ? t.copyWith(isDone: isDone) : t)
        .toList();
    await _persist();
  }

  Future<void> delete(String id) async {
    _tasks = _tasks.where((t) => t.id != id).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    _tasks = [];
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners(); // UI langsung berubah
    await _repository.saveAll(_tasks); // lalu disimpan ke local storage
  }
}
