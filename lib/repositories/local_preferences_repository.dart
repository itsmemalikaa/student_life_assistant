import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_preferences.dart';
import 'storage_scope.dart';

/// Repository: menyembunyikan detail baca/tulis local storage dari UI.
class LocalPreferencesRepository {
  // Key diberi awalan sesuai pengguna aktif (lihat StorageScope).
  String get _displayNameKey => StorageScope.key('profile.display_name');
  String get _showCompletedTasksKey => StorageScope.key('tasks.show_completed');
  String get _darkModeKey => StorageScope.key('theme.dark_mode');

  Future<UserPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = UserPreferences.defaults();
    final name = prefs.getString(_displayNameKey);

    return UserPreferences(
      displayName: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : defaults.displayName,
      showCompletedTasks:
          prefs.getBool(_showCompletedTasksKey) ?? defaults.showCompletedTasks,
      isDarkMode: prefs.getBool(_darkModeKey) ?? defaults.isDarkMode,
    );
  }

  Future<void> save(UserPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, value.displayName.trim());
    await prefs.setBool(_showCompletedTasksKey, value.showCompletedTasks);
    await prefs.setBool(_darkModeKey, value.isDarkMode);
  }
}
