import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/journey/presentation/journey_screens.dart';
import 'package:thumal_quest/features/learning/domain/learning_state.dart';
import 'package:thumal_quest/src/controller.dart';

void main() {
  testWidgets('journey map exposes the first story and locks the next',
      (tester) async {
    final controller = QuestController(
      repository: InMemoryQuestRepository(
        learningState: LearningState.fresh().copyWith(
          level: LearningLevel.tq1,
        ),
      ),
    );
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: JourneyScreen(controller: controller)),
    );

    expect(find.text('Mizo Journey'), findsOneWidget);
    expect(find.text('OPTIONAL DAILY • NO PENALTY'), findsOneWidget);
    expect(find.text('OPTIONAL WEEKLY • NO DEADLINE'), findsOneWidget);
    expect(find.text('Coming Home'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('TQ1'), findsOneWidget);
  });

  testWidgets('story requires a natural reply before continuing',
      (tester) async {
    final controller = QuestController(
      repository: InMemoryQuestRepository(
        learningState: LearningState.fresh().copyWith(
          level: LearningLevel.tq1,
        ),
      ),
    );
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: JourneyScreen(controller: controller)),
    );
    await tester.ensureVisible(find.text('Coming Home'));
    await tester.tap(find.text('Coming Home'));
    await tester.pumpAndSettle();

    expect(find.text('Story Quest'), findsOneWidget);
    expect(find.text('Choose a natural reply'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton).last);
    expect(button.onPressed, isNull);

    await tester.ensureVisible(find.textContaining('Ka dam e, Pi'));
    await tester.tap(find.textContaining('Ka dam e, Pi'));
    await tester.pump();
    final enabled = tester.widget<FilledButton>(find.byType(FilledButton).last);
    expect(enabled.onPressed, isNotNull);
  });
}
