import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../src/controller.dart';
import '../../../src/data.dart';
import '../../../src/game_session.dart';
import '../../../src/game_text.dart';
import '../../../src/game_words.dart';
import '../../../src/theme.dart';
import '../../../src/widgets.dart';
import '../application/game_runtime.dart';
import '../engine/crossword_layout.dart';
import '../engine/game_engine.dart';

typedef _Cell = (int, int);

/// Mini Crossword — a real interlocking crossword built from reviewed words.
/// Levels 1–2 clue in English (recall the Mizo word), level 3 up clue with
/// the Mizo meaning. Each word is checked as soon as it is filled in.
class MiniCrosswordGame extends StatefulWidget {
  const MiniCrosswordGame({super.key, required this.controller, this.mode = GameMode.standard});

  static const gameId = 'crossword';

  /// On-screen keys: the single letters Mizo is written with.
  static const keyRows = <String>['AÂEÊIÎOÔUÛ', 'BCDFGHJKLM', 'NPRSTṬVWZ'];

  final QuestController controller;
  final GameMode mode;

  @override
  State<MiniCrosswordGame> createState() => _MiniCrosswordGameState();
}

class _MiniCrosswordGameState extends State<MiniCrosswordGame> {
  static const _fallback = <CrosswordCandidate>[
    CrosswordCandidate(id: 'fallback.aizawl', answer: 'AIZAWL', clue: 'Mizoram khawpui ber'),
    CrosswordCandidate(id: 'fallback.mizo', answer: 'MIZO', clue: 'Kan hnam hming'),
    CrosswordCandidate(id: 'fallback.nula', answer: 'NULA', clue: 'Hmeichhe naupang puitling tawh'),
    CrosswordCandidate(id: 'fallback.lal', answer: 'LAL', clue: 'Khua leh ram awptu'),
    CrosswordCandidate(id: 'fallback.zai', answer: 'ZAI', clue: 'Hla sak'),
    CrosswordCandidate(id: 'fallback.hla', answer: 'HLA', clue: 'Zai atana thu phuah'),
  ];

  late final GameRuntime runtime;
  GameSession get session => runtime.session;
  final FocusNode focus = FocusNode(debugLabel: 'crossword');

  late CrosswordLayout layout;
  late Map<_Cell, String> solution;
  final Map<_Cell, String> letters = {};
  final Set<String> solved = {};
  /// Letters marked wrong by the last check of their word. A word is only
  /// checked again once all of them have been replaced, so fixing it costs
  /// at most one more heart.
  final Set<_Cell> wrongCells = {};
  late _Cell active;
  bool across = true;
  CrosswordSlot? lastSolved;
  bool finishing = false;

  CrosswordSlot get activeSlot {
    final here = layout.slotsAt(active);
    return here.firstWhere((slot) => slot.across == across, orElse: () => here.first);
  }

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: MiniCrosswordGame.gameId,
      mode: widget.mode,
      onChanged: () {
        if (mounted) setState(() {});
      },
      onTimedOut: () => _finish(GameEndReason.timedOut),
    );
    _buildPuzzle();
    unawaited(
      runtime.initialize(
        currentIndex: () => solved.length,
        readPayload: () => <String, Object?>{
          'cells': {for (final MapEntry(:key, :value) in letters.entries) '${key.$1},${key.$2}': value},
          'solved': solved.toList(),
          'wrong': [for (final cell in wrongCells) '${cell.$1},${cell.$2}'],
          'active': '${active.$1},${active.$2}',
          'across': across,
        },
        restorePayload: (snapshot) {
          // The saved letters belong to the puzzle built from the saved seed.
          _buildPuzzle();
          final cells = snapshot.payload['cells'];
          if (cells is Map) {
            for (final MapEntry(:key, :value) in cells.entries) {
              final cell = _decode(key.toString());
              if (cell != null && solution.containsKey(cell) && value is String && value.isNotEmpty) {
                letters[cell] = value;
              }
            }
          }
          final keys = layout.slots.map((slot) => slot.key).toSet();
          solved.addAll((snapshot.payload['solved'] as List<Object?>? ?? const <Object?>[])
              .whereType<String>()
              .where(keys.contains));
          wrongCells.addAll((snapshot.payload['wrong'] as List<Object?>? ?? const <Object?>[])
              .whereType<String>()
              .map(_decode)
              .whereType<_Cell>()
              .where((cell) => letters[cell] != null && letters[cell] != solution[cell]));
          final saved = _decode(snapshot.payload['active'] as String? ?? '');
          if (saved != null && solution.containsKey(saved)) active = saved;
          across = snapshot.payload['across'] as bool? ?? across;
        },
      ),
    );
  }

  void _buildPuzzle() {
    final random = session.random;
    final rating = widget.controller.gameSkill(MiniCrosswordGame.gameId);
    // Small grids of short words first; bigger, longer ones as the level rises.
    final (target, longest) = rating < 2 ? (4, 5) : (rating < 3.5 ? (5, 6) : (6, 7));
    final english = rating < 3;
    // Only words the on-screen keyboard can spell.
    final typeable = MiniCrosswordGame.keyRows.join().split('').toSet();
    final spellings = <String>{};
    final pool = widget.controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .where((entry) => entry.supportsGame(MiniCrosswordGame.gameId))
        .where((entry) {
      final answer = entry.word.trim().toUpperCase();
      return answer.length >= 3 && answer.length <= longest && answer.split('').every(typeable.contains) && spellings.add(answer);
    });
    final candidates = [
      for (final entry in pickWordsForLevel(widget.controller, MiniCrosswordGame.gameId, pool, 40, random))
        if (_clueFor(entry, english: english) case final clue when clue.isNotEmpty)
          CrosswordCandidate(id: entry.id, answer: entry.word.trim().toUpperCase(), clue: clue),
    ];
    final built = CrosswordBuilder.build(candidates, target: target, maxSize: longest + 1, random: random);
    layout = built != null && built.slots.length >= 3
        ? built
        : CrosswordBuilder.build(_fallback, target: 5, random: random)!;
    solution = layout.solution;
    letters.clear();
    solved.clear();
    wrongCells.clear();
    lastSolved = null;
    across = layout.slots.first.across;
    active = (layout.slots.first.row, layout.slots.first.col);
  }

  static String _clueFor(WordEntry entry, {required bool english}) {
    final gloss = entry.englishGloss.trim();
    final mizo = meaningWithoutWord(entry.meaningMizo, entry.word);
    if (english && gloss.isNotEmpty) return gloss;
    return mizo.isNotEmpty ? mizo : gloss;
  }

  _Cell? _decode(String value) {
    final parts = value.split(',');
    if (parts.length != 2) return null;
    final row = int.tryParse(parts[0]);
    final col = int.tryParse(parts[1]);
    return row == null || col == null ? null : (row, col);
  }

  bool _locked(_Cell cell) => layout.slotsAt(cell).any((slot) => solved.contains(slot.key));

  @override
  void dispose() {
    runtime.dispose();
    focus.dispose();
    super.dispose();
  }

  void _select(_Cell cell) {
    final here = layout.slotsAt(cell);
    if (here.isEmpty) return;
    setState(() {
      if (cell == active && here.length > 1) {
        across = !across;
      } else if (!here.any((slot) => slot.across == across)) {
        across = here.first.across;
      }
      active = cell;
    });
    focus.requestFocus();
  }

  void _selectSlot(CrosswordSlot slot) {
    setState(() {
      across = slot.across;
      active = slot.cells.firstWhere((cell) => letters[cell] == null && !_locked(cell), orElse: () => slot.cells.first);
    });
    focus.requestFocus();
  }

  void _stepSlot(int direction) {
    final open = layout.slots.where((slot) => !solved.contains(slot.key)).toList();
    if (open.isEmpty) return;
    final at = open.indexOf(activeSlot);
    _selectSlot(open[(at + direction) % open.length]);
  }

  Future<void> _type(String letter) async {
    if (!runtime.ready || finishing) return;
    final slot = activeSlot;
    if (_locked(active)) {
      _advance(slot);
      return;
    }
    setState(() {
      letters[active] = letter;
      wrongCells.remove(active);
    });
    await _checkAround(active);
    if (finishing || !mounted) return;
    setState(() => _afterEntry(slot));
    await runtime.persist();
  }

  void _afterEntry(CrosswordSlot slot) {
    if (solved.contains(slot.key)) {
      _moveToNextOpenSlot();
    } else {
      _advance(slot);
    }
  }

  /// Moves to the next unlocked cell of [slot], preferring an empty one.
  void _advance(CrosswordSlot slot) {
    final cells = slot.cells;
    final after = cells.skip(cells.indexOf(active) + 1).where((cell) => !_locked(cell));
    final next = after.where((cell) => letters[cell] == null).firstOrNull ?? after.firstOrNull;
    if (next != null) active = next;
  }

  void _moveToNextOpenSlot() {
    final open = layout.slots.where((slot) => !solved.contains(slot.key)).toList();
    if (open.isEmpty) return;
    final next = open.firstWhere((slot) => slot.cells.any((cell) => letters[cell] == null), orElse: () => open.first);
    across = next.across;
    active = next.cells.firstWhere((cell) => letters[cell] == null && !_locked(cell), orElse: () => next.cells.first);
  }

  Future<void> _erase() async {
    if (!runtime.ready || finishing) return;
    final cells = activeSlot.cells;
    setState(() {
      var target = active;
      if (letters[target] == null || _locked(target)) {
        final before = cells.take(cells.indexOf(active)).where((cell) => !_locked(cell));
        if (before.isEmpty) return;
        target = before.last;
        active = target;
      }
      letters.remove(target);
      wrongCells.remove(target);
    });
    await runtime.persist();
  }

  /// Checks every word through [cell] that has just been filled in.
  Future<void> _checkAround(_Cell cell) async {
    for (final slot in layout.slotsAt(cell)) {
      if (solved.contains(slot.key) ||
          slot.cells.any((c) => letters[c] == null || wrongCells.contains(c))) {
        continue;
      }
      final correct = slot.cells.every((c) => letters[c] == solution[c]);
      setState(() {
        if (correct) {
          solved.add(slot.key);
          lastSolved = slot;
        } else {
          wrongCells.addAll(slot.cells.where((c) => letters[c] != solution[c]));
        }
        runtime.answer(correct);
      });
      unawaited(correct ? HapticFeedback.selectionClick() : HapticFeedback.mediumImpact());
    }
    if (solved.length == layout.slots.length) {
      await _finish();
    } else if (!session.hasHearts) {
      await _finish(GameEndReason.heartsExhausted);
    }
  }

  Future<void> _hint() async {
    if (!runtime.ready || finishing || runtime.hintRevealed) return;
    final slot = solved.contains(activeSlot.key)
        ? layout.slots.firstWhere((slot) => !solved.contains(slot.key))
        : activeSlot;
    final cell = slot.cells.firstWhere((cell) => letters[cell] != solution[cell]);
    await runtime.revealHint();
    if (!mounted) return;
    setState(() {
      across = slot.across;
      active = cell;
      letters[cell] = solution[cell]!;
      wrongCells.remove(cell);
    });
    await _checkAround(cell);
    if (finishing || !mounted) return;
    setState(() => _afterEntry(slot));
    await runtime.persist();
  }

  Future<void> _finish([GameEndReason? reason]) async {
    if (finishing || !mounted) return;
    finishing = true;
    final result = await runtime.finish(baseXp: 60, reason: reason);
    if (!mounted) return;
    await showGameResult(context, widget.controller, MiniCrosswordGame.gameId, result);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      unawaited(_erase());
      return KeyEventResult.handled;
    }
    final step = switch (key) {
      LogicalKeyboardKey.arrowUp => (-1, 0),
      LogicalKeyboardKey.arrowDown => (1, 0),
      LogicalKeyboardKey.arrowLeft => (0, -1),
      LogicalKeyboardKey.arrowRight => (0, 1),
      _ => null,
    };
    if (step != null) {
      final next = (active.$1 + step.$1, active.$2 + step.$2);
      if (solution.containsKey(next)) {
        setState(() {
          across = step.$1 == 0;
          if (!layout.slotsAt(next).any((slot) => slot.across == across)) across = !across;
          active = next;
        });
      }
      return KeyEventResult.handled;
    }
    final letter = event.character?.toUpperCase();
    if (letter != null && MiniCrosswordGame.keyRows.any((row) => row.contains(letter)) && letter.length == 1) {
      unawaited(_type(letter));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  String _wrongMessage() {
    final words = [
      for (final slot in layout.slots)
        // Only words that were checked: filled in and holding a red letter.
        if (slot.cells.any(wrongCells.contains) && slot.cells.every(letters.containsKey))
          '${slot.number}${slot.across ? '→' : '↓'}',
    ].join(', ');
    // Right letter, missing circumflex or dot: say so, it's what learners miss.
    final accentOnly = wrongCells.every((cell) => foldMizo(letters[cell] ?? '') == foldMizo(solution[cell]!));
    final subject = words.isEmpty ? 'I chhanna' : 'Thumal $words';
    return accentOnly
        ? '$subject a hnaih hle! Hawrawp sen chu â, ê, î, ô, û emaw ṭ emaw a ni ang.'
        : '$subject a dik lo. Hawrawp sen te thlak la, tum leh rawh.';
  }

  WordEntry? _entryFor(CrosswordSlot slot) =>
      widget.controller.wordCatalog.where((entry) => entry.id == slot.id).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final copy = GameText.of(MiniCrosswordGame.gameId);
    final slot = activeSlot;
    return QuestPage(
      title: copy.title,
      subtitle: 'Solve each clue',
      hud: GameHud(
        session: session,
        progress: solved.length / layout.slots.length,
        secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null,
      ),
      child: Focus(
        focusNode: focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (runtime.restoredSession) const GameResumeBanner(),
          _ClueBar(
            slot: slot,
            solved: solved.contains(slot.key),
            onPrevious: () => _stepSlot(-1),
            onNext: () => _stepSlot(1),
          ),
          const SizedBox(height: 12),
          _Board(
            layout: layout,
            letters: letters,
            active: active,
            activeSlot: slot,
            isSolved: _locked,
            isWrong: wrongCells.contains,
            onTap: _select,
          ),
          GameHintButton(revealed: runtime.hintRevealed, onPressed: _hint),
          if (runtime.hintRevealed) GameHintCard(message: copy.hint),
          if (wrongCells.isNotEmpty) ...[
            const SizedBox(height: 10),
            FeedbackCard(correct: false, message: _wrongMessage()),
          ] else if (lastSolved case final done?) ...[
            const SizedBox(height: 10),
            FeedbackCard(
              correct: true,
              message: switch (_entryFor(done)) {
                final entry? => '${entry.word}: ${entry.meaningMizo}'
                    '${entry.englishGloss.isEmpty ? '' : ' (${entry.englishGloss})'}',
                null => '${done.answer}: ${done.clue}',
              },
            ),
          ],
          const SizedBox(height: 14),
          _Keyboard(onLetter: _type, onErase: _erase, enabled: runtime.ready && !finishing),
          const SizedBox(height: 22),
          for (final direction in const [true, false])
            if (layout.slots.any((slot) => slot.across == direction)) ...[
              SectionTitle(direction ? 'Across →' : 'Down ↓'),
              const SizedBox(height: 8),
              for (final item in layout.slots.where((slot) => slot.across == direction))
                _ClueTile(
                  slot: item,
                  active: item.key == slot.key,
                  solved: solved.contains(item.key),
                  onTap: () => _selectSlot(item),
                ),
              const SizedBox(height: 14),
            ],
        ]),
      ),
    );
  }
}

class _ClueBar extends StatelessWidget {
  const _ClueBar({required this.slot, required this.solved, required this.onPrevious, required this.onNext});

  final CrosswordSlot slot;
  final bool solved;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [QuestColors.midnight, QuestColors.indigo]),
          borderRadius: BorderRadius.circular(QuestRadius.medium),
        ),
        child: Row(children: [
          IconButton(
            onPressed: onPrevious,
            tooltip: 'Previous clue',
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Column(children: [
                Text(
                  '${slot.number} ${slot.across ? 'ACROSS →' : 'DOWN ↓'}  •  ${slot.answer.length} HAWRAWP',
                  style: const TextStyle(color: QuestColors.teal, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                const SizedBox(height: 6),
                Text(
                  solved ? '${slot.answer} ✓' : slot.clue,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.3, fontWeight: FontWeight.w800),
                ),
              ]),
            ),
          ),
          IconButton(
            onPressed: onNext,
            tooltip: 'Next clue',
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ),
        ]),
      );
}

class _Board extends StatelessWidget {
  const _Board({
    required this.layout,
    required this.letters,
    required this.active,
    required this.activeSlot,
    required this.isSolved,
    required this.isWrong,
    required this.onTap,
  });

  final CrosswordLayout layout;
  final Map<_Cell, String> letters;
  final _Cell active;
  final CrosswordSlot activeSlot;
  final bool Function(_Cell) isSolved;
  final bool Function(_Cell) isWrong;
  final ValueChanged<_Cell> onTap;

  @override
  Widget build(BuildContext context) {
    final numbers = {for (final slot in layout.slots) (slot.row, slot.col): slot.number};
    final inActive = activeSlot.cells.toSet();
    return LayoutBuilder(builder: (context, constraints) {
      const gap = 3.0;
      final size = ((constraints.maxWidth - 12 - gap * (layout.cols - 1)) / layout.cols).clamp(0.0, 54.0);
      return Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: QuestColors.navy, borderRadius: BorderRadius.circular(14)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (var row = 0; row < layout.rows; row++)
              Padding(
                padding: EdgeInsets.only(bottom: row == layout.rows - 1 ? 0 : gap),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  for (var col = 0; col < layout.cols; col++)
                    Padding(
                      padding: EdgeInsets.only(right: col == layout.cols - 1 ? 0 : gap),
                      child: SizedBox.square(dimension: size, child: _cell((row, col), numbers, inActive, size)),
                    ),
                ]),
              ),
          ]),
        ),
      );
    });
  }

  Widget _cell(_Cell cell, Map<_Cell, int> numbers, Set<_Cell> inActive, double size) {
    final used = layout.slotsAt(cell).isNotEmpty;
    if (!used) return const SizedBox.shrink();
    final letter = letters[cell];
    final solved = isSolved(cell);
    final wrong = isWrong(cell);
    // A wrong letter stays red even under the cursor; the cursor is then
    // shown as a gold border.
    final color = wrong
        ? const Color(0xFFFCE4EC)
        : cell == active
            ? QuestColors.gold
            : solved
                ? const Color(0xFFD9F4E5)
                : inActive
                    .contains(cell)
                    ? const Color(0xFFDDF3FF)
                    : Colors.white;
    return Semantics(
      button: true,
      selected: cell == active,
      label: 'Row ${cell.$1 + 1}, column ${cell.$2 + 1}, ${letter == null ? 'empty' : 'letter $letter'}',
      child: GestureDetector(
        onTap: () => onTap(cell),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: wrong && cell == active ? Border.all(color: QuestColors.gold, width: 3) : null,
          ),
          child: Stack(children: [
            if (numbers[cell] case final number?)
              Positioned(
                left: 3,
                top: 1,
                child: ExcludeSemantics(
                  child: Text('$number', style: TextStyle(fontSize: size * .2, fontWeight: FontWeight.w900, color: QuestColors.slate)),
                ),
              ),
            Center(
              child: ExcludeSemantics(
                child: Text(
                  letter ?? '',
                  style: TextStyle(
                    fontSize: size * .48,
                    fontWeight: FontWeight.w900,
                    color: wrong ? const Color(0xFFC2185B) : (solved ? QuestColors.successInk : QuestColors.navy),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Keyboard extends StatelessWidget {
  const _Keyboard({required this.onLetter, required this.onErase, required this.enabled});

  final ValueChanged<String> onLetter;
  final VoidCallback onErase;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(children: [
        for (final (index, row) in MiniCrosswordGame.keyRows.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              for (final letter in row.split(''))
                _Key(label: letter, onTap: enabled ? () => onLetter(letter) : null),
              if (index == MiniCrosswordGame.keyRows.length - 1)
                _Key(
                  label: 'Erase',
                  icon: Icons.backspace_outlined,
                  onTap: enabled ? onErase : null,
                ),
            ]),
          ),
      ]);
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap, this.icon});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Material(
            color: icon == null ? QuestColors.mist : const Color(0xFFFFF4CA),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 46,
                child: Center(
                  child: icon == null
                      ? Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: QuestColors.navy))
                      : Icon(icon, size: 20, color: const Color(0xFF9A6800), semanticLabel: label),
                ),
              ),
            ),
          ),
        ),
      );
}

class _ClueTile extends StatelessWidget {
  const _ClueTile({required this.slot, required this.active, required this.solved, required this.onTap});

  final CrosswordSlot slot;
  final bool active;
  final bool solved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFDDF3FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 28,
              child: Text('${slot.number}', style: const TextStyle(fontWeight: FontWeight.w900, color: QuestColors.indigo)),
            ),
            Expanded(
              child: Text(
                solved ? '${slot.clue} — ${slot.answer}' : '${slot.clue} (${slot.answer.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: solved ? QuestColors.successInk : QuestColors.ink,
                ),
              ),
            ),
            if (solved) const Icon(Icons.check_circle_rounded, size: 18, color: QuestColors.success),
          ]),
        ),
      );
}
