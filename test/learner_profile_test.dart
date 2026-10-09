import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/onboarding/domain/learner_profile.dart';

void main() {
  test('learner profile survives a JSON round-trip', () {
    final profile = LearnerProfile.fresh().copyWith(
      ageBand: LearnerAgeBand.adult,
      proficiency: MizoProficiency.understandsSome,
      goals: <LearningGoal>[
        LearningGoal.conversation,
        LearningGoal.reading,
      ],
      dailyGoalMinutes: 10,
      onboardingCompleted: true,
      gentleMode: false,
      appLocale: 'ja',
    );

    final decoded = LearnerProfile.fromJson(profile.toJson());

    expect(decoded.ageBand, LearnerAgeBand.adult);
    expect(decoded.goals, profile.goals);
    expect(decoded.dailyGoalMinutes, 10);
    expect(decoded.onboardingCompleted, isTrue);
    expect(decoded.gentleMode, isFalse);
    expect(decoded.appLocale, 'ja');
    expect(LearnerProfile.fromJson(profile.copyWith(appLocale: null).toJson()).appLocale, isNull);
  });

  test('older profiles default to gentle engagement', () {
    final decoded = LearnerProfile.fromJson(const <String, Object?>{});

    expect(decoded.gentleMode, isTrue);
  });

  test('profiles follow the phone\'s language until one is chosen', () {
    expect(LearnerProfile.fromJson(const <String, Object?>{}).appLocale, isNull);
    // The earlier English/Mizo choice isn't carried over.
    expect(LearnerProfile.fromJson(const {'uiLanguage': 'mizo'}).appLocale, isNull);
    expect(LearnerProfile.fromJson(const {'appLocale': 'xx'}).appLocale, isNull);
  });
}
