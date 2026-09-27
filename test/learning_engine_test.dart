import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/features/learning/domain/learning_engine.dart';
import 'package:thumal_quest/features/learning/domain/learning_state.dart';

void main() {
  const placement = PlacementEngine();
  const scheduler = SpacedRepetitionScheduler();
  const adaptive = AdaptiveDifficulty();
  const planner = DailyLessonPlanner();
  final now = DateTime.utc(2026, 9, 13, 9);

  test('placement maps a ten-question score across TQ0 to TQ4', () {
    expect(placement.levelForScore(correct: 0, total: 10), LearningLevel.tq0);
    expect(placement.levelForScore(correct: 2, total: 10), LearningLevel.tq1);
    expect(placement.levelForScore(correct: 4, total: 10), LearningLevel.tq2);
    expect(placement.levelForScore(correct: 6, total: 10), LearningLevel.tq3);
    expect(placement.levelForScore(correct: 8, total: 10), LearningLevel.tq4);
  });

  test('spaced repetition advances and resets an item deterministically', () {
    final first = scheduler.review(
      itemId: 'word.in',
      rating: ReviewRating.good,
      now: now,
    );
    final second = scheduler.review(
      itemId: 'word.in',
      rating: ReviewRating.good,
      now: now.add(const Duration(days: 1)),
      current: first,
    );
    final lapse = scheduler.review(
      itemId: 'word.in',
      rating: ReviewRating.again,
      now: now.add(const Duration(days: 4)),
      current: second,
    );

    expect(first.intervalDays, 1);
    expect(second.intervalDays, 3);
    expect(second.stage, MasteryStage.familiar);
    expect(lapse.repetitions, 0);
    expect(lapse.lapses, 1);
    expect(lapse.dueAt, now.add(const Duration(days: 4, minutes: 10)));
  });

  test('adaptive difficulty moves only after enough recent evidence', () {
    expect(
      adaptive.recommend(
        current: LearningLevel.tq1,
        recentOutcomes: const <bool>[true, true, true, true],
      ),
      LearningLevel.tq1,
    );
    expect(
      adaptive.recommend(
        current: LearningLevel.tq1,
        recentOutcomes: const <bool>[true, true, true, true, false],
      ),
      LearningLevel.tq2,
    );
    expect(
      adaptive.recommend(
        current: LearningLevel.tq1,
        recentOutcomes: const <bool>[false, false, true, false, false],
      ),
      LearningLevel.tq0,
    );
  });

  test('daily planner prioritizes due reviews before eligible new items', () {
    final due = scheduler.review(
      itemId: 'word.in',
      rating: ReviewRating.good,
      now: now.subtract(const Duration(days: 2)),
    );
    final future = scheduler.review(
      itemId: 'word.nu',
      rating: ReviewRating.easy,
      now: now,
    );
    final state = LearningState.fresh().copyWith(
      level: LearningLevel.tq1,
      masteries: <String, ItemMastery>{
        due.itemId: due,
        future.itemId: future,
      },
    );

    final plan = planner.build(
      state: state,
      allItemIds: const <String>['word.in', 'word.nu', 'word.pa', 'word.sang'],
      itemLevels: const <String, int>{
        'word.in': 0,
        'word.nu': 0,
        'word.pa': 1,
        'word.sang': 3,
      },
      now: now,
    );

    expect(plan.reviewItemIds, <String>['word.in']);
    expect(plan.newItemIds, <String>['word.pa']);
    expect(plan.itemIds.first, 'word.in');
  });

  test('learning state survives a JSON round-trip', () {
    final mastery = scheduler.review(
      itemId: 'word.in',
      rating: ReviewRating.good,
      now: now,
    );
    final original = LearningState.fresh().copyWith(
      level: LearningLevel.tq2,
      placementCompleted: true,
      placementCorrect: 5,
      placementTotal: 10,
      masteries: <String, ItemMastery>{mastery.itemId: mastery},
      recentOutcomes: const <bool>[true, false],
      contentReports: const <String, String>{'word.in': 'wrong meaning'},
    );

    final restored = LearningState.fromJson(original.toJson());

    expect(restored.level, LearningLevel.tq2);
    expect(restored.placementCompleted, isTrue);
    expect(restored.masteries['word.in']!.intervalDays, 1);
    expect(restored.recentOutcomes, <bool>[true, false]);
    expect(restored.reportedContentIds, <String>['word.in']);
    expect(restored.contentReports['word.in'], 'wrong meaning');
  });
}
