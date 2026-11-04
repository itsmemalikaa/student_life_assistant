import 'package:flutter/material.dart';

import '../logic/task_logic.dart';
import '../models/task_item.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'bouncy.dart';

/// Kartu tugas berwarna. Warna mengikuti prioritas:
/// tinggi = strawberry, sedang = limeade, rendah = blueberry.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  final TaskItem task;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  static Color colorFor(TaskItem task) {
    if (task.isDone) return const Color(0xFFF3E6EC);
    return switch (task.priority) {
      TaskPriority.high => AppColors.rose,
      TaskPriority.medium => AppColors.mustard,
      TaskPriority.low => AppColors.sage,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Bouncy(scale: 0.97, child: _content(context));
  }

  Widget _content(BuildContext context) {
    const textColor = AppColors.ink;
    final urgent = task.needsAttention();

    return Material(
      color: colorFor(task),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontFamily: AppFonts.title,
 fontWeight: FontWeight.w600,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 16, color: textColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${deadlineLabel(task)} • ${formatDate(task.deadline)}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight:
                                  urgent ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x99FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.course,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Tombol centang bulat
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => onToggle(!task.isDone),
                // Lingkaran centang berubah warna & ikon "pop" saat diketuk.
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isDone ? AppColors.wineDark : Colors.white,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: CurvedAnimation(
                        parent: animation,
                        curve: Curves.elasticOut,
                      ),
                      child: child,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      key: ValueKey(task.isDone),
                      color: task.isDone
                          ? Colors.white
                          : const Color(0x66D94680),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
