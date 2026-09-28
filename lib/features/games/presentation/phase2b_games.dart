import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../src/controller.dart';
import '../../../src/data.dart';
import '../../../src/game_session.dart';
import '../../../src/game_text.dart';
import '../../../src/content_widgets.dart';
import '../../../src/theme.dart';
import '../../../src/widgets.dart';
import '../../learning/domain/learning_state.dart';
import '../application/game_runtime.dart';
import '../engine/game_engine.dart';
import '../engine/game_difficulty.dart';
import '../engine/phase2b_engine.dart';

class SentenceBuilderGame extends StatefulWidget {
  const SentenceBuilderGame({
    super.key,
    required this.controller,
    this.mode = GameMode.standard,
    this.exercises = sentenceExercises,
  });

  final QuestController controller;
  final GameMode mode;
  final List<SentenceExercise> exercises;

  @override
  State<SentenceBuilderGame> createState() => _SentenceBuilderGameState();
}

class _SentenceBuilderGameState extends State<SentenceBuilderGame> {
  static const engine = SentenceBuilderEngine();
  late final GameRuntime runtime;
  GameSession get session => runtime.session;

  List<SentenceExercise> questions = <SentenceExercise>[];
  List<List<SentenceTile>> tileSets = <List<SentenceTile>>[];
  final List<String> selectedIds = <String>[];
  int index = 0;
  bool? isCorrect;
  bool finishing = false;

  SentenceExercise get question => questions[index];
  List<SentenceTile> get allTiles => tileSets[index];
  List<SentenceTile> get answerTiles => selectedIds
      .map((id) => allTiles.firstWhere((tile) => tile.id == id))
      .toList();
  List<SentenceTile> get bankTiles =>
      allTiles.where((tile) => !selectedIds.contains(tile.id)).toList();

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: 'sentence_builder',
      mode: widget.mode,
      onChanged: () {
        if (mounted) setState(() {});
      },
      onTimedOut: _timedOut,
    );
    _buildRound();
    unawaited(
      runtime.initialize(
        currentIndex: () => index,
        readPayload: () => <String, Object?>{
          'selectedIds': selectedIds,
          if (isCorrect != null) 'isCorrect': isCorrect,
        },
        restorePayload: (snapshot) {
          _buildRound();
          index = snapshot.currentIndex.clamp(0, questions.length - 1).toInt();
          final validIds = allTiles.map((tile) => tile.id).toSet();
          selectedIds
            ..clear()
            ..addAll(
              (snapshot.payload['selectedIds'] as List<Object?>? ??
                      const <Object?>[])
                  .whereType<String>()
                  .where(validIds.contains),
            );
          isCorrect = snapshot.payload['isCorrect'] as bool?;
        },
      ),
    );
  }

  void _buildRound() {
    // Reviewed Studio sentences come first so they replace a built-in
    // sentence with the same ID.
    final combined = <SentenceExercise>[
      for (final sentence in widget.controller.deliveredSentences)
        SentenceExercise(
          id: sentence.id,
          textMizo: sentence.textMizo,
          englishSupport: sentence.englishSupport,
          tqLevel: sentence.difficulty,
        ),
      ...widget.exercises,
      ..._wordCatalogSentenceExercises(),
    ];
    final seenIds = <String>{};
    final deduped = <SentenceExercise>[
      for (final exercise in combined)
        if (seenIds.add(exercise.id)) exercise,
    ];
    // A sentence's difficulty blends its content level with how many
    // tiles there are to arrange.
    int difficultyOf(SentenceExercise exercise) {
      final tiles = exercise.textMizo.trim().split(RegExp(r'\s+')).length;
      final lengthLevel = (tiles - 2).clamp(1, 7);
      return ((exercise.tqLevel + lengthLevel) / 2).round().clamp(1, 7);
    }

    questions = GameDifficulty.pick(deduped,
        rating: widget.controller.gameSkill('sentence_builder'),
        count: 5,
        difficultyOf: difficultyOf,
        random: session.random);
    tileSets = questions
        .map((exercise) => engine.shuffledTiles(exercise, session.random))
        .toList();
  }

  /// Turns each live/reviewed word catalog entry's own `exampleMizo`
  /// sentence into a Sentence Builder exercise, so newly reviewed and
  /// published content (e.g. the Kumtluang curriculum batch, where every
  /// word already carries one original example sentence) shows up here
  /// too, without needing a separate "delivered sentence" pipeline.
  /// Single-word "sentences" are skipped -- there's nothing to rearrange.
  List<SentenceExercise> _wordCatalogSentenceExercises() {
    return widget.controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .where((entry) => entry.supportsGame('sentence_builder'))
        .where((entry) => entry.exampleMizo.trim().split(' ').length >= 2)
        .map((entry) => SentenceExercise(
              id: 'sentence.word.${entry.id}',
              textMizo: entry.exampleMizo,
              // No English translation of the example exists, so show the
              // word it teaches rather than passing its gloss off as one.
              englishSupport:
                  'A sentence with “${entry.word}” (${entry.englishGloss})',
              tqLevel: entry.difficulty,
            ))
        .toList();
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  Future<void> _timedOut() => _finish(GameEndReason.timedOut);

  Future<void> _finish([GameEndReason? reason]) async {
    if (!mounted || finishing) return;
    finishing = true;
    final result = await runtime.finish(baseXp: 55, reason: reason);
    if (!mounted) return;
    await showGameResult(context, widget.controller, 'sentence_builder', result);
  }

  void _selectTile(SentenceTile tile) {
    if (isCorrect != null || finishing) return;
    HapticFeedback.selectionClick();
    setState(() => selectedIds.add(tile.id));
    unawaited(runtime.persist());
  }

  void _returnTile(SentenceTile tile) {
    if (isCorrect != null || finishing) return;
    setState(() => selectedIds.remove(tile.id));
    unawaited(runtime.persist());
  }

  Future<void> _hint() async {
    if (runtime.hintRevealed || finishing) return;
    final firstId = '${question.id}.0';
    setState(() {
      selectedIds
        ..clear()
        ..add(firstId);
      isCorrect = null;
    });
    await runtime.revealHint();
  }

  Future<void> _check() async {
    if (!runtime.ready || selectedIds.length != allTiles.length || finishing) {
      return;
    }
    final correct = engine.evaluate(question, answerTiles);
    setState(() {
      isCorrect = correct;
      runtime.answer(correct);
    });
    await widget.controller.recordReview(
      itemId: question.id,
      rating: correct ? ReviewRating.good : ReviewRating.again,
    );
    if (!mounted) return;
    if (!correct && !session.hasHearts) {
      await _finish(GameEndReason.heartsExhausted);
    }
  }

  Future<void> _continue() async {
    if (isCorrect == null || finishing) return;
    if (isCorrect == false) {
      setState(() {
        selectedIds.clear();
        isCorrect = null;
      });
      await runtime.persist();
      return;
    }
    if (index == questions.length - 1) {
      await _finish();
      return;
    }
    setState(() {
      index += 1;
      selectedIds.clear();
      isCorrect = null;
      runtime.hintRevealed = false;
    });
    await runtime.persist();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const QuestPage(
        title: 'Sentence Builder',
        child: PremiumCard(child: Text('Sentence content is not available.')),
      );
    }
    return QuestPage(
      title: GameText.of('sentence_builder').title,
      subtitle: 'Arrange the tiles into natural Mizo',
      hud: GameHud(
        session: session,
        progress: (index + (isCorrect == true ? 1 : 0)) / questions.length,
        secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (runtime.restoredSession) const GameResumeBanner(),
          PremiumCard(
            gradient: const LinearGradient(
              colors: <Color>[QuestColors.midnight, QuestColors.indigo],
            ),
            child: Column(
              children: <Widget>[
                Text(
                  GameText.of('sentence_builder').prompt,
                  style: const TextStyle(
                    color: QuestColors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  question.englishSupport,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          GameHintButton(revealed: runtime.hintRevealed, onPressed: _hint),
          if (runtime.hintRevealed)
            GameHintCard(message: GameText.of('sentence_builder').hint),
          const SizedBox(height: 8),
          const Text(
            'YOUR SENTENCE',
            style: TextStyle(
              color: QuestColors.slate,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect == true
                  ? const Color(0xFFE1F6EA)
                  : isCorrect == false
                      ? const Color(0xFFFFE7E4)
                      : Colors.white,
              border: Border.all(color: QuestColors.line),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: answerTiles
                  .map(
                    (tile) => ActionChip(
                      label: Text(
                        tile.text,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onPressed: isCorrect == null ? () => _returnTile(tile) : null,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bankTiles
                .map(
                  (tile) => ActionChip(
                    backgroundColor: const Color(0xFFE9E4FF),
                    side: BorderSide.none,
                    avatar: const Icon(Icons.add_rounded, size: 17),
                    label: Text(
                      tile.text,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    onPressed: isCorrect == null ? () => _selectTile(tile) : null,
                  ),
                )
                .toList(),
          ),
          if (isCorrect != null) ...<Widget>[
            const SizedBox(height: 18),
            FeedbackCard(
              correct: isCorrect!,
              message: isCorrect!
                  ? '${question.textMizo} — A rem dik e.'
                  : 'A indawt a la dik lo. “${question.textMizo}” tih hi en la, tum leh rawh.',
            ),
            ContentReportButton(
              controller: widget.controller,
              contentId: question.id,
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            onPressed: isCorrect == null
                ? (selectedIds.length == allTiles.length ? _check : null)
                : _continue,
            child: Text(
              isCorrect == null
                  ? 'Check Sentence'
                  : isCorrect == true
                      ? (index == questions.length - 1 ? 'Finish' : 'Next Sentence')
                      : 'Try Again',
            ),
          ),
        ],
      ),
    );
  }
}
