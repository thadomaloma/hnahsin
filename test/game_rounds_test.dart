import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/data/quest_repository.dart';
import 'package:thumal_quest/features/games/engine/game_engine.dart';
import 'package:thumal_quest/src/controller.dart';
import 'package:thumal_quest/features/games/presentation/crossword_game.dart';
import 'package:thumal_quest/src/games.dart';
import 'package:thumal_quest/src/widgets.dart';

Finder _hearts(int left) => find.bySemanticsLabel(RegExp('^$left of 3 hearts'));

void main() {
  Future<void> pumpChain(WidgetTester tester, List<String> chain) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = InMemoryQuestRepository();
    final engine = GameEngine(const GameSessionConfig(
        gameId: 'word_chain', mode: GameMode.standard, seed: 1))
      ..pause();
    await repository.saveSession(
        engine.snapshot(currentIndex: chain.length - 1, payload: {'chain': chain}));
    await tester.pumpWidget(MaterialApp(
        home: WordChainGame(
            controller: QuestController(repository: repository),
            mode: GameMode.standard)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> play(WidgetTester tester, String word) async {
    await tester.enterText(find.byType(TextField), word);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }

  testWidgets('word chain: an unknown word costs no heart, a wrong link does',
      (tester) async {
    await pumpChain(tester, ['in']);

    await play(tester, 'qwxz');
    expect(find.textContaining('a la awm lo'), findsOneWidget);
    expect(_hearts(3), findsOneWidget);

    // "lal" is known but cannot follow "in".
    await play(tester, 'lal');
    expect(_hearts(2), findsOneWidget);
    expect(find.textContaining('“n” hmanga bulṭan tûr a ni'), findsOneWidget);
  });

  testWidgets('word chain links by Mizo alphabet letters: th starts with t',
      (tester) async {
    await pumpChain(tester, ['in', 'nat']);

    // Nothing here starts with “ng”, so “thing” would strand the learner:
    // it is explained, not scored.
    await play(tester, 'thing');
    expect(find.textContaining('bulṭan thumal kan la nei lo'), findsOneWidget);
    expect(_hearts(3), findsOneWidget);

    await play(tester, 'thla');
    expect(_hearts(3), findsOneWidget);
    expect(find.text('Thla'), findsOneWidget);
    expect(find.textContaining('“a” hmanga zawm leh rawh'), findsOneWidget);
  });

  testWidgets('a new word chain starts from a word with ways to go on',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
        home: WordChainGame(
            controller: QuestController(repository: InMemoryQuestRepository()))));
    await tester.pump();
    final tip = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? '')
        .firstWhere((data) => data.startsWith('TIP'));
    final count = int.parse(RegExp(r'thumal (\d+) kan nei').firstMatch(tip)!.group(1)!);
    expect(count, greaterThan(0));
  });

  testWidgets('crossword resumes the puzzle its saved letters belong to',
      (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<String> resumedClues() async {
      final repository = InMemoryQuestRepository();
      final engine = GameEngine(const GameSessionConfig(
          gameId: 'crossword', mode: GameMode.relaxed, seed: 7))
        ..pause();
      await repository.saveSession(engine.snapshot());
      await tester.pumpWidget(MaterialApp(
          key: UniqueKey(),
          home: MiniCrosswordGame(
              controller: QuestController(repository: repository),
              mode: GameMode.relaxed)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(GameResumeBanner), findsOneWidget);
      return tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .join('|');
    }

    expect(await resumedClues(), await resumedClues());
  });

  testWidgets('crossword checks each word as soon as it is filled in',
      (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = QuestController(repository: InMemoryQuestRepository());
    await tester.pumpWidget(MaterialApp(
        home: MiniCrosswordGame(controller: controller, mode: GameMode.standard)));
    await tester.pump();

    Future<void> typeWord(String word) async {
      for (final letter in word.split('')) {
        await tester.tap(find.ancestor(
            of: find.text(letter), matching: find.byType(InkWell)).first);
        await tester.pump();
      }
    }

    String activeAnswer() {
      // Level 1 clues are the English gloss.
      final header = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .firstWhere((data) => data.contains('HAWRAWP'));
      final length = int.parse(RegExp(r'(\d+) HAWRAWP').firstMatch(header)!.group(1)!);
      final clues = tester.widgetList<Text>(find.byType(Text)).map((text) => text.data);
      return controller.wordCatalog
          .map((entry) => entry.word.trim().toUpperCase())
          .firstWhere((word) =>
              word.length == length &&
              clues.contains(controller.wordCatalog
                  .firstWhere((entry) => entry.word.trim().toUpperCase() == word)
                  .englishGloss
                  .trim()));
    }

    await typeWord(activeAnswer());
    expect(find.byType(FeedbackCard), findsOneWidget);
    expect(_hearts(3), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    // A wrong word costs a heart and is marked for another try.
    final next = activeAnswer();
    final wrongWord = next.split('').map((letter) => letter == 'Z' ? 'A' : 'Z').join();
    await typeWord(wrongWord);
    expect(_hearts(2), findsOneWidget);
    expect(find.textContaining('a dik lo'), findsOneWidget);

    // Fixing it letter by letter is not checked again until every red
    // letter is replaced, so it costs no further hearts.
    final gloss = controller.wordCatalog
        .firstWhere((entry) => entry.word.trim().toUpperCase() == next)
        .englishGloss
        .trim();
    await tester.tap(find.text('$gloss (${next.length})'));
    await tester.pump();
    await typeWord(next);
    expect(_hearts(2), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
  });
}
