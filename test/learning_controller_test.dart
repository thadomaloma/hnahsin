import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/learning/domain/learning_state.dart';
import 'package:thumal_quest/src/controller.dart';
import 'package:thumal_quest/src/data.dart';

void main() {
  test('placement persists TQ level and aligns the learning track', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);

    final level = await controller.completePlacement(correct: 7, total: 10);
    final stored = await repository.loadLearningState();

    expect(level, LearningLevel.tq3);
    expect(controller.track, LearningTrack.explorer);
    expect(stored.placementCompleted, isTrue);
    expect(stored.placementCorrect, 7);
  });

  test('review outcome persists mastery and enters the future queue', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);

    await controller.recordReview(
      itemId: 'word.in',
      rating: ReviewRating.good,
    );
    final stored = await repository.loadLearningState();
    final mastery = stored.masteries['word.in'];

    expect(mastery, isNotNull);
    expect(mastery!.attempts, 1);
    expect(mastery.correctAnswers, 1);
    expect(mastery.dueAt.isAfter(DateTime.now().toUtc()), isTrue);
  });

  test('reset clears placement and mastery data', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    await controller.completePlacement(correct: 9, total: 10);
    await controller.recordReview(
      itemId: 'word.in',
      rating: ReviewRating.easy,
    );

    await controller.resetAll();

    expect(controller.learningState.placementCompleted, isFalse);
    expect(controller.learningState.masteries, isEmpty);
    expect((await repository.loadLearningState()).masteries, isEmpty);
  });

  test('content report is deduplicated and persists locally', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);

    await controller.reportContent(
      'word.in',
      reason: 'picture does not match',
    );
    await controller.reportContent('word.in');

    expect(
      (await repository.loadLearningState()).reportedContentIds,
      <String>['word.in'],
    );
    expect(
      (await repository.loadLearningState())
          .contentReports['word.in'],
      'picture does not match',
    );
  });
}
