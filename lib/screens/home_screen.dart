import 'package:flutter/material.dart';

import '../logic/task_logic.dart';
import '../models/task_item.dart';
import '../state/account_controller.dart';
import '../state/preferences_controller.dart';
import '../state/task_controller.dart';
import '../state/transaction_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/bouncy.dart';
import '../widgets/decorations.dart';
import '../widgets/shapes.dart';
import '../widgets/task_card.dart';
import 'external_task_screen.dart';
import 'finance/transaction_form_screen.dart';
import 'profile_screen.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

/// Beranda bergaya "soft clay studio": banner wine bergelombang,
/// menu berbentuk lengkung, kartu coral, dan footer.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.tasks,
    required this.finance,
    required this.preferences,
    required this.accounts,
    required this.onSwitchUser,
    required this.onSelectTab,
  });

  final TaskController tasks;
  final TransactionController finance;
  final PreferencesController preferences;
  final AccountController accounts;
  final VoidCallback onSwitchUser; // keluar & ganti pengguna
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

                // Setiap bagian muncul berurutan (animasi stagger).
                final left = <Widget>[
                  FadeSlideIn(order: 1, child: _buildHero(context)),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    order: 2,
                    child: PostcardBanner(name: preferences.value.displayName),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(order: 3, child: _buildQuickMenu(context)),
                ];
                final right = <Widget>[
                  FadeSlideIn(
                    order: 4,
                    child: _NextTaskCard(
                      task: tasks.isLoading ? null : tasks.recommendation,
                      isLoading: tasks.isLoading,
                      onOpen: (task) => _openTask(context, task),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(order: 5, child: _buildSummary(context)),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    order: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildOtherTasks(context),
                    ),
                  ),
                ];

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(padding, 16, padding, 24),
                      children: [
                        FadeSlideIn(order: 0, child: _buildHeader(context)),
                        const SizedBox(height: 20),
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
                          const SizedBox(height: 28),
                          ...right,
                        ],
                        const SizedBox(height: 32),
                        const FadeSlideIn(order: 7, child: _Footer()),
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
            ProfileScreen(
            preferences: preferences,
            tasks: tasks,
            accounts: accounts,
            onSwitchUser: onSwitchUser,
          ),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.rose,
            foregroundColor: AppColors.wineDark,
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontFamily: AppFonts.title,
                fontWeight: FontWeight.w700,
              ),
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
                  fontSize: 24,
                  fontFamily: AppFonts.script,
                  fontWeight: FontWeight.w700,
                  color: AppColors.wine,
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
            backgroundColor: AppColors.coral,
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

  // ---------------- Banner utama (wine, pinggir bergelombang) ----------------
  Widget _buildHero(BuildContext context) {
    final pending = tasks.pendingCount;

    final String title;
    final String subtitle;
    if (tasks.isLoading) {
      title = 'Sebentar ya...';
      subtitle = 'Data kamu sedang disiapkan.';
    } else if (pending == 0) {
      title = 'Semua tugas beres!';
      subtitle = 'Saatnya istirahat sebentar.';
    } else {
      title = 'Kamu punya $pending tugas';
      subtitle = 'Pelan-pelan, satu per satu pasti selesai.';
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: const ScallopClipper(radius: 11),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 40),
            color: AppColors.wine,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppFonts.title,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cream,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.rose),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.mustard,
                          foregroundColor: AppColors.ink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => onSelectTab(1),
                        child: const Text('Lihat tugasku'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 72),
              ],
            ),
          ),
        ),
        // Hiasan bunga di sisi kanan banner
        const Positioned(
          right: 18,
          top: 16,
          child: Sticker('daisy', size: 46, angle: 0.2),
        ),
        const Positioned(
          right: 6,
          bottom: 28,
          child: Sticker('tulip', size: 74, angle: 0.12, floatDistance: 3),
        ),
        const Positioned(
          right: 64,
          bottom: 34,
          child: Sticker('leaf', size: 40, angle: -0.3),
        ),
      ],
    );
  }

  // ---------------- Menu cepat (bentuk lengkung / arch) ----------------
  Widget _buildQuickMenu(BuildContext context) {
    final actions = [
      _ArchAction(
        icon: Icons.cloud_rounded,
        label: 'Tugas Eksternal',
        background: AppColors.sage,
        foreground: AppColors.forest,
        onTap: () => _push(context, const ExternalTaskScreen()),
      ),
      _ArchAction(
        icon: Icons.payments_rounded,
        label: 'Catat uang',
        background: AppColors.mustard,
        foreground: AppColors.cocoa,
        onTap: () => openTransactionForm(context, finance),
      ),
      _ArchAction(
        icon: Icons.calendar_month_rounded,
        label: 'Jadwal',
        background: AppColors.rose,
        foreground: AppColors.wineDark,
        onTap: () => onSelectTab(2),
      ),
      _ArchAction(
        icon: Icons.person_rounded,
        label: 'Profil',
        background: AppColors.coral,
        foreground: Colors.white,
        onTap: () => _push(
          context,
          ProfileScreen(
            preferences: preferences,
            tasks: tasks,
            accounts: accounts,
            onSwitchUser: onSwitchUser,
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Menu cepat',
          decoration: const Sticker('flower', size: 28, angle: -0.2),
          action: IconButton.filled(
            tooltip: 'Tambah tugas',
            onPressed: () => _addTask(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final action in actions) ...[
                action,
                const SizedBox(width: 12),
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
            background: AppColors.mustard,
            foreground: AppColors.cocoa,
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
            background: AppColors.sage,
            foreground: AppColors.forest,
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
      SectionTitle(
        'Tugas lainnya',
        decoration: const Sticker('heart', size: 26, angle: 0.2),
        squiggleColor: AppColors.sage,
        action: TextButton(
          onPressed: () => onSelectTab(1),
          child: const Text('Lihat semua'),
        ),
      ),
      const SizedBox(height: 12),
      if (tasks.isLoading)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (others.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('Tidak ada tugas lain. Mantap!')),
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

/// Tombol menu berbentuk lengkung (arch), seperti kartu produk di referensi.
class _ArchAction extends StatelessWidget {
  const _ArchAction({
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
    return Bouncy(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 78,
          child: Column(
            children: [
              Container(
                width: 74,
                height: 88,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(37),
                    bottom: Radius.circular(18),
                  ),
                ),
                child: Icon(icon, color: foreground, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu "Tugas berikutnya" berwarna coral dengan pinggir bawah bergelombang.
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
        const SectionTitle(
          'Tugas berikutnya',
          decoration: Sticker('sparkle', size: 28, angle: 0.15),
          squiggleColor: AppColors.mustard,
        ),
        const SizedBox(height: 14),
        Bouncy(
          child: GestureDetector(
            onTap: current == null ? null : () => onOpen(current),
            child: ClipPath(
              clipper: const ScallopClipper(radius: 11),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 38),
                color: AppColors.coral,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: AppFonts.title,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColors.cream,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (current != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 16,
                                    color: AppColors.wine,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '${deadlineLabel(current)} • '
                                      '${formatDate(current.deadline)}',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.wine,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              recommendationMessage(current),
                              style: const TextStyle(
                                color: AppColors.cream,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const _Bubble(
                          icon: Icons.lightbulb_rounded,
                          background: AppColors.mustard,
                          foreground: AppColors.cocoa,
                        ),
                        const SizedBox(height: 8),
                        const _Bubble(
                          icon: Icons.menu_book_rounded,
                          background: AppColors.sage,
                          foreground: AppColors.forest,
                        ),
                        const SizedBox(height: 8),
                        const _Bubble(
                          icon: Icons.edit_rounded,
                          background: AppColors.rose,
                          foreground: AppColors.wineDark,
                        ),
                        if (current != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
    return Bouncy(
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
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
                        fontWeight: FontWeight.w700,
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
                      fontFamily: AppFonts.title,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

/// Footer wine dengan pinggir atas bergelombang, seperti di referensi.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const ScallopClipper(radius: 11, top: true, bottom: false),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 26),
        color: AppColors.wineDark,
        child: const Column(
          children: [
            Squiggle(color: AppColors.rose),
            SizedBox(height: 10),
            Text(
              'your assistant buddy',
              style: TextStyle(
                color: AppColors.cream,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'study hard, rest harder, stay cute',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.rose,
                fontFamily: AppFonts.script,
                  fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
