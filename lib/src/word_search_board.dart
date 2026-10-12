import 'dart:math';

import '../features/games/engine/game_difficulty.dart';
import 'data.dart';

/// A Word Search grid and where each hidden word sits.
class WordSearchBoard {
  const WordSearchBoard({
    required this.rows,
    required this.placements,
    this.labels = const <String, String>{},
  });

  /// [size] strings of [size] letters.
  final List<String> rows;

  /// Each hidden word (its letters, without spaces) and its cells in
  /// reading order, in the order the words are listed to the player.
  final Map<String, List<(int, int)>> placements;

  /// How a hidden word is written, where that differs from its letters:
  /// “AITECHHIN” is “AITE CHHIN”.
  final Map<String, String> labels;

  static const wordCount = 5;

  /// The grid's side: 6 at levels 1–2, then 8 so longer words and phrases
  /// fit.
  static int sizeFor(double rating) => rating < 3 ? 6 : 8;

  int get size => rows.length;

  Iterable<String> get words => placements.keys;

  String labelOf(String word) => labels[word] ?? word;
}

/// A word's letters as the grid holds them: upper case, without spaces.
String wordSearchLetters(String word) =>
    word.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');

const _fallbackWords = <String>['NULA', 'ZAI', 'AWM', 'RAM', 'TUI', 'LUI'];
final _lettersOnly = RegExp(r'^[A-ZÂÊÎÔÛṬ]+$');

/// Hides [WordSearchBoard.wordCount] reviewed words in a straight line each.
/// Level 1 lays them across, one per row from the left; from level 2 they
/// sit anywhere across; from level 4 some run down, from 5 some slant and
/// from 6 some run backwards. The rest of the grid
/// is filled with letters from the catalog — at higher levels mostly the
/// hidden words' own letters, so decoys look like real words.
WordSearchBoard buildWordSearchBoard({
  required List<WordEntry> catalog,
  required double rating,
  required Random random,
  required List<WordEntry> Function(List<WordEntry> pool, int count) pick,
}) {
  final n = WordSearchBoard.sizeFor(rating);
  final spellings = <String>{};
  final candidates = catalog
      .where((entry) => ContentPolicy.playable(entry.review))
      .where((entry) => entry.supportsGame('word_search'))
      .where((entry) {
    final word = wordSearchLetters(entry.word);
    // Three letters or more: two-letter words turn up by chance anywhere.
    return word.length >= 3 &&
        word.length <= n &&
        _lettersOnly.hasMatch(word) &&
        spellings.add(word);
  }).toList();
  final labels = <String, String>{};

  final cells = List.generate(n, (_) => List<String?>.filled(n, null));
  final placements = <String, List<(int, int)>>{};
  final ordered = rating < 2;
  // Across always; down from level 4; slanting from 5; backwards from 6.
  final directions = <(int, int)>[
    (0, 1),
    if (rating >= 4) (1, 0),
    if (rating >= 5) ...[(1, 1), (-1, 1)],
    if (rating >= 6) ...[(0, -1), (-1, 0), (-1, -1), (1, -1)],
  ];
  int start(int step, int length) => step == 1
      ? random.nextInt(n - length + 1)
      : step == -1
          ? length - 1 + random.nextInt(n - length + 1)
          : random.nextInt(n);

  bool place(String word) {
    // A word inside another would be found in passing.
    if (placements.keys
        .any((other) => other.contains(word) || word.contains(other)))
      return false;
    for (var attempt = 0; attempt < 60; attempt++) {
      final (dr, dc) = ordered
          ? (0, 1)
          : directions[random.nextInt(directions.length)];
      final row = ordered ? placements.length : start(dr, word.length);
      final col = ordered ? 0 : start(dc, word.length);
      final spots = [
        for (var i = 0; i < word.length; i++) (row + dr * i, col + dc * i)
      ];
      if (spots.any((s) => s.$1 < 0 || s.$2 < 0 || s.$1 >= n || s.$2 >= n)) {
        continue;
      }
      final fits = [
        for (final (i, s) in spots.indexed)
          cells[s.$1][s.$2] == null || cells[s.$1][s.$2] == word[i],
      ].every((ok) => ok);
      if (!fits) {
        if (ordered) return false;
        continue;
      }
      for (final (i, s) in spots.indexed) {
        cells[s.$1][s.$2] = word[i];
      }
      placements[word] = spots;
      return true;
    }
    return false;
  }

  for (final entry in pick(candidates, WordSearchBoard.wordCount * 3)) {
    if (placements.length >= WordSearchBoard.wordCount) break;
    final word = wordSearchLetters(entry.word);
    if (place(word) && entry.word.trim().contains(' ')) {
      labels[word] =
          entry.word.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    }
  }
  for (final word in _fallbackWords) {
    if (placements.length >= WordSearchBoard.wordCount) break;
    place(word);
  }

  final catalogLetters = <String>{
    for (final entry in catalog) ...entry.word.toUpperCase().split(''),
  }..removeWhere((letter) => !_lettersOnly.hasMatch(letter));
  if (catalogLetters.isEmpty)
    catalogLetters.addAll(const ['A', 'E', 'I', 'K', 'N', 'T', 'M', 'R']);
  final letterList = catalogLetters.toList();
  final targetLetters = [for (final word in placements.keys) ...word.split('')];
  final hardness = GameDifficulty.hardness(rating);
  String filler() => targetLetters.isNotEmpty && random.nextDouble() < hardness
      ? targetLetters[random.nextInt(targetLetters.length)]
      : letterList[random.nextInt(letterList.length)];

  return WordSearchBoard(
    rows: [
      for (final row in cells)
        [for (final letter in row) letter ?? filler()].join(),
    ],
    placements: placements,
    labels: labels,
  );
}
