import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/schedule_item.dart';
import '../theme/app_theme.dart';

/// Form tambah / edit jadwal. Hasil dikirim kembali lewat Navigator.pop.
class ScheduleFormScreen extends StatefulWidget {
  const ScheduleFormScreen({super.key, this.initial, this.initialDay});

  final ScheduleItem? initial; // null = jadwal baru
  final String? initialDay; // hari yang sedang dipilih di halaman jadwal

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _courseController;
  late final TextEditingController _roomController;
  late final TextEditingController _lecturerController;
  late final TextEditingController _noteController;
  late String _day;
  late TimeOfDay _start;
  late TimeOfDay _end;
  String? _timeError;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _courseController = TextEditingController(text: initial?.course ?? '');
    _roomController = TextEditingController(text: initial?.room ?? '');
    _lecturerController =
        TextEditingController(text: initial?.lecturer ?? '');
    _noteController = TextEditingController(text: initial?.note ?? '');
    _day = initial?.day ?? widget.initialDay ?? SampleData.days.first;
    _start = _parse(initial?.start ?? '08.00');
    _end = _parse(initial?.end ?? '09.40');
  }

  @override
  void dispose() {
    _courseController.dispose();
    _roomController.dispose();
    _lecturerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // "08.00" <-> TimeOfDay
  TimeOfDay _parse(String text) {
    final parts = text.split('.');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _format(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      helpText: isStart ? 'Jam mulai' : 'Jam selesai',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
      _timeError = null;
    });
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    final timeValid = _minutes(_end) > _minutes(_start);
    setState(() {
      _timeError = timeValid ? null : 'Jam selesai harus setelah jam mulai';
    });
    if (!formValid || !timeValid) return;

    final note = _noteController.text.trim();
    final lecturer = _lecturerController.text.trim();
    final result = ScheduleItem(
      id: widget.initial?.id ??
          'sch-${DateTime.now().microsecondsSinceEpoch}',
      course: _courseController.text.trim(),
      day: _day,
      start: _format(_start),
      end: _format(_end),
      room: _roomController.text.trim(),
      lecturer: lecturer.isEmpty ? '-' : lecturer,
      note: note.isEmpty ? null : note,
    );
    Navigator.of(context).pop(result); // kirim data kembali
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Jadwal' : 'Jadwal Baru')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _courseController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Mata kuliah',
                    prefixIcon: Icon(Icons.menu_book_rounded),
                  ),
                  validator: (v) => _required(v, 'Mata kuliah'),
                ),
                const SizedBox(height: 16),
                Text('Hari', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final day in SampleData.days)
                      ChoiceChip(
                        label: Text(day),
                        selected: _day == day,
                        onSelected: (_) => setState(() => _day = day),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _TimeBox(
                        label: 'Mulai',
                        value: _format(_start),
                        onTap: () => _pickTime(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeBox(
                        label: 'Selesai',
                        value: _format(_end),
                        onTap: () => _pickTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                if (_timeError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
                    child: Text(
                      _timeError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                    labelText: 'Ruang',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) => _required(v, 'Ruang'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lecturerController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Dosen (opsional)',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    prefixIcon: Icon(Icons.sticky_note_2_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Jadwal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color ?? Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.rose),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppColors.wine),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: AppFonts.title,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
