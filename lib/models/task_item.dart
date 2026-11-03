/// Prioritas tugas. Urutan nilai menentukan urutan prioritas
/// (index 0 = paling penting).
enum TaskPriority {
  high('Tinggi'),
  medium('Sedang'),
  low('Rendah');

  const TaskPriority(this.label);

  final String label;
}

/// Model satu tugas kuliah.
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.course,
    required this.deadline,
    required this.priority,
    this.description,
    this.isDone = false,
  });

  final String id;
  final String title;
  final String course;
  final DateTime deadline;
  final TaskPriority priority;
  final String? description; // null safety: deskripsi boleh kosong
  final bool isDone;

  /// Sisa hari menuju deadline (negatif = sudah lewat).
  int daysLeft([DateTime? now]) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final due = DateTime(deadline.year, deadline.month, deadline.day);
    return due.difference(today).inDays;
  }

  /// Aturan "perlu perhatian" (dikembangkan dari logika Bab 2):
  /// belum selesai DAN (prioritas tinggi ATAU deadline <= 1 hari lagi).
  bool needsAttention([DateTime? now]) {
    return !isDone && (priority == TaskPriority.high || daysLeft(now) <= 1);
  }

  TaskItem copyWith({
    String? title,
    String? course,
    DateTime? deadline,
    TaskPriority? priority,
    String? description,
    bool? isDone,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      course: course ?? this.course,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course': course,
      'deadline': deadline.toIso8601String(),
      'priority': priority.name,
      'description': description,
      'isDone': isDone,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      course: json['course'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      priority: TaskPriority.values.byName(json['priority'] as String),
      description: json['description'] as String?,
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}
