import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/progress/domain/quest_progress.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/game_session.dart';

GameResult _round({required int correct, int attempts = 10, String id = 'r1', GameEndReason reason = GameEndReason.completed}) => GameResult(
      sessionId: id,
      rewardTransactionId: 'reward.$id',
      score: correct * 100,
      correctAnswers: correct,
      attempts: attempts,
      bestCombo: correct,
      heartsLeft: 3,
      xp: 40,
      endReason: reason,
    );

void main() {
  test('a perfect round raises the game level and is saved', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    expect(controller.gameSkill('spelling'), 1);

    final outcome = await controller.reward('spelling', _round(correct: 10));

    expect(outcome.skill, greaterThan(1.5));
    expect(controller.gameSkill('spelling'), outcome.skill);
    expect(controller.gameSkill('picture_match'), 1, reason: 'levels are per game');
    final saved = await repository.loadProgress();
    expect(saved.gameSkills['spelling'], (outcome.skill * 100).round());
  });

  test('losing every heart steps the level down and higher levels earn more XP', () async {
    final controller = QuestController(
      repository: InMemoryQuestRepository(
        progress: QuestProgress.empty().copyWith(gameSkills: const {'tawng_upa': 450}),
      ),
    );
    await controller.load();

    final outcome = await controller.reward(
      'tawng_upa',
      _round(correct: 7, reason: GameEndReason.heartsExhausted),
    );

    expect(outcome.skill, lessThan(4.5));
    expect(outcome.levelledDown, isFalse, reason: '4.5 → 4.1 stays level 4');
    expect(outcome.xp, greaterThan(40));
  });

  test('game skills survive a JSON round-trip', () {
    final progress = QuestProgress.empty().copyWith(gameSkills: const {'word_search': 320});
    expect(QuestProgress.fromJson(progress.toJson()).gameSkills, {'word_search': 320});
    expect(QuestProgress.fromJson(QuestProgress.empty().toJson()).gameSkills, isEmpty);
  });
}
