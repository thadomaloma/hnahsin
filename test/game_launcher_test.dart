import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/games/engine/game_engine.dart';
import 'package:thumal_quest/src/controller.dart';
import 'package:thumal_quest/src/games.dart';

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

    expect(find.text('Saved game available'), findsOneWidget);
    expect(find.text('Resume Game'), findsOneWidget);
    expect(find.text('Start New Game'), findsOneWidget);
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

    await tester.ensureVisible(find.text('Timed — Second 90 chhungin'));
    await tester.tap(find.text('Timed — Second 90 chhungin'));
    await tester.ensureVisible(find.text('Start Game'));
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    expect(find.text('mode:timed'), findsOneWidget);
  });
}
