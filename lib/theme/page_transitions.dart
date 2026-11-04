import 'package:flutter/material.dart';

/// Transisi halaman yang halus: halaman baru muncul pelan (fade)
/// sambil naik sedikit, halaman lama memudar (crossfade).
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeIn = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    final slideUp = animation.drive(
      Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
    );
    final dimOut = secondaryAnimation.drive(
      Tween<double>(begin: 1, end: 0)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
    );

    return FadeTransition(
      opacity: fadeIn,
      child: SlideTransition(
        position: slideUp,
        child: FadeTransition(opacity: dimOut, child: child),
      ),
    );
  }
}
