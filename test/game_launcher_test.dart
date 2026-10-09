import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/game_demo.dart';
import 'package:hnahsin/src/games.dart';

void main() {
  testWidgets('launcher shows resume choice for a saved game', (tester) async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    final engine = GameEngine(
      const GameSessionConfig(
        gameId: 'spelling',
        mode: GameMode.standard,
        seed: 29,
      ),
    )..pause();
    await repository.saveSession(engine.snapshot(currentIndex: 2));

    await tester.pumpWidget(
      MaterialApp(
        home: GameLaunchScreen(
          controller: controller,
          gameId: 'spelling',
          title: 'Spelling',
          subtitle: 'Complete the word',
          instructions: const <String>['Choose a letter.'],
          builder: (mode) => Scaffold(body: Text(mode.name)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text(AppText.of('launcher.saved')), findsOneWidget);
    expect(find.text(AppText.of('launcher.resume')), findsOneWidget);
    expect(find.text(AppText.of('launcher.startNew')), findsOneWidget);
  });

  testWidgets('launcher starts a new timed game', (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    await tester.pumpWidget(
      MaterialApp(
        home: GameLaunchScreen(
          controller: controller,
          gameId: 'word_search',
          title: 'Word Search',
          subtitle: 'Find the words',
          instructions: const <String>['Tap nearby letters.'],
          builder: (mode) => Scaffold(body: Text('mode:${mode.name}')),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    await tester.ensureVisible(find.text(AppText.of('launcher.timed')));
    await tester.tap(find.text(AppText.of('launcher.timed')));
    await tester.ensureVisible(find.text(AppText.of('launcher.start')));
    await tester.tap(find.text(AppText.of('launcher.start')));
    // The demo loops forever, so pump through the page change by hand.
    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('mode:timed'), findsOneWidget);
  });

  testWidgets('every game has a how-to-play demo, still with reduced motion', (tester) async {
    for (final id in ['picture_match', 'spelling', 'word_search', 'word_chain', 'tawng_upa', 'crossword', 'thumal_kawp', 'sentence_builder']) {
      expect(GameDemo.covers(id), isTrue, reason: id);
      for (final reduce in [false, true]) {
        await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduce),
                child: Scaffold(body: GameDemo(gameId: id)))));
        for (var step = 0; step < 10; step++) {
          await tester.pump(const Duration(milliseconds: 460));
        }
        expect(tester.takeException(), isNull, reason: id);
      }
    }
  });
}
