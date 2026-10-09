import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/journey/presentation/culture_screens.dart';
import 'package:hnahsin/src/controller.dart';

void main() {
  testWidgets('Culture Trail opens an accessible Mizo context card',
      (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: CultureTrailScreen(controller: controller)),
    );

    expect(find.text(AppText.of('journey.cultureTrail')), findsOneWidget);
    expect(find.text('Tlawmngaihna'), findsOneWidget);
    await tester.ensureVisible(find.text('Tlawmngaihna'));
    await tester.tap(find.text('Tlawmngaihna'));
    await tester.pumpAndSettle();

    expect(find.text('A hman dân leh a nihna'), findsOneWidget);
    expect(find.text(AppText.of('culture.add')), findsOneWidget);
  });

  testWidgets('collection shows age-responsive avatar lock state',
      (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    await controller.load();
    await tester.pumpWidget(
      MaterialApp(home: CollectionScreen(controller: controller)),
    );

    expect(find.text(AppText.of('journey.collection')), findsOneWidget);
    expect(find.text('Little Pathfinder'), findsOneWidget);
    expect(find.text('🧭  Little Pathfinder'), findsOneWidget);
    expect(find.textContaining(AppText.of('collection.avatarLocked', {'avatar': 'Hill Adventurer', 'marks': 3})), findsOneWidget);
    expect(find.text(AppText.of('collection.note')), findsOneWidget);
  });
}
