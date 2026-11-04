import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Memotong pinggiran widget menjadi bergelombang (scallop),
/// seperti pinggiran kue atau perangko.
class ScallopClipper extends CustomClipper<Path> {
  const ScallopClipper({
    this.radius = 12,
    this.top = false,
    this.bottom = true,
    this.cornerRadius = 28,
  });

  final double radius; // ukuran gelombang
  final bool top;
  final bool bottom;
  final double cornerRadius; // sudut bulat di sisi yang tidak bergelombang

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final count = math.max(1, (w / (radius * 2)).floor());
    final seg = w / count;
    final r = seg / 2;
    final path = Path();

    // Sisi atas
    if (top) {
      path.moveTo(0, r);
      for (var i = 0; i < count; i++) {
        path.arcToPoint(
          Offset((i + 1) * seg, r),
          radius: Radius.circular(r),
          clockwise: true,
        );
      }
    } else {
      path.moveTo(0, cornerRadius);
      path.quadraticBezierTo(0, 0, cornerRadius, 0);
      path.lineTo(w - cornerRadius, 0);
      path.quadraticBezierTo(w, 0, w, cornerRadius);
    }

    // Sisi bawah
    if (bottom) {
      path.lineTo(w, h - r);
      for (var i = count - 1; i >= 0; i--) {
        path.arcToPoint(
          Offset(i * seg, h - r),
          radius: Radius.circular(r),
          clockwise: true,
        );
      }
    } else {
      path.lineTo(w, h - cornerRadius);
      path.quadraticBezierTo(w, h, w - cornerRadius, h);
      path.lineTo(cornerRadius, h);
      path.quadraticBezierTo(0, h, 0, h - cornerRadius);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(ScallopClipper oldClipper) =>
      oldClipper.radius != radius ||
      oldClipper.top != top ||
      oldClipper.bottom != bottom;
}

/// Garis berliku kecil (hiasan di bawah judul).
class Squiggle extends StatelessWidget {
  const Squiggle({
    super.key,
    this.color = AppColors.coral,
    this.width = 54,
  });

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, 10),
      painter: _SquigglePainter(color),
    );
  }
}

class _SquigglePainter extends CustomPainter {
  _SquigglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height / 2);
    const waves = 4;
    final step = size.width / waves;
    for (var i = 0; i < waves; i++) {
      final x = i * step;
      path.quadraticBezierTo(
        x + step / 4,
        i.isEven ? 0 : size.height,
        x + step / 2,
        size.height / 2,
      );
      path.quadraticBezierTo(
        x + step * 3 / 4,
        i.isEven ? size.height : 0,
        x + step,
        size.height / 2,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SquigglePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Judul seksi: teks serif + hiasan (opsional) + garis berliku di bawahnya.
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.text, {
    super.key,
    this.decoration,
    this.action,
    this.squiggleColor = AppColors.coral,
  });

  final String text;
  final Widget? decoration; // misalnya Sticker kecil
  final Widget? action; // misalnya tombol di kanan
  final Color squiggleColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: AppFonts.title,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.rose : AppColors.wineDark,
                      ),
                    ),
                  ),
                  if (decoration != null) ...[
                    const SizedBox(width: 6),
                    decoration!,
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Squiggle(color: squiggleColor),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
