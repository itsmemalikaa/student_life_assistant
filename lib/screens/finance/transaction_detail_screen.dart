import 'package:flutter/material.dart';

import '../../data/categories.dart';
import '../../models/transaction.dart';
import '../../state/transaction_controller.dart';
import '../../utils/formatters.dart';
import 'transaction_form_screen.dart';

/// Halaman detail. Data transaksi DIKIRIM dari halaman sebelumnya
/// melalui constructor (pengiriman data antar halaman).
class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.controller,
  });

  final Transaction transaction;
  final TransactionController controller;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Transaction _transaction = widget.transaction;

  Future<void> _edit() async {
    // Menunggu hasil dari halaman form (data dikirim balik lewat pop).
    final updated = await Navigator.of(context).push<Transaction>(
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(initial: _transaction),
      ),
    );
    if (updated == null) return;

    await widget.controller.update(updated);
    if (!mounted) return;
    setState(() => _transaction = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi diperbarui')),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: Text('"${_transaction.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await widget.controller.delete(_transaction.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = _transaction;
    final colors = Theme.of(context).colorScheme;
    final amountColor = t.isIncome ? Colors.green.shade600 : colors.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: t.isIncome
                    ? colors.primaryContainer
                    : colors.errorContainer,
                child: Icon(iconForCategory(t.category), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                t.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '${t.isIncome ? '+' : '-'} ${formatRupiah(t.amount)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.swap_vert),
                      title: const Text('Jenis'),
                      trailing: Text(t.type.label),
                    ),
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Kategori'),
                      trailing: Text(t.category),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Tanggal'),
                      trailing: Text(formatDate(t.date)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.notes),
                      title: const Text('Catatan'),
                      subtitle: Text(
                        (t.note == null || t.note!.isEmpty) ? '-' : t.note!,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
