import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/journey/domain/journey_content.dart';
import 'package:hnahsin/features/journey/domain/journey_engine.dart';
import 'package:hnahsin/features/journey/domain/journey_models.dart';
import 'package:hnahsin/features/journey/domain/journey_state.dart';

void main() {
  const engine = JourneyEngine();

  test('culture values use a Dart-safe topic name', () {
    expect(CultureTopic.communityValues.name, 'communityValues');
    expect(cultureCards.first.topic, CultureTopic.communityValues);
  });

  test('culture reread counts engagement without duplicating collection', () {
    final first = engine.collectCultureCard(
      state: JourneyState.fresh(),
      card: cultureCards.first,
      now: DateTime(2026, 9, 13),
    );
    final second = engine.collectCultureCard(
      state: first,
      card: cultureCards.first,
      now: DateTime(2026, 9, 13),
    );

    expect(second.collectedCultureCardIds, <String>{'culture.tlawmngaihna'});
    expect(second.actionCounts['2026-09-13:culture'], 2);
  });

  test('completed daily quest awards Trail Mark only once', () {
    final active = engine.collectCultureCard(
      state: JourneyState.fresh(),
      card: cultureCards.first,
      now: DateTime(2026, 9, 13),
    );
    final progress = engine
        .dailyQuests(state: active, now: DateTime(2026, 9, 13))
        .singleWhere((item) => item.quest.id == 'daily.culture');

    final claimed = engine.claimQuest(state: active, progress: progress);
    final duplicate = engine.claimQuest(state: claimed, progress: progress);

    expect(claimed.trailMarks, 1);
    expect(claimed.claimedQuestKeys, contains(progress.claimKey));
    expect(identical(duplicate, claimed), isTrue);
  });

  test('incomplete quest cannot be claimed', () {
    final state = JourneyState.fresh();
    final progress = engine.dailyQuests(
      state: state,
      now: DateTime(2026, 9, 13),
    ).first;

    expect(identical(engine.claimQuest(state: state, progress: progress), state),
        isTrue);
  });

  test('weekly quests use a stable Monday claim key', () {
    var state = JourneyState.fresh();
    for (var day = 14; day <= 16; day += 1) {
      state = engine.recordAction(
        state: state,
        action: JourneyAction.story,
        now: DateTime(2026, 9, day),
      );
    }

    final storyWeek = engine
        .weeklyQuests(state: state, now: DateTime(2026, 9, 16))
        .singleWhere((item) => item.quest.id == 'weekly.story');

    expect(storyWeek.completed, isTrue);
    expect(storyWeek.claimKey, 'week:2026-09-14:weekly.story');
  });

  test('avatar styles unlock from recognition marks only', () {
    final locked = JourneyState.fresh();
    final unlocked = locked.copyWith(trailMarks: 3);

    expect(
      identical(
        engine.selectAvatar(state: locked, avatar: avatarStyles[1]),
        locked,
      ),
      isTrue,
    );
    expect(
      engine.selectAvatar(state: unlocked, avatar: avatarStyles[1])
          .selectedAvatarId,
      'avatar.hill_walker',
    );
  });

  test('seasonal trail keeps an archive path and no expiry requirement', () {
    expect(seasonalTrails.single.archiveAvailable, isTrue);
    expect(seasonalTrails.single.cardIds, hasLength(3));
  });
}
