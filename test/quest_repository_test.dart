import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/game_session.dart';

void main() {
  test('duplicate reward transaction is committed only once', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    final session =
        GameSession(gameId: 'picture_match', mode: GameMode.relaxed, seed: 5)
          ..registerAnswer(true);
    final result = session.finish(baseXp: 30);

    await controller.reward('picture_match', result);
    await controller.reward('picture_match', result);

    expect(controller.xp, result.xp);
    expect(controller.dailyProgress, 1);
    expect(controller.completedGames, contains('picture_match'));
  });

  test('Classic and Speed earn more XP, and keep their own best score',
      () async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    final earned = <GameMode, int>{};
    for (final mode in GameMode.values) {
      final result = (GameSession(gameId: 'spelling', mode: mode, seed: 3)
            ..registerAnswer(true))
          .finish(baseXp: 40);
      earned[mode] = (await controller.reward('spelling', result)).xp;
      expect(controller.bestScore('spelling', mode), result.score);
    }
    expect(
        earned[GameMode.standard], (earned[GameMode.relaxed]! * 1.25).round());
    expect(earned[GameMode.timed], (earned[GameMode.relaxed]! * 1.5).round());
  });

  test('the play mode and seen how-to-plays are remembered', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    await controller.setPlayMode(GameMode.timed);
    await controller.markHowToSeen('spelling');

    final reloaded = QuestController(repository: repository);
    await reloaded.load();
    expect(reloaded.playMode, GameMode.timed);
    expect(reloaded.seenHowTo, {'spelling'});
  });

  test('reset clears local learner progress', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    final session = GameSession(gameId: 'spelling', seed: 8)
      ..registerAnswer(true);
    await controller.reward('spelling', session.finish(baseXp: 40));

    await controller.resetAll();

    expect(controller.xp, 0);
    expect(controller.completedGames, isEmpty);
    expect(controller.profile.onboardingCompleted, isFalse);
  });

  test('repository restores a saved in-progress game snapshot', () async {
    final repository = InMemoryQuestRepository();
    final engine = GameEngine(
      const GameSessionConfig(gameId: 'picture_match', seed: 13),
    )..registerAnswer(isCorrect: true);
    await repository.saveSession(engine.snapshot(currentIndex: 2));

    final restored = await repository.loadSession('picture_match');

    expect(restored, isNotNull);
    expect(restored!.currentIndex, 2);
    expect(restored.score, 100);
  });
}
