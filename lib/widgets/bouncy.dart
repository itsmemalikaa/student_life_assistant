import 'package:flutter/material.dart';

/// Efek "membal": widget mengecil sedikit saat ditekan, lalu kembali.
/// Memakai Listener sehingga tidak mengganggu onTap milik widget di dalamnya.
class Bouncy extends StatefulWidget {
  const Bouncy({super.key, required this.child, this.scale = 0.95});

  final Widget child;
  final double scale;

  @override
  State<Bouncy> createState() => _BouncyState();
}

class _BouncyState extends State<Bouncy> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
