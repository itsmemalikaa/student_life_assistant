import 'package:flutter/material.dart';

import '../data/categories.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Reusable widget untuk menampilkan satu baris transaksi.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onTap});

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final amountColor =
        transaction.isIncome ? Colors.green.shade600 : colors.error;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: transaction.isIncome
            ? colors.primaryContainer
            : colors.errorContainer,
        foregroundColor: transaction.isIncome
            ? colors.onPrimaryContainer
            : colors.onErrorContainer,
        child: Icon(iconForCategory(transaction.category)),
      ),
      title: Text(
        transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${transaction.category} • ${formatDate(transaction.date)}',
      ),
      trailing: Text(
        '${transaction.isIncome ? '+' : '-'} '
        '${formatRupiah(transaction.amount)}',
        style: TextStyle(color: amountColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
