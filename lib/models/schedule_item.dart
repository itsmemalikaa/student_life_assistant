/// Model jadwal kuliah (data statis, tidak berubah saat aplikasi berjalan).
class ScheduleItem {
  const ScheduleItem({
    required this.course,
    required this.day,
    required this.time,
    required this.room,
    required this.lecturer,
    this.note,
  });

  final String course;
  final String day;
  final String time;
  final String room;
  final String lecturer;
  final String? note;
}
