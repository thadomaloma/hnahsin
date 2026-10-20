import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../src/app_text.dart';
import '../../../src/controller.dart';
import '../../../src/daily_widgets.dart';
import '../../../src/data.dart';
import '../../../src/game_session.dart';
import '../../../src/game_sounds.dart';
import '../../../src/game_text.dart';
import '../../../src/juice.dart';
import '../../../src/theme.dart';
import '../../../src/widgets.dart';
import '../../../src/word_groups.dart';
import '../../../src/word_groups_puzzle.dart';
import '../application/daily_puzzle.dart';
import '../application/game_runtime.dart';
import '../engine/game_engine.dart';

/// Word Groups, a daily puzzle: sort sixteen Mizo words into four groups
/// of four. Four mistakes are allowed. Up to Wednesday's level each word's
/// English meaning shows under it.
class WordGroupsGame extends StatefulWidget {
  const WordGroupsGame(
      {super.key, required this.controller, required this.daily});

  static const gameId = 'word_groups';
  static const mistakesAllowed = 4;

  final QuestController controller;
  final DailyPuzzle daily;

  @override
  State<WordGroupsGame> createState() => _WordGroupsGameState();
}

/// Each group's colour, easiest first (matching [WordGroupsPuzzle.squares]).
const _groupColors = <Color>[
  Color(0xFFF7D774),
  Color(0xFFA9D67C),
  Color(0xFF9CC7F2),
  Color(0xFFC8A6EE),
];

class _WordGroupsGameState extends State<WordGroupsGame> {
  late final GameRuntime runtime;
  GameSession get session => runtime.session;
  WordGroupsPuzzle? puzzle;

  /// The tiles still on the board, in their shown order (word ids).
  List<String> order = <String>[];
  final Set<String> selected = <String>{};
  final List<String> solved = <String>[];

  /// Every four tried, as word ids: the shared grid's rows.
  final List<List<String>> attempts = <List<String>>[];
  int mistakes = 0;
  String? message;
  int misses = 0;
  bool finishing = false;

  bool get showMeanings => widget.daily.rating < 3.5;
  bool get over =>
      solved.length == 4 || mistakes >= WordGroupsGame.mistakesAllowed;

  Map<String, WordEntry> get _byId =>
      {for (final entry in puzzle!.tiles) entry.id: entry};

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: widget.daily.sessionId,
      mode: GameMode.relaxed,
      countUp: true,
      onChanged: () {
        if (mounted) setState(() {});
      },
      onTimedOut: () async {},
    );
    _build();
    unawaited(runtime.initialize(
      currentIndex: () => solved.length,
      readPayload: () => <String, Object?>{
        'order': order,
        'selected': selected.toList(),
        'solved': solved,
        'attempts': [for (final row in attempts) row.join(',')],
        'mistakes': mistakes,
      },
      restorePayload: (snapshot) {
        _build();
        final ids = _byId.keys.toSet();
        List<String> known(Object? raw) => [
              for (final id in raw as List<Object?>? ?? const <Object?>[])
                if (id is String && ids.contains(id)) id
            ];
        final groupIds =
            puzzle?.groups.map((group) => group.id).toSet() ?? const <String>{};
        solved
          ..clear()
          ..addAll([
            for (final id in snapshot.payload['solved'] as List<Object?>? ??
                const <Object?>[])
              if (id is String && groupIds.contains(id)) id
          ]);
        final savedOrder = known(snapshot.payload['order']);
        if (savedOrder.isNotEmpty) order = savedOrder;
        selected
          ..clear()
          ..addAll(known(snapshot.payload['selected']));
        attempts
          ..clear()
          ..addAll([
            for (final row in snapshot.payload['attempts'] as List<Object?>? ??
                const <Object?>[])
              if (row is String) row.split(',').where(ids.contains).toList()
          ]);
        mistakes = (snapshot.payload['mistakes'] as num?)?.toInt() ?? 0;
      },
    ));
  }

  void _build() {
    final built = buildWordGroupsPuzzle(
      catalog: widget.controller.wordCatalog,
      rating: widget.daily.rating,
      random: widget.daily.random,
    );
    puzzle = built;
    if (built == null) return;
    order = [for (final entry in built.tiles) entry.id]
      ..shuffle(widget.daily.random);
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    if (!runtime.ready || over || finishing) return;
    HapticFeedback.selectionClick();
    GameSounds.play(GameSound.tap);
    setState(() {
      message = null;
      if (!selected.remove(id) && selected.length < 4) selected.add(id);
    });
  }

  void _shuffle() {
    GameSounds.play(GameSound.flip);
    setState(() => order.shuffle(session.random));
  }

  Future<void> _submit() async {
    if (selected.length != 4 || over || finishing) return;
    final puzzle = this.puzzle!;
    final picks = [for (final id in selected) _byId[id]!];
    final tried = selected.toSet();
    if (attempts.any((row) => row.toSet().containsAll(tried))) {
      setState(() => message = AppText.of('groups.tried'));
      return;
    }
    attempts.add(selected.toList());
    final groups = picks.map(puzzle.groupOf).toList();
    final group = groups.first;
    if (groups.every((g) => g == group)) {
      setState(() {
        solved.add(group.id);
        order.removeWhere(tried.contains);
        selected.clear();
        message = null;
        runtime.answer(true,
            wordId: picks.first.id,
            word: picks.first.word,
            sound: GameSound.match);
        for (final entry in picks.skip(1)) {
          runtime.noteWord(entry.id, entry.word);
        }
      });
    } else {
      final most = groups
          .map((g) => groups.where((other) => other == g).length)
          .reduce((a, b) => a > b ? a : b);
      setState(() {
        mistakes++;
        misses++;
        message = AppText.of(most == 3 ? 'groups.oneAway' : 'groups.notGroup');
        runtime.answer(false);
      });
    }
    await runtime.persist();
    if (over) await _finish();
  }

  Future<void> _finish() async {
    if (finishing) return;
    finishing = true;
    // Show the groups not found before the result.
    setState(() {
      for (final group in this.puzzle!.groups) {
        if (!solved.contains(group.id)) solved.add(group.id);
      }
      order.clear();
      selected.clear();
    });
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final result = await runtime.finish(baseXp: 50);
    if (!mounted) return;
    final puzzle = this.puzzle!;
    final grid = [
      for (final row in attempts)
        row
            .map((id) => WordGroupsPuzzle
                .squares[puzzle.groups.indexOf(puzzle.groupOf(_byId[id]!))])
            .join(),
    ].join('\n');
    await finishDaily(
        context,
        widget.controller,
        widget.daily,
        result,
        DailyResult(
          marks: [for (final rune in grid.runes) String.fromCharCode(rune)],
          seconds: runtime.elapsedSeconds,
          hints: runtime.hintsUsed,
        ));
  }

  /// The easiest group not yet found: what the hint names.
  WordGroup? get _hintGroup =>
      puzzle?.groups.where((group) => !solved.contains(group.id)).firstOrNull;

  String _groupName(WordGroup group) => AppText.of('group.${group.id}');

  @override
  Widget build(BuildContext context) {
    final copy = GameText.of(WordGroupsGame.gameId);
    final puzzle = this.puzzle;
    if (puzzle == null) {
      return QuestPage(
        title: dailyTitle(widget.daily),
        child: PremiumCard(child: Text(AppText.of('groups.empty'))),
      );
    }
    final byId = _byId;
    return QuestPage(
      title: dailyTitle(widget.daily),
      subtitle: copy.subtitle,
      hud: GameHud(
          session: session,
          progress: solved.length / 4,
          secondsElapsed: runtime.elapsedSeconds),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (runtime.restoredSession) const GameResumeBanner(),
        Text(copy.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        // Groups found, in the order found, each popping into place.
        for (final id in solved)
          if (puzzle.groups.where((group) => group.id == id).firstOrNull
              case final group?)
            PopIn(
              key: ValueKey('group$id'),
              from: .7,
              child: _SolvedGroup(
                name: _groupName(group),
                words: [for (final entry in puzzle.words[id]!) entry.word],
                color: _groupColors[puzzle.groups.indexOf(group)],
              ),
            ),
        Shake(
          trigger: misses,
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: showMeanings ? .95 : 1.25,
            children: [
              for (final (i, id) in order.indexed)
                SlideIn(
                  key: ValueKey('tile$id'),
                  index: i % 4,
                  child: _WordTile(
                    word: byId[id]!.word,
                    meaning: showMeanings
                        ? byId[id]!.englishGloss.split(';').first.trim()
                        : '',
                    selected: selected.contains(id),
                    onTap: () => _toggle(id),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(AppText.of('groups.mistakes'),
              style: const TextStyle(
                  color: QuestColors.slate, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          for (var i = 0; i < WordGroupsGame.mistakesAllowed; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: motionFor(context, const Duration(milliseconds: 250)),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < WordGroupsGame.mistakesAllowed - mistakes
                      ? QuestColors.ink
                      : QuestColors.line,
                ),
              ),
            ),
        ]),
        SizedBox(
          height: 28,
          child: Center(
            child: Text(message ?? '',
                style: const TextStyle(
                    color: QuestColors.coral, fontWeight: FontWeight.w800)),
          ),
        ),
        if (!over) ...[
          GameHintButton(
              revealed: runtime.hintRevealed, onPressed: runtime.revealHint),
          if (runtime.hintRevealed && _hintGroup != null)
            GameHintCard(
                message:
                    fillGameText(copy.hint, gloss: _groupName(_hintGroup!))),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: OutlinedButton(
                    onPressed: _shuffle,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(AppText.of('groups.shuffle'))))),
            const SizedBox(width: 8),
            Expanded(
                child: OutlinedButton(
                    onPressed: selected.isEmpty
                        ? null
                        : () => setState(selected.clear),
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(AppText.of('groups.clear'))))),
            const SizedBox(width: 8),
            Expanded(
                child: FilledButton(
                    onPressed: selected.length == 4 ? _submit : null,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(AppText.of('groups.submit'))))),
          ]),
        ],
      ]),
    );
  }
}

class _WordTile extends StatelessWidget {
  const _WordTile(
      {required this.word,
      required this.meaning,
      required this.selected,
      required this.onTap});

  final String word;
  final String meaning;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: meaning.isEmpty ? word : '$word, $meaning',
        child: ExcludeSemantics(
          child: AnimatedScale(
            scale: selected ? .94 : 1,
            duration: motionFor(context, const Duration(milliseconds: 140)),
            child: Material(
              color: selected ? QuestColors.navy : Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(word,
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: selected
                                      ? Colors.white
                                      : QuestColors.ink)),
                        ),
                        if (meaning.isNotEmpty)
                          Text(meaning,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10.5,
                                  height: 1.15,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? const Color(0xFFDDF3FF)
                                      : QuestColors.slate)),
                      ]),
                ),
              ),
            ),
          ),
        ),
      );
}

class _SolvedGroup extends StatelessWidget {
  const _SolvedGroup(
      {required this.name, required this.words, required this.color});

  final String name;
  final List<String> words;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        label: AppText.of(
            'groups.groupSpoken', {'group': name, 'words': words.join(', ')}),
        child: ExcludeSemantics(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Text(name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                      color: QuestColors.ink)),
              const SizedBox(height: 3),
              Text(words.join(', '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: QuestColors.ink)),
            ]),
          ),
        ),
      );
}
