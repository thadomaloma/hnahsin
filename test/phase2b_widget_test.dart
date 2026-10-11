import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/game_text.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/features/games/presentation/phase2b_games.dart';
import 'package:hnahsin/features/games/presentation/thumal_kawp_game.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/widgets.dart';

void main() {
  testWidgets('Thumal Kawp deals hidden pairs sized to the learner level',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = QuestController(repository: InMemoryQuestRepository());
    await tester.pumpWidget(
      MaterialApp(
        home: ThumalKawpGame(controller: controller, mode: GameMode.relaxed),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Thumal Kawp'), findsOneWidget);
    final hidden = find.bySemanticsLabel(AppText.of('kawp.hiddenSpoken'));
    expect(hidden, findsNWidgets(8), reason: 'level 1 plays four pairs');

    await tester.tap(hidden.first);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(AppText.of('kawp.hiddenSpoken')),
        findsNWidgets(7));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sentence builder opens with accessible game controls',
      (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    await tester.pumpWidget(
      MaterialApp(
        home: SentenceBuilderGame(
          controller: controller,
          mode: GameMode.relaxed,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Sentence Builder'), findsOneWidget);
    // A translated sentence asks for its meaning; a word's example shows the word.
    expect(
        find.text(GameText.of('sentence_builder').prompt).evaluate().length +
            find.text(AppText.of('sentence.usingWord')).evaluate().length,
        1);
    expect(find.text(AppText.of('sentence.check')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sentence builder\'s second question can ask for a missing word',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Not every sentence has a word to blank out: find a round whose
    // second one does.
    var found = false;
    for (var seed = 1; seed <= 20 && !found; seed++) {
      final repository = InMemoryQuestRepository();
      final engine = GameEngine(GameSessionConfig(
          gameId: 'sentence_builder', mode: GameMode.relaxed, seed: seed))
        ..pause();
      await repository.saveSession(engine.snapshot(currentIndex: 1));
      await tester.pumpWidget(MaterialApp(
          key: ValueKey(seed),
          home: SentenceBuilderGame(
              controller: QuestController(repository: repository),
              mode: GameMode.relaxed)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      found = find.text(AppText.of('sentence.gapPrompt')).evaluate().isNotEmpty;
    }
    expect(found, isTrue);

    expect(find.textContaining('____'), findsOneWidget);
    expect(find.text(AppText.of('sentence.yours')), findsNothing);
    final options = find.byType(AnswerButton);
    expect(options, findsNWidgets(4));

    await tester.tap(options.first);
    await tester.pump();
    expect(
        find.textContaining('That\'s the word!').evaluate().length +
            find.text(AppText.of('sentence.gapWrong')).evaluate().length,
        1);
    expect(tester.takeException(), isNull);
  });
}
