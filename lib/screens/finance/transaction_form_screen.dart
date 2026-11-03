import 'package:flutter/material.dart';

import '../../data/categories.dart';
import '../../models/transaction.dart';
import '../../state/transaction_controller.dart';
import '../../utils/formatters.dart';

/// Helper: buka form, tunggu hasilnya, lalu simpan ke controller.
/// Dipakai oleh Beranda dan Riwayat Transaksi.
Future<void> openTransactionForm(
  BuildContext context,
  TransactionController controller,
) async {
  final result = await Navigator.of(context).push<Transaction>(
    MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
  );
  if (result == null) return; // pengguna menekan tombol kembali

  await controller.add(result);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('"${result.title}" berhasil disimpan')),
  );
}

/// Form tambah / edit transaksi.
/// Jika [initial] diisi -> mode edit. Hasil dikembalikan via Navigator.pop.
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.initial});

  final Transaction? initial;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _type;
  late String _category;
  late DateTime _date;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _amountController = TextEditingController(
      text: initial == null ? '' : initial.amount.toString(),
    );
    _noteController = TextEditingController(text: initial?.note ?? '');
    _type = initial?.type ?? TransactionType.expense;
    _category = initial?.category ?? kCategories[_type]!.first;
    _date = initial?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _changeType(TransactionType type) {
    setState(() {
      _type = type;
      // Reset kategori jika tidak cocok dengan jenis yang baru.
      if (!kCategories[type]!.contains(_category)) {
        _category = kCategories[type]!.first;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final note = _noteController.text.trim();
    final result = Transaction(
      id: widget.initial?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: parseRupiah(_amountController.text)!,
      type: _type,
      category: _category,
      date: _date,
      note: note.isEmpty ? null : note,
    );

    Navigator.of(context).pop(result); // kirim data kembali
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaksi' : 'Transaksi Baru'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Pengeluaran'),
                      icon: Icon(Icons.north_east),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Pemasukan'),
                      icon: Icon(Icons.south_west),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) =>
                      _changeType(selection.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    hintText: 'Contoh: Makan siang',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    final amount = parseRupiah(value ?? '');
                    if (amount == null || amount <= 0) {
                      return 'Masukkan nominal yang valid (> 0)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Kategori',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in kCategories[_type]!)
                      ChoiceChip(
                        avatar: Icon(iconForCategory(c), size: 18),
                        label: Text(c),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Tanggal'),
                  subtitle: Text(formatDate(_date)),
                  trailing: TextButton(
                    onPressed: _pickDate,
                    child: const Text('Ubah'),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
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
