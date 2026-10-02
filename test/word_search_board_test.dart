import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/word_search_board.dart';

WordEntry _word(String word) => WordEntry(
      id: 'w.$word',
      word: word,
      meaningMizo: 'awmzia',
      englishGloss: 'gloss',
      exampleMizo: '',
      emoji: '',
      category: WordCategory.values.first,
      review: ContentReview.approved,
    );

WordSearchBoard _board(List<WordEntry> catalog,
        {double rating = 1, int seed = 0}) =>
    buildWordSearchBoard(
      catalog: catalog,
      rating: rating,
      random: Random(seed),
      pick: (pool, count) => pool.take(count).toList(),
    );

void main() {
  final catalog = [
    for (final w in [
      'au',
      'in',
      'chi-ai',
      'bâwng',
      'rûl',
      'ram',
      'rama',
      'tlâng',
      'kâng',
      'nula',
      'thlawk',
      'sava',
      'ui ',
      'lehkhabu'
    ])
      _word(w),
  ];

  test('every word sits in a straight line and reads right', () {
    for (var seed = 0; seed < 50; seed++) {
      for (final rating in const [1.0, 2.5, 5.0]) {
        final board = _board(catalog, rating: rating, seed: seed);
        final size = WordSearchBoard.sizeFor(rating);
        expect(board.rows, hasLength(size));
        expect(board.rows.every((row) => row.length == size), isTrue);
        expect(board.placements, hasLength(WordSearchBoard.wordCount));
        for (final MapEntry(key: word, value: cells)
            in board.placements.entries) {
          expect(cells.map((c) => board.rows[c.$1][c.$2]).join(), word);
          final (dr, dc) =
              (cells[1].$1 - cells[0].$1, cells[1].$2 - cells[0].$2);
          expect({(0, 1), (1, 0)}, contains((dr, dc)));
          for (var i = 1; i < cells.length; i++) {
            expect(
                (cells[i].$1 - cells[i - 1].$1, cells[i].$2 - cells[i - 1].$2),
                (dr, dc));
          }
        }
      }
    }
  });

  test(
      'two-letter words, hyphenated words and words inside others are left out',
      () {
    for (var seed = 0; seed < 50; seed++) {
      final words = _board(catalog, rating: 3, seed: seed).words.toSet();
      expect(words.where((w) => w.length < 3), isEmpty);
      expect(words.where((w) => w.contains('-')), isEmpty);
      expect(words.containsAll({'RAM', 'RAMA'}), isFalse);
    }
  });

  test(
      'levels 1–2 lay words across from the left; level 4 up can run them down',
      () {
    final easy = _board(catalog);
    expect(
        easy.placements.values.every(
            (cells) => cells.first.$2 == 0 && cells[1].$1 == cells[0].$1),
        isTrue);
    final downs = [
      for (var seed = 0; seed < 30; seed++)
        ..._board(catalog, rating: 5, seed: seed)
            .placements
            .values
            .where((cells) => cells[1].$2 == cells[0].$2),
    ];
    expect(downs, isNotEmpty);
  });

  test('the same seed builds the same board', () {
    expect(_board(catalog, rating: 5, seed: 9).rows,
        _board(catalog, rating: 5, seed: 9).rows);
  });

  test('level 3 up uses an 8×8 grid, with room for longer words and phrases',
      () {
    expect(WordSearchBoard.sizeFor(2.9), 6);
    expect(WordSearchBoard.sizeFor(3), 8);
    final long = [
      for (final w in [
        'lehkhabu',
        'aite chhin',
        'thlawhna',
        'bâwngsa',
        'mautawk',
        'zirtirtu'
      ])
        _word(w),
    ];
    var phrases = 0;
    for (var seed = 0; seed < 30; seed++) {
      final board = _board(long, rating: 4, seed: seed);
      expect(board.size, 8);
      expect(board.words, contains('LEHKHABU'));
      for (final word in board.words) {
        expect(word, isNot(contains(' ')));
        expect(board.placements[word], hasLength(word.length));
      }
      if (board.words.contains('AITECHHIN')) fail('9 letters do not fit in 8');
      phrases += board.labels.length;
    }
    // “aite chhin” is 9 letters: too long; a phrase that fits keeps its spaces.
    final fits = _board([
      ..._wordsOf(['ui ram', 'nula', 'rûl', 'kâng', 'tlâng'])
    ], rating: 4);
    expect(fits.labelOf('UIRAM'), 'UI RAM');
    expect(fits.labelOf('NULA'), 'NULA');
    expect(phrases, 0);
  });
}

List<WordEntry> _wordsOf(List<String> words) =>
    [for (final w in words) _word(w)];
