import 'package:flutter/material.dart';

import 'models/account.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/account_controller.dart';
import 'state/preferences_controller.dart';
import 'state/schedule_controller.dart';
import 'state/task_controller.dart';
import 'state/transaction_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/gradient_background.dart';
import 'widgets/state_views.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentLifeAssistantApp());
}

/// Tahapan saat aplikasi dibuka.
enum _Stage { welcome, picker, register, app }

/// Root aplikasi. Application state dibuat SATU kali di sini,
/// lalu diteruskan ke screen melalui constructor.
class StudentLifeAssistantApp extends StatefulWidget {
  const StudentLifeAssistantApp({super.key});

  @override
  State<StudentLifeAssistantApp> createState() =>
      _StudentLifeAssistantAppState();
}

class _StudentLifeAssistantAppState extends State<StudentLifeAssistantApp> {
  final _accounts = AccountController();
  final _tasks = TaskController();
  final _finance = TransactionController();
  final _preferences = PreferencesController();
  final _schedules = ScheduleController();

  _Stage _stage = _Stage.welcome;

  @override
  void initState() {
    super.initState();
    // Yang dibaca pertama kali hanya daftar akun.
    // Data tugas/keuangan/jadwal baru dimuat setelah pengguna masuk.
    _accounts.load();
  }

  @override
  void dispose() {
    _accounts.dispose();
    _tasks.dispose();
    _finance.dispose();
    _preferences.dispose();
    _schedules.dispose();
    super.dispose();
  }

  /// Masuk ke akun: arahkan penyimpanan ke data milik akun ini,
  /// lalu muat semua datanya.
  Future<void> _enter(Account account) async {
    await _accounts.select(account);
    await Future.wait([
      _tasks.load(),
      _finance.load(),
      _schedules.load(),
      _preferences.load(),
    ]);
    // Akun baru: simpan namanya ke preferensi.
    if (_preferences.value.displayName != account.name) {
      await _preferences.save(
        _preferences.value.copyWith(displayName: account.name),
      );
    }
    if (mounted) setState(() => _stage = _Stage.app);
  }

  Future<void> _register(String name) async {
    final account = await _accounts.loginOrRegister(name);
    await _enter(account);
  }

  /// Dipanggil dari halaman Profil: keluar dan pilih pengguna lain.
  void _switchUser() => setState(() => _stage = _Stage.picker);

  @override
  Widget build(BuildContext context) {
    // Tema ikut berubah ketika preferensi dark mode berubah.
    return ListenableBuilder(
      listenable: Listenable.merge([_preferences, _accounts]),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Student Life Assistant',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          // Latar gradasi dipasang di bawah semua halaman.
          builder: (context, child) =>
              GradientBackground(child: child ?? const SizedBox.shrink()),
          themeMode: _stage == _Stage.app && _preferences.value.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    if (_accounts.isLoading) {
      return const Scaffold(body: LoadingView(message: 'Menyiapkan...'));
    }

    // Belum ada pengguna sama sekali -> pendaftaran.
    if (_accounts.isEmpty) {
      return OnboardingScreen(onSubmit: _register);
    }

    switch (_stage) {
      case _Stage.app:
        return MainShell(
          tasks: _tasks,
          finance: _finance,
          preferences: _preferences,
          schedules: _schedules,
          accounts: _accounts,
          onSwitchUser: _switchUser,
        );
      case _Stage.register:
        return OnboardingScreen(
          onSubmit: _register,
          onBack: () => setState(() => _stage = _Stage.picker),
        );
      case _Stage.picker:
        return AccountPickerScreen(
          accounts: _accounts.accounts,
          onPick: (account) async {
            await _accounts.select(account);
            setState(() => _stage = _Stage.welcome);
          },
          onAddNew: () => setState(() => _stage = _Stage.register),
          onBack: () => setState(() => _stage = _Stage.welcome),
        );
      case _Stage.welcome:
        final current = _accounts.current!;
        return WelcomeBackScreen(
          name: current.name,
          onContinue: () => _enter(current),
          onNotYou: () => setState(() => _stage = _Stage.picker),
        );
    }
  }
}
