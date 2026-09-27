/// Privacy-minimal event model. Events remain local in Phase 1 and deliberately
/// exclude names, free-form answers, audio, exact age, and device identifiers.
enum QuestEventType { gameStarted, answerEvaluated, gameFinished, lessonFinished }

enum DurationBucket { underFiveSeconds, underFifteenSeconds, underMinute, overMinute }

class QuestAnalyticsEvent {
  const QuestAnalyticsEvent({
    required this.type,
    required this.occurredAt,
    required this.sessionId,
    this.gameId,
    this.contentId,
    this.correct,
    this.durationBucket,
    this.ageBand,
    this.level,
  });

  final QuestEventType type;
  final DateTime occurredAt;
  final String sessionId;
  final String? gameId;
  final String? contentId;
  final bool? correct;
  final DurationBucket? durationBucket;
  final String? ageBand;
  final int? level;

  Map<String, Object?> toLocalRecord() => <String, Object?>{
        'type': type.name,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'sessionId': sessionId,
        if (gameId != null) 'gameId': gameId,
        if (contentId != null) 'contentId': contentId,
        if (correct != null) 'correct': correct,
        if (durationBucket != null) 'durationBucket': durationBucket!.name,
        if (ageBand != null) 'ageBand': ageBand,
        if (level != null) 'level': level,
      };
}
