import 'dart:math';

import 'data.dart';
import 'game_words.dart';
import 'word_groups.dart';

/// Word Groups: sixteen words to sort into four groups of four (birds,
/// fruit…). The daily puzzle is the same for everyone.
class WordGroupsPuzzle {
  WordGroupsPuzzle(this.groups, this.words);

  /// Easiest first: their colour follows this order.
  final List<WordGroup> groups;

  /// Each group's four words.
  final Map<String, List<WordEntry>> words;

  List<WordEntry> get tiles =>
      [for (final group in groups) ...words[group.id]!];

  WordGroup groupOf(WordEntry entry) =>
      groups.firstWhere((group) => words[group.id]!.contains(entry));

  /// A group's colour square in a shared grid, easiest to hardest.
  static const squares = ['🟨', '🟩', '🟦', '🟪'];
}

/// Four groups that don't overlap, four words each that belong to no other
/// chosen group and share no meaning or spelling with each other. From
/// level 3 two groups may be close (birds and four-legged animals), from
/// 4.5 all four may be. Null when the content can't make one.
WordGroupsPuzzle? buildWordGroupsPuzzle({
  required List<WordEntry> catalog,
  required double rating,
  required Random random,
}) {
  final byId = {
    for (final entry in catalog)
      if (ContentPolicy.playable(entry.review)) entry.id: entry
  };
  final members = <String, List<WordEntry>>{
    for (final group in wordGroups)
      group.id: [
        for (final id in group.wordIds)
          if (byId[id] case final entry?) entry
      ],
  };
  final sameFamily = rating < 3 ? 1 : (rating < 4.5 ? 2 : 4);

  for (var attempt = 0; attempt < 30; attempt++) {
    final candidates = [
      for (final group in wordGroups)
        if (members[group.id]!.length >= 4) group
    ]..shuffle(random);
    final chosen = <WordGroup>[];
    for (final group in candidates) {
      if (chosen.length == 4) break;
      if (chosen.any((other) => groupsOverlap(group, other))) continue;
      if (chosen.where((other) => other.family == group.family).length >=
          sameFamily) {
        continue;
      }
      chosen.add(group);
    }
    if (chosen.length < 4) continue;

    final spellings = <String>{};
    final senses = <String>{};
    final words = <String, List<WordEntry>>{};
    for (final group in chosen) {
      final pool = members[group.id]!
          .where((entry) => !chosen.any(
              (other) => other != group && other.wordIds.contains(entry.id)))
          .toList()
        ..shuffle(random);
      // Easier words first on easier days.
      if (rating < 3) {
        pool.sort((a, b) => a.difficulty.compareTo(b.difficulty));
      }
      final picked = <WordEntry>[];
      for (final entry in pool) {
        if (picked.length == 4) break;
        final spelling = foldMizo(entry.word);
        final meaning = glossSenses(entry.englishGloss);
        if (spellings.contains(spelling) ||
            meaning.intersection(senses).isNotEmpty) {
          continue;
        }
        picked.add(entry);
        spellings.add(spelling);
        senses.addAll(meaning);
      }
      if (picked.length < 4) break;
      words[group.id] = picked;
    }
    if (words.length < 4) continue;

    // Easiest first: a group alone in its family, of simpler words.
    double hardness(WordGroup group) =>
        chosen.where((other) => other.family == group.family).length * 10 +
        words[group.id]!.fold<int>(0, (sum, entry) => sum + entry.difficulty) /
            4;
    chosen.sort((a, b) => hardness(a).compareTo(hardness(b)));
    return WordGroupsPuzzle(chosen, words);
  }
  return null;
}
