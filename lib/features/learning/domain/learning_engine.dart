import 'dart:math';

import 'learning_state.dart';

class PlacementEngine {
  const PlacementEngine();

  LearningLevel levelForScore({required int correct, required int total}) {
    if (total <= 0) return LearningLevel.level1;
    final ratio = correct.clamp(0, total) / total;
    if (ratio < .2) return LearningLevel.level1;
    if (ratio < .4) return LearningLevel.level2;
    if (ratio < .6) return LearningLevel.level3;
    if (ratio < .8) return LearningLevel.level4;
    return LearningLevel.level5;
  }
}

class SpacedRepetitionScheduler {
  const SpacedRepetitionScheduler();

  ItemMastery review({
    required String itemId,
    required ReviewRating rating,
    required DateTime now,
    ItemMastery? current,
  }) {
    final previous = current ?? ItemMastery.unseen(itemId, now);
    var repetitions = previous.repetitions;
    var interval = previous.intervalDays;
    var ease = previous.easeFactor;
    var lapses = previous.lapses;

    switch (rating) {
      case ReviewRating.again:
        repetitions = 0;
        interval = 0;
        ease = max(1.3, ease - .2);
        lapses += 1;
      case ReviewRating.hard:
        repetitions += 1;
        interval = max(1, (max(1, interval) * 1.2).round());
        ease = max(1.3, ease - .05);
      case ReviewRating.good:
        repetitions += 1;
        interval = repetitions == 1
            ? 1
            : repetitions == 2
                ? 3
                : max(4, (max(1, interval) * ease).round());
      case ReviewRating.easy:
        repetitions += 1;
        interval = repetitions == 1
            ? 3
            : repetitions == 2
                ? 7
                : max(8, (max(1, interval) * ease * 1.3).round());
        ease = min(3.0, ease + .1);
    }

    final correct = rating != ReviewRating.again;
    final dueAt = rating == ReviewRating.again
        ? now.toUtc().add(const Duration(minutes: 10))
        : now.toUtc().add(Duration(days: interval));
    return ItemMastery(
      itemId: itemId,
      stage: _stageFor(repetitions),
      repetitions: repetitions,
      intervalDays: interval,
      easeFactor: ease,
      attempts: previous.attempts + 1,
      correctAnswers: previous.correctAnswers + (correct ? 1 : 0),
      lapses: lapses,
      dueAt: dueAt,
      lastReviewedAt: now.toUtc(),
    );
  }

  MasteryStage _stageFor(int repetitions) {
    if (repetitions <= 1) return MasteryStage.learning;
    if (repetitions == 2) return MasteryStage.familiar;
    if (repetitions == 3) return MasteryStage.strong;
    return MasteryStage.mastered;
  }
}

class AdaptiveDifficulty {
  const AdaptiveDifficulty();

  LearningLevel recommend({
    required LearningLevel current,
    required List<bool> recentOutcomes,
  }) {
    if (recentOutcomes.length < 5) return current;
    final window = recentOutcomes.length > 8
        ? recentOutcomes.sublist(recentOutcomes.length - 8)
        : recentOutcomes;
    final accuracy = window.where((value) => value).length / window.length;
    if (accuracy >= .8 && current.index < LearningLevel.values.length - 1) {
      return LearningLevel.values[current.index + 1];
    }
    if (accuracy <= .4 && current.index > 0) {
      return LearningLevel.values[current.index - 1];
    }
    return current;
  }
}

class DailyLessonPlan {
  const DailyLessonPlan({
    required this.reviewItemIds,
    required this.newItemIds,
  });

  final List<String> reviewItemIds;
  final List<String> newItemIds;

  List<String> get itemIds => <String>[...reviewItemIds, ...newItemIds];
  int get total => reviewItemIds.length + newItemIds.length;
  bool get isEmpty => total == 0;
}

class DailyLessonPlanner {
  const DailyLessonPlanner();

  DailyLessonPlan build({
    required LearningState state,
    required List<String> allItemIds,
    required Map<String, int> itemLevels,
    required DateTime now,
    int reviewLimit = 5,
    int newLimit = 5,
  }) {
    final due = state.masteries.values
        .where((item) => item.stage != MasteryStage.unseen && item.isDue(now))
        .toList()
      ..sort((a, b) {
        final dueOrder = a.dueAt.compareTo(b.dueAt);
        return dueOrder == 0 ? a.itemId.compareTo(b.itemId) : dueOrder;
      });

    final eligibleNew = allItemIds
        .where((id) => !state.masteries.containsKey(id))
        .where((id) => (itemLevels[id] ?? 0) <= state.level.index)
        .toList();

    return DailyLessonPlan(
      reviewItemIds: List<String>.unmodifiable(
        due.take(reviewLimit).map((item) => item.itemId),
      ),
      newItemIds: List<String>.unmodifiable(eligibleNew.take(newLimit)),
    );
  }
}
