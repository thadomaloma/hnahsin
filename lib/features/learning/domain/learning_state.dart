import '../../../src/app_text.dart';

enum LearningLevel { level1, level2, level3, level4, level5, level6, level7, level8 }

extension LearningLevelText on LearningLevel {
  /// What learners see: Level 1 to Level 8.
  String get code => AppText.of('level.code', {'n': index + 1});

  String get title => switch (this) {
        LearningLevel.level1 => AppText.of('level.1.title'),
        LearningLevel.level2 => AppText.of('level.2.title'),
        LearningLevel.level3 => AppText.of('level.3.title'),
        LearningLevel.level4 => AppText.of('level.4.title'),
        LearningLevel.level5 => AppText.of('level.5.title'),
        LearningLevel.level6 => AppText.of('level.6.title'),
        LearningLevel.level7 => AppText.of('level.7.title'),
        LearningLevel.level8 => AppText.of('level.8.title'),
      };

  String get mizoDescription => switch (this) {
        LearningLevel.level1 => AppText.of('level.1.description'),
        LearningLevel.level2 => AppText.of('level.2.description'),
        LearningLevel.level3 => AppText.of('level.3.description'),
        LearningLevel.level4 => AppText.of('level.4.description'),
        LearningLevel.level5 => AppText.of('level.5.description'),
        LearningLevel.level6 => AppText.of('level.6.description'),
        LearningLevel.level7 => AppText.of('level.7.description'),
        LearningLevel.level8 => AppText.of('level.8.description'),
      };
}

enum MasteryStage { unseen, learning, familiar, strong, mastered }

extension MasteryStageText on MasteryStage {
  String get label => switch (this) {
        MasteryStage.unseen => AppText.of('mastery.unseen'),
        MasteryStage.learning => AppText.of('mastery.learning'),
        MasteryStage.familiar => AppText.of('mastery.familiar'),
        MasteryStage.strong => AppText.of('mastery.strong'),
        MasteryStage.mastered => AppText.of('mastery.mastered'),
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
        level: LearningLevel.level1,
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
    // Saved before the rename from Thumal Quest as tq0–tq7.
    final legacy = RegExp(r'^tq([0-7])$').firstMatch('${rawLevel ?? ''}');
    final levels = legacy != null
        ? [LearningLevel.values[int.parse(legacy[1]!)]]
        : LearningLevel.values.where((value) => value.name == rawLevel);
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
      level: levels.isEmpty ? LearningLevel.level1 : levels.first,
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
