import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/learning/domain/learning_state.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/data.dart';

void main() {
  test('placement persists the level and aligns the learning track', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);

    final level = await controller.completePlacement(correct: 7, total: 10);
    final stored = await repository.loadLearningState();

    expect(level, LearningLevel.level4);
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
      (await repository.loadLearningState()).contentReports['word.in'],
      'picture does not match',
    );
  });

  test('a run of right answers moves the level up once, not every answer',
      () async {
    final controller = QuestController(repository: InMemoryQuestRepository());

    for (var answer = 0; answer < 8; answer += 1) {
      await controller.recordReview(
        itemId: 'word.$answer',
        rating: ReviewRating.good,
      );
    }

    expect(controller.learningState.level, LearningLevel.level2);
    expect(controller.learningState.recentOutcomes, hasLength(3));
  });

  test('moving up a level starts the answer window afresh', () async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    for (var answer = 0; answer < 4; answer += 1) {
      await controller.recordReview(
        itemId: 'word.$answer',
        rating: ReviewRating.good,
      );
    }
    expect(controller.learningState.level, LearningLevel.level1);

    await controller.recordReview(itemId: 'word.4', rating: ReviewRating.good);

    expect(controller.learningState.level, LearningLevel.level2);
    expect(controller.learningState.recentOutcomes, isEmpty);
  });
}
