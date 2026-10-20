import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/src/games.dart';
import 'package:hnahsin/data/quest_repository.dart';
import 'package:hnahsin/features/games/application/daily_puzzle.dart';
import 'package:hnahsin/features/progress/domain/quest_progress.dart';
import 'package:hnahsin/src/controller.dart';
import 'package:hnahsin/src/daily_widgets.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/game_session.dart';
import 'package:hnahsin/src/game_words.dart';
import 'package:hnahsin/src/word_search_board.dart';

void main() {
  test('puzzles are numbered from 9 October 2026 and named by game and day',
      () {
    final first =
        DailyPuzzle(gameId: 'crossword', day: DateTime(2026, 10, 9, 23, 59));
    expect(first.number, 1);
    expect(first.key, 'crossword.2026-10-09');
    expect(DailyPuzzle(gameId: 'crossword', day: DateTime(2026, 11, 8)).number,
        31);
  });

  test('the seed is the same for everyone and differs by game and day', () {
    final a = DailyPuzzle(gameId: 'crossword', day: DateTime(2026, 10, 12));
    expect(a.seed,
        DailyPuzzle(gameId: 'crossword', day: DateTime(2026, 10, 12, 18)).seed);
    expect(
        a.seed,
        isNot(DailyPuzzle(gameId: 'word_search', day: DateTime(2026, 10, 12))
            .seed));
    expect(
        a.seed,
        isNot(DailyPuzzle(gameId: 'crossword', day: DateTime(2026, 10, 13))
            .seed));
  });

  test('Monday is easiest and Sunday hardest', () {
    expect(DailyPuzzle(gameId: 'crossword', day: DateTime(2026, 10, 12)).rating,
        1.5); // Monday
    expect(DailyPuzzle(gameId: 'crossword', day: DateTime(2026, 10, 18)).rating,
        5); // Sunday
  });

  test('a result survives storage and its share text names no words', () {
    const result =
        DailyResult(marks: ['🟩', '🟨', '🟩'], seconds: 151, hints: 1);
    final back = DailyResult.decode(result.encode())!;
    expect(back.marks, result.marks);
    expect(back.time, '2:31');
    expect(back.hints, 1);
    final text = dailyShareText(
        DailyPuzzle(gameId: 'word_search', day: DateTime(2026, 10, 10)), back);
    expect(text, contains('#2'));
    expect(text, contains('🟩🟨🟩'));
    expect(text, contains('2:31'));
  });

  test('two players get the same word search, whatever they remember', () {
    final puzzle =
        DailyPuzzle(gameId: 'word_search', day: DateTime(2026, 10, 14));
    WordSearchBoard board() => buildWordSearchBoard(
          catalog: wordEntries,
          rating: puzzle.rating,
          random: puzzle.random,
          pick: (pool, count) => pickDailyWords(pool, puzzle, count),
        );
    expect(board().rows, board().rows);
    expect(board().placements.keys, board().placements.keys);
    // An everyday board is random.
    final other = buildWordSearchBoard(
        catalog: wordEntries,
        rating: puzzle.rating,
        random: Random(99),
        pick: (pool, count) => pickDailyWords(pool, puzzle, count));
    expect(other.rows, isNot(board().rows));
  });

  test('daily results are saved with progress, the first one kept', () async {
    final repository = InMemoryQuestRepository();
    final controller = QuestController(repository: repository);
    final puzzle = controller.dailyPuzzle('crossword');
    await controller.recordDaily(
        puzzle, const DailyResult(marks: ['🟩'], seconds: 30, hints: 0));
    await controller.recordDaily(
        puzzle, const DailyResult(marks: ['🟨'], seconds: 10, hints: 2));

    expect(controller.dailyResult(puzzle)!.seconds, 30);
    final saved =
        QuestProgress.fromJson((await repository.loadProgress()).toJson());
    expect(DailyResult.decode(saved.dailyPuzzles[puzzle.key])!.marks, ['🟩']);
  });

  test('a daily puzzle earns XP but leaves the game level alone', () async {
    final controller = QuestController(repository: InMemoryQuestRepository());
    final before = controller.gameSkill('crossword');
    final outcome = await controller.reward(
      'crossword',
      const GameResult(
          sessionId: 's',
          rewardTransactionId: 't',
          score: 500,
          correctAnswers: 5,
          attempts: 5,
          bestCombo: 5,
          heartsLeft: 3,
          xp: 60,
          endReason: GameEndReason.completed),
      adaptive: false,
    );
    expect(outcome.xp, greaterThan(0));
    expect(controller.gameSkill('crossword'), before);
    expect(controller.bestScores['crossword'], isNull);
  });

  testWidgets('finishing the daily word search shows and keeps its result',
      (tester) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = QuestController(repository: InMemoryQuestRepository());
    final puzzle = controller.dailyPuzzle('word_search');
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: Center(
                    child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (_) => WordSearchGame(
                                    controller: controller,
                                    mode: GameMode.relaxed,
                                    daily: puzzle))),
                        child: const Text('open')))))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Everyone's board is this one, so the test knows where the words are.
    final board = buildWordSearchBoard(
      catalog: controller.wordCatalog,
      rating: puzzle.rating,
      random: puzzle.random,
      pick: (pool, count) => pickDailyWords(pool, puzzle, count),
    );
    await tester.pump(const Duration(seconds: 3));
    for (final cells in board.placements.values) {
      for (final (row, col) in cells) {
        await tester.tap(find.bySemanticsLabel(AppText.of('search.cellSpoken', {
          'row': row + 1,
          'column': col + 1,
          'letter': board.rows[row][col]
        })));
        await tester.pump();
      }
    }
    await tester.pumpAndSettle();

    final result = controller.dailyResult(puzzle)!;
    expect(
        result.marks, List.filled(board.placements.length, DailyResult.clean));
    expect(result.seconds, greaterThanOrEqualTo(3));
    expect(find.text(dailyTitle(puzzle)), findsWidgets);
    expect(find.text(AppText.of('daily.share')), findsOneWidget);
  });

  testWidgets('a word is found by swiping across it, either way',
      (tester) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = QuestController(repository: InMemoryQuestRepository());
    final puzzle = controller.dailyPuzzle('word_search');
    await tester.pumpWidget(MaterialApp(
        home: WordSearchGame(
            controller: controller, mode: GameMode.relaxed, daily: puzzle)));
    await tester.pump(const Duration(seconds: 1));
    final board = buildWordSearchBoard(
      catalog: controller.wordCatalog,
      rating: puzzle.rating,
      random: puzzle.random,
      pick: (pool, count) => pickDailyWords(pool, puzzle, count),
    );
    Offset centre((int, int) cell) => tester.getCenter(find.bySemanticsLabel(
        AppText.of('search.cellSpoken', {
          'row': cell.$1 + 1,
          'column': cell.$2 + 1,
          'letter': board.rows[cell.$1][cell.$2],
        })));
    Future<void> swipe((int, int) from, (int, int) to) async {
      final gesture = await tester.startGesture(centre(from));
      await tester.pump(const Duration(milliseconds: 20));
      final start = centre(from);
      final end = centre(to);
      for (var i = 1; i <= 8; i++) {
        await gesture.moveTo(Offset.lerp(start, end, i / 8)!);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 400));
    }

    final words = board.placements.entries.toList();
    // The first word from its first letter, the second from its last.
    await swipe(words[0].value.first, words[0].value.last);
    await swipe(words[1].value.last, words[1].value.first);
    expect(find.textContaining(board.labelOf(words[0].key)), findsWidgets);
    final state = tester.state(find.byType(WordSearchGame)) as dynamic;
    expect((state.found as Set<String>).length, 2);
    expect(tester.takeException(), isNull);
  });
}
