import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class NavItem {
  const NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Navigasi bawah dengan lekukan (notch). Tab aktif naik menjadi
/// lingkaran berwarna dan bergeser dengan animasi saat tab berganti.
class NotchNavBar extends StatelessWidget {
  const NotchNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const double _barTop = 34; // jarak lingkaran di atas bar
  static const double _height = 112;

  @override
  Widget build(BuildContext context) {
    final barColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;

          // Animasi posisi lingkaran dari tab lama ke tab baru.
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(end: selectedIndex.toDouble()),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, position, _) {
              final centerX = (position + 0.5) * itemWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bar putih dengan lekukan
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NotchPainter(
                        centerX: centerX,
                        barTop: _barTop,
                        color: barColor,
                      ),
                    ),
                  ),
                  // Lingkaran tab aktif
                  Positioned(
                    left: centerX - 30,
                    top: 4,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppColors.wine,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66D94680),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        items[selectedIndex].icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  // Ikon & label tiap tab
                  Positioned.fill(
                    child: Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: GestureDetector(
                              key: ValueKey('nav-$i'),
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onSelect(i),
                              child: Column(
                                children: [
                                  const SizedBox(height: 46),
                                  if (i == selectedIndex)
                                    const SizedBox(height: 26)
                                  else
                                    Icon(
                                      items[i].icon,
                                      color: const Color(0xFFB08A9C),
                                      size: 26,
                                    ),
                                  const SizedBox(height: 6),
                                  Text(
                                    items[i].label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: i == selectedIndex
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: i == selectedIndex
                                          ? onSurface
                                          : const Color(0xFFB08A9C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Menggambar bar bersudut bulat lalu "melubangi" bagian atasnya
/// dengan lingkaran di posisi tab aktif.
class _NotchPainter extends CustomPainter {
  _NotchPainter({
    required this.centerX,
    required this.barTop,
    required this.color,
  });

  final double centerX;
  final double barTop;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final bar = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, barTop, size.width, size.height - barTop),
          const Radius.circular(28),
        ),
      );
    final notch = Path()
      ..addOval(Rect.fromCircle(center: Offset(centerX, barTop), radius: 40));
    final shape = Path.combine(PathOperation.difference, bar, notch);

    canvas.drawShadow(shape, const Color(0x55A82A5E), 8, false);
    canvas.drawPath(shape, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_NotchPainter oldDelegate) {
    return oldDelegate.centerX != centerX || oldDelegate.color != color;
  }
}
