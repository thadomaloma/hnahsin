import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/mizo_lexicon.dart';
import 'package:hnahsin/features/games/presentation/crossword_game.dart';
import 'package:hnahsin/src/games.dart';
import 'package:hnahsin/src/widgets.dart';

Finder _hearts(int left) => find.bySemanticsLabel(
    RegExp('^${RegExp.escape(AppText.of('hud.heartsSpoken', {'hearts': left, 'total': 3}))}'));

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
    expect(find.textContaining("We don't have this word yet"), findsOneWidget);
    expect(_hearts(3), findsOneWidget);

    // "lal" is known but cannot follow "in".
    await play(tester, 'lal');
    expect(_hearts(2), findsOneWidget);
    expect(find.textContaining('it needs to start with “n”'), findsOneWidget);
  });

  testWidgets('word chain accepts a real Mizo word the content does not teach',
      (tester) async {
    MizoLexicon.use(['nawlpui']);
    addTearDown(() => MizoLexicon.use(const <String>[]));
    await pumpChain(tester, ['in']);

    await play(tester, 'nawlpui');
    expect(find.textContaining("We don't have this word yet"), findsNothing);
    expect(find.text('Nawlpui'), findsOneWidget);
    // Rova answers.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Nawlpui'), findsOneWidget);
  });

  testWidgets('word chain: Rova answers each word with one that links on',
      (tester) async {
    await pumpChain(tester, ['in']);
    await play(tester, 'nula');
    expect(find.text('…'), findsOneWidget, reason: 'Rova is thinking');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('…'), findsNothing);
    // Rova's word starts with the a that “nula” ends with.
    final bubbles = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? '')
        .where((data) => data.startsWith('A'))
        .toList();
    expect(bubbles, isNotEmpty);
  });

  testWidgets('word chain links by Mizo alphabet letters: th starts with t',
      (tester) async {
    await pumpChain(tester, ['nat']);

    // Nothing here starts with “ng”, so “thing” would strand the learner:
    // it is explained, not scored.
    await play(tester, 'thing');
    expect(find.textContaining('we have no word starting with'), findsOneWidget);
    expect(_hearts(3), findsOneWidget);

    await play(tester, 'thla');
    expect(_hearts(3), findsOneWidget);
    expect(find.text('Thla'), findsOneWidget);
    expect(find.textContaining('Now link a word starting with “a”'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
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
    final count = int.parse(RegExp(r'We know (\d+) words').firstMatch(tip)!.group(1)!);
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

    // Tap the on-screen keyboard's keys, not a grid square showing the same
    // letter (that would move to another word).
    final keyboard = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_Keyboard');
    Future<void> typeWord(String word) async {
      for (final letter in word.split('')) {
        await tester.tap(find.ancestor(
            of: find.descendant(of: keyboard, matching: find.text(letter)),
            matching: find.byType(InkWell)));
        await tester.pump();
      }
    }

    /// The letters of [answer] that the active word doesn't show yet, read
    /// from the grid's cells (the cursor is on its first open cell).
    String redLetters(String answer) {
      final cells = <(int, int), String?>{};
      late (int, int) cursor;
      for (final semantics in tester.widgetList<Semantics>(find.byWidgetPredicate(
          (widget) => widget is Semantics && (widget.properties.label ?? '').startsWith('Row ')))) {
        final match = RegExp(r'^Row (\d+), column (\d+), (?:empty|letter (.+))$')
            .firstMatch(semantics.properties.label!)!;
        final cell = (int.parse(match[1]!), int.parse(match[2]!));
        cells[cell] = match[3];
        if (semantics.properties.selected ?? false) cursor = cell;
      }
      final down = tester
          .widgetList<Text>(find.byType(Text))
          .any((text) => (text.data ?? '').contains('DOWN') && (text.data ?? '').contains('LETTERS'));
      final (dr, dc) = down ? (1, 0) : (0, 1);
      var start = cursor;
      while (cells.containsKey((start.$1 - dr, start.$2 - dc))) {
        start = (start.$1 - dr, start.$2 - dc);
      }
      return [
        for (var index = 0; index < answer.length; index += 1)
          if (cells[(start.$1 + dr * index, start.$2 + dc * index)] != answer[index]) answer[index],
      ].join();
    }

    String activeAnswer() {
      // Level 1 clues are the English gloss.
      final header = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data ?? '')
          .firstWhere((data) => data.contains('LETTERS'));
      final length = int.parse(RegExp(r'(\d+) LETTERS').firstMatch(header)!.group(1)!);
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
    // One wrong letter per open cell; a letter shared with the solved word
    // is already there.
    final wrongWord = redLetters(next).split('').map((letter) => letter == 'Z' ? 'A' : 'Z').join();
    await typeWord(wrongWord);
    expect(_hearts(2), findsOneWidget);
    expect(find.textContaining("isn't right"), findsOneWidget);

    // Fixing it letter by letter is not checked again until every red
    // letter is replaced, so it costs no further hearts.
    final gloss = controller.wordCatalog
        .firstWhere((entry) => entry.word.trim().toUpperCase() == next)
        .englishGloss
        .trim();
    await tester.tap(find.text('$gloss (${next.length})'));
    await tester.pump();
    // Retype only the red letters: a letter shared with the solved word is
    // locked and the cursor steps over it.
    await typeWord(redLetters(next));
    expect(_hearts(2), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
  });
}
