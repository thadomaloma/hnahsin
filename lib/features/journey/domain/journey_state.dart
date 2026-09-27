class JourneyState {
  const JourneyState({
    required this.completedNodeIds,
    required this.collectedCultureCardIds,
    required this.unlockedRewardIds,
    required this.actionCounts,
    required this.streakDays,
    required this.graceAvailable,
    required this.lastActiveDay,
    required this.lastCompletedNodeId,
    required this.storyChoices,
    required this.healthyStops,
    required this.claimedQuestKeys,
    required this.trailMarks,
    required this.selectedAvatarId,
  });

  factory JourneyState.fresh() => const JourneyState(
        completedNodeIds: <String>{},
        collectedCultureCardIds: <String>{},
        unlockedRewardIds: <String>{},
        actionCounts: <String, int>{},
        streakDays: 0,
        graceAvailable: true,
        lastActiveDay: null,
        lastCompletedNodeId: null,
        storyChoices: 0,
        healthyStops: 0,
        claimedQuestKeys: <String>{},
        trailMarks: 0,
        selectedAvatarId: 'avatar.pathfinder',
      );

  final Set<String> completedNodeIds;
  final Set<String> collectedCultureCardIds;
  final Set<String> unlockedRewardIds;
  final Map<String, int> actionCounts;
  final int streakDays;
  final bool graceAvailable;
  final String? lastActiveDay;
  final String? lastCompletedNodeId;
  final int storyChoices;
  final int healthyStops;
  final Set<String> claimedQuestKeys;
  final int trailMarks;
  final String selectedAvatarId;

  JourneyState copyWith({
    Set<String>? completedNodeIds,
    Set<String>? collectedCultureCardIds,
    Set<String>? unlockedRewardIds,
    Map<String, int>? actionCounts,
    int? streakDays,
    bool? graceAvailable,
    String? lastActiveDay,
    bool clearLastActiveDay = false,
    String? lastCompletedNodeId,
    bool clearLastCompletedNodeId = false,
    int? storyChoices,
    int? healthyStops,
    Set<String>? claimedQuestKeys,
    int? trailMarks,
    String? selectedAvatarId,
  }) {
    return JourneyState(
      completedNodeIds: Set<String>.unmodifiable(
        completedNodeIds ?? this.completedNodeIds,
      ),
      collectedCultureCardIds: Set<String>.unmodifiable(
        collectedCultureCardIds ?? this.collectedCultureCardIds,
      ),
      unlockedRewardIds: Set<String>.unmodifiable(
        unlockedRewardIds ?? this.unlockedRewardIds,
      ),
      actionCounts: Map<String, int>.unmodifiable(
        actionCounts ?? this.actionCounts,
      ),
      streakDays: streakDays ?? this.streakDays,
      graceAvailable: graceAvailable ?? this.graceAvailable,
      lastActiveDay:
          clearLastActiveDay ? null : lastActiveDay ?? this.lastActiveDay,
      lastCompletedNodeId: clearLastCompletedNodeId
          ? null
          : lastCompletedNodeId ?? this.lastCompletedNodeId,
      storyChoices: storyChoices ?? this.storyChoices,
      healthyStops: healthyStops ?? this.healthyStops,
      claimedQuestKeys: Set<String>.unmodifiable(
        claimedQuestKeys ?? this.claimedQuestKeys,
      ),
      trailMarks: trailMarks ?? this.trailMarks,
      selectedAvatarId: selectedAvatarId ?? this.selectedAvatarId,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'completedNodeIds': completedNodeIds.toList()..sort(),
        'collectedCultureCardIds': collectedCultureCardIds.toList()..sort(),
        'unlockedRewardIds': unlockedRewardIds.toList()..sort(),
        'actionCounts': actionCounts,
        'streakDays': streakDays,
        'graceAvailable': graceAvailable,
        'lastActiveDay': lastActiveDay,
        'lastCompletedNodeId': lastCompletedNodeId,
        'storyChoices': storyChoices,
        'healthyStops': healthyStops,
        'claimedQuestKeys': claimedQuestKeys.toList()..sort(),
        'trailMarks': trailMarks,
        'selectedAvatarId': selectedAvatarId,
      };

  factory JourneyState.fromJson(Map<String, Object?> json) {
    Set<String> stringSet(String key) {
      final value = json[key];
      return value is List
          ? Set<String>.unmodifiable(value.whereType<String>())
          : const <String>{};
    }

    final rawCounts = json['actionCounts'];
    return JourneyState(
      completedNodeIds: stringSet('completedNodeIds'),
      collectedCultureCardIds: stringSet('collectedCultureCardIds'),
      unlockedRewardIds: stringSet('unlockedRewardIds'),
      actionCounts: rawCounts is Map
          ? Map<String, int>.unmodifiable(
              rawCounts.map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value as num?)?.toInt() ?? 0,
                ),
              ),
            )
          : const <String, int>{},
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      graceAvailable: json['graceAvailable'] as bool? ?? true,
      lastActiveDay: json['lastActiveDay'] as String?,
      lastCompletedNodeId: json['lastCompletedNodeId'] as String?,
      storyChoices: (json['storyChoices'] as num?)?.toInt() ?? 0,
      healthyStops: (json['healthyStops'] as num?)?.toInt() ?? 0,
      claimedQuestKeys: stringSet('claimedQuestKeys'),
      trailMarks: (json['trailMarks'] as num?)?.toInt() ?? 0,
      selectedAvatarId:
          json['selectedAvatarId'] as String? ?? 'avatar.pathfinder',
    );
  }
}
