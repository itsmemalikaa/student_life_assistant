import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Stiker hiasan yang melayang pelan naik-turun.
/// Ketuk stikernya untuk membuatnya "pop" dan berputar.
/// [name]: bow, heart, sparkle, flower, letter
class Sticker extends StatefulWidget {
  const Sticker(
    this.name, {
    super.key,
    this.size = 40,
    this.angle = 0,
    this.floatDistance = 4,
    this.period = const Duration(milliseconds: 2600),
  });

  final String name;
  final double size;
  final double angle; // kemiringan dasar (radian)
  final double floatDistance;
  final Duration period;

  @override
  State<Sticker> createState() => _StickerState();
}

class _StickerState extends State<Sticker> with TickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat(reverse: true);

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void dispose() {
    _float.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pop.forward(from: 0),
      child: AnimatedBuilder(
        animation: Listenable.merge([_float, _pop]),
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_float.value);
          final p = math.sin(math.pi * _pop.value); // 0 -> 1 -> 0
          return Transform.translate(
            offset: Offset(0, -widget.floatDistance * t - 6 * p),
            child: Transform.rotate(
              angle: widget.angle + 0.06 * (t - 0.5) + 2 * math.pi * _pop.value,
              child: Transform.scale(scale: 1 + 0.35 * p, child: child),
            ),
          );
        },
        child: Image.asset(
          'assets/images/sticker_${widget.name}.png',
          width: widget.size,
          height: widget.size,
        ),
      ),
    );
  }
}

/// Animasi masuk: konten muncul pelan sambil naik sedikit.
/// [order] membuat beberapa bagian muncul berurutan (stagger).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.order, required this.child});

  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const base = 450;
    final delay = order * 90;
    final total = base + delay;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

const _quotes = [
  'Pelan-pelan asal selesai. Kamu pasti bisa!',
  'Satu tugas selesai = satu langkah lebih dekat ke liburan.',
  'Jangan lupa minum air dan istirahat sebentar ya.',
  'Hari ini cukup lakukan yang terbaik, bukan yang sempurna.',
  'Bangga sama kamu yang tetap berusaha.',
];

/// Postcard di beranda. Ketuk kartunya untuk membalik (animasi 3D)
/// dan membaca pesan semangat di baliknya.
class PostcardBanner extends StatefulWidget {
  const PostcardBanner({super.key, required this.name});

  final String name;

  @override
  State<PostcardBanner> createState() => _PostcardBannerState();
}

class _PostcardBannerState extends State<PostcardBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  int _quoteIndex = 0;
  bool _showBack = false;

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_flip.isAnimating) return;
    if (_showBack) {
      _flip.reverse();
    } else {
      setState(() => _quoteIndex = (_quoteIndex + 1) % _quotes.length);
      _flip.forward();
    }
    _showBack = !_showBack;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Pesan kecil untukmu',
              style: TextStyle(
                fontFamily: AppFonts.script,
                  fontWeight: FontWeight.w700,
                fontSize: 24,
                color: AppColors.wineDark,
              ),
            ),
            SizedBox(width: 6),
            Sticker('letter', size: 30, floatDistance: 3),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Ketuk kartunya untuk membalik',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        // Lebar kartu dibatasi supaya tidak terlalu besar di layar lebar.
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: _buildCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedBuilder(
                  animation: _flip,
                  builder: (context, _) {
                    final angle =
                        Curves.easeInOutBack.transform(_flip.value) * math.pi;
                    final isBack = angle > math.pi / 2;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(angle)
                        ..rotateZ(-0.03),
                      child: AspectRatio(
                        aspectRatio: 800 / 614,
                        child: isBack
                            ? Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: _PostcardBack(
                                  name: widget.name,
                                  quote: _quotes[_quoteIndex],
                                ),
                              )
                            : Image.asset(
                                'assets/images/postcard.png',
                                fit: BoxFit.contain,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Positioned(
              left: -6,
              top: -10,
              child: Sticker('bow', size: 56, angle: -0.35),
            ),
            const Positioned(
              right: -2,
              bottom: -8,
              child: Sticker(
                'heart',
                size: 44,
                angle: 0.25,
                period: Duration(milliseconds: 2200),
              ),
            ),
          ],
        );
  }
}

class _PostcardBack extends StatelessWidget {
  const _PostcardBack({required this.name, required this.quote});

  final String name;
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.rose,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEDD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Sticker('flower', size: 40),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Semangat, $name!',
                style: const TextStyle(
                  fontFamily: AppFonts.script,
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  color: AppColors.wine,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              quote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.title,
                fontSize: 15,
                color: AppColors.ink,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
