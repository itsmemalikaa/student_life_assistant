import 'package:flutter/foundation.dart';

import '../models/user_preferences.dart';
import '../repositories/local_preferences_repository.dart';

/// Application state untuk preferensi pengguna.
/// Memiliki state loading, saving, dan error (materi Bab 5).
class PreferencesController extends ChangeNotifier {
  PreferencesController({LocalPreferencesRepository? repository})
      : _repository = repository ?? LocalPreferencesRepository();

  final LocalPreferencesRepository _repository;

  UserPreferences _value = const UserPreferences.defaults();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  UserPreferences get value => _value;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _value = await _repository.load();
    } catch (e) {
      _errorMessage = 'Preferensi gagal dimuat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengembalikan true jika berhasil disimpan.
  Future<bool> save(UserPreferences newValue) async {
    _isSaving = true;
    _value = newValue; // UI langsung bereaksi
    notifyListeners();
    try {
      await _repository.save(newValue); // persist
      return true;
    } catch (e) {
      _errorMessage = 'Preferensi gagal disimpan: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> setShowCompletedTasks(bool show) {
    return save(_value.copyWith(showCompletedTasks: show));
  }

  Future<bool> setDarkMode(bool enabled) {
    return save(_value.copyWith(isDarkMode: enabled));
  }
}
