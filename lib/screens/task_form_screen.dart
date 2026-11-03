import 'package:flutter/material.dart';

import '../models/task_item.dart';
import '../utils/formatters.dart';

/// Form tambah / edit tugas. Hasil dikirim kembali via Navigator.pop.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.initial});

  final TaskItem? initial; // null = tambah baru, terisi = edit

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _courseController;
  late final TextEditingController _descriptionController;
  late DateTime _deadline;
  late TaskPriority _priority;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _courseController = TextEditingController(text: initial?.course ?? '');
    _descriptionController =
        TextEditingController(text: initial?.description ?? '');
    _deadline =
        initial?.deadline ?? DateTime.now().add(const Duration(days: 1));
    _priority = initial?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();
    final result = TaskItem(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      course: _courseController.text.trim(),
      deadline: _deadline,
      priority: _priority,
      description: description.isEmpty ? null : description,
      isDone: widget.initial?.isDone ?? false,
    );
    Navigator.of(context).pop(result);
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Tugas' : 'Tugas Baru')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Judul tugas',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  validator: (v) => _required(v, 'Judul'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _courseController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Mata kuliah',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.menu_book),
                  ),
                  validator: (v) => _required(v, 'Mata kuliah'),
                ),
                const SizedBox(height: 16),
                Text('Prioritas', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<TaskPriority>(
                  segments: [
                    for (final p in TaskPriority.values)
                      ButtonSegment(value: p, label: Text(p.label)),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (selection) =>
                      setState(() => _priority = selection.first),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: const Text('Deadline'),
                  subtitle: Text(formatDate(_deadline)),
                  trailing: TextButton(
                    onPressed: _pickDeadline,
                    child: const Text('Ubah'),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: Text(_isEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
