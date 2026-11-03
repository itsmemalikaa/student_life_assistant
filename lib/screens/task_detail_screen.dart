import 'package:flutter/material.dart';

import '../logic/task_logic.dart';
import '../models/task_item.dart';
import '../state/task_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/task_card.dart';
import 'schedule_detail_screen.dart';
import 'task_form_screen.dart';

/// Detail tugas. Data dikirim dari halaman sebelumnya lewat constructor.
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.controller,
  });

  final TaskItem task;
  final TaskController controller;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskItem _task = widget.task;

  Future<void> _edit() async {
    // Menunggu data hasil edit yang dikirim balik lewat Navigator.pop.
    final updated = await Navigator.of(context).push<TaskItem>(
      MaterialPageRoute(builder: (_) => TaskFormScreen(initial: _task)),
    );
    if (updated == null) return;

    await widget.controller.update(updated);
    if (!mounted) return;
    setState(() => _task = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas diperbarui')),
    );
  }

  Future<void> _toggleDone() async {
    final updated = _task.copyWith(isDone: !_task.isDone);
    await widget.controller.toggleDone(_task.id, updated.isDone);
    if (!mounted) return;
    setState(() => _task = updated);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tugas?'),
        content: Text('"${_task.title}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await widget.controller.delete(_task.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Tutup',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton.outlined(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
          const SizedBox(width: 4),
          IconButton.outlined(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _delete,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: DarkPill(
                    text: '${formatDate(task.deadline)} • ${deadlineLabel(task)}',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  task.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.course,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(
                      text: task.isDone ? 'Selesai' : 'Belum selesai',
                      color: task.isDone
                          ? AppColors.limeade
                          : AppColors.blueberry,
                    ),
                    _Tag(
                      text: 'Prioritas ${task.priority.label}',
                      color: TaskCard.colorFor(task.copyWith(isDone: false)),
                    ),
                    if (task.needsAttention())
                      const _Tag(
                        text: '⚠ Perlu perhatian',
                        color: AppColors.strawberry,
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Detail',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                InfoRow(
                  color: AppColors.strawberry,
                  label: 'Mata kuliah',
                  value: task.course,
                  icon: Icons.menu_book_rounded,
                ),
                InfoRow(
                  color: AppColors.limeade,
                  label: 'Deadline',
                  value: formatDate(task.deadline),
                  icon: Icons.event_rounded,
                ),
                InfoRow(
                  color: AppColors.blueberry,
                  label: 'Deskripsi',
                  value: task.description ?? '-',
                  icon: Icons.notes_rounded,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _toggleDone,
                  icon: Icon(task.isDone ? Icons.undo_rounded : Icons.check),
                  label: Text(
                    task.isDone ? 'Tandai belum selesai' : 'Tandai selesai',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
