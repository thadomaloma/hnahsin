import 'dart:math';

import '../features/games/engine/game_difficulty.dart';
import 'data.dart';

/// A Word Search grid and where each hidden word sits.
class WordSearchBoard {
  const WordSearchBoard({required this.rows, required this.placements});

  /// [WordSearchBoard.size] strings of [WordSearchBoard.size] letters.
  final List<String> rows;

  /// Each hidden word and its cells in reading order, in the order the
  /// words are listed to the player.
  final Map<String, List<(int, int)>> placements;

  static const size = 6;
  static const wordCount = 5;

  Iterable<String> get words => placements.keys;
}

const _fallbackWords = <String>['NULA', 'ZAI', 'AWM', 'RAM', 'TUI', 'LUI'];
final _lettersOnly = RegExp(r'^[A-ZÂÊÎÔÛṬ]+$');

/// Hides [WordSearchBoard.wordCount] reviewed words in a straight line each.
/// Levels 1–2 lay them across, one per row from the left; from level 2 they
/// sit anywhere across; from level 4 some run down too. The rest of the grid
/// is filled with letters from the catalog — at higher levels mostly the
/// hidden words' own letters, so decoys look like real words.
WordSearchBoard buildWordSearchBoard({
  required List<WordEntry> catalog,
  required double rating,
  required Random random,
  required List<WordEntry> Function(List<WordEntry> pool, int count) pick,
}) {
  const n = WordSearchBoard.size;
  final spellings = <String>{};
  final candidates = catalog
      .where((entry) => ContentPolicy.playable(entry.review))
      .where((entry) => entry.supportsGame('word_search'))
      .where((entry) {
    final word = entry.word.trim().toUpperCase();
    // Three letters or more: two-letter words turn up by chance anywhere.
    return word.length >= 3 && word.length <= n && _lettersOnly.hasMatch(word) && spellings.add(word);
  }).toList();

  final cells = List.generate(n, (_) => List<String?>.filled(n, null));
  final placements = <String, List<(int, int)>>{};
  final ordered = rating < 2;
  final canRunDown = rating >= 4;

  bool place(String word) {
    // A word inside another would be found in passing.
    if (placements.keys.any((other) => other.contains(word) || word.contains(other))) return false;
    for (var attempt = 0; attempt < 60; attempt++) {
      final down = canRunDown && random.nextBool();
      final row = ordered ? placements.length : random.nextInt(down ? n - word.length + 1 : n);
      final col = ordered ? 0 : random.nextInt(down ? n : n - word.length + 1);
      final spots = [for (var i = 0; i < word.length; i++) down ? (row + i, col) : (row, col + i)];
      if (spots.any((s) => s.$1 >= n || s.$2 >= n)) continue;
      final fits = [
        for (final (i, s) in spots.indexed) cells[s.$1][s.$2] == null || cells[s.$1][s.$2] == word[i],
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
    place(entry.word.trim().toUpperCase());
  }
  for (final word in _fallbackWords) {
    if (placements.length >= WordSearchBoard.wordCount) break;
    place(word);
  }

  final catalogLetters = <String>{
    for (final entry in catalog) ...entry.word.toUpperCase().split(''),
  }..removeWhere((letter) => !_lettersOnly.hasMatch(letter));
  if (catalogLetters.isEmpty) catalogLetters.addAll(const ['A', 'E', 'I', 'K', 'N', 'T', 'M', 'R']);
  final letterList = catalogLetters.toList();
  final targetLetters = [for (final word in placements.keys) ...word.split('')];
  final hardness = GameDifficulty.hardness(rating);
  String filler() => targetLetters.isNotEmpty && random.nextDouble() < hardness
      ? targetLetters[random.nextInt(targetLetters.length)]
      : letterList[random.nextInt(letterList.length)];

  return WordSearchBoard(
    rows: [
      for (final row in cells) [for (final letter in row) letter ?? filler()].join(),
    ],
    placements: placements,
  );
}
