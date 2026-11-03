import 'package:flutter/material.dart';

import '../logic/task_logic.dart';
import '../models/task_item.dart';
import '../state/preferences_controller.dart';
import '../state/task_controller.dart';
import '../state/transaction_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/task_card.dart';
import 'external_task_screen.dart';
import 'finance/transaction_form_screen.dart';
import 'profile_screen.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

/// Beranda: sapaan, ringkasan tugas, menu cepat, tugas berikutnya.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.tasks,
    required this.finance,
    required this.preferences,
    required this.onSelectTab,
  });

  final TaskController tasks;
  final TransactionController finance;
  final PreferencesController preferences;
  final ValueChanged<int> onSelectTab; // pindah tab di navigasi bawah

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openTask(BuildContext context, TaskItem task) {
    _push(context, TaskDetailScreen(task: task, controller: tasks));
  }

  Future<void> _addTask(BuildContext context) async {
    final newTask = await Navigator.of(context).push<TaskItem>(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (newTask == null) return;
    await tasks.add(newTask);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tugas "${newTask.title}" ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([tasks, finance, preferences]),
          builder: (context, _) {
            // LayoutBuilder: 1 kolom di HP, 2 kolom di layar lebar.
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final padding = isWide ? 32.0 : 20.0;

                final left = <Widget>[
                  _buildHeadline(context),
                  const SizedBox(height: 24),
                  _buildQuickMenu(context),
                  const SizedBox(height: 24),
                  _NextTaskCard(
                    task: tasks.isLoading ? null : tasks.recommendation,
                    isLoading: tasks.isLoading,
                    onOpen: (task) => _openTask(context, task),
                  ),
                ];
                final right = <Widget>[
                  _buildSummary(context),
                  const SizedBox(height: 24),
                  ..._buildOtherTasks(context),
                ];

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(padding, 16, padding, 24),
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Column(children: left)),
                              const SizedBox(width: 32),
                              Expanded(child: Column(children: right)),
                            ],
                          )
                        else ...[
                          ...left,
                          const SizedBox(height: 20),
                          ...right,
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ---------------- Header: avatar, sapaan, notifikasi ----------------
  Widget _buildHeader(BuildContext context) {
    final name = preferences.value.displayName;
    final urgentCount = tasks.isLoading
        ? 0
        : tasks.tasks.where((t) => t.needsAttention()).length;

    return Row(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _push(
            context,
            ProfileScreen(preferences: preferences, tasks: tasks),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.strawberry,
            foregroundColor: AppColors.raspberry,
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()}!',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton.outlined(
          tooltip: 'Tugas mendesak',
          onPressed: () => onSelectTab(1),
          icon: Badge(
            isLabelVisible: urgentCount > 0,
            backgroundColor: AppColors.cherry,
            label: Text('$urgentCount'),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  // ---------------- Judul besar ----------------
  Widget _buildHeadline(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final pending = tasks.pendingCount;

    final String light;
    final String bold;
    if (tasks.isLoading) {
      light = 'Sebentar ya,\n';
      bold = 'data sedang dimuat';
    } else if (pending == 0) {
      light = 'Semua tugas\n';
      bold = 'sudah beres! 🎉';
    } else {
      light = 'Kamu punya $pending tugas\n';
      bold = 'yang perlu dikerjakan';
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: light,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w300,
                color: color,
                height: 1.2,
              ),
            ),
            TextSpan(
              text: bold,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Menu cepat (lingkaran warna-warni) ----------------
  Widget _buildQuickMenu(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.cloud_rounded,
        label: 'Tugas Eksternal',
        background: AppColors.blueberry,
        foreground: AppColors.navy,
        onTap: () => _push(context, const ExternalTaskScreen()),
      ),
      _QuickAction(
        icon: Icons.payments_rounded,
        label: 'Catat uang',
        background: AppColors.limeade,
        foreground: AppColors.olive,
        onTap: () => openTransactionForm(context, finance),
      ),
      _QuickAction(
        icon: Icons.calendar_month_rounded,
        label: 'Jadwal',
        background: AppColors.strawberry,
        foreground: AppColors.raspberry,
        onTap: () => onSelectTab(2),
      ),
      _QuickAction(
        icon: Icons.person_rounded,
        label: 'Profil',
        background: AppColors.blueberry,
        foreground: AppColors.navy,
        onTap: () => _push(
          context,
          ProfileScreen(preferences: preferences, tasks: tasks),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Menu cepat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton.filled(
              tooltip: 'Tambah tugas',
              onPressed: () => _addTask(context),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final action in actions) ...[
                action,
                const SizedBox(width: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- Ringkasan progres & saldo ----------------
  Widget _buildSummary(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MiniStat(
            background: AppColors.limeade,
            foreground: AppColors.olive,
            icon: Icons.insights_rounded,
            label: 'Progres',
            value: tasks.isLoading
                ? '...'
                : '${tasks.completedCount}/${tasks.totalCount} selesai',
            progress: tasks.isLoading ? null : tasks.progress,
            onTap: () => onSelectTab(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStat(
            background: AppColors.blueberry,
            foreground: AppColors.navy,
            icon: Icons.savings_rounded,
            label: 'Saldo',
            value: finance.isLoading ? '...' : formatRupiah(finance.balance),
            onTap: () => onSelectTab(3),
          ),
        ),
      ],
    );
  }

  // ---------------- Tugas lainnya ----------------
  List<Widget> _buildOtherTasks(BuildContext context) {
    final recommended = tasks.recommendation;
    final others = tasks.tasks
        .where((t) => !t.isDone && t.id != recommended?.id)
        .take(3)
        .toList();

    return [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Tugas lainnya',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          TextButton(
            onPressed: () => onSelectTab(1),
            child: const Text('Lihat semua'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (tasks.isLoading)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (others.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('Tidak ada tugas lain. Mantap! ✨')),
        )
      else
        for (final task in others)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCard(
              task: task,
              onTap: () => _openTask(context, task),
              onToggle: (done) => tasks.toggleDone(task.id, done),
            ),
          ),
    ];
  }
}

// ======================================================================

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: foreground, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextTaskCard extends StatelessWidget {
  const _NextTaskCard({
    required this.task,
    required this.isLoading,
    required this.onOpen,
  });

  final TaskItem? task;
  final bool isLoading;
  final ValueChanged<TaskItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final current = task;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tugas berikutnya',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            // Kartu bayangan di belakang (efek bertumpuk)
            Positioned(
              left: 14,
              right: 14,
              top: 24,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.raspberry,
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [AppColors.cherry, Color(0xFFB8195F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildText(current)),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const _Bubble(
                          icon: Icons.lightbulb_rounded,
                          background: AppColors.limeade,
                          foreground: AppColors.olive,
                        ),
                        const SizedBox(height: 8),
                        const _Bubble(
                          icon: Icons.menu_book_rounded,
                          background: AppColors.blueberry,
                          foreground: AppColors.navy,
                        ),
                        const SizedBox(height: 8),
                        const _Bubble(
                          icon: Icons.edit_rounded,
                          background: AppColors.strawberry,
                          foreground: AppColors.raspberry,
                        ),
                        const SizedBox(height: 16),
                        if (current != null)
                          InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => onOpen(current),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildText(TaskItem? current) {
    final String title;
    final String subtitle;
    if (isLoading) {
      title = 'Memuat...';
      subtitle = '';
    } else if (current == null) {
      title = 'Semua tugas selesai';
      subtitle = 'Saatnya istirahat sebentar.';
    } else {
      title = current.title;
      subtitle = current.course;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.strawberry,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (current != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white15,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.limeade,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${deadlineLabel(current)} • ${formatDate(current.deadline)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            recommendationMessage(current),
            style: const TextStyle(color: AppColors.strawberry, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, size: 20, color: foreground),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.progress,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: foreground, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: foreground,
                    backgroundColor: const Color(0x66FFFFFF),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
