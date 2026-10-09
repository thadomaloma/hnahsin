import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/journey/presentation/journey_screens.dart';
import 'package:hnahsin/features/learning/domain/learning_state.dart';
import 'package:hnahsin/src/controller.dart';

void main() {
  testWidgets('journey map exposes the first story and locks the next',
      (tester) async {
    final controller = QuestController(
      repository: InMemoryQuestRepository(
        learningState: LearningState.fresh().copyWith(
          level: LearningLevel.level2,
        ),
      ),
    );
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: JourneyScreen(controller: controller)),
    );

    expect(find.text(AppText.of('home.journey')), findsOneWidget);
    expect(find.text(AppText.of('journey.dailyGentle')), findsOneWidget);
    expect(find.text(AppText.of('journey.weeklyGentle')), findsOneWidget);
    expect(find.text('In Lam Pan'), findsOneWidget);
    expect(find.text(AppText.of('journey.start')), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
  });

  testWidgets('story requires a natural reply before continuing',
      (tester) async {
    final controller = QuestController(
      repository: InMemoryQuestRepository(
        learningState: LearningState.fresh().copyWith(
          level: LearningLevel.level2,
        ),
      ),
    );
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: JourneyScreen(controller: controller)),
    );
    await tester.ensureVisible(find.text('In Lam Pan'));
    await tester.tap(find.text('In Lam Pan'));
    await tester.pumpAndSettle();

    expect(find.text(AppText.of('story.title')), findsOneWidget);
    expect(find.text(AppText.of('story.chooseReply')), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton).last);
    expect(button.onPressed, isNull);

    await tester.ensureVisible(find.textContaining('Ka dam e, Pi'));
    await tester.tap(find.textContaining('Ka dam e, Pi'));
    await tester.pump();
    final enabled = tester.widget<FilledButton>(find.byType(FilledButton).last);
    expect(enabled.onPressed, isNotNull);
  });
}
