import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_life_assistant/logic/task_logic.dart';
import 'package:student_life_assistant/main.dart';
import 'package:student_life_assistant/models/external_todo.dart';
import 'package:student_life_assistant/models/task_item.dart';
import 'package:student_life_assistant/utils/formatters.dart';

void main() {
  testWidgets('beranda menampilkan menu dan navigasi bawah', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StudentLifeAssistantApp());
    await tester.pump();

    expect(find.text('Menu cepat'), findsOneWidget);
    expect(find.text('Tugas Eksternal'), findsOneWidget);
    expect(find.text('Malika'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      expect(find.byKey(ValueKey('nav-$i')), findsOneWidget);
    }
  });

  group('Logika rekomendasi tugas (Bab 2)', () {
    final now = DateTime(2026, 11, 3);

    TaskItem task(
      String id, {
      required int dueInDays,
      TaskPriority priority = TaskPriority.medium,
      bool isDone = false,
    }) {
      return TaskItem(
        id: id,
        title: 'Tugas $id',
        course: 'MK',
        deadline: now.add(Duration(days: dueInDays)),
        priority: priority,
        isDone: isDone,
      );
    }

    test('tugas mendesak didahulukan', () {
      final tasks = [
        task('a', dueInDays: 5),
        task('b', dueInDays: 1),
        task('c', dueInDays: 0, isDone: true),
      ];
      expect(recommendTask(tasks, now)?.id, 'b');
    });

    test('prioritas tinggi termasuk perlu perhatian', () {
      final tasks = [
        task('a', dueInDays: 3),
        task('b', dueInDays: 7, priority: TaskPriority.high),
      ];
      expect(recommendTask(tasks, now)?.id, 'b');
    });

    test('null jika semua tugas selesai', () {
      expect(recommendTask([task('a', dueInDays: 1, isDone: true)], now),
          isNull);
    });

    test('label deadline mudah dibaca', () {
      expect(deadlineLabel(task('a', dueInDays: 0), now), 'Hari ini');
      expect(deadlineLabel(task('a', dueInDays: 1), now), 'Besok');
      expect(deadlineLabel(task('a', dueInDays: -2), now), 'Lewat 2 hari');
    });
  });

  group('JSON mapping', () {
    test('TaskItem toJson -> fromJson tetap sama', () {
      final original = TaskItem(
        id: '1',
        title: 'Laporan',
        course: 'Kriptografi',
        deadline: DateTime(2026, 11, 10),
        priority: TaskPriority.high,
      );
      final restored = TaskItem.fromJson(original.toJson());
      expect(restored.title, 'Laporan');
      expect(restored.priority, TaskPriority.high);
      expect(restored.description, isNull);
      expect(restored.isDone, isFalse);
    });

    test('ExternalTodo.fromJson membaca response REST API', () {
      final todo = ExternalTodo.fromJson({
        'userId': 1,
        'id': 7,
        'title': 'contoh tugas',
        'completed': true,
      });
      expect(todo.id, 7);
      expect(todo.completed, isTrue);
    });
  });

  test('formatRupiah memberi pemisah ribuan', () {
    expect(formatRupiah(1500000), 'Rp 1.500.000');
    expect(formatRupiah(-12500), '-Rp 12.500');
  });
}
