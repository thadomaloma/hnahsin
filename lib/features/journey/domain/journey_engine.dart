import 'journey_models.dart';
import 'journey_state.dart';

enum JourneyNodeStatus { completed, available, locked }

class JourneyEngine {
  const JourneyEngine();

  String dayKey(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  JourneyNodeStatus statusFor({
    required JourneyNode node,
    required JourneyState state,
    required int learningLevel,
  }) {
    if (state.completedNodeIds.contains(node.id)) {
      return JourneyNodeStatus.completed;
    }
    final prerequisitesMet = node.prerequisiteNodeIds
        .every(state.completedNodeIds.contains);
    return prerequisitesMet && learningLevel >= node.minimumLevel
        ? JourneyNodeStatus.available
        : JourneyNodeStatus.locked;
  }

  JourneyState completeStory({
    required JourneyState state,
    required JourneyNode node,
    required StoryEpisode story,
    required DateTime now,
    required int learningLevel,
    required int choicesMade,
  }) {
    if (statusFor(
          node: node,
          state: state,
          learningLevel: learningLevel,
        ) ==
        JourneyNodeStatus.locked) {
      return state;
    }
    final today = dayKey(now);
    final streak = _advanceStreak(state: state, today: today);
    final alreadyCompleted = state.completedNodeIds.contains(node.id);
    final counts = _increment(
      state.actionCounts,
      '$today:${JourneyAction.story.key}',
      1,
    );
    return state.copyWith(
      completedNodeIds: <String>{...state.completedNodeIds, node.id},
      collectedCultureCardIds: <String>{
        ...state.collectedCultureCardIds,
        story.id,
      },
      unlockedRewardIds: <String>{...state.unlockedRewardIds, node.rewardId},
      actionCounts: counts,
      streakDays: streak.days,
      graceAvailable: streak.graceAvailable,
      lastActiveDay: today,
      lastCompletedNodeId: node.id,
      storyChoices: state.storyChoices + (alreadyCompleted ? 0 : choicesMade),
    );
  }

  JourneyState recordAction({
    required JourneyState state,
    required JourneyAction action,
    required DateTime now,
    int amount = 1,
  }) {
    if (amount <= 0) return state;
    final today = dayKey(now);
    final streak = _advanceStreak(state: state, today: today);
    return state.copyWith(
      actionCounts: _increment(
        state.actionCounts,
        '$today:${action.key}',
        amount,
      ),
      streakDays: streak.days,
      graceAvailable: streak.graceAvailable,
      lastActiveDay: today,
    );
  }

  JourneyState acknowledgeHealthyStop(JourneyState state) => state.copyWith(
        healthyStops: state.healthyStops + 1,
      );

  JourneyState collectCultureCard({
    required JourneyState state,
    required CultureCard card,
    required DateTime now,
  }) {
    final withAction = recordAction(
      state: state,
      action: JourneyAction.culture,
      now: now,
    );
    return withAction.copyWith(
      collectedCultureCardIds: <String>{
        ...withAction.collectedCultureCardIds,
        card.id,
      },
    );
  }

  JourneyState claimQuest({
    required JourneyState state,
    required QuestProgressView progress,
  }) {
    if (!progress.completed ||
        progress.claimed ||
        state.claimedQuestKeys.contains(progress.claimKey)) {
      return state;
    }
    return state.copyWith(
      claimedQuestKeys: <String>{
        ...state.claimedQuestKeys,
        progress.claimKey,
      },
      trailMarks: state.trailMarks + progress.quest.rewardMarks,
    );
  }

  JourneyState selectAvatar({
    required JourneyState state,
    required AvatarStyle avatar,
  }) {
    if (state.trailMarks < avatar.requiredMarks ||
        state.selectedAvatarId == avatar.id) {
      return state;
    }
    return state.copyWith(selectedAvatarId: avatar.id);
  }

  List<QuestProgressView> dailyQuests({
    required JourneyState state,
    required DateTime now,
  }) {
    final key = dayKey(now);
    return dailyQuestCatalog
        .map(
          (quest) => QuestProgressView(
            quest: quest,
            progress: state.actionCounts['$key:${quest.action.key}'] ?? 0,
            claimKey: '$key:${quest.id}',
            claimed: state.claimedQuestKeys.contains('$key:${quest.id}'),
          ),
        )
        .toList(growable: false);
  }

  String weekKey(DateTime value) {
    final local = value.toLocal();
    final monday = local.subtract(Duration(days: local.weekday - 1));
    return 'week:${dayKey(monday)}';
  }

  List<QuestProgressView> weeklyQuests({
    required JourneyState state,
    required DateTime now,
  }) {
    final key = weekKey(now);
    return weeklyQuestCatalog
        .map(
          (quest) => QuestProgressView(
            quest: quest,
            progress: weeklyActionCount(
              state: state,
              action: quest.action,
              now: now,
            ),
            claimKey: '$key:${quest.id}',
            claimed: state.claimedQuestKeys.contains('$key:${quest.id}'),
          ),
        )
        .toList(growable: false);
  }

  int weeklyActionCount({
    required JourneyState state,
    required JourneyAction action,
    required DateTime now,
  }) {
    final local = now.toLocal();
    final monday = local.subtract(Duration(days: local.weekday - 1));
    var total = 0;
    for (var offset = 0; offset < 7; offset += 1) {
      final date = monday.add(Duration(days: offset));
      total += state.actionCounts['${dayKey(date)}:${action.key}'] ?? 0;
    }
    return total;
  }

  int weeklyStoryCount({
    required JourneyState state,
    required DateTime now,
  }) {
    return weeklyActionCount(
      state: state,
      action: JourneyAction.story,
      now: now,
    );
  }

  bool shouldShowComeback({
    required JourneyState state,
    required DateTime now,
  }) {
    final last = _parseDay(state.lastActiveDay);
    if (last == null) return false;
    return _calendarDaysBetween(last, now.toLocal()) >= 2;
  }

  Map<String, int> _increment(
    Map<String, int> source,
    String key,
    int amount,
  ) {
    if (amount == 0) return source;
    final result = <String, int>{...source};
    result[key] = (result[key] ?? 0) + amount;
    if (result.length > 45) {
      final sorted = result.keys.toList()..sort();
      for (final stale in sorted.take(result.length - 45)) {
        result.remove(stale);
      }
    }
    return result;
  }

  _StreakResult _advanceStreak({
    required JourneyState state,
    required String today,
  }) {
    if (state.lastActiveDay == today) {
      return _StreakResult(state.streakDays, state.graceAvailable);
    }
    final previous = _parseDay(state.lastActiveDay);
    if (previous == null) return const _StreakResult(1, true);
    final current = DateTime.parse(today);
    final gap = _calendarDaysBetween(previous, current);
    if (gap == 1) {
      return _StreakResult(state.streakDays + 1, state.graceAvailable);
    }
    if (gap == 2 && state.graceAvailable) {
      return _StreakResult(state.streakDays + 1, false);
    }
    return const _StreakResult(1, true);
  }

  DateTime? _parseDay(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  int _calendarDaysBetween(DateTime from, DateTime to) {
    final first = DateTime(from.year, from.month, from.day);
    final second = DateTime(to.year, to.month, to.day);
    return second.difference(first).inDays;
  }
}

class _StreakResult {
  const _StreakResult(this.days, this.graceAvailable);

  final int days;
  final bool graceAvailable;
}

const dailyQuestCatalog = <EngagementQuest>[
  EngagementQuest(
    id: 'daily.story',
    textId: 'quest.story',
    action: JourneyAction.story,
    target: 1,
    cadence: QuestCadence.daily,
    rewardMarks: 1,
  ),
  EngagementQuest(
    id: 'daily.review',
    textId: 'quest.words',
    action: JourneyAction.review,
    target: 3,
    cadence: QuestCadence.daily,
    rewardMarks: 1,
  ),
  EngagementQuest(
    id: 'daily.culture',
    textId: 'quest.culture',
    action: JourneyAction.culture,
    target: 1,
    cadence: QuestCadence.daily,
    rewardMarks: 1,
  ),
];

const weeklyQuestCatalog = <EngagementQuest>[
  EngagementQuest(
    id: 'weekly.story',
    textId: 'quest.storyWeek',
    action: JourneyAction.story,
    target: 3,
    cadence: QuestCadence.weekly,
    rewardMarks: 2,
  ),
  EngagementQuest(
    id: 'weekly.culture',
    textId: 'quest.cultureWeek',
    action: JourneyAction.culture,
    target: 3,
    cadence: QuestCadence.weekly,
    rewardMarks: 2,
  ),
];
