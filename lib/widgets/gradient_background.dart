import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Latar belakang gradasi lembut untuk seluruh aplikasi.
/// Ada tiga "gelembung" warna yang bergerak sangat pelan
/// supaya tampilan terasa hidup.
class GradientBackground extends StatefulWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColors = isDark
        ? const [Color(0xFF1F0A15), Color(0xFF2A0F20), Color(0xFF241024)]
        : const [Color(0xFFFFF0F5), Color(0xFFFDE2EE), Color(0xFFF9E8F3)];
    final blobColors = isDark
        ? const [Color(0x55A82A5E), Color(0x44D94680), Color(0x33E8C8F0)]
        : const [Color(0x99F8C8DA), Color(0x66F2849E), Color(0x55E8C8F0)];

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: baseColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value * 2 * math.pi;
            return Stack(
              fit: StackFit.expand,
              children: [
                _Blob(
                  color: blobColors[0],
                  alignment: Alignment(-0.9 + 0.25 * math.sin(t), -0.8),
                  size: 340,
                ),
                _Blob(
                  color: blobColors[1],
                  alignment: Alignment(0.9, -0.1 + 0.2 * math.cos(t)),
                  size: 280,
                ),
                _Blob(
                  color: blobColors[2],
                  alignment: Alignment(-0.5 + 0.2 * math.cos(t), 0.95),
                  size: 360,
                ),
              ],
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.alignment,
    required this.size,
  });

  final Color color;
  final Alignment alignment;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withAlpha(0)],
            ),
          ),
        ),
      ),
    );
  }
}

/// Teks dengan warna gradasi yang berkilau pelan.
class GradientText extends StatefulWidget {
  const GradientText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<GradientText> createState() => _GradientTextState();
}

class _GradientTextState extends State<GradientText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shift = -1 + 2 * _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(shift - 1, 0),
            end: Alignment(shift + 1, 0),
            colors: const [
              AppColors.wineDark,
              AppColors.wine,
              AppColors.coral,
              AppColors.wine,
            ],
            tileMode: TileMode.mirror,
          ).createShader(bounds),
          child: child,
        );
      },
      child: Text(widget.text, style: widget.style),
    );
  }
}
