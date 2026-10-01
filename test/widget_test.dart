import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/onboarding/domain/learner_profile.dart';
import 'package:thumal_quest/features/learning/presentation/learning_screens.dart';
import 'package:thumal_quest/src/app.dart';
import 'package:thumal_quest/src/controller.dart';
import 'package:thumal_quest/src/widgets.dart';

void main() {
  testWidgets('opens personalized onboarding for a new learner', (tester) async {
    await tester.pumpWidget(HnahsinApp(controller: QuestController()));
    await tester.pumpAndSettle();

    expect(find.text('HNAHSIN'), findsOneWidget);
    expect(find.text('Your Mizo journey starts here.'), findsOneWidget);
    expect(find.text('Start My Journey'), findsOneWidget);
  });

  testWidgets('opens the premium home after onboarding', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = InMemoryQuestRepository(
      profile: LearnerProfile.fresh().copyWith(onboardingCompleted: true),
    );
    final controller = QuestController(repository: repository);
    await controller.load();
    await tester.pumpWidget(HnahsinApp(controller: controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.profile.onboardingCompleted, isTrue);
    expect(find.text('VAWIIN GAME'), findsOneWidget);
    expect(find.text('Khel rawh'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Learn'), findsWidgets);
    expect(find.text('Games'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });

  testWidgets('premium cards provide a visible Material surface for list tiles',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PremiumCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              title: const Text('Sound'),
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Sound'), findsOneWidget);
  });

  testWidgets('learning overview opens the placement check', (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LearningOverviewCard(controller: controller)),
      ),
    );

    expect(find.text('TQ0'), findsOneWidget);
    expect(find.text('Find My Mizo Level'), findsOneWidget);
    await tester.tap(find.text('Find My Mizo Level'));
    await tester.pumpAndSettle();

    expect(find.text('Placement Check'), findsOneWidget);
    expect(find.text('Question 1 of 10'), findsOneWidget);
  });
}
