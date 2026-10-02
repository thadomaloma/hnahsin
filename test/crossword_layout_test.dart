import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/games/engine/crossword_layout.dart';
import 'package:hnahsin/features/games/presentation/crossword_game.dart';
import 'package:hnahsin/src/data.dart';

List<CrosswordCandidate> _candidates() => [
      for (final entry in wordEntries)
        if (RegExp(r'^[A-ZÂÊÎÔÛṬ]{3,7}$').hasMatch(entry.word.trim().toUpperCase()))
          CrosswordCandidate(id: entry.id, answer: entry.word.trim().toUpperCase(), clue: entry.englishGloss),
    ];

/// Every horizontal or vertical run of two or more letters on the grid.
Set<String> _runs(CrosswordLayout layout) {
  final letters = layout.solution;
  final runs = <String>{};
  for (final across in const [true, false]) {
    for (var line = 0; line < (across ? layout.rows : layout.cols); line++) {
      var start = -1;
      for (var i = 0; i <= (across ? layout.cols : layout.rows); i++) {
        final cell = across ? (line, i) : (i, line);
        if (letters.containsKey(cell)) {
          if (start < 0) start = i;
        } else {
          if (start >= 0 && i - start >= 2) runs.add('${across ? 'a' : 'd'}$line:$start-${i - 1}');
          start = -1;
        }
      }
    }
  }
  return runs;
}

void main() {
  test('builds valid interlocking crosswords', () {
    final candidates = _candidates();
    expect(candidates.length, greaterThan(10));
    for (var seed = 0; seed < 60; seed++) {
      final layout = CrosswordBuilder.build(candidates, target: 6, random: Random(seed))!;
      expect(layout.slots.length, greaterThanOrEqualTo(4), reason: 'seed $seed');
      expect(layout.rows, lessThanOrEqualTo(8));
      expect(layout.cols, lessThanOrEqualTo(8));

      // Crossing letters agree.
      final seen = <(int, int), String>{};
      for (final slot in layout.slots) {
        for (final (i, cell) in slot.cells.indexed) {
          expect(seen.putIfAbsent(cell, () => slot.answer[i]), slot.answer[i]);
        }
      }
      // Letters only touch where words cross: every run is a clued word.
      final slotRuns = {
        for (final slot in layout.slots)
          slot.across
              ? 'a${slot.row}:${slot.col}-${slot.col + slot.answer.length - 1}'
              : 'd${slot.col}:${slot.row}-${slot.row + slot.answer.length - 1}',
      };
      expect(_runs(layout), slotRuns, reason: 'seed $seed');
      // Every word crosses another.
      for (final slot in layout.slots) {
        expect(slot.cells.any((cell) => layout.slotsAt(cell).length > 1), isTrue);
      }
      // Numbers run in reading order.
      final starts = layout.slots.map((slot) => (slot.row, slot.col)).toSet().toList()
        ..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
      for (final slot in layout.slots) {
        expect(slot.number, starts.indexOf((slot.row, slot.col)) + 1);
      }
    }
  });

  test('the same seed builds the same puzzle', () {
    String describe(CrosswordLayout layout) =>
        layout.slots.map((slot) => '${slot.key}:${slot.answer}@${slot.row},${slot.col}').join(' ');
    final candidates = _candidates();
    expect(describe(CrosswordBuilder.build(candidates, target: 5, random: Random(3))!),
        describe(CrosswordBuilder.build(candidates, target: 5, random: Random(3))!));
  });

  test('the keyboard has every letter Mizo words are spelled with', () {
    final keys = MiniCrosswordGame.keyRows.join().split('').toSet();
    for (final letter in 'ABCDEFGHIJKLMNOPRSTUVWZÂÊÎÔÛṬ'.split('')) {
      expect(keys, contains(letter));
    }
  });

  test('clues never contain their own answer', () {
    expect(maskWordInClue('Bauh chu ui au dan a ni.', 'bauh'), '…… chu ui au dan a ni.');
    expect(maskWordInClue('Hmûn chu hmun a ni', 'hmun'), '…… chu …… a ni');
    expect(maskWordInClue('Ui au dan', 'bauh'), 'Ui au dan');
  });
}
