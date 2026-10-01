import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/src/controller.dart';
import 'package:thumal_quest/src/game_session.dart';

GameResult _round(int seed) {
  final session = GameSession(gameId: 'picture_match', seed: seed)..registerAnswer(true);
  return session.finish(baseXp: 30);
}

void main() {
  test('daily rounds start over each day and the streak counts days in a row', () async {
    var now = DateTime(2026, 10, 1, 9);
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository, clock: () => now);

    expect(controller.roundsToday, 0);
    expect(controller.currentStreak, 0, reason: 'nothing played yet');

    await controller.reward('picture_match', _round(1));
    await controller.reward('picture_match', _round(2));
    expect(controller.roundsToday, 2);
    expect(controller.currentStreak, 1);

    now = DateTime(2026, 10, 2, 8); // next morning
    expect(controller.roundsToday, 0, reason: 'yesterday does not carry over');
    expect(controller.currentStreak, 1, reason: 'still alive until today is missed');
    await controller.reward('picture_match', _round(3));
    expect(controller.roundsToday, 1);
    expect(controller.currentStreak, 2);

    now = DateTime(2026, 10, 4, 20); // a day skipped
    expect(controller.currentStreak, 0);
    await controller.reward('picture_match', _round(4));
    expect(controller.currentStreak, 1);

    final reloaded = QuestController(repository: repository, clock: () => now);
    await reloaded.load();
    expect(reloaded.playDay, '2026-10-04');
    expect(reloaded.roundsToday, 1);
    expect(reloaded.currentStreak, 1);
  });

  test('today\'s game changes at local midnight', () {
    var now = DateTime(2026, 10, 1, 23, 59);
    final controller = QuestController(clock: () => now);
    final today = controller.dayNumber;
    now = DateTime(2026, 10, 2, 0, 1);
    expect(controller.dayNumber, today + 1);
  });
}
