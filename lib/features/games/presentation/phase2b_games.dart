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
import '../../../src/app_text.dart';
import '../../../src/game_sounds.dart';
import '../../../src/game_words.dart';
import '../../../src/meaning_round.dart' show blankOutWord;
import '../../../src/word_sentences.dart';

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

  /// Questions (by index) asked as “which word is missing?” instead of
  /// built from tiles.
  Map<int, _Gap> gaps = <int, _Gap>{};

  /// The word picked for a gap question.
  String? picked;
  int index = 0;
  bool? isCorrect;
  bool finishing = false;

  SentenceExercise get question => questions[index];
  _Gap? get gap => gaps[index];
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
          if (picked != null) 'picked': picked,
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
          final saved = snapshot.payload['picked'] as String?;
          picked = gap?.options.contains(saved) ?? false ? saved : null;
          isCorrect = snapshot.payload['isCorrect'] as bool?;
        },
      ),
    );
  }

  /// Names keep their capital on a tile: words written with one somewhere
  /// other than the start of a sentence.
  Set<String> names = const <String>{};

  void _buildRound() {
    final rating = widget.controller.gameSkill('sentence_builder');
    // Sentences with an English meaning to build: reviewed Studio ones
    // first, so they replace a built-in sentence with the same ID.
    final seenIds = <String>{};
    final seenTexts = <String>{};
    bool fresh(SentenceExercise exercise) =>
        exercise.tokens.length >= 2 &&
        seenIds.add(exercise.id) &&
        seenTexts.add(exercise.tokens.join(' ').toLowerCase());
    final translated = <SentenceExercise>[
      for (final sentence in widget.controller.deliveredSentences)
        SentenceExercise(
          id: sentence.id,
          textMizo: sentence.textMizo,
          englishSupport: sentence.englishSupport,
          tqLevel: sentence.difficulty,
        ),
      ...widget.exercises,
    ].where(fresh).toList();
    // Words' example sentences show their word and its English meaning in
    // place of a translation. Every level uses them (there are only a few
    // translated sentences); low levels get the short ones, and the longest
    // wait for higher levels.
    final maxTiles =
        rating < 2 ? 5 : (rating < 3 ? 6 : (rating < 3.5 ? 8 : 12));
    final examples = _wordCatalogSentenceExercises()
        .where((exercise) => exercise.tokens.length <= maxTiles)
        .where(fresh)
        .toList();
    final pool = [...translated, ...examples];
    names = {
      for (final exercise in pool)
        for (final (index, token) in exercise.tokens.indexed)
          // Not the start of a sentence, nor of one after “E khai!”.
          if (index > 0 &&
              !_sentenceEnd.hasMatch(exercise.tokens[index - 1]) &&
              _capitalised.hasMatch(token))
            SentenceBuilderEngine.tileText(token, first: false),
    };
    // A sentence's difficulty blends its content level with how many
    // tiles there are to arrange.
    int difficultyOf(SentenceExercise exercise) {
      final lengthLevel = (exercise.tokens.length - 2).clamp(1, 7);
      return ((exercise.tqLevel + lengthLevel) / 2).round().clamp(1, 7);
    }

    // Spread over levels 1–7 so every level has its own sentences.
    questions = GameDifficulty.pick(pool,
        rating: rating,
        count: 5,
        difficultyOf: GameDifficulty.spread(pool,
            difficultyOf: difficultyOf,
            tieBreak: (a, b) => a.tokens.length.compareTo(b.tokens.length)),
        random: session.random);
    tileSets = questions
        .map((exercise) =>
            engine.shuffledTiles(exercise, session.random, names: names))
        .toList();
    // The second and fourth questions ask for a missing word instead, where
    // the sentence has one to blank out.
    gaps = {
      for (final i in const [1, 3])
        if (i < questions.length)
          if (_gapFor(questions[i], rating) case final gap?) i: gap,
    };
  }

  /// [exercise] with one of its words blanked out and three wrong words to
  /// choose from: for a word's example sentence the word itself, for a
  /// Sheet sentence its least common word. Wrong words are of the same
  /// kind and share no meaning with it, and none is in the sentence.
  _Gap? _gapFor(SentenceExercise exercise, double rating) {
    final catalog = widget.controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .toList();
    final WordEntry? answer;
    if (exercise.keyWord != null) {
      final id = exercise.id.substring('sentence.word.'.length);
      answer = catalog.where((entry) => entry.id == id).firstOrNull;
    } else {
      final sentence = widget.controller.deliveredSentences
          .where((sentence) => sentence.id == exercise.id)
          .firstOrNull;
      // A built-in sentence: its longest word the catalog knows.
      answer = sentence != null
          ? widget.controller.sentenceIndex.gapWordIn(sentence)
          : (catalog
                  .where((entry) => foldMizo(entry.word).length >= 3)
                  .where((entry) =>
                      blankWholeWord(exercise.textMizo, entry.word) != null)
                  .toList()
                ..sort((a, b) => b.word.length.compareTo(a.word.length)))
              .firstOrNull;
    }
    if (answer == null) return null;
    final blanked = blankWholeWord(exercise.textMizo, answer.word);
    if (blanked == null) return null;
    bool isAction(WordEntry word) =>
        word.englishGloss.trim().toLowerCase().startsWith('to ');
    final spelling = foldMizo(answer.word);
    // Every meaning of the spelling, so “in” (house) never has “in” (drink)'s
    // synonyms as wrong options.
    final senses = {
      for (final entry in catalog)
        if (foldMizo(entry.word) == spelling)
          ...meaningWords(entry.englishGloss),
    };
    final seen = <String>{spelling};
    final candidates = catalog
        .where((other) => isAction(other) == isAction(answer!))
        .where((other) =>
            meaningWords(other.englishGloss).intersection(senses).isEmpty)
        .where((other) => blankOutWord(exercise.textMizo, other.word) == null)
        .where((other) => seen.add(foldMizo(other.word)))
        .toList();
    final wrong = GameDifficulty.distractors(answer, candidates,
        rating: rating,
        count: 3,
        similarity: wordSimilarity,
        random: session.random);
    if (wrong.length < 3) return null;
    return _Gap(
      blanked: blanked,
      entry: answer,
      options: [answer.word, ...wrong.map((other) => other.word)]
        ..shuffle(session.random),
    );
  }

  static final _capitalised = RegExp(r'^[“"‘(]*\p{Lu}', unicode: true);
  static final _sentenceEnd = RegExp(r'[.!?]["”’]?$');

  /// Turns each reviewed word's own `exampleMizo` sentence into an
  /// exercise, so newly published words show up here too. Examples that
  /// don't actually use their word are left out.
  List<SentenceExercise> _wordCatalogSentenceExercises() {
    return widget.controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .where((entry) => entry.supportsGame('sentence_builder'))
        .where((entry) => foldMizo(entry.exampleMizo)
            .contains(foldMizo(entry.word.trim().split(' ').first)))
        .map((entry) => SentenceExercise(
              id: 'sentence.word.${entry.id}',
              textMizo: entry.exampleMizo,
              englishSupport: entry.englishGloss,
              tqLevel: entry.difficulty,
              keyWord: entry.word.trim(),
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
    await showGameResult(
        context, widget.controller, 'sentence_builder', result);
  }

  void _selectTile(SentenceTile tile) {
    if (isCorrect != null || finishing) return;
    HapticFeedback.selectionClick();
    GameSounds.play(GameSound.tap);
    setState(() => selectedIds.add(tile.id));
    unawaited(runtime.persist());
  }

  void _returnTile(SentenceTile tile) {
    if (isCorrect != null || finishing) return;
    setState(() => selectedIds.remove(tile.id));
    unawaited(runtime.persist());
  }

  Future<void> _hint() async {
    // Once the sentence is right there is nothing left to hint at.
    if (runtime.hintRevealed || finishing || isCorrect == true) return;
    if (gap != null) {
      // Two wrong words go, leaving the right one and one other.
      setState(() {
        picked = null;
        isCorrect = null;
      });
      await runtime.revealHint();
      return;
    }
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

  Future<void> _pick(String option) async {
    final gap = this.gap;
    if (gap == null || !runtime.ready || isCorrect != null || finishing) {
      return;
    }
    final correct = option == gap.entry.word;
    setState(() {
      picked = option;
      isCorrect = correct;
      runtime.answer(correct, wordId: gap.entry.id, word: gap.entry.word);
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
        picked = null;
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
      picked = null;
      isCorrect = null;
      runtime.hintRevealed = false;
    });
    await runtime.persist();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return QuestPage(
        title: AppText.of('sentence.title'),
        child: PremiumCard(child: Text(AppText.of('sentence.empty'))),
      );
    }
    return QuestPage(
      title: GameText.of('sentence_builder').title,
      subtitle: GameText.of('sentence_builder').subtitle,
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
                  // A word's example sentence has no meaning to build, only
                  // the word it is there to teach.
                  gap != null
                      ? AppText.of('sentence.gapPrompt')
                      : question.keyWord == null
                          ? GameText.of('sentence_builder').prompt
                          : AppText.of('sentence.usingWord'),
                  style: const TextStyle(
                    color: QuestColors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  gap != null
                      ? gap!.blanked
                      : question.keyWord == null
                          ? question.englishSupport
                          : '“${question.keyWord}”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if ((gap != null || question.keyWord != null) &&
                    question.englishSupport.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    question.englishSupport,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFFDDF3FF), fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          GameHintButton(
              revealed: runtime.hintRevealed,
              onPressed: isCorrect == true ? null : _hint),
          if (runtime.hintRevealed && gap == null)
            GameHintCard(message: GameText.of('sentence_builder').hint),
          const SizedBox(height: 8),
          if (gap case final gap?)
            for (final option in gap.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Opacity(
                  opacity: gap.ruledOut(option, runtime.hintRevealed) ? .35 : 1,
                  child: AnswerButton(
                    label: option,
                    selected: picked == option,
                    correct: picked == option ? option == gap.entry.word : null,
                    onTap: isCorrect == null &&
                            runtime.ready &&
                            !gap.ruledOut(option, runtime.hintRevealed)
                        ? () => _pick(option)
                        : null,
                  ),
                ),
              )
          else ...<Widget>[
            Text(
              AppText.of('sentence.yours'),
              style: const TextStyle(
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
                    ? const Color(0xFFE6F5E2)
                    : isCorrect == false
                        ? const Color(0xFFFCE4EC)
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
                        onPressed:
                            isCorrect == null ? () => _returnTile(tile) : null,
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
                      onPressed:
                          isCorrect == null ? () => _selectTile(tile) : null,
                    ),
                  )
                  .toList(),
            ),
          ],
          if (isCorrect != null) ...<Widget>[
            const SizedBox(height: 18),
            FeedbackCard(
              correct: isCorrect!,
              message: gap != null
                  ? (isCorrect!
                      ? AppText.of(
                          'sentence.gapRight', {'sentence': question.textMizo})
                      : AppText.of('sentence.gapWrong'))
                  : isCorrect!
                      ? AppText.of(
                          'sentence.right', {'sentence': question.textMizo})
                      : AppText.of(
                          'sentence.wrong', {'sentence': question.textMizo}),
            ),
            ContentReportButton(
              controller: widget.controller,
              contentId: question.id,
            ),
          ],
          const SizedBox(height: 18),
          // A gap is answered by tapping a word; the button only moves on.
          if (gap == null || isCorrect != null)
            FilledButton(
              onPressed: isCorrect == null
                  ? (selectedIds.length == allTiles.length ? _check : null)
                  : _continue,
              child: Text(
                isCorrect == null
                    ? AppText.of('sentence.check')
                    : isCorrect == true
                        ? AppText.of(index == questions.length - 1
                            ? 'sentence.finish'
                            : 'sentence.next')
                        : AppText.of('sentence.retry'),
              ),
            ),
        ],
      ),
    );
  }
}

/// A sentence with a word blanked out, and the words to choose from.
class _Gap {
  const _Gap(
      {required this.blanked, required this.entry, required this.options});

  final String blanked;

  /// The missing word.
  final WordEntry entry;
  final List<String> options;

  /// Whether the hint has taken [option] away: the first two wrong words.
  bool ruledOut(String option, bool hinted) =>
      hinted &&
      option != entry.word &&
      options.where((other) => other != entry.word).take(2).contains(option);
}
