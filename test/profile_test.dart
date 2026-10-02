import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/onboarding/domain/learner_profile.dart';
import 'package:hnahsin/features/progress/domain/quest_progress.dart';
import 'package:hnahsin/src/app.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/screens.dart';

Future<QuestController> _profile(WidgetTester tester,
    {QuestProgress? progress, LearnerProfile? profile}) async {
  await tester.binding.setSurfaceSize(const Size(430, 2600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final controller = QuestController(
    repository: InMemoryQuestRepository(
      progress: progress,
      profile:
          profile ?? LearnerProfile.fresh().copyWith(onboardingCompleted: true),
    ),
    clock: () => DateTime(2026, 10, 2, 9),
  );
  await controller.load();
  await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ProfileScreen(controller: controller))));
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  testWidgets('the day streak is the live one, as on Home', (tester) async {
    // Five days in a row, but the last round was a month ago.
    const progress = QuestProgress(
      xp: 0,
      streak: 5,
      completedLessons: 2,
      dailyProgress: 3,
      trackIndex: 0,
      completedGames: {'spelling'},
      bestScores: {},
      playDay: '2026-09-01',
    );
    final controller = await _profile(tester,
        progress: progress,
        // Gentle mode shows “Calm” instead of a number.
        profile: LearnerProfile.fresh()
            .copyWith(onboardingCompleted: true, gentleMode: false));

    expect(controller.currentStreak, 0);
    expect(find.text('5'), findsNothing);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('daily goal, age range and English support can be changed',
      (tester) async {
    final controller = await _profile(tester);

    await tester.tap(find.text('15 min'));
    await tester.pumpAndSettle();
    expect(controller.profile.dailyGoalMinutes, 15);

    await tester.tap(find.text('Adult').first);
    await tester.pumpAndSettle();
    expect(controller.profile.ageBand, LearnerAgeBand.adult);

    final english = controller.profile.supportLanguage;
    await tester.tap(find.text('English support'));
    await tester.pumpAndSettle();
    expect(controller.profile.supportLanguage, isNot(english));

    expect(find.text('Level en leh rawh'), findsOneWidget);
    // The old track picker did nothing, so it's gone.
    expect(find.textContaining('Bulṭan —'), findsNothing);
  });

  testWidgets('Reduce motion turns animations off across the app',
      (tester) async {
    final controller = QuestController(
      repository: InMemoryQuestRepository(
        profile: LearnerProfile.fresh()
            .copyWith(onboardingCompleted: true, reducedMotion: true),
      ),
    );
    await controller.load();
    await tester.pumpWidget(HnahsinApp(controller: controller));
    await tester.pump();

    expect(
        MediaQuery.disableAnimationsOf(tester.element(find.byType(QuestShell))),
        isTrue);

    await controller
        .updateProfile(controller.profile.copyWith(reducedMotion: false));
    await tester.pump();
    expect(
        MediaQuery.disableAnimationsOf(tester.element(find.byType(QuestShell))),
        isFalse);
  });
}
