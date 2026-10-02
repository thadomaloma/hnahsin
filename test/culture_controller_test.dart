import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/journey/domain/journey_state.dart';
import 'package:hnahsin/features/learning/domain/learning_state.dart';
import 'package:hnahsin/src/controller.dart';

void main() {
  test('controller persists a reviewed culture-card read', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    await controller.load();

    expect(await controller.collectCultureCard('culture.tlawmngaihna'), isTrue);

    final saved = await repository.loadJourneyState();
    expect(saved.collectedCultureCardIds, contains('culture.tlawmngaihna'));
    expect(
      controller.dailyJourneyQuests
          .singleWhere((item) => item.quest.id == 'daily.culture')
          .completed,
      isTrue,
    );
  });

  test('level lock prevents collecting an advanced culture card', () async {
    final controller = QuestController(repository: InMemoryQuestRepository());

    expect(await controller.collectCultureCard('culture.kut'), isFalse);
    expect(controller.journeyState.collectedCultureCardIds, isEmpty);
  });

  test('quest claim and avatar selection are idempotent', () async {
    final repository = InMemoryQuestRepository(
      journeyState: JourneyState.fresh().copyWith(
        actionCounts: <String, int>{
          '${_todayKey()}:culture': 1,
        },
        trailMarks: 2,
      ),
      learningState: LearningState.fresh().copyWith(
        level: LearningLevel.level3,
      ),
    );
    final controller = QuestController(repository: repository);
    await controller.load();
    final cultureQuest = controller.dailyJourneyQuests
        .singleWhere((item) => item.quest.id == 'daily.culture');

    expect(await controller.claimJourneyQuest(cultureQuest.claimKey), isTrue);
    expect(await controller.claimJourneyQuest(cultureQuest.claimKey), isFalse);
    expect(controller.journeyState.trailMarks, 3);
    expect(await controller.selectJourneyAvatar('avatar.hill_walker'), isTrue);
    expect(await controller.selectJourneyAvatar('avatar.hill_walker'), isFalse);
    expect(controller.selectedAvatar.id, 'avatar.hill_walker');
  });
}

String _todayKey() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}
