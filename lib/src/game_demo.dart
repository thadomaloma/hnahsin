import 'dart:math';

import 'package:flutter/material.dart';

import 'theme.dart';

/// A few seconds of a game playing itself, on a loop: a hand taps where a
/// player would, so the launcher shows how to play without much reading
/// (most useful to young children). With reduced motion it shows the
/// finished move, still.
class GameDemo extends StatefulWidget {
  const GameDemo({super.key, required this.gameId});

  final String gameId;

  /// Games that have a demo.
  static bool covers(String gameId) => _demos.containsKey(gameId);

  @override
  State<GameDemo> createState() => _GameDemoState();
}

class _GameDemoState extends State<GameDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _time
        ..stop()
        ..value = .8;
    } else if (!_time.isAnimating) {
      _time.repeat();
    }
  }

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final demo = _demos[widget.gameId];
    if (demo == null) return const SizedBox.shrink();
    return ExcludeSemantics(
      child: Container(
        height: 156,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.all(8),
        child: FittedBox(
          child: SizedBox(
            width: _size.width,
            height: _size.height,
            child: AnimatedBuilder(
              animation: _time,
              builder: (context, _) {
                final t = _time.value;
                return Stack(clipBehavior: Clip.none, children: [
                  ...demo.frame(t),
                  _Hand(
                      position: demo.handAt(t),
                      pressed: demo.pressedAt(t),
                      opacity: demo.handOpacity(t)),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }
}

const _size = Size(300, 140);

/// One game's demo: where the hand taps and when, and what the board looks
/// like at each moment of the loop (0–1).
class _Demo {
  const _Demo({required this.taps, required this.frame});

  /// (time, point) for each tap, in order.
  final List<(double, Offset)> taps;
  final List<Widget> Function(double t) frame;

  /// Where the hand waits before its first tap: just below and right of
  /// it, inside the board.
  Offset get _rest {
    final first = taps.first.$2;
    return Offset(min(first.dx + 36, _size.width - 22),
        min(first.dy + 28, _size.height - 32));
  }

  static const _travel = .14;

  /// How many taps have landed by [t].
  int tapsBy(double t) => taps.where((tap) => t >= tap.$1).length;

  Offset handAt(double t) {
    final first = taps.first;
    if (t < first.$1 - _travel) return _rest;
    for (var i = 0; i < taps.length; i++) {
      final (time, point) = taps[i];
      final from = i == 0 ? _rest : taps[i - 1].$2;
      final start = time - _travel;
      if (t < start) return from;
      if (t < time)
        return Offset.lerp(
            from, point, Curves.easeInOut.transform((t - start) / _travel))!;
    }
    return taps.last.$2;
  }

  bool pressedAt(double t) =>
      taps.any((tap) => t >= tap.$1 && t < tap.$1 + .05);

  double handOpacity(double t) {
    if (t < taps.first.$1 - _travel - .06)
      return ((t - .02) / .1).clamp(0, 1).toDouble();
    if (t > .82) return (1 - (t - .82) / .08).clamp(0, 1).toDouble();
    return 1;
  }
}

class _Hand extends StatelessWidget {
  const _Hand(
      {required this.position, required this.pressed, required this.opacity});
  final Offset position;
  final bool pressed;
  final double opacity;

  @override
  Widget build(BuildContext context) => Positioned(
        // The fingertip is near the icon's top centre.
        left: position.dx - 15,
        top: position.dy - 4,
        child: Opacity(
          opacity: opacity,
          child: AnimatedScale(
            scale: pressed ? .82 : 1,
            duration: const Duration(milliseconds: 90),
            child: const Icon(Icons.touch_app_rounded,
                size: 34,
                color: QuestColors.goldDeep,
                shadows: [
                  Shadow(
                      color: Color(0x55000000),
                      blurRadius: 6,
                      offset: Offset(0, 2)),
                ]),
          ),
        ),
      );
}

enum _Look { idle, picked, right }

/// A letter, word or option tile.
Widget _tile(String text, Offset at,
    {double width = 44,
    double height = 40,
    _Look look = _Look.idle,
    double fontSize = 17}) {
  final (fill, border, ink) = switch (look) {
    _Look.idle => (const Color(0xFFF2F8FD), QuestColors.line, QuestColors.ink),
    _Look.picked => (
        const Color(0xFFEAF6FF),
        QuestColors.indigo,
        QuestColors.indigo
      ),
    _Look.right => (
        const Color(0xFFE6F5E2),
        QuestColors.success,
        QuestColors.successInk
      ),
  };
  return Positioned(
    left: at.dx - width / 2,
    top: at.dy - height / 2,
    child: Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: look == _Look.idle ? 1.5 : 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: fontSize, fontWeight: FontWeight.w800, color: ink)),
    ),
  );
}

Widget _text(String text, Offset at,
        {double fontSize = 15,
        Color color = QuestColors.navy,
        FontWeight weight = FontWeight.w800}) =>
    Positioned(
      left: at.dx - 140,
      top: at.dy - 14,
      width: 280,
      child: Text(text,
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: fontSize, fontWeight: weight, color: color)),
    );

Widget _check(Offset at, double t, double from) => Positioned(
      left: at.dx - 13,
      top: at.dy - 13,
      child: Transform.scale(
        scale: Curves.elasticOut
            .transform(((t - from) / .18).clamp(0, 1).toDouble()),
        child: const CircleAvatar(
          radius: 13,
          backgroundColor: QuestColors.success,
          child: Icon(Icons.check_rounded, color: Colors.white, size: 18),
        ),
      ),
    );

/// The loop shows its result until here, then starts over.
const _reset = .9;

final _demos = <String, _Demo>{
  // A picture, three names: tap the right one.
  'picture_match':
      _choice(prompt: '💧', options: ['ar', 'tui', 'lui'], answer: 1),
  // A saying's meaning: tap the right line.
  'tawng_upa': _choice(
      prompt: '“Chibai!”',
      options: ['Hello', 'Rain', 'Hill'],
      answer: 0,
      promptSize: 26),
  'spelling': _spelling(),
  'word_search': _wordSearch(),
  'word_chain': _wordChain(),
  'crossword': _crossword(),
  'sentence_builder': _sentence(),
  // Two animals and a drink: tap the one that doesn't belong.
  'odd_one_out': _choice(
      prompt: '🐕  🐖  💧', options: ['ui', 'vawk', 'tui'], answer: 2, promptSize: 34),
};

_Demo _choice(
    {required String prompt,
    required List<String> options,
    required int answer,
    double promptSize = 46}) {
  const y = 106.0;
  final xs = [for (var i = 0; i < options.length; i++) 60.0 + i * 90];
  const tap = .45;
  return _Demo(
    taps: [(tap, Offset(xs[answer], y))],
    frame: (t) {
      final done = t >= tap && t < _reset;
      return [
        _text(prompt, const Offset(150, 34), fontSize: promptSize),
        for (final (i, option) in options.indexed)
          _tile(option, Offset(xs[i], y),
              width: 80, look: done && i == answer ? _Look.right : _Look.idle),
        if (done) _check(Offset(xs[answer] + 38, y - 20), t, tap),
      ];
    },
  );
}

_Demo _spelling() {
  const word = ['N', '_', 'L', 'A'];
  const options = ['E', 'U', 'O'];
  const tap = .45;
  return _Demo(
    taps: const [(tap, Offset(150, 108))],
    frame: (t) {
      final done = t >= tap && t < _reset;
      return [
        for (final (i, letter) in word.indexed)
          _tile(i == 1 && done ? 'U' : letter, Offset(84 + i * 44.0, 38),
              look: i == 1 ? (done ? _Look.right : _Look.picked) : _Look.idle),
        for (final (i, letter) in options.indexed)
          _tile(letter, Offset(106 + i * 44.0, 108)),
        if (done) _check(const Offset(256, 38), t, tap),
      ];
    },
  );
}

_Demo _wordSearch() {
  const rows = ['KAPZ', 'TUIR', 'MAWL'];
  Offset cell(int r, int c) => Offset(84 + c * 44.0, 26 + r * 44.0);
  final taps = [for (var c = 0; c < 3; c++) (.3 + c * .14, cell(1, c))];
  return _Demo(
    taps: taps,
    frame: (t) {
      final picked = taps.where((tap) => t >= tap.$1).length;
      final found = picked == 3 && t < _reset;
      return [
        for (var r = 0; r < rows.length; r++)
          for (var c = 0; c < 4; c++)
            _tile(rows[r][c], cell(r, c),
                look: r == 1 && c < picked && t < _reset
                    ? (found ? _Look.right : _Look.picked)
                    : _Look.idle),
        if (found) _check(cell(1, 3) + const Offset(36, 0), t, taps.last.$1),
      ];
    },
  );
}

_Demo _wordChain() {
  const start = .25;
  const send = .7;
  return _Demo(
    taps: const [(send, Offset(258, 104))],
    frame: (t) {
      final typed =
          t < _reset ? ((t - start) / .35 * 4).floor().clamp(0, 4) : 0;
      final done = t >= send && t < _reset;
      return [
        _tile('I', const Offset(40, 36)),
        _tile('N', const Offset(84, 36), look: _Look.picked),
        _text('→', const Offset(150, 36),
            fontSize: 24, color: QuestColors.slate),
        for (var i = 0; i < 4; i++)
          if (i < typed)
            _tile('NULA'[i], Offset(176 + i * 40.0, 36),
                width: 38,
                look:
                    done ? _Look.right : (i == 0 ? _Look.picked : _Look.idle)),
        Positioned(
          left: 30,
          top: 86,
          child: Container(
            width: 200,
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                color: const Color(0xFFF2F8FD),
                border: Border.all(color: QuestColors.line, width: 1.5),
                borderRadius: BorderRadius.circular(10)),
            child: Text('nula'.substring(0, done ? 0 : typed),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: QuestColors.ink)),
          ),
        ),
        Positioned(
          left: 240,
          top: 86,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: QuestColors.indigo,
                borderRadius: BorderRadius.circular(10)),
            child:
                const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ];
    },
  );
}

_Demo _crossword() {
  // A clue (💧), its boxes, and the keys that fill them: T, U, I.
  Offset cell(int c) => Offset(106 + c * 44.0, 30);
  const keys = ['I', 'T', 'U'];
  Offset key(String letter) => Offset(106 + keys.indexOf(letter) * 44.0, 108);
  final taps = [
    for (final (i, letter) in 'TUI'.split('').indexed)
      (.3 + i * .15, key(letter))
  ];
  return _Demo(
    taps: taps,
    frame: (t) {
      final typed = t < _reset ? taps.where((tap) => t >= tap.$1).length : 0;
      final done = typed == 3;
      return [
        for (var c = 0; c < 3; c++)
          _tile(c < typed ? 'TUI'[c] : '', cell(c),
              look: done
                  ? _Look.right
                  : (c == typed ? _Look.picked : _Look.idle)),
        _text('💧', const Offset(150, 70), fontSize: 22),
        for (final letter in keys) _tile(letter, key(letter), height: 36),
        if (done) _check(cell(2) + const Offset(36, 0), t, taps.last.$1),
      ];
    },
  );
}

_Demo _sentence() {
  // Bank (shuffled) → answer row, in order: Lehkhabu ka chhiar.
  const bank = ['chhiar', 'Lehkhabu', 'ka'];
  const order = [1, 2, 0];
  Offset slot(int i) => Offset(60 + i * 90.0, 34);
  Offset inBank(int i) => Offset(60 + i * 90.0, 108);
  final taps = [for (final (k, i) in order.indexed) (.28 + k * .16, inBank(i))];
  return _Demo(
    taps: taps,
    frame: (t) {
      final placed = t < _reset ? taps.where((tap) => t >= tap.$1).length : 0;
      final done = placed == 3;
      return [
        for (var k = 0; k < 3; k++)
          k < placed
              ? _tile(bank[order[k]], slot(k),
                  width: 86,
                  look: done ? _Look.right : _Look.picked,
                  fontSize: 14)
              : Positioned(
                  left: slot(k).dx - 43,
                  top: slot(k).dy + 14,
                  child:
                      Container(width: 86, height: 3, color: QuestColors.line),
                ),
        for (var i = 0; i < 3; i++)
          if (!order.take(placed).contains(i))
            _tile(bank[i], inBank(i), width: 86, fontSize: 14),
        if (done) _check(const Offset(286, 12), t, taps.last.$1),
      ];
    },
  );
}
