import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../state/preferences_controller.dart';
import '../state/task_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({
    super.key,
    required this.controller,
    required this.preferences,
  });

  final TaskController controller;
  final PreferencesController preferences;

  Future<void> _addTask(BuildContext context) async {
    // Menunggu data yang dikirim balik dari form (Navigator.pop).
    final newTask = await Navigator.of(context).push<TaskItem>(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (newTask == null) return;

    await controller.add(newTask);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tugas "${newTask.title}" ditambahkan')),
    );
  }

  Future<void> _delete(BuildContext context, TaskItem task) async {
    await controller.delete(task.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${task.title}" dihapus'),
          action: SnackBarAction(
            label: 'URUNGKAN',
            onPressed: () => controller.add(task),
          ),
        ),
      );
  }

  void _openDetail(BuildContext context, TaskItem task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskDetailScreen(task: task, controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Saya')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTask(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tugas baru'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([controller, preferences]),
          builder: (context, _) {
            if (controller.isLoading) {
              return const LoadingView(message: 'Memuat tugas...');
            }
            if (controller.errorMessage != null) {
              return ErrorView(
                message: controller.errorMessage!,
                onRetry: controller.load,
              );
            }
            return _buildList(context);
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final showCompleted = preferences.value.showCompletedTasks;
    final visible = controller.tasks
        .where((task) => showCompleted || !task.isDone)
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          children: [
            _ProgressHeader(
              completed: controller.completedCount,
              total: controller.totalCount,
              progress: controller.progress,
              showCompleted: showCompleted,
              // Preferensi ini disimpan lokal & tetap ada setelah restart.
              onShowCompletedChanged: preferences.setShowCompletedTasks,
            ),
            const SizedBox(height: 20),
            if (visible.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: EmptyView(
                  icon: Icons.task_alt_rounded,
                  title: 'Tidak ada tugas',
                  subtitle: 'Tambahkan tugas baru dengan tombol di bawah.',
                ),
              )
            else
              for (final task in visible)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  // Geser ke kiri untuk menghapus.
                  child: Dismissible(
                    key: ValueKey(task.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: AppColors.raspberry,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.delete_rounded,
                          color: Colors.white),
                    ),
                    onDismissed: (_) => _delete(context, task),
                    child: TaskCard(
                      task: task,
                      onTap: () => _openDetail(context, task),
                      onToggle: (done) => controller.toggleDone(task.id, done),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.completed,
    required this.total,
    required this.progress,
    required this.showCompleted,
    required this.onShowCompletedChanged,
  });

  final int completed;
  final int total;
  final double progress;
  final bool showCompleted;
  final ValueChanged<bool> onShowCompletedChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [AppColors.raspberry, AppColors.cherry],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$completed dari $total tugas selesai',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                color: AppColors.limeade,
                backgroundColor: AppColors.white30,
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Tampilkan tugas selesai',
              style: TextStyle(color: Colors.white),
            ),
            value: showCompleted,
            activeTrackColor: AppColors.limeade,
            onChanged: onShowCompletedChanged,
          ),
        ],
      ),
    );
  }
}
