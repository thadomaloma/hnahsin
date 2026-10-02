import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/journey/domain/journey_content.dart';
import 'package:hnahsin/features/journey/domain/journey_engine.dart';
import 'package:hnahsin/features/journey/domain/journey_models.dart';
import 'package:hnahsin/features/journey/domain/journey_state.dart';

void main() {
  const engine = JourneyEngine();

  test('first node is available and later nodes stay locked', () {
    final state = JourneyState.fresh();

    expect(
      engine.statusFor(
        node: journeyNodes[0],
        state: state,
        learningLevel: 0,
      ),
      JourneyNodeStatus.available,
    );
    expect(
      engine.statusFor(
        node: journeyNodes[1],
        state: state,
        learningLevel: 4,
      ),
      JourneyNodeStatus.locked,
    );
  });

  test('story completion unlocks reward, culture card and next node', () {
    final completed = engine.completeStory(
      state: JourneyState.fresh(),
      node: journeyNodes[0],
      story: journeyStories[0],
      now: DateTime(2026, 9, 13, 12),
      learningLevel: 1,
      choicesMade: 2,
    );

    expect(completed.completedNodeIds, contains('journey.homecoming'));
    expect(completed.unlockedRewardIds, contains('reward.home_scarf'));
    expect(completed.collectedCultureCardIds, contains('story.homecoming'));
    expect(completed.storyChoices, 2);
    expect(
      engine.statusFor(
        node: journeyNodes[1],
        state: completed,
        learningLevel: 1,
      ),
      JourneyNodeStatus.available,
    );
  });

  test('replaying a story cannot duplicate completion progress', () {
    final first = engine.completeStory(
      state: JourneyState.fresh(),
      node: journeyNodes[0],
      story: journeyStories[0],
      now: DateTime(2026, 9, 13),
      learningLevel: 1,
      choicesMade: 2,
    );
    final replay = engine.completeStory(
      state: first,
      node: journeyNodes[0],
      story: journeyStories[0],
      now: DateTime(2026, 9, 13),
      learningLevel: 1,
      choicesMade: 2,
    );

    expect(replay.completedNodeIds.length, 1);
    expect(replay.storyChoices, 2);
    expect(
      replay.actionCounts['2026-09-13:${JourneyAction.story.key}'],
      2,
    );
  });

  test('one missed day consumes grace without losing the rhythm', () {
    var state = engine.recordAction(
      state: JourneyState.fresh(),
      action: JourneyAction.review,
      now: DateTime(2026, 9, 10),
    );
    state = engine.recordAction(
      state: state,
      action: JourneyAction.review,
      now: DateTime(2026, 9, 12),
    );

    expect(state.streakDays, 2);
    expect(state.graceAvailable, isFalse);
  });

  test('a longer absence starts gently at one', () {
    var state = engine.recordAction(
      state: JourneyState.fresh(),
      action: JourneyAction.story,
      now: DateTime(2026, 9, 1),
    );
    state = engine.recordAction(
      state: state,
      action: JourneyAction.story,
      now: DateTime(2026, 9, 8),
    );

    expect(state.streakDays, 1);
    expect(state.graceAvailable, isTrue);
  });

  test('daily quests use bounded progress and reset by date', () {
    var state = JourneyState.fresh();
    for (var count = 0; count < 3; count += 1) {
      state = engine.recordAction(
        state: state,
        action: JourneyAction.review,
        now: DateTime(2026, 9, 13),
      );
    }

    final today = engine.dailyQuests(
      state: state,
      now: DateTime(2026, 9, 13),
    );
    final tomorrow = engine.dailyQuests(
      state: state,
      now: DateTime(2026, 9, 14),
    );

    expect(
      today.singleWhere((item) => item.quest.id == 'daily.review').completed,
      isTrue,
    );
    expect(
      tomorrow.singleWhere((item) => item.quest.id == 'daily.review').progress,
      0,
    );
  });

  test('journey state round-trips without losing collections', () {
    final original = JourneyState.fresh().copyWith(
      completedNodeIds: <String>{'journey.homecoming'},
      collectedCultureCardIds: <String>{'story.homecoming'},
      unlockedRewardIds: <String>{'reward.home_scarf'},
      actionCounts: <String, int>{'2026-09-13:story': 1},
      streakDays: 3,
      lastActiveDay: '2026-09-13',
      storyChoices: 2,
      healthyStops: 1,
      claimedQuestKeys: <String>{'2026-09-13:daily.story'},
      trailMarks: 4,
      selectedAvatarId: 'avatar.hill_walker',
    );

    final restored = JourneyState.fromJson(original.toJson());

    expect(restored.completedNodeIds, original.completedNodeIds);
    expect(restored.actionCounts, original.actionCounts);
    expect(restored.streakDays, 3);
    expect(restored.healthyStops, 1);
    expect(restored.trailMarks, 4);
    expect(restored.selectedAvatarId, 'avatar.hill_walker');
  });
}
