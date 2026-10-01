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
      };

  factory QuestProgress.fromJson(Map<String, Object?> json) {
    final rawGames = json['completedGames'];
    final rawScores = json['bestScores'];
    final rawSkills = json['gameSkills'];
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
    );
  }
}
