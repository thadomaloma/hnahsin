import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/learning/domain/learning_state.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/garden.dart';
import 'package:hnahsin/src/word_sentences.dart';
import 'package:shared_preferences/shared_preferences.dart';

ItemMastery _mastery(String id, MasteryStage stage, DateTime due) => ItemMastery(
    itemId: id,
    stage: stage,
    repetitions: 2,
    intervalDays: 3,
    easeFactor: 2.5,
    attempts: 2,
    correctAnswers: 2,
    lapses: 0,
    dueAt: due,
    lastReviewedAt: due);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  QuestController gardenWith(
      {required List<WordEntry> cards,
      List<WordEntry> due = const [],
      List<WordEntry> learning = const [],
      List<WordEntry> gold = const []}) {
    final controller = QuestController(repository: InMemoryQuestRepository());
    final now = DateTime.now().toUtc();
    for (final entry in cards) {
      controller.wordCards[entry.id] = gold.contains(entry) ? 2 : 1;
    }
    controller.learningState = controller.learningState.copyWith(masteries: {
      for (final entry in cards)
        entry.id: _mastery(
            entry.id,
            MasteryStage.familiar,
            due.contains(entry)
                ? now.subtract(const Duration(days: 1))
                : now.add(const Duration(days: 5))),
      for (final entry in learning)
        entry.id: _mastery(entry.id, MasteryStage.learning,
            now.add(const Duration(days: 5))),
    });
    return controller;
  }

  Future<void> frames(WidgetTester tester, [int n = 10]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> open(WidgetTester tester, QuestController controller) async {
    tester.view.physicalSize = const Size(600, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: GardenScreen(controller: controller)));
    await tester.pump(const Duration(milliseconds: 500));
  }

  test('a flower per collected card, a sprout per word being learned', () {
    final words = wordEntries.take(5).toList();
    final controller = gardenWith(
        cards: words.take(3).toList(), learning: words.skip(3).toList());
    expect(gardenFlowers(controller).map((f) => f.$1), words.take(3));
    expect(gardenSprouts(controller), words.skip(3));
  });

  testWidgets('a word due for review makes its flower thirsty; a right answer waters it',
      (tester) async {
    final words = wordEntries.where((e) => !e.word.contains(' ')).take(4).toList();
    final controller = gardenWith(cards: words, due: [words.first]);
    await open(tester, controller);
    expect(find.text(AppText.of('garden.thirsty', {'n': 1})), findsOneWidget);

    await tester.tap(find.text(AppText.of('garden.water')));
    await frames(tester);
    await tester.tap(find.text(words.first.word).last);
    await frames(tester, 15);
    expect(find.text(AppText.of('garden.done', {'n': 1, 'total': 1})), findsOneWidget);
    await tester.tap(find.text(AppText.of('common.continue')));
    await frames(tester);
    expect(find.text(AppText.of('garden.thirsty', {'n': 1})), findsNothing);
    expect(controller.learningState.masteries[words.first.id]!.isDue(DateTime.now()),
        isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a gold flower bears fruit: a gap in its example sentence',
      (tester) async {
    final word = wordEntries
        .firstWhere((e) => blankWholeWord(e.exampleMizo, e.word) != null);
    final controller = gardenWith(cards: [word], gold: [word]);
    await open(tester, controller);
    await tester.tap(find.text(AppText.of('garden.ripe', {'n': 1})));
    await frames(tester);
    expect(find.text(blankWholeWord(word.exampleMizo, word.word)!), findsOneWidget);
    await tester.tap(find.text(word.word).last);
    await frames(tester);
    expect(find.text(word.exampleMizo), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
