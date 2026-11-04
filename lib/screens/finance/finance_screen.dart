import 'package:flutter/material.dart';

import '../../models/transaction.dart';
import '../../state/transaction_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/expense_donut.dart';
import '../../widgets/shapes.dart';
import '../../widgets/state_views.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';

/// Fitur ciri khas versi Malika: catatan keuangan mahasiswa.
class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key, required this.controller});

  final TransactionController controller;

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  TransactionType? _filter; // local state: null = semua

  Future<void> _delete(Transaction t) async {
    await widget.controller.delete(t.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${t.title}" dihapus'),
          action: SnackBarAction(
            label: 'URUNGKAN',
            onPressed: () => widget.controller.add(t),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Keuangan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openTransactionForm(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Catat'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.isLoading) return const LoadingView();
            if (controller.errorMessage != null) {
              return ErrorView(
                message: controller.errorMessage!,
                onRetry: controller.load,
              );
            }
            return _buildContent(context);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final controller = widget.controller;
    final colors = Theme.of(context).colorScheme;
    final items = controller.items
        .where((t) => _filter == null || t.type == _filter)
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            ClipPath(
              clipper: const ScallopClipper(radius: 10),
              child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
              color: AppColors.wine,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Saldo', style: TextStyle(color: AppColors.rose)),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatRupiah(controller.balance),
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontFamily: AppFonts.title,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    icon: Icons.south_west,
                    label: 'Pemasukan',
                    value: formatRupiah(controller.totalIncome),
                    color: Colors.green.shade600,
                  ),
                ),
                Expanded(
                  child: SummaryCard(
                    icon: Icons.north_east,
                    label: 'Pengeluaran',
                    value: formatRupiah(controller.totalExpense),
                    color: colors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Diagram lingkaran pengeluaran per kategori
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.donut_large_rounded,
                            color: AppColors.wine),
                        SizedBox(width: 8),
                        Text(
                          'Pengeluaran per kategori',
                          style: TextStyle(
                            fontFamily: AppFonts.title,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ExpenseDonutChart(data: controller.expenseByCategory),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                for (final type in TransactionType.values)
                  ChoiceChip(
                    label: Text(type.label),
                    selected: _filter == type,
                    onSelected: (_) => setState(() => _filter = type),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: EmptyView(
                  icon: Icons.receipt_long,
                  title: 'Belum ada transaksi',
                  subtitle: 'Tekan tombol "Catat" untuk menambahkan.',
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (final t in items)
                      Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: colors.error,
                          child: Icon(Icons.delete, color: colors.onError),
                        ),
                        onDismissed: (_) => _delete(t),
                        child: TransactionTile(
                          transaction: t,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TransactionDetailScreen(
                                transaction: t,
                                controller: controller,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
