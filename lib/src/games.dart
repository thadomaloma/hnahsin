import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/games/application/game_runtime.dart';
import '../features/games/engine/game_difficulty.dart';
import '../features/games/engine/game_engine.dart';
import 'controller.dart';
import 'data.dart';
import 'editor_tools.dart';
import 'game_session.dart';
import 'game_text.dart';
import 'game_words.dart';
import 'theme.dart';
import 'widgets.dart';

class GameLaunchScreen extends StatefulWidget {
  const GameLaunchScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.gameId,
    required this.instructions,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final QuestController controller;
  final String gameId;
  final List<String> instructions;
  final Widget Function(GameMode mode) builder;

  @override
  State<GameLaunchScreen> createState() => _GameLaunchScreenState();
}

class _GameLaunchScreenState extends State<GameLaunchScreen> {
  GameMode mode = GameMode.relaxed;
  GameSessionSnapshot? savedSession;

  @override
  void initState() {
    super.initState();
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    final saved = await widget.controller.loadSession(widget.gameId);
    if (!mounted || saved == null) return;
    if (saved.status != GameSessionStatus.active &&
        saved.status != GameSessionStatus.paused) return;
    setState(() {
      savedSession = saved;
      mode = saved.mode;
    });
  }

  Future<void> _launch({required bool resume}) async {
    final saved = savedSession;
    if (!resume && saved != null) {
      await widget.controller.clearSession(saved.sessionId);
      if (!mounted) return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => widget.builder(mode)),
    );
  }

  @override
  Widget build(BuildContext context) => QuestPage(
        title: widget.title,
        subtitle: widget.subtitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PremiumCard(
              gradient: const LinearGradient(
                colors: <Color>[QuestColors.midnight, QuestColors.indigo],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('HOW TO PLAY',
                      style: TextStyle(
                          color: QuestColors.teal,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 12),
                  ...widget.instructions.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                    color: QuestColors.gold,
                                    shape: BoxShape.circle),
                                child: Text('${entry.key + 1}',
                                    style: const TextStyle(
                                        color: QuestColors.midnight,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(entry.value,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          height: 1.35,
                                          fontWeight: FontWeight.w700))),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (savedSession != null) ...<Widget>[
              PremiumCard(
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.restore_rounded,
                        color: QuestColors.tealDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Saved game available',
                              style: TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(
                              '${savedSession!.mode.name} mode • ${savedSession!.attempts} attempts',
                              style: const TextStyle(color: QuestColors.slate)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            GameLevelCard(skill: widget.controller.gameSkill(widget.gameId)),
            const SizedBox(height: 18),
            const SectionTitle('Choose a mode'),
            const SizedBox(height: 12),
            AnswerButton(
              label: 'Relaxed — Learn without losing hearts',
              selected: mode == GameMode.relaxed,
              onTap: () => setState(() => mode = GameMode.relaxed),
            ),
            const SizedBox(height: 10),
            AnswerButton(
              label: 'Standard — Three-heart challenge',
              selected: mode == GameMode.standard,
              onTap: () => setState(() => mode = GameMode.standard),
            ),
            const SizedBox(height: 10),
            AnswerButton(
              label: 'Timed — 90-second challenge',
              selected: mode == GameMode.timed,
              onTap: () => setState(() => mode = GameMode.timed),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _launch(resume: savedSession != null),
                icon: Icon(savedSession == null
                    ? Icons.play_arrow_rounded
                    : Icons.restore_rounded),
                label:
                    Text(savedSession == null ? 'Start Game' : 'Resume Game'),
              ),
            ),
            if (savedSession != null) ...<Widget>[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _launch(resume: false),
                  child: const Text('Start New Game'),
                ),
              ),
            ],
          ],
        ),
      );
}

class PictureMatchGame extends StatefulWidget {
  const PictureMatchGame(
      {super.key, required this.controller, this.mode = GameMode.standard});
  final QuestController controller;
  final GameMode mode;
  @override
  State<PictureMatchGame> createState() => _PictureMatchGameState();
}

class _PictureMatchGameState extends State<PictureMatchGame> {
  late final GameRuntime runtime;
  GameSession get session => runtime.session;
  late List<WordEntry> questions;
  late List<List<String>> optionSets;
  int index = 0;
  String? selected;
  bool finishing = false;

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: 'picture_match',
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
          if (selected != null) 'selected': selected,
        },
        restorePayload: (snapshot) {
          _buildRound();
          index = snapshot.currentIndex.clamp(0, questions.length - 1).toInt();
          selected = snapshot.payload['selected'] as String?;
        },
      ),
    );
  }

  void _buildRound() {
    final pool = widget.controller.wordCatalog
        .where((word) => ContentPolicy.playable(word.review))
        .where((word) => word.supportsGame('picture_match'))
        .where(hasWordPicture);
    questions = pickWordsForLevel(
        widget.controller, 'picture_match', pool, 5, session.random);
    final rating = widget.controller.gameSkill('picture_match');
    optionSets = questions.map((question) {
      final seen = <String>{normalizeMizo(question.word)};
      final others = widget.controller.wordCatalog
          .where((word) => ContentPolicy.playable(word.review))
          .where((word) => seen.add(normalizeMizo(word.word)))
          .toList();
      final wrong = GameDifficulty.distractors(question, others,
          rating: rating,
          count: 3,
          similarity: wordSimilarity,
          random: session.random);
      return <String>[question.word, ...wrong.map((word) => word.word)]
        ..shuffle(session.random);
    }).toList();
  }

  Future<void> _timedOut() async {
    if (!mounted || finishing) return;
    finishing = true;
    final result =
        await runtime.finish(baseXp: 30, reason: GameEndReason.timedOut);
    if (!mounted) return;
    await showGameResult(
      context,
      widget.controller,
      'picture_match',
      result,
    );
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  void choose(String value) {
    if (!runtime.ready || selected != null || finishing) return;
    final correct = value == questions[index].word;
    HapticFeedback.selectionClick();
    setState(() {
      selected = value;
      runtime.answer(correct);
    });
  }

  Future<void> next() async {
    if (finishing) return;
    if (!session.hasHearts || index == questions.length - 1) {
      finishing = true;
      if (session.hasHearts) await widget.controller.completeLesson();
      if (!mounted) return;
      final result = await runtime.finish(baseXp: 30);
      if (!mounted) return;
      await showGameResult(context, widget.controller, 'picture_match', result);
      return;
    }
    setState(() {
      index += 1;
      selected = null;
    });
    await runtime.persist();
  }

  Widget _pictureFor(WordEntry entry) => WordPicture(entry: entry, size: 112);

  @override
  Widget build(BuildContext context) {
    final entry = questions[index];
    final answered = selected != null;
    final correct = selected == entry.word;
    return QuestPage(
      title: GameText.of('picture_match').title,
      subtitle: 'Picture vocabulary',
      hud: GameHud(
          session: session,
          progress: (index + 1) / questions.length,
          secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null),
      child: Column(children: [
        if (runtime.restoredSession) const GameResumeBanner(),
        GameStage(
            child: Column(children: [
          _pictureFor(entry),
          const SizedBox(height: 16),
          Text(GameText.of('picture_match').prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        ])),
        GameHintButton(
            revealed: runtime.hintRevealed, onPressed: runtime.revealHint),
        if (runtime.hintRevealed)
          GameHintCard(
              message: fillGameText(GameText.of('picture_match').hint,
                  word: entry.word, gloss: entry.englishGloss, answer: entry.word)),
        const SizedBox(height: 18),
        ...optionSets[index].indexed.map((pair) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnswerButton(
                badge: String.fromCharCode(65 + pair.$1),
                label: pair.$2,
                selected: selected == pair.$2,
                correct: selected == pair.$2 ? pair.$2 == entry.word : null,
                onTap:
                    answered || !runtime.ready ? null : () => choose(pair.$2)))),
        if (answered) ...[
          const SizedBox(height: 6),
          FeedbackCard(
              correct: correct,
              message: correct
                  ? '${entry.word}: ${entry.meaningMizo}\n“${entry.exampleMizo}”'
                  : 'Chhanna dik chu “${entry.word}” a ni.'),
          StudioFixButton(contentId: entry.id),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: next,
                  child: Text(
                      !session.hasHearts || index == questions.length - 1
                          ? 'View Results'
                          : 'Next'))),
        ],
      ]),
    );
  }
}

class SpellingGame extends StatefulWidget {
  const SpellingGame(
      {super.key, required this.controller, this.mode = GameMode.standard});
  final QuestController controller;
  final GameMode mode;
  @override
  State<SpellingGame> createState() => _SpellingGameState();
}

class _SpellingGameState extends State<SpellingGame> {
  late final GameRuntime runtime;
  GameSession get session => runtime.session;
  late List<SpellingQuestion> questions;
  int index = 0;
  String? selected;
  bool finishing = false;

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: 'spelling',
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
          if (selected != null) 'selected': selected,
        },
        restorePayload: (snapshot) {
          _buildRound();
          index = snapshot.currentIndex.clamp(0, questions.length - 1).toInt();
          selected = snapshot.payload['selected'] as String?;
        },
      ),
    );
  }

  void _buildRound() {
    questions = _generateSpellingQuestions();
  }

  /// Builds a spelling round from the live/reviewed word catalog instead of
  /// the fixed `spellingQuestions` prototype list, so newly reviewed and
  /// published content (e.g. the Kumtluang curriculum batch) shows up here
  /// too. Falls back to `spellingQuestions` only if the catalog has nothing
  /// usable yet (fewer than 20 delivered words, per `ContentPolicy`).
  List<SpellingQuestion> _generateSpellingQuestions() {
    final random = session.random;
    final pool = widget.controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .where((entry) => entry.word.trim().length >= 2)
        .where((entry) => entry.supportsGame('spelling'))
        .toList();
    if (pool.isEmpty) {
      return <SpellingQuestion>[...spellingQuestions]..shuffle(random);
    }

    final letterBag = <String>{
      for (final entry in widget.controller.wordCatalog)
        ...entry.word.toUpperCase().split(''),
    }..removeWhere((letter) => !RegExp(r'^[A-ZÂÊÎÔÛṬ]$').hasMatch(letter));
    if (letterBag.length < 4) {
      letterBag.addAll(const ['A', 'E', 'I', 'K', 'N', 'T', 'M', 'R']);
    }

    final knownWords = <String>{
      ...widget.controller.wordCatalog.map((entry) => entry.word.toUpperCase()),
      ...widget.controller.chainVocabulary.map((word) => word.toUpperCase()),
    };

    final selected =
        pickWordsForLevel(widget.controller, 'spelling', pool, 10, random);
    return [
      for (final entry in selected)
        _spellingQuestionFor(entry, random, letterBag, knownWords),
    ];
  }

  SpellingQuestion _spellingQuestionFor(
    WordEntry entry,
    Random random,
    Set<String> letterBag,
    Set<String> knownWords,
  ) {
    final upper = entry.word.toUpperCase();
    final rating = widget.controller.gameSkill('spelling');
    final letterPositions = [
      for (var i = 0; i < upper.length; i++)
        if (RegExp(r'^[A-ZÂÊÎÔÛṬ]$').hasMatch(upper[i])) i,
    ];
    final positions = letterPositions.isEmpty
        ? [for (var i = 0; i < upper.length; i++) i]
        : letterPositions;
    // Higher levels hide the letters learners confuse most (â/a, ṭ/t…).
    final tricky = positions
        .where((i) =>
            GameDifficulty.confusableLetters.containsKey(upper[i]))
        .toList();
    final maskIndex = tricky.isNotEmpty &&
            random.nextDouble() < GameDifficulty.hardness(rating)
        ? tricky[random.nextInt(tricky.length)]
        : positions[random.nextInt(positions.length)];
    final correct = upper[maskIndex];
    final masked = upper.replaceRange(maskIndex, maskIndex + 1, '_');
    // A letter that spells another real word (e.g. a/â pairs) would mark a
    // right answer wrong, so it is never offered.
    final letterOptions = <String>{
      ...letterBag,
      ...?GameDifficulty.confusableLetters[correct],
    }
        .difference(<String>{correct})
        .where((letter) => !knownWords
            .contains(upper.replaceRange(maskIndex, maskIndex + 1, letter)))
        .toList();
    final distractors = GameDifficulty.distractors(correct, letterOptions,
        rating: rating,
        count: 3,
        similarity: GameDifficulty.letterSimilarity,
        random: random);
    final options = <String>{correct, ...distractors}.toList()..shuffle(random);
    return SpellingQuestion(
      masked: masked,
      options: options,
      answer: correct,
      // The meaning often opens with the word itself (“Thlêng chu …”).
      hint: maskWordInClue(entry.meaningMizo, entry.word),
      contentId: entry.id,
    );
  }

  Future<void> _timedOut() async {
    if (!mounted || finishing) return;
    finishing = true;
    final result =
        await runtime.finish(baseXp: 40, reason: GameEndReason.timedOut);
    if (!mounted) return;
    await showGameResult(
      context,
      widget.controller,
      'spelling',
      result,
    );
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  void choose(String value) {
    if (!runtime.ready || selected != null || finishing) return;
    HapticFeedback.selectionClick();
    setState(() {
      selected = value;
      runtime.answer(value == questions[index].answer);
    });
  }

  Future<void> next() async {
    if (finishing) return;
    if (!session.hasHearts || index == questions.length - 1) {
      finishing = true;
      final result = await runtime.finish(baseXp: 40);
      if (!mounted) return;
      await showGameResult(context, widget.controller, 'spelling', result);
      return;
    }
    setState(() {
      index += 1;
      selected = null;
    });
    await runtime.persist();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[index];
    final correct = selected == question.answer;
    return QuestPage(
      title: GameText.of('spelling').title,
      subtitle: 'Complete the Mizo word',
      hud: GameHud(
          session: session,
          progress: (index + 1) / questions.length,
          secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null),
      child: Column(children: [
        if (runtime.restoredSession) const GameResumeBanner(),
        PremiumCard(
            child: Column(children: [
          Text(GameText.of('spelling').prompt,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: QuestColors.slate)),
          const SizedBox(height: 18),
          FittedBox(
              child: Text(question.masked,
                  style: const TextStyle(
                      fontSize: 34,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w900,
                      color: QuestColors.navy))),
          const SizedBox(height: 14),
          Text('CLUE  •  ${question.hint}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: QuestColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ])),
        GameHintButton(
            revealed: runtime.hintRevealed, onPressed: runtime.revealHint),
        if (runtime.hintRevealed)
          GameHintCard(
              message: fillGameText(GameText.of('spelling').hint,
                  answer: question.answer)),
        const SizedBox(height: 18),
        GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: question.options
                .map((option) => AnswerButton(
                    label: option,
                    selected: selected == option,
                    correct:
                        selected == option ? option == question.answer : null,
                    onTap: selected == null && runtime.ready
                        ? () => choose(option)
                        : null))
                .toList()),
        if (selected != null) ...[
          const SizedBox(height: 18),
          FeedbackCard(
              correct: correct,
              message: correct
                  ? 'A dik e! Letter “${question.answer}” dah chuan thumal a kim.'
                  : 'A dik lo. Chhanna dik chu “${question.answer}” a ni.'),
          StudioFixButton(contentId: question.contentId),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: next,
                  child: Text(
                      !session.hasHearts || index == questions.length - 1
                          ? 'View Results'
                          : 'Next'))),
        ],
      ]),
    );
  }
}

class OldWordQuizGame extends StatefulWidget {
  const OldWordQuizGame(
      {super.key, required this.controller, this.mode = GameMode.standard});
  final QuestController controller;
  final GameMode mode;
  @override
  State<OldWordQuizGame> createState() => _OldWordQuizGameState();
}

class _OldWordQuizGameState extends State<OldWordQuizGame> {
  late final GameRuntime runtime;
  GameSession get session => runtime.session;
  late List<ChoiceQuestion> questions;
  int index = 0;
  String? selected;
  bool finishing = false;

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: 'tawng_upa',
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
          if (selected != null) 'selected': selected,
        },
        restorePayload: (snapshot) {
          _buildRound();
          index = snapshot.currentIndex.clamp(0, questions.length - 1).toInt();
          selected = snapshot.payload['selected'] as String?;
        },
      ),
    );
  }

  void _buildRound() {
    questions = _generateMeaningQuestions();
  }

  List<ChoiceQuestion> _generateMeaningQuestions() {
    final random = session.random;
    final pool = widget.controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .where((entry) => entry.meaningMizo.trim().isNotEmpty)
        .toList();
    final distinctMeanings = <String>{
      for (final entry in pool) entry.meaningMizo.trim(),
    };
    // Questions written in Editorial Studio join every round, picked by
    // level alongside the ones generated from word meanings.
    final written = widget.controller.deliveredQuestions;
    if (pool.isEmpty || distinctMeanings.length < 4) {
      return <ChoiceQuestion>[...written, ...oldWordQuestions]..shuffle(random);
    }
    final usedWords = <String>{};
    // Any reviewed meaning can be a wrong option; only words tagged for
    // Tawng Upa (or untagged) are asked about.
    final uniqueWords = pool
        .where((entry) => entry.supportsGame('tawng_upa'))
        .where((entry) => usedWords.add(normalizeMizo(entry.word)));
    final selected =
        pickWordsForLevel(widget.controller, 'tawng_upa', uniqueWords, 10, random);
    final generated = [
      for (final entry in selected) _meaningQuestionFor(entry, random, pool),
    ];
    if (written.isEmpty) return generated;
    return GameDifficulty.pick(
      [...generated, ...written],
      rating: widget.controller.gameSkill('tawng_upa'),
      count: 10,
      difficultyOf: (question) => question.difficulty,
      random: random,
    );
  }

  ChoiceQuestion _meaningQuestionFor(
      WordEntry entry, Random random, List<WordEntry> pool) {
    // Meanings often open with their own word (“Thlêng chu …”), which
    // would point straight at the right option, so every option hides it.
    String meaningOf(WordEntry word) =>
        maskWordInClue(word.meaningMizo.trim(), word.word);
    final correct = meaningOf(entry);
    final rating = widget.controller.gameSkill('tawng_upa');
    final seenMeanings = <String>{correct};
    final distractorPool = pool
        .where((other) => seenMeanings.add(meaningOf(other)))
        .toList();
    final distractors = GameDifficulty.distractors(entry, distractorPool,
            rating: rating,
            count: 3,
            similarity: wordSimilarity,
            random: random)
        .map(meaningOf)
        .toList();
    if (distractors.length < 3) {
      final fallbackMeanings = oldWordQuestions
          .expand((question) => question.options)
          .where((option) => option != correct && !distractors.contains(option))
          .toSet()
          .toList()
        ..shuffle(random);
      distractors.addAll(fallbackMeanings.take(3 - distractors.length));
    }
    final options = [correct, ...distractors]..shuffle(random);
    return ChoiceQuestion(
      prompt: fillGameText(GameText.of('tawng_upa').prompt, word: entry.word),
      options: options,
      answer: correct,
      explanation: '“${entry.word}”: ${entry.meaningMizo.trim()}',
      difficulty: entry.difficulty,
      // From level 4 the picture no longer gives the meaning away.
      emoji: entry.emoji.trim().isEmpty || rating >= 4 ? '💬' : entry.emoji,
      review: entry.review,
      contentId: entry.id,
    );
  }

  Future<void> _timedOut() async {
    if (!mounted || finishing) return;
    finishing = true;
    final result =
        await runtime.finish(baseXp: 50, reason: GameEndReason.timedOut);
    if (!mounted) return;
    await showGameResult(
      context,
      widget.controller,
      'tawng_upa',
      result,
    );
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  void choose(String value) {
    if (!runtime.ready || selected != null || finishing) return;
    HapticFeedback.selectionClick();
    setState(() {
      selected = value;
      runtime.answer(value == questions[index].answer);
    });
  }

  Future<void> next() async {
    if (finishing) return;
    if (!session.hasHearts || index == questions.length - 1) {
      finishing = true;
      final result = await runtime.finish(baseXp: 50);
      if (!mounted) return;
      await showGameResult(context, widget.controller, 'tawng_upa', result);
      return;
    }
    setState(() {
      index += 1;
      selected = null;
    });
    await runtime.persist();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[index];
    final correct = selected == question.answer;
    return QuestPage(
      title: GameText.of('tawng_upa').title,
      subtitle: 'Meaning challenge',
      hud: GameHud(
          session: session,
          progress: (index + 1) / questions.length,
          secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null),
      child: Column(children: [
        if (runtime.restoredSession) const GameResumeBanner(),
        Text(question.emoji, style: const TextStyle(fontSize: 60)),
        const SizedBox(height: 14),
        Text(question.prompt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall),
        GameHintButton(
            revealed: runtime.hintRevealed, onPressed: runtime.revealHint),
        if (runtime.hintRevealed)
          GameHintCard(
              message: fillGameText(GameText.of('tawng_upa').hint,
                  answer: question.answer)),
        const SizedBox(height: 22),
        ...question.options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnswerButton(
                label: option,
                selected: selected == option,
                correct: selected == option ? option == question.answer : null,
                onTap: selected == null && runtime.ready
                    ? () => choose(option)
                    : null))),
        if (selected != null) ...[
          const SizedBox(height: 8),
          FeedbackCard(
              correct: correct,
              message: correct
                  ? question.explanation
                  : 'Chhanna dik chu “${question.answer}” a ni.\n${question.explanation}'),
          StudioFixButton(contentId: question.contentId),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: next,
                  child: Text(
                      !session.hasHearts || index == questions.length - 1
                          ? 'View Results'
                          : 'Next'))),
        ],
      ]),
    );
  }
}

class WordChainGame extends StatefulWidget {
  const WordChainGame(
      {super.key, required this.controller, this.mode = GameMode.standard});
  final QuestController controller;
  final GameMode mode;
  @override
  State<WordChainGame> createState() => _WordChainGameState();
}

class _WordChainGameState extends State<WordChainGame> {
  late final GameRuntime runtime;
  GameSession get session => runtime.session;
  final TextEditingController input = TextEditingController();
  final List<String> chain = ['in'];
  String? message;
  bool messageIsError = false;
  bool finishing = false;

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: 'word_chain',
      mode: widget.mode,
      onChanged: () {
        if (mounted) setState(() {});
      },
      onTimedOut: _timedOut,
    );
    unawaited(
      runtime.initialize(
        currentIndex: () => chain.length - 1,
        readPayload: () => <String, Object?>{
          'chain': chain,
          if (message != null) 'message': message,
          'messageIsError': messageIsError,
        },
        restorePayload: (snapshot) {
          final savedChain = (snapshot.payload['chain'] as List<Object?>?)
                  ?.whereType<String>()
                  .toList() ??
              const <String>[];
          chain
            ..clear()
            ..addAll(savedChain.isEmpty ? const <String>['in'] : savedChain);
          message = snapshot.payload['message'] as String?;
          messageIsError = snapshot.payload['messageIsError'] as bool? ?? false;
        },
      ),
    );
  }

  @override
  void dispose() {
    runtime.dispose();
    input.dispose();
    super.dispose();
  }

  Future<void> _timedOut() async {
    if (!mounted || finishing) return;
    finishing = true;
    final result =
        await runtime.finish(baseXp: 45, reason: GameEndReason.timedOut);
    if (!mounted) return;
    await showGameResult(
      context,
      widget.controller,
      'word_chain',
      result,
    );
  }

  static bool _links(String from, String to) =>
      foldMizo(lastMizoUnit(from)) == foldMizo(firstMizoUnit(to));

  /// Unused words that could follow [word] in the chain.
  Iterable<String> _nextWords(String word, Set<String> vocabulary) => vocabulary
      .where((next) => next != word && !chain.contains(next))
      .where((next) => _links(word, next));

  String get _hintWord {
    final vocabulary = widget.controller.chainVocabulary;
    final lastTurn = chain.length == 5;
    final matches = _nextWords(chain.last, vocabulary)
        .where((word) => lastTurn || _nextWords(word, vocabulary).isNotEmpty)
        .toList()
      ..sort();
    return matches.isEmpty
        ? 'A thumal dang ngaihtuah rawh.'
        : '“${matches.first}” i hmang thei.';
  }

  /// The vocabulary spelling of what was typed; â, ṭ and friends are
  /// optional as long as only one known word matches.
  String? _resolve(String typed, Set<String> vocabulary) {
    if (vocabulary.contains(typed)) return typed;
    final folded = foldMizo(typed);
    final matches = vocabulary.where((word) => foldMizo(word) == folded);
    return matches.length == 1 ? matches.single : null;
  }

  Future<void> submit() async {
    if (!runtime.ready || finishing) return;
    final typed = normalizeMizo(input.text);
    final needed = lastMizoUnit(chain.last);
    if (typed.isEmpty) return;
    final vocabulary = widget.controller.chainVocabulary;
    final resolved = _resolve(typed, vocabulary);
    // A word we don't know yet may still be real Mizo, and a word nothing
    // can follow would leave the learner stuck; neither costs a heart.
    String? notice;
    if (resolved == null) {
      notice = 'He thumal hi kan thumal dahkhâwmnaah a la awm lo. '
          'Thumal dang ziak rawh.';
    } else if (!chain.contains(resolved) &&
        _links(chain.last, resolved) &&
        chain.length < 5 &&
        _nextWords(resolved, vocabulary).isEmpty) {
      notice = '“$resolved” a dik, mahse “${lastMizoUnit(resolved)}” hmanga '
          'bulṭan thumal kan la nei lo. Thumal dang ziak rawh.';
    }
    if (notice != null) {
      setState(() {
        message = notice;
        messageIsError = true;
        input.clear();
      });
      await runtime.persist();
      return;
    }
    final word = resolved!;
    String? error;
    if (chain.contains(word)) {
      error = 'He thumal hi i hmang tawh.';
    } else if (!_links(chain.last, word)) {
      error = '“$needed” hmanga bulṭan tûr a ni.';
    }
    if (error != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        message = error;
        messageIsError = true;
        input.clear();
        runtime.answer(false);
      });
      if (!session.hasHearts) {
        finishing = true;
        final result = await runtime.finish(baseXp: 45);
        if (!mounted) return;
        await showGameResult(context, widget.controller, 'word_chain', result);
      }
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      chain.add(word);
      input.clear();
      message = 'A dik e! “${lastMizoUnit(word)}” hmanga zawm leh rawh.';
      messageIsError = false;
      runtime.answer(true);
    });
    if (chain.length == 6) {
      finishing = true;
      final result = await runtime.finish(baseXp: 45);
      if (!mounted) return;
      await showGameResult(context, widget.controller, 'word_chain', result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final needed = lastMizoUnit(chain.last);
    return QuestPage(
      title: GameText.of('word_chain').title,
      subtitle: 'Build a Mizo word sequence',
      hud: GameHud(
          session: session,
          progress: (chain.length - 1) / 5,
          secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (runtime.restoredSession) const GameResumeBanner(),
        const PremiumCard(
            gradient: LinearGradient(
                colors: [QuestColors.midnight, QuestColors.indigo]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('HOW TO PLAY',
                  style: TextStyle(
                      color: QuestColors.teal,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
              const SizedBox(height: 7),
              const Text(
                  'Thumal tawpna hawrawp inzawm hmangin thumal dang bulṭan rawh.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text('Entîrna: In → Nula → Aizawl → Lal',
                  style: TextStyle(color: Color(0xFFC4D0EA))),
            ])),
        const SizedBox(height: 22),
        const SectionTitle('Kan chain'),
        const SizedBox(height: 12),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chain
                .map((word) => Chip(
                    label: Text('${word[0].toUpperCase()}${word.substring(1)}',
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    backgroundColor: const Color(0xFFD8F8F3),
                    side: BorderSide.none))
                .toList()),
        const SizedBox(height: 24),
        Text('“$needed” hmanga bulṭan rawh',
            style: Theme.of(context).textTheme.titleLarge),
        GameHintButton(
            revealed: runtime.hintRevealed, onPressed: runtime.revealHint),
        if (runtime.hintRevealed)
          GameHintCard(
              message: fillGameText(GameText.of('word_chain').hint,
                  word: _hintWord)),
        const SizedBox(height: 10),
        TextField(
            controller: input,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            onSubmitted: (_) => submit(),
            decoration: InputDecoration(
                hintText: 'Mizo thumal ziak rawh…',
                suffixIcon: IconButton(
                    onPressed: submit,
                    icon: const Icon(Icons.arrow_upward_rounded)))),
        if (message != null) ...[
          const SizedBox(height: 14),
          FeedbackCard(correct: !messageIsError, message: message!)
        ],
        const SizedBox(height: 14),
        const Text('TIP  •  nula, ni, aizawl, ar, lal, lunglei, lehkhabu…',
            style: TextStyle(
                color: QuestColors.slate,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class WordSearchGame extends StatefulWidget {
  const WordSearchGame(
      {super.key, required this.controller, this.mode = GameMode.standard});
  final QuestController controller;
  final GameMode mode;
  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  static const _fallbackTargets = <String>['NULA', 'IN', 'ZAI', 'AWM', 'RAM'];
  static const _gridSize = 6;
  late List<String> grid;
  late Set<String> targets;
  late final GameRuntime runtime;
  GameSession get session => runtime.session;
  final List<(int, int)> selected = [];
  final Set<String> found = {};
  String message = 'Letter-te indawtin tap rawh.';
  bool finishing = false;
  String get current =>
      selected.map((position) => grid[position.$1][position.$2]).join();

  /// Builds the letter grid from the live/reviewed word catalog (words up
  /// to `_gridSize` letters, one per row, left-aligned, remaining cells
  /// filled with plausible letters drawn from the catalog itself) instead
  /// of the fixed 6-word prototype board. Falls back to that fixed board
  /// if fewer than `_fallbackTargets.length` usable words are available.
  void _buildBoard() {
    final random = session.random;
    final rating = widget.controller.gameSkill('word_search');
    final seen = <String>{};
    final candidates = widget.controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .where((entry) => entry.supportsGame('word_search'))
        .where((entry) {
          final word = entry.word.toUpperCase();
          return word.length >= 2 &&
              word.length <= _gridSize &&
              !word.contains(' ') &&
              seen.add(word);
        })
        .toList();

    final words = <String>[
      for (final entry in pickWordsForLevel(widget.controller, 'word_search',
          candidates, _fallbackTargets.length, random))
        entry.word.toUpperCase(),
    ];
    for (final word in _fallbackTargets) {
      if (words.length >= _fallbackTargets.length) break;
      if (!words.contains(word)) words.add(word);
    }

    final catalogLetters = <String>{
      for (final entry in widget.controller.wordCatalog)
        ...entry.word.toUpperCase().split(''),
    }..removeWhere((letter) => !RegExp(r'^[A-ZÂÊÎÔÛṬ]$').hasMatch(letter));
    if (catalogLetters.isEmpty) {
      catalogLetters.addAll(const ['A', 'E', 'I', 'K', 'N', 'T', 'M', 'R']);
    }
    // Higher levels fill the grid with the target words' own letters, so
    // decoy sequences look like real words.
    final targetLetters = [for (final word in words) ...word.split('')];
    final hardness = GameDifficulty.hardness(rating);
    final letterList = catalogLetters.toList();
    String filler() => targetLetters.isNotEmpty && random.nextDouble() < hardness
        ? targetLetters[random.nextInt(targetLetters.length)]
        : letterList[random.nextInt(letterList.length)];

    // Level 1–2: each word starts its row, top to bottom. Level 3+: words
    // sit anywhere in their row and rows are shuffled.
    final scatter = rating >= 3;
    String fillRow(String word) {
      final offset = scatter ? random.nextInt(_gridSize - word.length + 1) : 0;
      final buffer = StringBuffer();
      for (var i = 0; i < offset; i++) {
        buffer.write(filler());
      }
      buffer.write(word);
      while (buffer.length < _gridSize) {
        buffer.write(filler());
      }
      return buffer.toString();
    }

    final rows = <String>[for (final word in words) fillRow(word)];
    while (rows.length < _gridSize) {
      rows.add(fillRow(''));
    }
    if (scatter) rows.shuffle(random);

    grid = rows;
    targets = words.toSet();
  }

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: 'word_search',
      mode: widget.mode,
      onChanged: () {
        if (mounted) setState(() {});
      },
      onTimedOut: _timedOut,
    );
    _buildBoard();
    unawaited(
      runtime.initialize(
        currentIndex: () => found.length,
        readPayload: () => <String, Object?>{
          'found': found.toList(),
          'selected': selected
              .map((position) => '${position.$1},${position.$2}')
              .toList(),
          'message': message,
        },
        restorePayload: (snapshot) {
          _buildBoard();
          found
            ..clear()
            ..addAll(
              (snapshot.payload['found'] as List<Object?>? ?? const <Object?>[])
                  .whereType<String>(),
            );
          selected
            ..clear()
            ..addAll(
              (snapshot.payload['selected'] as List<Object?>? ??
                      const <Object?>[])
                  .whereType<String>()
                  .map(_decodePosition)
                  .whereType<(int, int)>(),
            );
          message = snapshot.payload['message'] as String? ?? message;
        },
      ),
    );
  }

  (int, int)? _decodePosition(String value) {
    final parts = value.split(',');
    if (parts.length != 2) return null;
    final row = int.tryParse(parts[0]);
    final col = int.tryParse(parts[1]);
    if (row == null ||
        col == null ||
        row < 0 ||
        row > 5 ||
        col < 0 ||
        col > 5) {
      return null;
    }
    return (row, col);
  }

  Future<void> _timedOut() async {
    if (!mounted || finishing) return;
    finishing = true;
    final result =
        await runtime.finish(baseXp: 45, reason: GameEndReason.timedOut);
    if (!mounted) return;
    await showGameResult(
      context,
      widget.controller,
      'word_search',
      result,
    );
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  String get _hintWord {
    for (final word in targets) {
      if (!found.contains(word)) return word;
    }
    return 'Thumal zawng zawng i hmu tawh.';
  }

  bool _near(int row, int col) {
    if (selected.isEmpty) return true;
    final last = selected.last;
    return (last.$1 == row && (last.$2 - col).abs() == 1) ||
        (last.$2 == col && (last.$1 - row).abs() == 1);
  }

  Future<void> tapCell(int row, int col) async {
    if (!runtime.ready || finishing) return;
    final position = (row, col);
    if (selected.contains(position)) {
      setState(() {
        selected.clear();
        message = 'Letter bul hnai indawtin thlang rawh.';
      });
      await runtime.persist();
      return;
    }
    // A cell away from the selection starts a new word from that cell.
    setState(() {
      if (!_near(row, col)) selected.clear();
      selected.add(position);
    });
    final word = current;
    if (targets.contains(word) && !found.contains(word)) {
      HapticFeedback.selectionClick();
      setState(() {
        found.add(word);
        selected.clear();
        message = '“$word” i hmu ta!';
        runtime.answer(true);
      });
      if (found.length == targets.length) {
        finishing = true;
        final result = await runtime.finish(baseXp: 45);
        if (!mounted) return;
        await showGameResult(context, widget.controller, 'word_search', result);
      }
      return;
    }
    final canContinue = targets
        .where((target) => !found.contains(target))
        .any((target) => target.startsWith(word));
    if (!canContinue) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        selected.clear();
        message = 'A rem lo. Bulṭan nawn leh rawh.';
      });
      await runtime.persist();
    }
  }

  @override
  Widget build(BuildContext context) => QuestPage(
        title: GameText.of('word_search').title,
        subtitle: 'Find Mizo words in the grid',
        hud: GameHud(
            session: session,
            progress: found.length / targets.length,
            secondsRemaining:
                runtime.isTimed ? runtime.remainingSeconds : null),
        child: Column(children: [
          if (runtime.restoredSession) const GameResumeBanner(),
          GameHintButton(
              revealed: runtime.hintRevealed, onPressed: runtime.revealHint),
          if (runtime.hintRevealed)
            GameHintCard(
                message: fillGameText(GameText.of('word_search').hint,
                    word: _hintWord)),
          PremiumCard(
              padding: const EdgeInsets.all(12),
              child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5),
                    itemCount: 36,
                    itemBuilder: (context, cell) {
                      final row = cell ~/ 6;
                      final col = cell % 6;
                      final active = selected.contains((row, col));
                      return Semantics(
                          label:
                              'Row ${row + 1}, column ${col + 1}, letter ${grid[row][col]}',
                          button: true,
                          selected: active,
                          child: InkWell(
                              onTap: () => tapCell(row, col),
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: active
                                          ? QuestColors.gold
                                          : QuestColors.mist,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ExcludeSemantics(
                                      child: Text(grid[row][col],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 19,
                                              color: QuestColors.navy))))));
                    },
                  ))),
          const SizedBox(height: 18),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          if (selected.isNotEmpty)
            Text(current,
                style: const TextStyle(
                    fontSize: 25,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w900,
                    color: QuestColors.tealDark)),
          const SizedBox(height: 18),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: targets
                  .map((word) => Chip(
                      avatar: Icon(
                          found.contains(word)
                              ? Icons.check_rounded
                              : Icons.search_rounded,
                          size: 17),
                      label: Text(word,
                          style: TextStyle(
                              decoration: found.contains(word)
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.w800)),
                      backgroundColor: found.contains(word)
                          ? const Color(0xFFE1F6EA)
                          : Colors.white,
                      side: BorderSide.none))
                  .toList()),
        ]),
      );
}
