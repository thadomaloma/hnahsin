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
      appLanguage: AppLanguage.english,
    );

    final decoded = LearnerProfile.fromJson(profile.toJson());

    expect(decoded.ageBand, LearnerAgeBand.adult);
    expect(decoded.goals, profile.goals);
    expect(decoded.dailyGoalMinutes, 10);
    expect(decoded.onboardingCompleted, isTrue);
    expect(decoded.gentleMode, isFalse);
    expect(decoded.appLanguage, AppLanguage.english);
  });

  test('older profiles default to gentle engagement', () {
    final decoded = LearnerProfile.fromJson(const <String, Object?>{});

    expect(decoded.gentleMode, isTrue);
  });

  test('older profiles show the app in Mizo', () {
    expect(LearnerProfile.fromJson(const <String, Object?>{}).appLanguage, AppLanguage.mizo);
  });
}
