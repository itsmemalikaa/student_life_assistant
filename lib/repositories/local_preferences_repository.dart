import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_preferences.dart';

/// Repository: menyembunyikan detail baca/tulis local storage dari UI.
class LocalPreferencesRepository {
  static const _displayNameKey = 'profile.display_name';
  static const _showCompletedTasksKey = 'tasks.show_completed';
  static const _darkModeKey = 'theme.dark_mode';

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
