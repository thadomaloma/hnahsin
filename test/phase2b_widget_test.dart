import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/game_text.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/features/games/presentation/phase2b_games.dart';
import 'package:hnahsin/features/games/presentation/thumal_kawp_game.dart';
import 'package:hnahsin/src/controller.dart';

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
    expect(find.bySemanticsLabel(AppText.of('kawp.hiddenSpoken')), findsNWidgets(7));
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
    expect(find.text(GameText.of('sentence_builder').prompt), findsOneWidget);
    expect(find.text(AppText.of('sentence.check')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
