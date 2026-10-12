import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../src/app_text.dart';
import '../../../src/controller.dart';
import '../../../src/game_session.dart';
import '../../../src/game_text.dart';
import '../../../src/games.dart' show advanceAfterRightAnswer;
import '../../../src/game_words.dart';
import '../../../src/odd_one_out.dart';
import '../../../src/widgets.dart';
import '../application/game_runtime.dart';
import '../engine/game_engine.dart';

/// Odd One Out: four words, three of one kind. Find the one that doesn't
/// belong. Levels 1–2 show the words' pictures too.
class OddOneOutGame extends StatefulWidget {
  const OddOneOutGame(
      {super.key, required this.controller, this.mode = GameMode.standard});

  static const gameId = 'odd_one_out';

  final QuestController controller;
  final GameMode mode;

  @override
  State<OddOneOutGame> createState() => _OddOneOutGameState();
}

class _OddOneOutGameState extends State<OddOneOutGame> {
  late final GameRuntime runtime;
  GameSession get session => runtime.session;
  late List<OddOneOutQuestion> questions;
  late bool withPictures;
  int index = 0;
  String? selected;
  bool finishing = false;

  @override
  void initState() {
    super.initState();
    runtime = GameRuntime(
      controller: widget.controller,
      gameId: OddOneOutGame.gameId,
      mode: widget.mode,
      onChanged: () {
        if (mounted) setState(() {});
      },
      onTimedOut: () => _finish(GameEndReason.timedOut),
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
          index = snapshot.currentIndex
              .clamp(0, questions.isEmpty ? 0 : questions.length - 1)
              .toInt();
          selected = snapshot.payload['selected'] as String?;
        },
      ),
    );
  }

  void _buildRound() {
    final rating = widget.controller.gameSkill(OddOneOutGame.gameId);
    withPictures = rating < 3;
    questions = buildOddOneOutRound(
      catalog: widget.controller.wordCatalog,
      rating: rating,
      random: session.random,
      pick: (pool, count) => pickWordsForLevel(
          widget.controller, OddOneOutGame.gameId, pool, count, session.random),
    );
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  void choose(String id) {
    if (!runtime.ready || selected != null || finishing) return;
    final question = questions[index];
    final correct = id == question.odd.id;
    HapticFeedback.selectionClick();
    setState(() {
      selected = id;
      runtime.answer(correct, wordId: question.odd.id, word: question.odd.word);
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
      await _finish();
      return;
    }
    setState(() {
      index += 1;
      selected = null;
    });
    await runtime.persist();
  }

  Future<void> _finish([GameEndReason? reason]) async {
    if (!mounted || finishing) return;
    finishing = true;
    final result = await runtime.finish(baseXp: 40, reason: reason);
    if (!mounted) return;
    await showGameResult(
        context, widget.controller, OddOneOutGame.gameId, result);
  }

  String _groupName(String id) => AppText.of('group.$id');

  @override
  Widget build(BuildContext context) {
    final copy = GameText.of(OddOneOutGame.gameId);
    if (questions.isEmpty) {
      return QuestPage(
        title: copy.title,
        child: PremiumCard(child: Text(AppText.of('oddOne.empty'))),
      );
    }
    final question = questions[index];
    final answered = selected != null;
    final correct = selected == question.odd.id;
    final three = [
      for (final entry in question.options)
        if (entry.id != question.odd.id) entry.word
    ];
    return QuestPage(
      title: copy.title,
      subtitle: copy.subtitle,
      hud: GameHud(
          session: session,
          progress: (index + 1) / questions.length,
          secondsRemaining: runtime.isTimed ? runtime.remainingSeconds : null),
      child: Column(children: [
        if (runtime.restoredSession) const GameResumeBanner(),
        GameStage(
          child: Text(copy.prompt,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        ),
        GameHintButton(
            revealed: runtime.hintRevealed,
            onPressed: answered ? null : runtime.revealHint),
        if (runtime.hintRevealed)
          GameHintCard(
              message: fillGameText(copy.hint,
                  gloss: _groupName(question.group.id))),
        const SizedBox(height: 18),
        for (final (i, entry) in question.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnswerButton(
              badge: String.fromCharCode(65 + i),
              label: withPictures && entry.emoji.trim().isNotEmpty
                  ? '${entry.emoji}  ${entry.word}'
                  : entry.word,
              selected: selected == entry.id,
              correct:
                  selected == entry.id ? entry.id == question.odd.id : null,
              onTap: answered || !runtime.ready ? null : () => choose(entry.id),
            ),
          ),
        if (answered) ...[
          const SizedBox(height: 6),
          FeedbackCard(
            correct: correct,
            message: AppText.of(correct ? 'oddOne.right' : 'oddOne.wrong', {
              'odd': question.odd.word,
              'three': three.join(', '),
              'group': _groupName(question.group.id),
              'oddGroup': _groupName(question.oddGroup.id),
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: next,
              child: Text(!session.hasHearts || index == questions.length - 1
                  ? AppText.of('common.viewResults')
                  : AppText.of('common.next')),
            ),
          ),
        ],
      ]),
    );
  }
}
