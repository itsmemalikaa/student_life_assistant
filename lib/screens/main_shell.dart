import 'package:flutter/material.dart';

import '../state/account_controller.dart';
import '../state/preferences_controller.dart';
import '../state/schedule_controller.dart';
import '../state/task_controller.dart';
import '../state/transaction_controller.dart';
import '../widgets/notch_nav_bar.dart';
import 'finance/finance_screen.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'task_screen.dart';

/// Kerangka utama dengan navigasi bawah berlekuk (notch).
/// State tiap tab tetap terjaga saat berpindah, dengan animasi crossfade.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.tasks,
    required this.finance,
    required this.preferences,
    required this.schedules,
    required this.accounts,
    required this.onSwitchUser,
  });

  final TaskController tasks;
  final TransactionController finance;
  final PreferencesController preferences;
  final ScheduleController schedules;
  final AccountController accounts;
  final VoidCallback onSwitchUser;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0; // local state: tab aktif

  static const _items = [
    NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    NavItem(icon: Icons.task_alt_rounded, label: 'Tugas'),
    NavItem(icon: Icons.calendar_month_rounded, label: 'Jadwal'),
    NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Keuangan'),
  ];

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        tasks: widget.tasks,
        finance: widget.finance,
        preferences: widget.preferences,
        accounts: widget.accounts,
        onSwitchUser: widget.onSwitchUser,
        onSelectTab: _select,
      ),
      TaskScreen(controller: widget.tasks, preferences: widget.preferences),
      ScheduleScreen(controller: widget.schedules),
      FinanceScreen(controller: widget.finance),
    ];

    return Scaffold(
      // Semua tab tetap hidup (state terjaga), tetapi perpindahannya
      // dianimasikan: tab lama memudar, tab baru muncul sambil naik sedikit.
      body: Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < pages.length; i++)
            _AnimatedTab(active: i == _index, child: pages[i]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: NotchNavBar(
                items: _items,
                selectedIndex: _index,
                onSelect: _select,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Membungkus satu tab dengan animasi fade + slide.
class _AnimatedTab extends StatelessWidget {
  const _AnimatedTab({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !active,
      child: ExcludeSemantics(
        excluding: !active,
        child: AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: active ? Offset.zero : const Offset(0, 0.03),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            // Animasi di tab yang tidak aktif dihentikan (hemat baterai).
            child: TickerMode(enabled: active, child: child),
          ),
        ),
      ),
    );
  }
}
