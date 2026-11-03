import 'package:flutter/material.dart';

import '../state/preferences_controller.dart';
import '../state/task_controller.dart';
import '../state/transaction_controller.dart';
import '../widgets/pill_nav_bar.dart';
import 'finance/finance_screen.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'task_screen.dart';

/// Kerangka utama dengan navigasi bawah berbentuk pill.
/// IndexedStack menjaga state tiap tab saat berpindah.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.tasks,
    required this.finance,
    required this.preferences,
  });

  final TaskController tasks;
  final TransactionController finance;
  final PreferencesController preferences;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0; // local state: tab aktif

  static const _items = [
    PillNavItem(icon: Icons.home_rounded, label: 'Beranda'),
    PillNavItem(icon: Icons.task_alt_rounded, label: 'Tugas'),
    PillNavItem(icon: Icons.calendar_month_rounded, label: 'Jadwal'),
    PillNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Keuangan'),
  ];

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            tasks: widget.tasks,
            finance: widget.finance,
            preferences: widget.preferences,
            onSelectTab: _select,
          ),
          TaskScreen(
            controller: widget.tasks,
            preferences: widget.preferences,
          ),
          const ScheduleScreen(),
          FinanceScreen(controller: widget.finance),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Center(
            heightFactor: 1,
            child: PillNavBar(
              items: _items,
              selectedIndex: _index,
              onSelect: _select,
            ),
          ),
        ),
      ),
    );
  }
}
