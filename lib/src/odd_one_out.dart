import 'dart:math';

import 'data.dart';
import 'game_words.dart';
import 'word_groups.dart';

/// Four words, three of one group and one that doesn't belong.
class OddOneOutQuestion {
  const OddOneOutQuestion({
    required this.options,
    required this.odd,
    required this.group,
    required this.oddGroup,
  });

  final List<WordEntry> options;
  final WordEntry odd;

  /// What the other three have in common.
  final WordGroup group;
  final WordGroup oddGroup;
}

/// A round of [count] Odd One Out questions at [rating]. Up to level 3 the
/// odd word comes from another kind of thing (three animals and a drink);
/// from level 4 from a close group where there is one (three birds and a
/// four-legged animal). [pick] chooses words at the player's level.
List<OddOneOutQuestion> buildOddOneOutRound({
  required List<WordEntry> catalog,
  required double rating,
  required Random random,
  required List<WordEntry> Function(List<WordEntry> pool, int count) pick,
  int count = 6,
}) {
  final byId = {
    for (final entry in catalog)
      if (ContentPolicy.playable(entry.review)) entry.id: entry
  };
  final members = <WordGroup, List<WordEntry>>{
    for (final group in wordGroups)
      group: [
        for (final id in group.wordIds)
          if (byId[id] case final entry?) entry
      ],
  };
  final groups = [
    for (final group in wordGroups)
      if (members[group]!.length >= 3) group
  ]..shuffle(random);
  final close = rating >= 4;
  final questions = <OddOneOutQuestion>[];
  final used = <String>{};
  for (final group in groups) {
    if (questions.length >= count) break;
    final others = [
      for (final other in wordGroups)
        if (other != group && members[other]!.isNotEmpty) other
    ];
    final near = others.where((other) => other.family == group.family).toList();
    final far = others.where((other) => other.family != group.family).toList();
    final choices = close && near.isNotEmpty ? near : far;
    if (choices.isEmpty) continue;
    final oddGroup = choices[random.nextInt(choices.length)];
    final three = pick(
        members[group]!.where((entry) => !used.contains(entry.id)).toList(), 3);
    // A word in both groups (or spelt like one) could be either answer.
    final spellings = {for (final entry in three) foldMizo(entry.word)};
    final senses = {
      for (final entry in three) ...glossSenses(entry.englishGloss)
    };
    final oddPool = members[oddGroup]!
        .where((entry) =>
            !used.contains(entry.id) &&
            !group.wordIds.contains(entry.id) &&
            !spellings.contains(foldMizo(entry.word)) &&
            glossSenses(entry.englishGloss).intersection(senses).isEmpty)
        .toList();
    if (three.length < 3 || oddPool.isEmpty) continue;
    final odd = pick(oddPool, 1).single;
    used.addAll([...three.map((entry) => entry.id), odd.id]);
    questions.add(OddOneOutQuestion(
      options: [...three, odd]..shuffle(random),
      odd: odd,
      group: group,
      oddGroup: oddGroup,
    ));
  }
  return questions;
}
