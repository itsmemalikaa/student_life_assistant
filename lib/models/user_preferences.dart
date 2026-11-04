/// Preferensi pengguna yang disimpan lokal (key-value).
class UserPreferences {
  const UserPreferences({
    required this.displayName,
    required this.showCompletedTasks,
    required this.isDarkMode,
  });

  const UserPreferences.defaults()
      : displayName = '', // kosong = belum perkenalan
        showCompletedTasks = true,
        isDarkMode = false;

  final String displayName;
  final bool showCompletedTasks;
  final bool isDarkMode;

  UserPreferences copyWith({
    String? displayName,
    bool? showCompletedTasks,
    bool? isDarkMode,
  }) {
    return UserPreferences(
      displayName: displayName ?? this.displayName,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
