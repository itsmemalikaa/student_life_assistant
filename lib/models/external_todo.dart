/// Model data dari REST API JSONPlaceholder.
///
/// Contoh JSON:
/// { "userId": 1, "id": 1, "title": "delectus aut autem", "completed": false }
class ExternalTodo {
  const ExternalTodo({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  final int userId;
  final int id;
  final String title;
  final bool completed;

  /// Map hasil jsonDecode -> object Dart yang type-safe.
  factory ExternalTodo.fromJson(Map<String, dynamic> json) {
    return ExternalTodo(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }
}
