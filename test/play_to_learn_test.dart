import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/games/application/game_runtime.dart';
import 'package:thumal_quest/features/games/engine/game_difficulty.dart';
import 'package:thumal_quest/features/games/engine/game_engine.dart';
import 'package:thumal_quest/features/learning/domain/learning_state.dart';
import 'package:thumal_quest/src/controller.dart';
import 'package:thumal_quest/src/game_session.dart';
import 'package:thumal_quest/src/game_words.dart';
import 'package:thumal_quest/src/games.dart';
import 'package:thumal_quest/src/widgets.dart';

GameRuntime _runtime(QuestController controller) => GameRuntime(
      controller: controller,
      gameId: 'picture_match',
      mode: GameMode.relaxed,
      onChanged: () {},
      onTimedOut: () async {},
    );

Future<void> _start(GameRuntime runtime) => runtime.initialize(
      currentIndex: () => 0,
      readPayload: () => const <String, Object?>{},
      restorePayload: (_) {},
    );

void main() {
  testWidgets('a round remembers each word: missed ones come back soon', (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    final runtime = _runtime(controller);
    addTearDown(runtime.dispose);
    await _start(runtime);

    runtime.answer(true, wordId: 'word.ui', word: 'ui');
    runtime.answer(false, wordId: 'word.ar', word: 'ar');
    runtime.answer(true, wordId: 'word.ar', word: 'ar'); // right the second time, still missed
    await runtime.revealHint();
    runtime.answer(true, wordId: 'word.tui', word: 'tui');
    runtime.answer(true); // not about a word (e.g. a sentence)

    final result = await runtime.finish(baseXp: 30);
    expect(result.words.map((w) => (w.word, w.missed, w.hinted)), [
      ('ui', false, false),
      ('ar', true, false),
      ('tui', false, true),
    ]);
    final memory = controller.learningState.masteries;
    expect(memory['word.ar']!.lapses, 1);
    expect(memory['word.ar']!.stage, MasteryStage.learning);
    expect(memory['word.ui']!.lapses, 0);
    expect(memory.keys, containsAll(['word.ui', 'word.ar', 'word.tui']));
  });

  testWidgets('a resumed round keeps the words it has asked about', (tester) async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    final first = _runtime(controller);
    await _start(first);
    first.answer(false, wordId: 'word.ar', word: 'ar');
    await first.persist();
    first.dispose();

    final second = _runtime(controller);
    addTearDown(second.dispose);
    await second.initialize(
      currentIndex: () => 0,
      readPayload: () => const <String, Object?>{},
      restorePayload: (_) {},
    );
    expect(second.restoredSession, isTrue);
    expect(second.playedWords.single.missed, isTrue);
  });

  test('what the player remembers changes how often a word comes up', () {
    final now = DateTime.utc(2026, 10, 1, 12);
    ItemMastery memory({required MasteryStage stage, int lapses = 0, required DateTime due}) => ItemMastery(
          itemId: 'w',
          stage: stage,
          repetitions: 1,
          intervalDays: 1,
          easeFactor: 2.5,
          attempts: 1,
          correctAnswers: lapses == 0 ? 1 : 0,
          lapses: lapses,
          dueAt: due,
          lastReviewedAt: now,
        );
    final later = now.add(const Duration(days: 3));
    expect(wordMemoryBoost(null, now), 1);
    expect(wordMemoryBoost(memory(stage: MasteryStage.learning, lapses: 1, due: later), now), 3);
    expect(wordMemoryBoost(memory(stage: MasteryStage.familiar, due: now), now), 2);
    expect(wordMemoryBoost(memory(stage: MasteryStage.mastered, due: later), now), .35);
  });

  test('a boosted word is picked far more often than a well-known one', () {
    var missed = 0, known = 0;
    for (var seed = 0; seed < 400; seed++) {
      final pick = GameDifficulty.pick(
        ['missed', 'known', 'a', 'b', 'c', 'd'],
        rating: 1,
        count: 3,
        difficultyOf: (_) => 1,
        random: Random(seed),
        boost: (item) => switch (item) { 'missed' => 3.0, 'known' => .35, _ => 1.0 },
      );
      if (pick.contains('missed')) missed++;
      if (pick.contains('known')) known++;
    }
    expect(missed, greaterThan(known * 2));
  });

  testWidgets('a right answer moves on by itself, unless a screen reader is on', (tester) async {
    for (final screenReader in [false, true]) {
      var advanced = 0;
      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(accessibleNavigation: screenReader),
        child: _Harness(onReady: (state) => advanceAfterRightAnswer(state,
            stillWaiting: () => true, next: () async => advanced++)),
      ));
      await tester.pump(rightAnswerPause - const Duration(milliseconds: 100));
      expect(advanced, 0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(advanced, screenReader ? 0 : 1, reason: 'screen reader $screenReader');
    }
  });

  testWidgets('the result shows the round\'s words and Khelh leh starts again', (tester) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = QuestController(repository: InMemoryQuestRepository());
    _FakeGame.started = 0;
    await tester.pumpWidget(MaterialApp(home: _FakeGame(controller: controller)));
    expect(_FakeGame.started, 1);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Thumal i hmuh te'), findsOneWidget);
    expect(find.text('ar'), findsOneWidget);
    expect(find.text('A sen te hi i khelh leh hunah an lo lang leh ang.'), findsOneWidget);

    await tester.tap(find.text('Khelh leh'));
    await tester.pumpAndSettle();
    expect(_FakeGame.started, 2);
    expect(find.text('Finish'), findsOneWidget);
  });
}

class _Harness extends StatefulWidget {
  const _Harness({required this.onReady});
  final void Function(State<StatefulWidget>) onReady;
  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onReady(this);
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class _FakeGame extends StatefulWidget {
  const _FakeGame({required this.controller});
  final QuestController controller;
  static int started = 0;
  @override
  State<_FakeGame> createState() => _FakeGameState();
}

class _FakeGameState extends State<_FakeGame> {
  @override
  void initState() {
    super.initState();
    _FakeGame.started++;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => showGameResult(
              context,
              widget.controller,
              'picture_match',
              const GameResult(
                sessionId: 's',
                rewardTransactionId: 'r',
                score: 20,
                correctAnswers: 2,
                attempts: 3,
                bestCombo: 2,
                heartsLeft: 3,
                xp: 30,
                endReason: GameEndReason.completed,
                words: [WordPlay(id: 'word.ar', word: 'ar', missed: true), WordPlay(id: 'word.ui', word: 'ui')],
              ),
            ),
            child: const Text('Finish'),
          ),
        ),
      );
}
