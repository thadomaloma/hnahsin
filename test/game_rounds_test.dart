import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/games/engine/game_engine.dart';
import 'package:thumal_quest/src/controller.dart';
import 'package:thumal_quest/src/games.dart';

Finder _hearts(int left) => find.bySemanticsLabel(RegExp('^$left of 3 hearts'));

void main() {
  testWidgets('word chain: an unknown word costs no heart, a wrong link does',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = QuestController(repository: InMemoryQuestRepository());
    await tester.pumpWidget(MaterialApp(
        home: WordChainGame(controller: controller, mode: GameMode.standard)));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'qwxz');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.textContaining('a la awm lo'), findsOneWidget);
    expect(_hearts(3), findsOneWidget);

    // "lal" is known but cannot follow "in".
    await tester.enterText(find.byType(TextField), 'lal');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(_hearts(2), findsOneWidget);
  });

  testWidgets('crossword resumes the puzzle its saved letters belong to',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<List<String>> resumedClues() async {
      final repository = InMemoryQuestRepository();
      final engine = GameEngine(const GameSessionConfig(
          gameId: 'crossword', mode: GameMode.relaxed, seed: 7))
        ..pause();
      await repository.saveSession(engine.snapshot(payload: const {
        'cells': {'1,1': 'Q'},
      }));
      await tester.pumpWidget(MaterialApp(
          key: UniqueKey(),
          home: MiniCrosswordGame(
              controller: QuestController(repository: repository),
              mode: GameMode.relaxed)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Q'), findsOneWidget);
      return tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .where((data) => data.contains('→') || data.contains('↓'))
          .toList();
    }

    final first = await resumedClues();
    final second = await resumedClues();
    expect(first, isNotEmpty);
    expect(second, first);
  });
}
