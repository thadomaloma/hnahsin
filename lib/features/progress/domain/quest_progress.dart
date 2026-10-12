class QuestProgress {
  const QuestProgress({
    required this.xp,
    required this.streak,
    required this.completedLessons,
    required this.dailyProgress,
    required this.trackIndex,
    required this.completedGames,
    required this.bestScores,
    this.gameSkills = const <String, int>{},
    this.playDay,
    this.dailyPuzzles = const <String, String>{},
    this.wordCards = const <String, int>{},
    this.playMode,
    this.seenHowTo = const <String>{},
  });

  factory QuestProgress.empty() => const QuestProgress(
        xp: 0,
        streak: 1,
        completedLessons: 0,
        dailyProgress: 0,
        trackIndex: 0,
        completedGames: <String>{},
        bestScores: <String, int>{},
      );

  final int xp;
  final int streak;
  final int completedLessons;
  final int dailyProgress;
  final int trackIndex;
  final Set<String> completedGames;
  final Map<String, int> bestScores;

  /// Adaptive skill rating per game, stored ×100 (e.g. 340 = rating 3.4).
  final Map<String, int> gameSkills;

  /// The last local day (YYYY-MM-DD) a game round was finished: what
  /// [dailyProgress] and [streak] are counted against.
  final String? playDay;

  /// Finished daily puzzles: [DailyPuzzle.key] → [DailyResult.encode].
  final Map<String, String> dailyPuzzles;

  /// Collected word cards: word id → 1 (collected) or 2 (gold). Never lost.
  final Map<String, int> wordCards;

  /// The play mode the player picked last (GameMode name), for every game.
  final String? playMode;

  /// Games whose how-to-play the player has seen before their first round.
  final Set<String> seenHowTo;

  QuestProgress copyWith({
    int? xp,
    int? streak,
    int? completedLessons,
    int? dailyProgress,
    int? trackIndex,
    Set<String>? completedGames,
    Map<String, int>? bestScores,
    Map<String, int>? gameSkills,
    String? playDay,
    Map<String, String>? dailyPuzzles,
    Map<String, int>? wordCards,
    String? playMode,
    Set<String>? seenHowTo,
  }) {
    return QuestProgress(
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      completedLessons: completedLessons ?? this.completedLessons,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      trackIndex: trackIndex ?? this.trackIndex,
      completedGames: Set<String>.unmodifiable(
        completedGames ?? this.completedGames,
      ),
      bestScores: Map<String, int>.unmodifiable(bestScores ?? this.bestScores),
      gameSkills: Map<String, int>.unmodifiable(gameSkills ?? this.gameSkills),
      playDay: playDay ?? this.playDay,
      dailyPuzzles: Map<String, String>.unmodifiable(dailyPuzzles ?? this.dailyPuzzles),
      wordCards: Map<String, int>.unmodifiable(wordCards ?? this.wordCards),
      playMode: playMode ?? this.playMode,
      seenHowTo: Set<String>.unmodifiable(seenHowTo ?? this.seenHowTo),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'xp': xp,
        'streak': streak,
        'completedLessons': completedLessons,
        'dailyProgress': dailyProgress,
        'trackIndex': trackIndex,
        'completedGames': completedGames.toList()..sort(),
        'bestScores': bestScores,
        'gameSkills': gameSkills,
        if (playDay != null) 'playDay': playDay,
        if (dailyPuzzles.isNotEmpty) 'dailyPuzzles': dailyPuzzles,
        if (wordCards.isNotEmpty) 'wordCards': wordCards,
        if (playMode != null) 'playMode': playMode,
        if (seenHowTo.isNotEmpty) 'seenHowTo': seenHowTo.toList()..sort(),
      };

  factory QuestProgress.fromJson(Map<String, Object?> json) {
    final rawGames = json['completedGames'];
    final rawScores = json['bestScores'];
    final rawSkills = json['gameSkills'];
    final rawDaily = json['dailyPuzzles'];
    final rawCards = json['wordCards'];
    final rawSeen = json['seenHowTo'];
    return QuestProgress(
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 1,
      completedLessons: (json['completedLessons'] as num?)?.toInt() ?? 0,
      dailyProgress: (json['dailyProgress'] as num?)?.toInt() ?? 0,
      trackIndex: (json['trackIndex'] as num?)?.toInt() ?? 0,
      completedGames: rawGames is List
          ? Set<String>.unmodifiable(rawGames.whereType<String>())
          : const <String>{},
      bestScores: rawScores is Map
          ? Map<String, int>.unmodifiable(
              rawScores.map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value as num?)?.toInt() ?? 0,
                ),
              ),
            )
          : const <String, int>{},
      gameSkills: rawSkills is Map
          ? Map<String, int>.unmodifiable(
              rawSkills.map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value as num?)?.toInt() ?? 100,
                ),
              ),
            )
          : const <String, int>{},
      playDay: json['playDay'] is String ? json['playDay'] as String : null,
      dailyPuzzles: rawDaily is Map
          ? Map<String, String>.unmodifiable({
              for (final MapEntry(:key, :value) in rawDaily.entries)
                if (value is String) key.toString(): value,
            })
          : const <String, String>{},
      wordCards: rawCards is Map
          ? Map<String, int>.unmodifiable({
              for (final MapEntry(:key, :value) in rawCards.entries)
                if (value is num) key.toString(): value.toInt().clamp(1, 2),
            })
          : const <String, int>{},
      playMode: json['playMode'] is String ? json['playMode'] as String : null,
      seenHowTo: rawSeen is List
          ? Set<String>.unmodifiable(rawSeen.whereType<String>())
          : const <String>{},
    );
  }
}
