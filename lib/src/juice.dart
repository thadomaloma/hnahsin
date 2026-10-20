import 'dart:math';

import 'package:flutter/material.dart';

import 'app_text.dart';
import 'emoji_assets.dart';
import 'game_sounds.dart';
import 'theme.dart';

/// Small motions that make a round feel alive. Each one stands still with
/// reduced motion.
bool _still(BuildContext context) => MediaQuery.disableAnimationsOf(context);

/// [child] grows in with a little overshoot the first time it builds: a
/// new question's picture, a letter just typed. Give it a new key to play
/// again.
class PopIn extends StatelessWidget {
  const PopIn(
      {super.key,
      required this.child,
      this.from = .6,
      this.delay = Duration.zero,
      this.duration = const Duration(milliseconds: 420)});

  final Widget child;
  final double from;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (_still(context)) return child;
    final total = delay + duration;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (context, t, child) {
        final local = ((t - start) / (1 - start)).clamp(0, 1).toDouble();
        final grow = Curves.easeOutBack.transform(local);
        return Opacity(
          opacity: Curves.easeOut.transform(local),
          child: Transform.scale(scale: from + (1 - from) * grow, child: child),
        );
      },
      child: child,
    );
  }
}

/// [child] slides up into place, [index] steps after the first: a list of
/// answers arriving one by one.
class SlideIn extends StatelessWidget {
  const SlideIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (_still(context)) return child;
    const step = 70;
    const each = 320;
    final total = index * step + each;
    final start = index * step / total;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      builder: (context, t, child) {
        final local = Curves.easeOutCubic
            .transform(((t - start) / (1 - start)).clamp(0, 1).toDouble());
        return Opacity(
          opacity: local,
          child: Transform.translate(
              offset: Offset(0, 22 * (1 - local)), child: child),
        );
      },
      child: child,
    );
  }
}

/// Shakes [child] side to side each time [trigger] changes: a try that
/// isn't accepted.
class Shake extends StatefulWidget {
  const Shake({super.key, required this.trigger, required this.child});

  final Object trigger;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && !_still(context)) {
      _time.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _time,
        builder: (context, child) {
          final t = _time.value;
          return Transform.translate(
              offset: Offset(10 * sin(t * pi * 6) * (1 - t), 0), child: child);
        },
        child: widget.child,
      );
}

/// A happy hop with a ring of sparkles when [active] turns true: the
/// picture of a word just named right.
class Cheer extends StatefulWidget {
  const Cheer({super.key, required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<Cheer> createState() => _CheerState();
}

class _CheerState extends State<Cheer> with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didUpdateWidget(Cheer old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active && !_still(context)) {
      _time.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _time,
        builder: (context, child) {
          final t = _time.value;
          final hop = t < .45 ? sin(pi * t / .45) : 0.0;
          return CustomPaint(
            foregroundPainter: t > 0 && t < 1 ? _SparklePainter(t) : null,
            child: Transform.translate(
              offset: Offset(0, -16 * hop),
              child: Transform.rotate(
                  angle: .08 * sin(t * pi * 4) * (1 - t),
                  child: Transform.scale(scale: 1 + .12 * hop, child: child)),
            ),
          );
        },
        child: widget.child,
      );
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.t);
  final double t;

  static const _colors = [
    QuestColors.gold,
    QuestColors.success,
    QuestColors.indigoBright,
    QuestColors.goldDeep,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final reach = size.shortestSide * .35 + 70 * Curves.easeOut.transform(t);
    final fade = (1 - t).clamp(0, 1).toDouble();
    for (var i = 0; i < 12; i++) {
      final angle = i * pi / 6 + .3;
      final at = centre + Offset(cos(angle), sin(angle)) * reach;
      final paint = Paint()
        ..color = _colors[i % _colors.length].withValues(alpha: fade);
      final r = (i.isEven ? 6.0 : 4.0) * (1 - t * .5);
      // A four-pointed star.
      final path = Path()
        ..moveTo(at.dx, at.dy - r * 1.8)
        ..lineTo(at.dx + r * .5, at.dy - r * .5)
        ..lineTo(at.dx + r * 1.8, at.dy)
        ..lineTo(at.dx + r * .5, at.dy + r * .5)
        ..lineTo(at.dx, at.dy + r * 1.8)
        ..lineTo(at.dx - r * .5, at.dy + r * .5)
        ..lineTo(at.dx - r * 1.8, at.dy)
        ..lineTo(at.dx - r * .5, at.dy - r * .5)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.t != t;
}

/// “+10” floating up from a score that just grew.
class ScoreFloat extends StatefulWidget {
  const ScoreFloat({super.key, required this.score, required this.child});

  final int score;
  final Widget child;

  @override
  State<ScoreFloat> createState() => _ScoreFloatState();
}

class _ScoreFloatState extends State<ScoreFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  int gained = 0;

  @override
  void didUpdateWidget(ScoreFloat old) {
    super.didUpdateWidget(old);
    if (widget.score > old.score && !_still(context)) {
      gained = widget.score - old.score;
      _time.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _time,
            builder: (context, _) {
              final t = _time.value;
              if (t == 0 || t == 1) return const SizedBox.shrink();
              return Positioned(
                bottom: 28 + 26 * Curves.easeOut.transform(t),
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (1 - t * t).clamp(0, 1).toDouble(),
                    child: Text('+$gained',
                        style: const TextStyle(
                            color: QuestColors.gold,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            shadows: [
                              Shadow(color: Color(0x66000000), blurRadius: 4)
                            ])),
                  ),
                ),
              );
            },
          ),
        ],
      );
}

/// A banner across the screen when right answers run 3, 5 or 10 (and every
/// 5 after) in a row.
class ComboCheer extends StatefulWidget {
  const ComboCheer({super.key, required this.combo, required this.child});

  final int combo;
  final Widget child;

  /// Whether [combo] right answers in a row deserve a cheer.
  static bool milestone(int combo) =>
      combo == 3 || combo == 5 || (combo >= 10 && combo % 5 == 0);

  static String textFor(int combo) => AppText.of(
      combo >= 10
          ? 'cheer.streak10'
          : combo >= 5
              ? 'cheer.streak5'
              : 'cheer.streak3',
      {'n': combo});

  @override
  State<ComboCheer> createState() => _ComboCheerState();
}

class _ComboCheerState extends State<ComboCheer> {
  OverlayEntry? _entry;

  @override
  void didUpdateWidget(ComboCheer old) {
    super.didUpdateWidget(old);
    if (widget.combo > old.combo && ComboCheer.milestone(widget.combo)) {
      GameSounds.play(GameSound.match);
      // Not while building: the banner goes in once this frame is drawn.
      final combo = widget.combo;
      if (!_still(context)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _show(combo);
        });
      }
    }
  }

  void _show(int combo) {
    _entry?.remove();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ComboBanner(
        text: ComboCheer.textFor(combo),
        big: combo >= 5,
        onDone: () {
          if (_entry == entry) _entry = null;
          if (entry.mounted) entry.remove();
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  @override
  void dispose() {
    if (_entry?.mounted ?? false) _entry!.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ComboBanner extends StatefulWidget {
  const _ComboBanner(
      {required this.text, required this.big, required this.onDone});

  final String text;
  final bool big;
  final VoidCallback onDone;

  @override
  State<_ComboBanner> createState() => _ComboBannerState();
}

class _ComboBannerState extends State<_ComboBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300))
    ..forward().whenComplete(() {
      if (mounted) widget.onDone();
    });

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Align(
          alignment: const Alignment(0, -.25),
          child: AnimatedBuilder(
            animation: _time,
            builder: (context, child) {
              final t = _time.value;
              final grow = Curves.elasticOut.transform((t / .4).clamp(0, 1));
              final fade = t < .8 ? 1.0 : (1 - (t - .8) / .2);
              return Opacity(
                opacity: fade.clamp(0, 1).toDouble(),
                child: Transform.rotate(
                  angle: -.05,
                  child: Transform.scale(scale: .4 + .6 * grow, child: child),
                ),
              );
            },
            // Never wider than the screen, in any language.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: widget.big
                              ? const [Color(0xFFFF7A3D), QuestColors.coral]
                              : const [
                                  QuestColors.goldDeep,
                                  Color(0xFFFF9A3D)
                                ]),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x55000000),
                            blurRadius: 18,
                            offset: Offset(0, 8)),
                      ],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      EmojiImage('🔥', size: widget.big ? 34 : 28),
                      const SizedBox(width: 8),
                      Text(widget.text,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: widget.big ? 22 : 19)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/// [value] counting up from zero, for a result's score and XP.
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, this.prefix = '', this.style});

  final int value;
  final String prefix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.toDouble()),
        duration: motionFor(context, const Duration(milliseconds: 900)),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => Text('$prefix${v.round()}', style: style),
      );
}
