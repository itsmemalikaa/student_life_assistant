import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/categories.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Warna tiap potongan diagram (mengikuti palet aplikasi).
const _sliceColors = [
  AppColors.wine,
  AppColors.sage,
  AppColors.mustard,
  AppColors.wineDark,
  AppColors.rose,
  AppColors.coral,
  Color(0xFFE8C8F0),
  AppColors.forest,
  Color(0xFFC77DA8),
];

/// Diagram lingkaran (donat) pengeluaran per kategori + keterangannya.
/// Dibuat sendiri dengan CustomPainter, tanpa package tambahan.
class ExpenseDonutChart extends StatelessWidget {
  const ExpenseDonutChart({super.key, required this.data});

  /// Kategori -> total pengeluaran, sudah diurutkan dari yang terbesar.
  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Belum ada pengeluaran untuk ditampilkan.')),
      );
    }

    final entries = data.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final values = [for (final e in entries) e.value / total];
    final colors = [
      for (var i = 0; i < entries.length; i++)
        _sliceColors[i % _sliceColors.length],
    ];

    // Lingkaran digambar perlahan (animasi) setiap kali total berubah.
    final donut = TweenAnimationBuilder<double>(
      key: ValueKey(total),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) => SizedBox(
        width: 170,
        height: 170,
        child: CustomPaint(
          painter: _DonutPainter(
            values: values,
            colors: colors,
            progress: progress,
            trackColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    child: Text(
                      formatRupiah(total),
                      style: const TextStyle(
                        fontFamily: AppFonts.title,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final legend = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    iconForCategory(entries[i].key),
                    size: 16,
                    color: const {0, 3, 5, 7, 8}
                            .contains(i % _sliceColors.length)
                        ? Colors.white
                        : AppColors.ink,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entries[i].key,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${(values[i] * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: AppFonts.title,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 92,
                  child: Text(
                    formatRupiah(entries[i].value),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    // Responsif: berdampingan di layar lebar, bertumpuk di HP.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 480) {
          return Row(
            children: [
              donut,
              const SizedBox(width: 24),
              Expanded(child: legend),
            ],
          );
        }
        return Column(
          children: [
            donut,
            const SizedBox(height: 16),
            legend,
          ],
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.values,
    required this.colors,
    required this.progress,
    required this.trackColor,
  });

  final List<double> values; // persentase 0..1, total = 1
  final List<Color> colors;
  final double progress; // 0..1 untuk animasi
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 26.0;
    const gap = 0.04; // jarak kecil antar potongan (radian)
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: math.min(size.width, size.height) / 2 - stroke / 2,
    );

    // Lingkaran dasar
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    final visibleTotal = 2 * math.pi * progress;
    var start = 0.0;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] * 2 * math.pi;
      final visible = (visibleTotal - start).clamp(0.0, sweep).toDouble();
      final drawn = values.length > 1 ? visible - gap : visible;
      if (drawn > 0) {
        canvas.drawArc(
          rect,
          -math.pi / 2 + start,
          drawn,
          false,
          Paint()
            ..color = colors[i]
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.butt,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.values != values ||
        oldDelegate.colors != colors;
  }
}
