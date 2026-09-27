import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/features/analytics/domain/analytics_event.dart';

void main() {
  test('local analytics record contains no free-form learner data', () {
    final record = QuestAnalyticsEvent(
      type: QuestEventType.answerEvaluated,
      occurredAt: DateTime.utc(2026, 9, 13),
      sessionId: 'session-1',
      gameId: 'spelling',
      contentId: 'word-12-r2',
      correct: false,
      durationBucket: DurationBucket.underFifteenSeconds,
      ageBand: 'young',
      level: 1,
    ).toLocalRecord();

    expect(record, isNot(contains('answer')));
    expect(record, isNot(contains('name')));
    expect(record, isNot(contains('audio')));
    expect(record['contentId'], 'word-12-r2');
  });
}
