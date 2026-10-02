import 'dart:async';
import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/games/application/game_runtime.dart';
import '../features/games/engine/game_engine.dart';
import 'controller.dart';
import 'data.dart';
import 'spelling_round.dart';
import 'word_search_board.dart';
import 'game_session.dart';
import 'game_text.dart';
import 'game_words.dart';
import 'meaning_round.dart';
import 'theme.dart';
import 'widgets.dart';
import 'app_text.dart';

/// How long a right answer stays on screen before the round moves on.
const rightAnswerPause = Duration(milliseconds: 1100);

/// A right answer moves the round on by itself after [rightAnswerPause], so
/// play keeps its pace; a wrong one waits for Next so the player can take
/// in the right answer. Not with a screen reader, which needs the time.
void advanceAfterRightAnswer(State<StatefulWidget> state,
    {required bool Function() stillWaiting,
    required Future<void> Function() next}) {
  if (MediaQuery.of(state.context).accessibleNavigation) return;
  Future<void>.delayed(rightAnswerPause, () {
    if (state.mounted && stillWaiting()) next();
  });
}

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
                  Text(AppText.of('launcher.howToPlay'),
                      style: const TextStyle(
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
                          Text(AppText.of('launcher.saved'),
                              style: const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(
                              AppText.of('launcher.savedDetail', {
                                'mode': AppText.of('launcher.modeName.${savedSession!.mode.name}'),
                                'attempts': savedSession!.attempts,
                              }),
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
            SectionTitle(AppText.of('launcher.chooseMode')),
            const SizedBox(height: 12),
            AnswerButton(
              label: AppText.of('launcher.relaxed'),
              selected: mode == GameMode.relaxed,
              onTap: () => setState(() => mode = GameMode.relaxed),
            ),
            const SizedBox(height: 10),
            AnswerButton(
              label: AppText.of('launcher.standard'),
              selected: mode == GameMode.standard,
              onTap: () => setState(() => mode = GameMode.standard),
            ),
            const SizedBox(height: 10),
            AnswerButton(
              label: AppText.of('launcher.timed'),
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
                label: Text(savedSession == null
                    ? AppText.of('launcher.start')
                    : AppText.of('launcher.resume')),
              ),
            ),
            if (savedSession != null) ...<Widget>[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _launch(resume: false),
                  child: Text(AppText.of('launcher.startNew')),
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
      final wrong = pictureMatchDistractors(
          question, widget.controller.wordCatalog,
          rating: rating, random: session.random);
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
    final entry = questions[index];
    final correct = value == entry.word;
    HapticFeedback.selectionClick();
    setState(() {
      selected = value;
      runtime.answer(correct, wordId: entry.id, word: entry.word);
    });
    final at = index;
    if (correct) {
      advanceAfterRightAnswer(this,
          stillWaiting: () => !finishing && index == at, next: next);
    }
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
      subtitle: GameText.of('picture_match').subtitle,
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
              style:
                  const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        ])),
        GameHintButton(
            revealed: runtime.hintRevealed,
            onPressed: answered ? null : runtime.revealHint),
        if (runtime.hintRevealed)
          GameHintCard(
              message: fillGameText(GameText.of('picture_match').hint,
                  word: entry.word,
                  gloss: entry.englishGloss,
                  answer: entry.word)),
        const SizedBox(height: 18),
        ...optionSets[index].indexed.map((pair) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnswerButton(
                badge: String.fromCharCode(65 + pair.$1),
                label: pair.$2,
                selected: selected == pair.$2,
                correct: selected == pair.$2 ? pair.$2 == entry.word : null,
                onTap: answered || !runtime.ready
                    ? null
                    : () => choose(pair.$2)))),
        if (answered) ...[
          const SizedBox(height: 6),
          FeedbackCard(
              correct: correct,
              message: correct
                  ? AppText.of('picture.right', {'word': entry.word, 'gloss': entry.englishGloss})
                  : AppText.of('picture.wrong', {
                      'word': entry.word,
                      'meaning': entry.meaningMizo,
                      'example': entry.exampleMizo,
                    })),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: next,
                  child: Text(
                      !session.hasHearts || index == questions.length - 1
                          ? AppText.of('common.viewResults')
                          : AppText.of('common.next')))),
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

  List<SpellingQuestion> _generateSpellingQuestions() => buildSpellingRound(
        catalog: widget.controller.wordCatalog,
        knownWords: widget.controller.chainVocabulary,
        rating: widget.controller.gameSkill('spelling'),
        random: session.random,
        pick: (pool, count) => pickWordsForLevel(
            widget.controller, 'spelling', pool, count, session.random),
      );

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
      final question = questions[index];
      runtime.answer(value == question.answer,
          wordId: question.contentId, word: question.word);
    });
    final at = index;
    if (value == questions[index].answer) {
      advanceAfterRightAnswer(this,
          stillWaiting: () => !finishing && index == at, next: next);
    }
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
    // The hint takes away two wrong letters rather than naming the answer.
    final ruledOut = runtime.hintRevealed
        ? question.options
            .where((option) => option != question.answer)
            .take(2)
            .toSet()
        : const <String>{};
    return QuestPage(
      title: GameText.of('spelling').title,
      subtitle: GameText.of('spelling').subtitle,
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
              // Once answered, the whole word.
              child: Text(selected == null ? question.masked : question.word,
                  style: const TextStyle(
                      fontSize: 34,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w900,
                      color: QuestColors.navy))),
          const SizedBox(height: 14),
          Text(AppText.of('spelling.clue', {'hint': question.hint}),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: QuestColors.slate,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ])),
        GameHintButton(
            revealed: runtime.hintRevealed,
            onPressed: selected != null ? null : runtime.revealHint),
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
                .map((option) => Opacity(
                    opacity: ruledOut.contains(option) ? .35 : 1,
                    child: AnswerButton(
                        label: option,
                        selected: selected == option,
                        correct: selected == option
                            ? option == question.answer
                            : null,
                        onTap: selected == null &&
                                runtime.ready &&
                                !ruledOut.contains(option)
                            ? () => choose(option)
                            : null)))
                .toList()),
        if (selected != null) ...[
          const SizedBox(height: 18),
          FeedbackCard(
              correct: correct,
              message: correct
                  ? '${AppText.of('spelling.right', {'word': question.word})}'
                      '${question.gloss.isEmpty ? '' : '\n${question.gloss}'}'
                  : '${AppText.of('spelling.wrong', {'answer': question.answer, 'word': question.word})}'
                      '${question.gloss.isEmpty ? '' : '\n${question.gloss}'}'),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: next,
                  child: Text(
                      !session.hasHearts || index == questions.length - 1
                          ? AppText.of('common.viewResults')
                          : AppText.of('common.next')))),
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
          final saved = snapshot.payload['selected'] as String?;
          // Content synced since the save can change the options.
          selected =
              questions[index].options.contains(saved) ? saved : null;
        },
      ),
    );
  }

  void _buildRound() {
    questions = _generateMeaningQuestions();
  }

  List<ChoiceQuestion> _generateMeaningQuestions() => buildMeaningRound(
        catalog: widget.controller.wordCatalog,
        written: widget.controller.deliveredQuestions,
        rating: widget.controller.gameSkill('tawng_upa'),
        random: session.random,
        pick: (pool, count) => pickWordsForLevel(
            widget.controller, 'tawng_upa', pool, count, session.random),
      );

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
      final question = questions[index];
      runtime.answer(value == question.answer,
          wordId: question.word == null ? null : question.contentId,
          word: question.word);
    });
    final at = index;
    if (value == questions[index].answer) {
      advanceAfterRightAnswer(this,
          stillWaiting: () => !finishing && index == at, next: next);
    }
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
    // The hint takes away two wrong meanings rather than naming the answer,
    // always leaving at least one wrong one beside it.
    final wrong =
        question.options.where((option) => option != question.answer);
    final ruledOut = runtime.hintRevealed
        ? wrong.take(min(2, wrong.length - 1)).toSet()
        : const <String>{};
    return QuestPage(
      title: GameText.of('tawng_upa').title,
      subtitle: GameText.of('tawng_upa').subtitle,
      hud: GameHud(
          session: session,
          progress: (index + 1) / questions.length,
          secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null),
      child: Column(children: [
        if (runtime.restoredSession) const GameResumeBanner(),
        Text(question.emoji, style: const TextStyle(fontSize: 60)),
        const SizedBox(height: 14),
        if (question.instruction.isNotEmpty) ...[
          Text(question.instruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: QuestColors.slate, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
        ],
        Text(question.prompt,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall),
        GameHintButton(
            revealed: runtime.hintRevealed,
            onPressed: selected != null ? null : runtime.revealHint),
        if (runtime.hintRevealed)
          GameHintCard(
              message: fillGameText(GameText.of('tawng_upa').hint,
                  answer: question.answer)),
        const SizedBox(height: 22),
        ...question.options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Opacity(
                opacity: ruledOut.contains(option) ? .35 : 1,
                child: AnswerButton(
                    label: option,
                    selected: selected == option,
                    correct:
                        selected == option ? option == question.answer : null,
                    onTap: selected == null &&
                            runtime.ready &&
                            !ruledOut.contains(option)
                        ? () => choose(option)
                        : null)))),
        if (selected != null) ...[
          const SizedBox(height: 8),
          FeedbackCard(
              correct: correct,
              // A right answer already was the meaning; a wrong one shows it.
              message: correct
                  ? ''
                  : AppText.of('tawngUpa.wrong', {
                      'answer': question.answer,
                      'explanation': question.explanation,
                    })),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: next,
                  child: Text(
                      !session.hasHearts || index == questions.length - 1
                          ? AppText.of('common.viewResults')
                          : AppText.of('common.next')))),
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
  final List<String> chain = [];
  late final Set<String> vocabulary;

  /// Vocabulary words by their first letter, for finding what can follow.
  late final Map<String, List<String>> byFirstLetter;

  /// Catalog entries by normalized word, for meanings and difficulty.
  late final Map<String, WordEntry> entries;
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
    vocabulary = widget.controller.chainVocabulary;
    byFirstLetter = <String, List<String>>{};
    for (final word in vocabulary) {
      (byFirstLetter[firstMizoUnit(word)] ??= <String>[]).add(word);
    }
    entries = <String, WordEntry>{
      for (final entry in widget.controller.wordCatalog.reversed)
        normalizeMizo(entry.word): entry,
    };
    final start = _pickStart();
    chain.add(start);
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
            ..addAll(savedChain.isEmpty ? <String>[start] : savedChain);
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

  /// A word to start from: at the learner's level, with plenty of words
  /// that can follow it, so every round opens differently.
  String _pickStart() {
    final starts = widget.controller.wordCatalog.where((entry) {
      final word = normalizeMizo(entry.word);
      return vocabulary.contains(word) && _nextWords(word).length >= 8;
    });
    final picked = pickWordsForLevel(
        widget.controller, 'word_chain', starts, 1, session.random);
    return picked.isEmpty ? 'in' : normalizeMizo(picked.single.word);
  }

  static bool _links(String from, String to) =>
      lastMizoUnit(from) == firstMizoUnit(to);

  /// Unused words that could follow [word] in the chain.
  Iterable<String> _nextWords(String word) =>
      (byFirstLetter[lastMizoUnit(word)] ?? const <String>[])
          .where((next) => next != word && !chain.contains(next));

  /// Words that can come next without leaving the learner stuck.
  List<String> get _playable {
    final lastTurn = chain.length == 5;
    return _nextWords(chain.last)
        .where((word) => lastTurn || _nextWords(word).isNotEmpty)
        .toList();
  }

  String get _hintWord {
    // The easiest word the learner is likely to know.
    final matches = _playable
      ..sort((a, b) {
        final byLevel = (entries[a]?.difficulty ?? 1)
            .compareTo(entries[b]?.difficulty ?? 1);
        return byLevel != 0 ? byLevel : a.compareTo(b);
      });
    return matches.isEmpty
        ? AppText.of('chain.hintNone')
        : AppText.of('chain.hint', {'word': matches.first});
  }

  /// “nula (young woman)” — what a word means, when the catalog knows.
  String _withMeaning(String word) {
    final entry = entries[word];
    final meaning = entry == null
        ? ''
        : (entry.englishGloss.trim().isNotEmpty
            ? entry.englishGloss.trim()
            : entry.meaningMizo.trim());
    return meaning.isEmpty
        ? AppText.of('chain.word', {'word': word})
        : AppText.of('chain.wordMeaning', {'word': word, 'meaning': meaning});
  }

  /// The vocabulary spelling of what was typed; â, ṭ and friends are
  /// optional as long as only one known word matches.
  String? _resolve(String typed) {
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
    final resolved = _resolve(typed);
    // A word we don't know yet may still be real Mizo, and a word nothing
    // can follow would leave the learner stuck; neither costs a heart.
    String? notice;
    if (resolved == null) {
      notice = AppText.of('chain.unknown');
    } else if (!chain.contains(resolved) &&
        _links(chain.last, resolved) &&
        chain.length < 5 &&
        _nextWords(resolved).isEmpty) {
      notice = AppText.of('chain.deadEnd', {'word': resolved, 'unit': lastMizoUnit(resolved)});
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
      error = AppText.of('chain.used');
    } else if (!_links(chain.last, word)) {
      error = AppText.of('chain.wrongStart', {
        'word': word,
        'start': firstMizoUnit(word),
        'needed': needed,
      });
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
      // The card's own heading already says “A dik e!”.
      message = chain.length == 6
          ? _withMeaning(word)
          : AppText.of('chain.linked', {'word': _withMeaning(word), 'unit': lastMizoUnit(word)});
      messageIsError = false;
      final entry = entries[word];
      runtime.answer(true, wordId: entry?.id, word: entry?.word);
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
      subtitle: GameText.of('word_chain').subtitle,
      hud: GameHud(
          session: session,
          progress: (chain.length - 1) / 5,
          secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (runtime.restoredSession) const GameResumeBanner(),
        PremiumCard(
            gradient: const LinearGradient(
                colors: const [QuestColors.midnight, QuestColors.indigo]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppText.of('chain.howToPlay'),
                  style: const TextStyle(
                      color: QuestColors.teal,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
              const SizedBox(height: 7),
              Text(AppText.of('chain.rule'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(AppText.of('chain.example'),
                  style: const TextStyle(color: Color(0xFFDDF3FF))),
            ])),
        const SizedBox(height: 22),
        SectionTitle(AppText.of('chain.title')),
        const SizedBox(height: 12),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chain
                .map((word) => Chip(
                    label: Text('${word[0].toUpperCase()}${word.substring(1)}',
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    backgroundColor: const Color(0xFFDDF3FF),
                    side: BorderSide.none))
                .toList()),
        if (chain.length == 1) ...[
          const SizedBox(height: 8),
          Text(AppText.of('chain.start', {'word': _withMeaning(chain.single)}),
              style: const TextStyle(
                  color: QuestColors.slate, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 24),
        Text(AppText.of('chain.needed', {'unit': needed}),
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
                hintText: AppText.of('chain.input'),
                suffixIcon: IconButton(
                    onPressed: submit,
                    icon: const Icon(Icons.arrow_upward_rounded)))),
        if (message != null) ...[
          const SizedBox(height: 14),
          FeedbackCard(correct: !messageIsError, message: message!)
        ],
        const SizedBox(height: 14),
        Text(
            AppText.of('chain.tip', {'unit': needed, 'n': _playable.length}),
            style: const TextStyle(
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
  late List<String> grid;
  late Map<String, List<(int, int)>> placements;
  late Map<String, String> labels;
  Iterable<String> get targets => placements.keys;
  String _label(String word) => labels[word] ?? word;
  late final GameRuntime runtime;
  GameSession get session => runtime.session;
  final List<(int, int)> selected = [];
  final Set<String> found = {};
  String message = AppText.of('search.start');
  bool finishing = false;
  String get current =>
      selected.map((position) => grid[position.$1][position.$2]).join();

  /// English meanings of the catalog's words by their grid letters, shown
  /// when one is found.
  late final Map<String, String> glosses = {
    for (final entry in widget.controller.wordCatalog.reversed)
      wordSearchLetters(entry.word): entry.englishGloss.trim(),
  };

  /// The catalog's words by their grid letters, to remember found words.
  late final Map<String, WordEntry> wordEntries = {
    for (final entry in widget.controller.wordCatalog.reversed)
      wordSearchLetters(entry.word): entry,
  };

  void _buildBoard() {
    final board = buildWordSearchBoard(
      catalog: widget.controller.wordCatalog,
      rating: widget.controller.gameSkill('word_search'),
      random: session.random,
      pick: (pool, count) => pickWordsForLevel(
          widget.controller, 'word_search', pool, count, session.random),
    );
    grid = board.rows;
    placements = board.placements;
    labels = board.labels;
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
                  .whereType<String>()
                  .where(placements.containsKey),
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
        row >= grid.length ||
        col < 0 ||
        col >= grid.length) {
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
    return AppText.of('search.allFound');
  }

  /// Whether (row, col) continues the selection in a straight line: next
  /// to the last cell, and in the same direction as the cells before it.
  bool _extends(int row, int col) {
    if (selected.isEmpty) return true;
    final last = selected.last;
    final (dr, dc) = (row - last.$1, col - last.$2);
    if (dr.abs() + dc.abs() != 1) return false;
    if (selected.length == 1) return true;
    final before = selected[selected.length - 2];
    return dr == last.$1 - before.$1 && dc == last.$2 - before.$2;
  }

  Future<void> tapCell(int row, int col) async {
    if (!runtime.ready || finishing) return;
    final position = (row, col);
    if (selected.contains(position)) {
      setState(() {
        selected.clear();
        message = AppText.of('search.adjacent');
      });
      await runtime.persist();
      return;
    }
    // A cell away from the selection starts a new word from that cell.
    setState(() {
      if (!_extends(row, col)) selected.clear();
      selected.add(position);
    });
    final word = current;
    if (targets.contains(word) && !found.contains(word)) {
      HapticFeedback.selectionClick();
      setState(() {
        found.add(word);
        selected.clear();
        final gloss = glosses[word] ?? '';
        message = gloss.isEmpty
            ? AppText.of('search.found', {'word': _label(word)})
            : AppText.of('search.foundGloss',
                {'word': _label(word), 'gloss': gloss});
        final entry = wordEntries[word];
        runtime.answer(true, wordId: entry?.id, word: entry?.word);
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
        message = AppText.of('search.noMatch');
      });
      await runtime.persist();
    }
  }

  @override
  Widget build(BuildContext context) => QuestPage(
        title: GameText.of('word_search').title,
        subtitle: GameText.of('word_search').subtitle,
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
                    word: _label(_hintWord))),
          PremiumCard(
              padding: const EdgeInsets.all(12),
              child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: grid.length,
                            mainAxisSpacing: grid.length > 6 ? 4 : 5,
                            crossAxisSpacing: grid.length > 6 ? 4 : 5),
                    itemCount: grid.length * grid.length,
                    itemBuilder: (context, cell) {
                      final row = cell ~/ grid.length;
                      final col = cell % grid.length;
                      final active = selected.contains((row, col));
                      final isFound = found.any(
                          (word) => placements[word]!.contains((row, col)));
                      // The hint marks where the next word starts.
                      final hinted = runtime.hintRevealed &&
                          placements[_hintWord]?.first == (row, col);
                      return Semantics(
                          label:
                              AppText.of('search.cellSpoken', {'row': row + 1, 'column': col + 1, 'letter': grid[row][col]}),
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
                                          : isFound
                                              ? const Color(0xFFE6F5E2)
                                              : QuestColors.mist,
                                      border: hinted
                                          ? Border.all(
                                              color: QuestColors.coral,
                                              width: 3)
                                          : null,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ExcludeSemantics(
                                      child: Text(grid[row][col],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: grid.length > 6 ? 15 : 19,
                                              color: isFound && !active
                                                  ? QuestColors.successInk
                                                  : QuestColors.navy))))));
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
                      label: Text(_label(word),
                          style: TextStyle(
                              decoration: found.contains(word)
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.w800)),
                      backgroundColor: found.contains(word)
                          ? const Color(0xFFE6F5E2)
                          : Colors.white,
                      side: BorderSide.none))
                  .toList()),
        ]),
      );
}
