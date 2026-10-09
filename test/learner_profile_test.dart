import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/onboarding/domain/learner_profile.dart';
import 'package:hnahsin/src/app_text.dart';

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
      appLanguage: AppLanguage.mizo,
    );

    final decoded = LearnerProfile.fromJson(profile.toJson());

    expect(decoded.ageBand, LearnerAgeBand.adult);
    expect(decoded.goals, profile.goals);
    expect(decoded.dailyGoalMinutes, 10);
    expect(decoded.onboardingCompleted, isTrue);
    expect(decoded.gentleMode, isFalse);
    expect(decoded.appLanguage, AppLanguage.mizo);
  });

  test('older profiles default to gentle engagement', () {
    final decoded = LearnerProfile.fromJson(const <String, Object?>{});

    expect(decoded.gentleMode, isTrue);
  });

  test('older profiles show the app in English', () {
    expect(LearnerProfile.fromJson(const <String, Object?>{}).appLanguage, AppLanguage.english);
  });

  test('the Mizo labels saved when they were the default are not kept', () {
    expect(LearnerProfile.fromJson(const {'appLanguage': 'mizo'}).appLanguage, AppLanguage.english);
    expect(LearnerProfile.fromJson(const {'uiLanguage': 'mizo'}).appLanguage, AppLanguage.mizo);
  });
}
