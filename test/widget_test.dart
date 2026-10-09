import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/learning/domain/learning_state.dart';
import 'package:hnahsin/features/onboarding/domain/learner_profile.dart';
import 'package:hnahsin/features/learning/presentation/learning_screens.dart';
import 'package:hnahsin/src/app.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/widgets.dart';

void main() {
  testWidgets('opens personalized onboarding for a new learner',
      (tester) async {
    await tester.pumpWidget(HnahsinApp(controller: QuestController()));
    await tester.pumpAndSettle();

    expect(find.text('HNAHSIN'), findsOneWidget);
    expect(find.text(AppText.of('welcome.title')), findsOneWidget);
    expect(find.text(AppText.of('onboarding.start')), findsOneWidget);
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
    expect(find.text(AppText.of('home.todaysGame')), findsOneWidget);
    expect(find.text(AppText.of('home.play')), findsOneWidget);
    expect(find.text(AppText.of('nav.home')), findsOneWidget);
    expect(find.text(AppText.of('nav.learn')), findsWidgets);
    expect(find.text(AppText.of('nav.games')), findsWidgets);
    expect(find.text(AppText.of('nav.profile')), findsWidgets);
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

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.text(AppText.of('learn.findLevel')), findsOneWidget);
    await tester.tap(find.text(AppText.of('learn.findLevel')));
    await tester.pumpAndSettle();

    expect(find.text(AppText.of('placement.title')), findsOneWidget);
    expect(find.text('Question 1/10'), findsOneWidget);
  });

  testWidgets('placement asks ten different words with four different options',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = QuestController(repository: InMemoryQuestRepository());
    await tester.pumpWidget(
      MaterialApp(home: PlacementScreen(controller: controller)),
    );

    final asked = <String>[];
    for (var question = 0; question < 10; question += 1) {
      final entry = tester.widget<WordPicture>(find.byType(WordPicture)).entry;
      final options = tester
          .widgetList<AnswerButton>(find.byType(AnswerButton))
          .map((button) => button.label)
          .toList();
      asked.add(entry.id);
      expect(options.toSet(), hasLength(4));
      expect(options, contains(entry.englishGloss));
      await tester.tap(find.byType(AnswerButton).first);
      await tester.pump();
      await tester.tap(find.text(AppText.of(question == 9 ? 'placement.seeLevel' : 'common.next')));
      await tester.pumpAndSettle();
    }

    expect(asked.toSet(), hasLength(10));
    expect(find.text(AppText.of('placement.result')), findsOneWidget);
    expect(controller.learningState.placementCompleted, isTrue);
  });

  testWidgets('daily lesson asks a returning word before showing its meaning',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final now = DateTime.now().toUtc();
    final controller = QuestController(
      repository: InMemoryQuestRepository(
        learningState: LearningState.fresh().copyWith(
          placementCompleted: true,
          masteries: <String, ItemMastery>{
            'in': ItemMastery(
              itemId: 'in',
              stage: MasteryStage.learning,
              repetitions: 0,
              intervalDays: 0,
              easeFactor: 2.3,
              attempts: 1,
              correctAnswers: 0,
              lapses: 1,
              dueAt: now.subtract(const Duration(minutes: 1)),
              lastReviewedAt: now.subtract(const Duration(hours: 1)),
            ),
          },
        ),
      ),
    );
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: DailyReviewScreen(controller: controller)),
    );

    expect(find.text('In'), findsOneWidget);
    expect(find.text(AppText.of('lesson.prompt')), findsOneWidget);
    expect(find.text('Mihring chenna hmun'), findsNothing);
    expect(find.text(AppText.of('lesson.newWord')), findsNothing);

    await tester.tap(find.text('House'));
    await tester.pump();
    expect(find.text('Mihring chenna hmun'), findsOneWidget);

    await tester.tap(find.text(AppText.of('common.next')));
    await tester.pumpAndSettle();
    expect(find.text(AppText.of('lesson.newWord')), findsOneWidget);
    expect(find.text(AppText.of('lesson.prompt')), findsNothing);
  });
}
