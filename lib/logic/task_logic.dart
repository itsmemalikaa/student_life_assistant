import '../models/task_item.dart';

/// Logika rekomendasi "What Should I Do First?" (Dart Logic Challenge Bab 2),
/// sekarang dipakai langsung oleh aplikasi Flutter.
///
/// Aturan prioritas:
/// 1. Hanya tugas yang belum selesai.
/// 2. Tugas yang "perlu perhatian" didahulukan.
/// 3. Lalu deadline paling dekat.
/// 4. Jika deadline sama, prioritas lebih tinggi didahulukan.
TaskItem? recommendTask(List<TaskItem> tasks, [DateTime? now]) {
  final pending = tasks.where((task) => !task.isDone).toList();
  if (pending.isEmpty) return null;

  pending.sort((a, b) {
    final attentionA = a.needsAttention(now) ? 0 : 1;
    final attentionB = b.needsAttention(now) ? 0 : 1;
    if (attentionA != attentionB) return attentionA.compareTo(attentionB);

    final byDeadline = a.deadline.compareTo(b.deadline);
    if (byDeadline != 0) return byDeadline;

    return a.priority.index.compareTo(b.priority.index);
  });

  return pending.first;
}

String recommendationMessage(TaskItem? task) {
  if (task == null) return 'Semua tugas sudah selesai. Saatnya istirahat!';
  return 'Kerjakan "${task.title}" terlebih dahulu.';
}

/// Teks sisa waktu yang mudah dibaca.
String deadlineLabel(TaskItem task, [DateTime? now]) {
  final days = task.daysLeft(now);
  if (days < 0) return 'Lewat ${-days} hari';
  if (days == 0) return 'Hari ini';
  if (days == 1) return 'Besok';
  return '$days hari lagi';
}
