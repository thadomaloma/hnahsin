import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/features/onboarding/domain/learner_profile.dart';

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
    );

    final decoded = LearnerProfile.fromJson(profile.toJson());

    expect(decoded.ageBand, LearnerAgeBand.adult);
    expect(decoded.goals, profile.goals);
    expect(decoded.dailyGoalMinutes, 10);
    expect(decoded.onboardingCompleted, isTrue);
    expect(decoded.gentleMode, isFalse);
  });

  test('older profiles default to gentle engagement', () {
    final decoded = LearnerProfile.fromJson(const <String, Object?>{});

    expect(decoded.gentleMode, isTrue);
  });
}
