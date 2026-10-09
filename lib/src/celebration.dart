import 'dart:math';

import 'package:flutter/material.dart';

import 'theme.dart';

/// A burst of confetti falling over its area once, for a finished round.
/// Nothing shows with reduced motion.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, this.pieces = 70, this.seed = 7});

  final int pieces;
  final int seed;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200));
  late final List<_Piece> _pieces;

  static const _colors = <Color>[
    QuestColors.gold,
    QuestColors.goldDeep,
    QuestColors.teal,
    QuestColors.success,
    QuestColors.coral,
    QuestColors.violet,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    final random = Random(widget.seed);
    _pieces = [
      for (var i = 0; i < widget.pieces; i++)
        _Piece(
          // From the top centre, thrown out and up, then falling.
          x: .5 + (random.nextDouble() - .5) * .3,
          vx: (random.nextDouble() - .5) * 1.4,
          vy: -.2 - random.nextDouble() * .4,
          spin: (random.nextDouble() - .5) * 18,
          size: 5 + random.nextDouble() * 6,
          color: _colors[random.nextInt(_colors.length)],
          delay: random.nextDouble() * .15,
          round: random.nextDouble() < .3,
        ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _time.stop();
    } else if (!_time.isAnimating && _time.value == 0) {
      _time.forward();
    }
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ConfettiPainter(_pieces, _time),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.vx,
    required this.vy,
    required this.spin,
    required this.size,
    required this.color,
    required this.delay,
    required this.round,
  });

  final double x, vx, vy, spin, size, delay;
  final Color color;
  final bool round;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.time) : super(repaint: time);

  final List<_Piece> pieces;
  final Animation<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in pieces) {
      final t =
          ((time.value - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;
      // Seconds of flight, with gravity pulling the piece down.
      final s = t * 2.2;
      final dx = (piece.x + piece.vx * s * .45) * size.width;
      final dy = (.18 + piece.vy * s + .45 * s * s) * size.height;
      final fade = t > .75 ? (1 - t) / .25 : 1.0;
      paint.color = piece.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(piece.spin * s);
      if (piece.round) {
        canvas.drawCircle(Offset.zero, piece.size / 2.4, paint);
      } else {
        // A flat strip that seems to turn over as it falls.
        final turn = cos(piece.spin * s * 1.7).abs() * .8 + .2;
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero,
                width: piece.size,
                height: piece.size * .55 * turn),
            paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.pieces != pieces;
}

/// Plays a quick pop when [trigger] changes, for a value that just went up
/// (a score, a combo).
class PopOnChange extends StatefulWidget {
  const PopOnChange({super.key, required this.trigger, required this.child});

  final Object trigger;
  final Widget child;

  @override
  State<PopOnChange> createState() => _PopOnChangeState();
}

class _PopOnChangeState extends State<PopOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));

  @override
  void didUpdateWidget(PopOnChange old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger &&
        !MediaQuery.disableAnimationsOf(context)) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _pop,
        builder: (context, child) => Transform.scale(
            scale: 1 + .22 * sin(pi * Curves.easeOut.transform(_pop.value)),
            child: child),
        child: widget.child,
      );
}
