import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/game_words.dart';
import 'package:hnahsin/src/word_groups.dart';
import 'package:hnahsin/src/word_groups_puzzle.dart';

/// A catalog with a made-up word for every grouped word id.
List<WordEntry> _catalog() {
  final ids = {for (final group in wordGroups) ...group.wordIds}.toList();
  return [
    for (final (i, id) in ids.indexed)
      WordEntry(
        id: id,
        word: 'thumal$i',
        meaningMizo: 'awmzia $i',
        englishGloss: 'meaning $i',
        exampleMizo: '',
        emoji: '',
        category: WordCategory.khawvel,
        difficulty: 1 + i % 7,
        review: ContentReview.approved,
      ),
  ];
}

void main() {
  test('four groups of four different words, none in two chosen groups', () {
    for (final rating in [1.5, 3.0, 5.0]) {
      for (var seed = 0; seed < 20; seed++) {
        final puzzle = buildWordGroupsPuzzle(
            catalog: _catalog(), rating: rating, random: Random(seed))!;
        expect(puzzle.groups, hasLength(4));
        expect(puzzle.tiles, hasLength(16));
        expect(puzzle.tiles.map((entry) => entry.id).toSet(), hasLength(16));
        for (final group in puzzle.groups) {
          for (final other in puzzle.groups.where((g) => g != group)) {
            expect(groupsOverlap(group, other), isFalse);
            expect(
                puzzle.words[group.id]!
                    .any((entry) => other.wordIds.contains(entry.id)),
                isFalse,
                reason: '${group.id} / ${other.id}');
          }
        }
        final senses = puzzle.tiles.expand((e) => glossSenses(e.englishGloss));
        expect(senses.toSet().length, senses.length);
        if (rating < 3) {
          expect(puzzle.groups.map((g) => g.family).toSet(), hasLength(4),
              reason: 'easy days mix far-apart groups');
        }
      }
    }
  });

  test('the same day gives everyone the same puzzle', () {
    List<String> ids(int seed) => buildWordGroupsPuzzle(
            catalog: _catalog(), rating: 3, random: Random(seed))!
        .tiles
        .map((entry) => entry.id)
        .toList();
    expect(ids(42), ids(42));
  });
}
