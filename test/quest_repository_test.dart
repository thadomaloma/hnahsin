import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/games/engine/game_engine.dart';
import 'package:thumal_quest/src/controller.dart';
import 'package:thumal_quest/src/game_session.dart';

void main() {
  test('duplicate reward transaction is committed only once', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    final session = GameSession(gameId: 'picture_match', seed: 5)
      ..registerAnswer(true);
    final result = session.finish(baseXp: 30);

    await controller.reward('picture_match', result);
    await controller.reward('picture_match', result);

    expect(controller.xp, result.xp);
    expect(controller.dailyProgress, 1);
    expect(controller.completedGames, contains('picture_match'));
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
