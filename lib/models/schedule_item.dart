/// Model jadwal kuliah. Bisa ditambah, diedit, dan dihapus pengguna,
/// lalu disimpan lokal sebagai JSON.
class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.course,
    required this.day,
    required this.start,
    required this.end,
    required this.room,
    required this.lecturer,
    this.note,
  });

  final String id;
  final String course;
  final String day; // Senin ... Jumat
  final String start; // format "08.00"
  final String end; // format "09.40"
  final String room;
  final String lecturer;
  final String? note;

  /// Contoh: "08.00–09.40"
  String get time => '$start–$end';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'day': day,
      'start': start,
      'end': end,
      'room': room,
      'lecturer': lecturer,
      'note': note,
    };
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as String,
      course: json['course'] as String,
      day: json['day'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      room: json['room'] as String,
      lecturer: json['lecturer'] as String,
      note: json['note'] as String?,
    );
  }
}
