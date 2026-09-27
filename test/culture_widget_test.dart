import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/journey/presentation/culture_screens.dart';
import 'package:thumal_quest/src/controller.dart';

void main() {
  testWidgets('Culture Trail opens an accessible Mizo context card',
      (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: CultureTrailScreen(controller: controller)),
    );

    expect(find.text('Culture Trail'), findsOneWidget);
    expect(find.text('Tlawmngaihna'), findsOneWidget);
    await tester.ensureVisible(find.text('Tlawmngaihna'));
    await tester.tap(find.text('Tlawmngaihna'));
    await tester.pumpAndSettle();

    expect(find.text('A hman dân leh a nihna'), findsOneWidget);
    expect(find.text('Add to Collection'), findsOneWidget);
  });

  testWidgets('collection shows age-responsive avatar lock state',
      (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: CollectionScreen(controller: controller)),
    );

    expect(find.text('My Collection'), findsOneWidget);
    expect(find.text('Little Pathfinder'), findsOneWidget);
    expect(find.text('🧭  Little Pathfinder'), findsOneWidget);
    expect(find.textContaining('Hill Adventurer • 3 marks'), findsOneWidget);
    expect(find.text('Recognition only • No lesson is locked'), findsOneWidget);
  });
}
