/// Jenis transaksi menggunakan enhanced enum (Dart 2.17+).
/// Setiap nilai enum punya label berbahasa Indonesia untuk ditampilkan di UI.
enum TransactionType {
  income('Pemasukan'),
  expense('Pengeluaran');

  const TransactionType(this.label);

  final String label;
}

/// Model data satu transaksi keuangan.
///
/// Field dibuat `final` (immutable). Untuk mengubah data, kita membuat objek
/// baru lewat [copyWith]. Pola ini membuat perubahan state lebih mudah dilacak.
class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  final String id;
  final String title;
  final int amount; // dalam Rupiah, selalu positif
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note; // null safety: catatan boleh kosong

  bool get isIncome => type == TransactionType.income;

  /// Nilai bertanda: positif untuk pemasukan, negatif untuk pengeluaran.
  int get signedAmount => isIncome ? amount : -amount;

  Transaction copyWith({
    String? title,
    int? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  /// Object -> Map (lalu di-encode menjadi JSON untuk disimpan lokal).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  /// Map hasil jsonDecode -> Object.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toInt(),
      type: TransactionType.values.byName(json['type'] as String),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }
}
