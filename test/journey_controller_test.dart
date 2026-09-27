import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/learning/domain/learning_state.dart';
import 'package:thumal_quest/src/controller.dart';

void main() {
  test('controller persists story completion and reward exactly once', () async {
    final repository = InMemoryQuestRepository(
      learningState: LearningState.fresh().copyWith(
        level: LearningLevel.tq1,
      ),
    );
    final controller = QuestController(repository: repository);
    await controller.load();

    expect(controller.nextJourneyNode?.id, 'journey.homecoming');
    expect(
      await controller.completeJourneyStory(
        nodeId: 'journey.homecoming',
        choicesMade: 2,
      ),
      isTrue,
    );
    await controller.completeJourneyStory(
      nodeId: 'journey.homecoming',
      choicesMade: 2,
    );

    final saved = await repository.loadJourneyState();
    expect(saved.completedNodeIds, <String>{'journey.homecoming'});
    expect(saved.unlockedRewardIds, <String>{'reward.home_scarf'});
    expect(saved.storyChoices, 2);
    expect(controller.learningState.masteries.keys, containsAll(<String>['in', 'nu', 'ei']));
    expect(
      controller.dailyJourneyQuests
          .singleWhere((item) => item.quest.id == 'daily.review')
          .completed,
      isTrue,
    );
    expect(controller.nextJourneyNode?.id, 'journey.river_walk');
  });

  test('locked story cannot be completed out of order', () async {
    final repository = InMemoryQuestRepository(
      learningState: LearningState.fresh().copyWith(
        level: LearningLevel.tq4,
      ),
    );
    final controller = QuestController(repository: repository);
    await controller.load();

    final completed = await controller.completeJourneyStory(
      nodeId: 'journey.helping_hand',
      choicesMade: 2,
    );

    expect(completed, isFalse);
    expect(controller.journeyState.completedNodeIds, isEmpty);
  });

  test('reset clears journey and engagement data', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    await controller.completeJourneyStory(
      nodeId: 'journey.homecoming',
      choicesMade: 2,
    );

    await controller.resetAll();

    expect(controller.journeyState.completedNodeIds, isEmpty);
    expect((await repository.loadJourneyState()).completedNodeIds, isEmpty);
  });
}
