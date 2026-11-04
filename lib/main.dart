import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'state/preferences_controller.dart';
import 'state/schedule_controller.dart';
import 'state/task_controller.dart';
import 'state/transaction_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/gradient_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentLifeAssistantApp());
}

/// Root aplikasi. Application state dibuat SATU kali di sini,
/// lalu diteruskan ke screen melalui constructor.
class StudentLifeAssistantApp extends StatefulWidget {
  const StudentLifeAssistantApp({super.key});

  @override
  State<StudentLifeAssistantApp> createState() =>
      _StudentLifeAssistantAppState();
}

class _StudentLifeAssistantAppState extends State<StudentLifeAssistantApp> {
  final _tasks = TaskController();
  final _finance = TransactionController();
  final _preferences = PreferencesController();
  final _schedules = ScheduleController();

  @override
  void initState() {
    super.initState();
    // Membaca data lokal secara asynchronous saat aplikasi dibuka.
    _tasks.load();
    _finance.load();
    _preferences.load();
    _schedules.load();
  }

  @override
  void dispose() {
    _tasks.dispose();
    _finance.dispose();
    _preferences.dispose();
    _schedules.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tema ikut berubah ketika preferensi dark mode berubah.
    return ListenableBuilder(
      listenable: _preferences,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Student Life Assistant',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          // Latar gradasi dipasang di bawah semua halaman.
          builder: (context, child) =>
              GradientBackground(child: child ?? const SizedBox.shrink()),
          themeMode: _preferences.value.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: MainShell(
            tasks: _tasks,
            finance: _finance,
            preferences: _preferences,
            schedules: _schedules,
          ),
        );
      },
    );
  }
}
