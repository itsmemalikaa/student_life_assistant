// ignore_for_file: avoid_print

// Bab 2 — Dart Logic Challenge: "What Should I Do First?"
// Jalankan dari root project:  dart run dart_logic/main.dart

class Task {
  Task({
    required this.title,
    required this.priority,
    required this.remainingDays,
    this.isDone = false,
    this.location, // null safety: lokasi boleh tidak diisi
  });

  final String title;
  final String priority; // 'high' | 'medium' | 'low'
  final int remainingDays;
  bool isDone;
  final String? location;

  bool needsAttention() {
    return !isDone && (priority == 'high' || remainingDays <= 1);
  }
}

void printTasks(List<Task> tasks) {
  for (final task in tasks) {
    final status = task.isDone ? '[x]' : '[ ]';
    final place = task.location ?? 'online';
    print('$status ${task.title} (${task.priority}, '
        '${task.remainingDays} hari lagi, $place)');
  }
}

int countPending(List<Task> tasks) => tasks.where((t) => !t.isDone).length;

/// Aturan: tugas yang perlu perhatian dulu, lalu sisa hari paling sedikit.
Task? getRecommendation(List<Task> tasks) {
  final pending = tasks.where((t) => !t.isDone).toList();
  if (pending.isEmpty) return null;

  pending.sort((a, b) {
    final byAttention =
        (a.needsAttention() ? 0 : 1).compareTo(b.needsAttention() ? 0 : 1);
    if (byAttention != 0) return byAttention;
    return a.remainingDays.compareTo(b.remainingDays);
  });
  return pending.first;
}

void main() {
  final tasks = <Task>[
    Task(title: 'Demo UTS Mobile Programming', priority: 'high', remainingDays: 0),
    Task(
      title: 'Laporan praktikum AES',
      priority: 'medium',
      remainingDays: 3,
      location: 'Lab Komputer 2',
    ),
    Task(title: 'Resume algoritma A*', priority: 'low', remainingDays: 6),
    Task(title: 'Install Flutter', priority: 'medium', remainingDays: -40, isDone: true),
  ];

  printTasks(tasks);
  print('\nPending tasks: ${countPending(tasks)}');

  final recommended = getRecommendation(tasks);
  print('\nRecommendation:');
  print(recommended == null
      ? 'Semua tugas selesai!'
      : 'Kerjakan "${recommended.title}" terlebih dahulu.');
}
