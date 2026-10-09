import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/src/controller.dart';
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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(AppText.of('launcher.timed')));
    await tester.tap(find.text(AppText.of('launcher.timed')));
    await tester.ensureVisible(find.text(AppText.of('launcher.start')));
    await tester.tap(find.text(AppText.of('launcher.start')));
    await tester.pumpAndSettle();

    expect(find.text('mode:timed'), findsOneWidget);
  });
}
