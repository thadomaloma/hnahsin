import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/learning/domain/learning_state.dart';
import 'package:hnahsin/features/progress/domain/quest_progress.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/game_session.dart';
import 'package:hnahsin/src/word_cards.dart';

void main() {
  final word = wordEntries.first;
  List<WordPlay> play({bool missed = false}) => [WordPlay(id: word.id, word: word.word, missed: missed)];

  test('a word right in two games earns its card, four in a row turns it gold', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);

    expect((await controller.recordWordsPlayed(play())).isEmpty, isTrue);
    final second = await controller.recordWordsPlayed(play());
    expect(second.collected, [word.id]);
    expect(controller.wordCards[word.id], WordCards.collected);

    expect((await controller.recordWordsPlayed(play())).isEmpty, isTrue);
    final fourth = await controller.recordWordsPlayed(play());
    expect(fourth.gold, [word.id]);
    expect(controller.wordCards[word.id], WordCards.gold);

    // A miss later never takes a card back.
    await controller.recordWordsPlayed(play(missed: true));
    expect(controller.wordCards[word.id], WordCards.gold);
    final saved = QuestProgress.fromJson((await repository.loadProgress()).toJson());
    expect(saved.wordCards[word.id], WordCards.gold);
  });

  test('words learnt before cards existed get their cards on load', () async {
    final now = DateTime.now().toUtc();
    final controller = QuestController(
      repository: InMemoryQuestRepository(
        learningState: LearningState.fresh().copyWith(masteries: {
          word.id: ItemMastery(
            itemId: word.id,
            stage: MasteryStage.strong,
            repetitions: 3,
            intervalDays: 6,
            easeFactor: 2.5,
            attempts: 3,
            correctAnswers: 3,
            lapses: 0,
            dueAt: now.add(const Duration(days: 6)),
            lastReviewedAt: now,
          ),
        }),
      ),
    );
    await controller.load();
    expect(controller.wordCards[word.id], WordCards.collected);
  });

  testWidgets('the album counts cards and hides the ones not collected', (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    controller.wordCards[word.id] = WordCards.gold;
    await tester.pumpWidget(MaterialApp(home: WordCardsScreen(controller: controller)));
    await tester.pump();

    final total = controller.wordCatalog.where((entry) => ContentPolicy.playable(entry.review)).length;
    expect(find.text(AppText.of('cards.count', {'n': 1, 'total': total, 'gold': 1})), findsOneWidget);
    expect(find.bySemanticsLabel(AppText.of('cards.goldSpoken', {'word': word.word})), findsOneWidget);
    expect(find.bySemanticsLabel(AppText.of('cards.lockedSpoken')), findsWidgets);
  });

  testWidgets('a round\'s new cards turn over on the result sheet', (tester) async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    final ids = controller.wordCatalog.take(5).map((e) => e.id).toList();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: NewCardsRow(controller: controller, collected: ids.skip(1).toList(), gold: [ids.first]))));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(AppText.of('cards.new')), findsOneWidget);
    expect(find.byType(WordCard), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });
}
