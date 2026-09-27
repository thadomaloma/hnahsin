enum LearningLevel { tq0, tq1, tq2, tq3, tq4, tq5, tq6, tq7 }

extension LearningLevelText on LearningLevel {
  String get code => name.toUpperCase();

  String get title => switch (this) {
        LearningLevel.tq0 => 'First Steps',
        LearningLevel.tq1 => 'Everyday Words',
        LearningLevel.tq2 => 'Growing Speaker',
        LearningLevel.tq3 => 'Confident Reader',
        LearningLevel.tq4 => 'Storyteller',
        LearningLevel.tq5 => 'Explorer',
        LearningLevel.tq6 => 'Culture Apprentice',
        LearningLevel.tq7 => 'Culture & Fluency',
      };

  String get mizoDescription => switch (this) {
        LearningLevel.tq0 => 'Thumal bul leh thlalak hmanga bulṭan',
        LearningLevel.tq1 => 'Nitin thumal leh sentence tawi zirna',
        LearningLevel.tq2 => 'Conversation, spelling leh chhiarna',
        LearningLevel.tq3 => 'Sentence sei leh thu awmzia hriatna',
        LearningLevel.tq4 => 'Thawnthu leh chanchin zirna',
        LearningLevel.tq5 => 'Ram hmuhna leh nunphung zirna',
        LearningLevel.tq6 => 'Tawng upa leh grammar zirna',
        LearningLevel.tq7 => 'Tawng upa, hnam ziarang leh tawng thiamna famkim',
      };
}

enum MasteryStage { unseen, learning, familiar, strong, mastered }

extension MasteryStageText on MasteryStage {
  String get label => switch (this) {
        MasteryStage.unseen => 'New',
        MasteryStage.learning => 'Learning',
        MasteryStage.familiar => 'Familiar',
        MasteryStage.strong => 'Strong',
        MasteryStage.mastered => 'Mastered',
      };
}

enum ReviewRating { again, hard, good, easy }

class ItemMastery {
  const ItemMastery({
    required this.itemId,
    required this.stage,
    required this.repetitions,
    required this.intervalDays,
    required this.easeFactor,
    required this.attempts,
    required this.correctAnswers,
    required this.lapses,
    required this.dueAt,
    required this.lastReviewedAt,
  });

  factory ItemMastery.unseen(String itemId, DateTime now) => ItemMastery(
        itemId: itemId,
        stage: MasteryStage.unseen,
        repetitions: 0,
        intervalDays: 0,
        easeFactor: 2.5,
        attempts: 0,
        correctAnswers: 0,
        lapses: 0,
        dueAt: now.toUtc(),
        lastReviewedAt: null,
      );

  final String itemId;
  final MasteryStage stage;
  final int repetitions;
  final int intervalDays;
  final double easeFactor;
  final int attempts;
  final int correctAnswers;
  final int lapses;
  final DateTime dueAt;
  final DateTime? lastReviewedAt;

  double get accuracy => attempts == 0 ? 0 : correctAnswers / attempts;

  bool isDue(DateTime now) => !dueAt.isAfter(now.toUtc());

  Map<String, Object?> toJson() => <String, Object?>{
        'itemId': itemId,
        'stage': stage.name,
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'easeFactor': easeFactor,
        'attempts': attempts,
        'correctAnswers': correctAnswers,
        'lapses': lapses,
        'dueAt': dueAt.toUtc().toIso8601String(),
        'lastReviewedAt': lastReviewedAt?.toUtc().toIso8601String(),
      };

  factory ItemMastery.fromJson(Map<String, Object?> json) {
    final itemId = json['itemId'] as String? ?? '';
    final rawStage = json['stage'];
    final stage = MasteryStage.values.where((value) => value.name == rawStage);
    return ItemMastery(
      itemId: itemId,
      stage: stage.isEmpty ? MasteryStage.unseen : stage.first,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      dueAt: DateTime.tryParse(json['dueAt'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      lastReviewedAt:
          DateTime.tryParse(json['lastReviewedAt'] as String? ?? '')?.toUtc(),
    );
  }
}

class LearningState {
  const LearningState({
    required this.level,
    required this.placementCompleted,
    required this.placementCorrect,
    required this.placementTotal,
    required this.masteries,
    required this.recentOutcomes,
    required this.contentReports,
  });

  factory LearningState.fresh() => const LearningState(
        level: LearningLevel.tq0,
        placementCompleted: false,
        placementCorrect: 0,
        placementTotal: 0,
        masteries: <String, ItemMastery>{},
        recentOutcomes: <bool>[],
        contentReports: <String, String>{},
      );

  final LearningLevel level;
  final bool placementCompleted;
  final int placementCorrect;
  final int placementTotal;
  final Map<String, ItemMastery> masteries;
  final List<bool> recentOutcomes;
  final Map<String, String> contentReports;

  List<String> get reportedContentIds =>
      List<String>.unmodifiable(contentReports.keys);

  int get reviewedCount => masteries.length;
  int get masteredCount => masteries.values
      .where((item) => item.stage == MasteryStage.mastered)
      .length;

  int dueCount(DateTime now) => masteries.values
      .where((item) => item.stage != MasteryStage.unseen && item.isDue(now))
      .length;

  LearningState copyWith({
    LearningLevel? level,
    bool? placementCompleted,
    int? placementCorrect,
    int? placementTotal,
    Map<String, ItemMastery>? masteries,
    List<bool>? recentOutcomes,
    Map<String, String>? contentReports,
  }) {
    return LearningState(
      level: level ?? this.level,
      placementCompleted: placementCompleted ?? this.placementCompleted,
      placementCorrect: placementCorrect ?? this.placementCorrect,
      placementTotal: placementTotal ?? this.placementTotal,
      masteries: Map<String, ItemMastery>.unmodifiable(
        masteries ?? this.masteries,
      ),
      recentOutcomes: List<bool>.unmodifiable(
        recentOutcomes ?? this.recentOutcomes,
      ),
      contentReports: Map<String, String>.unmodifiable(
        contentReports ?? this.contentReports,
      ),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'level': level.name,
        'placementCompleted': placementCompleted,
        'placementCorrect': placementCorrect,
        'placementTotal': placementTotal,
        'masteries': masteries.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'recentOutcomes': recentOutcomes,
        'contentReports': contentReports,
      };

  factory LearningState.fromJson(Map<String, Object?> json) {
    final rawLevel = json['level'];
    final levels = LearningLevel.values.where((value) => value.name == rawLevel);
    final rawMasteries = json['masteries'];
    final masteries = <String, ItemMastery>{};
    if (rawMasteries is Map) {
      for (final entry in rawMasteries.entries) {
        if (entry.value is Map) {
          final mastery = ItemMastery.fromJson(
            Map<String, Object?>.from(entry.value as Map),
          );
          if (mastery.itemId.isNotEmpty) masteries[entry.key.toString()] = mastery;
        }
      }
    }
    return LearningState(
      level: levels.isEmpty ? LearningLevel.tq0 : levels.first,
      placementCompleted: json['placementCompleted'] as bool? ?? false,
      placementCorrect: (json['placementCorrect'] as num?)?.toInt() ?? 0,
      placementTotal: (json['placementTotal'] as num?)?.toInt() ?? 0,
      masteries: Map<String, ItemMastery>.unmodifiable(masteries),
      recentOutcomes: List<bool>.unmodifiable(
        (json['recentOutcomes'] as List<Object?>? ?? const <Object?>[])
            .whereType<bool>(),
      ),
      contentReports: Map<String, String>.unmodifiable(
        _readContentReports(json),
      ),
    );
  }

  static Map<String, String> _readContentReports(
    Map<String, Object?> json,
  ) {
    final rawReports = json['contentReports'];
    if (rawReports is Map) {
      return <String, String>{
        for (final entry in rawReports.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    }
    return <String, String>{
      for (final id in
          (json['reportedContentIds'] as List<Object?>? ?? const <Object?>[])
              .whereType<String>())
        id: 'other',
    };
  }
}
