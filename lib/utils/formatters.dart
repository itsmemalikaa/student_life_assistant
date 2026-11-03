// Fungsi-fungsi bantu format tampilan (tanpa package tambahan).

const List<String> _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// 1500000 -> "Rp 1.500.000", -25000 -> "-Rp 25.000"
String formatRupiah(num value) {
  final isNegative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final positionFromRight = digits.length - i;
    buffer.write(digits[i]);
    if (positionFromRight > 1 && positionFromRight % 3 == 1) {
      buffer.write('.');
    }
  }

  return '${isNegative ? '-' : ''}Rp ${buffer.toString()}';
}

/// DateTime -> "3 Nov 2026"
String formatDate(DateTime date) {
  return '${date.day} ${_bulan[date.month - 1]} ${date.year}';
}

/// Mengubah teks input "1.500.000" atau "1500000" menjadi int.
/// Mengembalikan null jika tidak valid (null safety).
int? parseRupiah(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) return null;
  return int.tryParse(cleaned);
}
