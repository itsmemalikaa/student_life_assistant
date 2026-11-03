import 'package:flutter/material.dart';

import '../models/transaction.dart';

/// Daftar kategori per jenis transaksi (Collections: Map & List).
const Map<TransactionType, List<String>> kCategories = {
  TransactionType.expense: [
    'Makan & Minum',
    'Transportasi',
    'Kuliah',
    'Belanja',
    'Hiburan',
    'Tagihan',
    'Lainnya',
  ],
  TransactionType.income: [
    'Uang Saku',
    'Freelance',
    'Beasiswa',
    'Hadiah',
    'Lainnya',
  ],
};

const Map<String, IconData> _categoryIcons = {
  'Makan & Minum': Icons.restaurant,
  'Transportasi': Icons.directions_bus,
  'Kuliah': Icons.school,
  'Belanja': Icons.shopping_bag,
  'Hiburan': Icons.movie,
  'Tagihan': Icons.receipt_long,
  'Uang Saku': Icons.account_balance_wallet,
  'Freelance': Icons.laptop_mac,
  'Beasiswa': Icons.workspace_premium,
  'Hadiah': Icons.card_giftcard,
};

IconData iconForCategory(String category) {
  return _categoryIcons[category] ?? Icons.category;
}
