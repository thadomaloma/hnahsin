import 'dart:math';

/// A word offered to the crossword builder.
class CrosswordCandidate {
  const CrosswordCandidate({required this.id, required this.answer, required this.clue});

  final String id;

  /// Upper-case letters only, one per cell.
  final String answer;
  final String clue;
}

/// A word placed on the grid, numbered in reading order like a printed
/// crossword.
class CrosswordSlot {
  const CrosswordSlot({
    required this.id,
    required this.number,
    required this.answer,
    required this.clue,
    required this.row,
    required this.col,
    required this.across,
  });

  final String id;
  final int number;
  final String answer;
  final String clue;
  final int row;
  final int col;
  final bool across;

  String get key => '$number${across ? 'a' : 'd'}';

  List<(int, int)> get cells => [
        for (var i = 0; i < answer.length; i++) across ? (row, col + i) : (row + i, col),
      ];
}

class CrosswordLayout {
  const CrosswordLayout({required this.rows, required this.cols, required this.slots});

  final int rows;
  final int cols;

  /// Across slots first, then down, each by number.
  final List<CrosswordSlot> slots;

  Map<(int, int), String> get solution => {
        for (final slot in slots)
          for (final (i, cell) in slot.cells.indexed) cell: slot.answer[i],
      };

  List<CrosswordSlot> slotsAt((int, int) cell) => [
        for (final slot in slots)
          if (slot.cells.contains(cell)) slot,
      ];
}

/// Builds a proper interlocking crossword: every word crosses another, and
/// letters only touch where they cross, so every run of two or more letters
/// on the grid is a clued word.
abstract final class CrosswordBuilder {
  static CrosswordLayout? build(
    List<CrosswordCandidate> candidates, {
    required int target,
    required Random random,
    int maxSize = 8,
    int tries = 16,
  }) {
    final usable = <String, CrosswordCandidate>{
      for (final candidate in candidates)
        if (candidate.answer.length >= 2 && candidate.answer.length <= maxSize) candidate.answer: candidate,
    }.values.toList();
    if (usable.length < 2) return null;

    _Grid? best;
    for (var attempt = 0; attempt < tries; attempt++) {
      final order = [...usable]..shuffle(random);
      // Start from the longest of a few words so others have letters to
      // cross; the rest keep their shuffled order so short words get in too.
      final opener = order.take(6).reduce((a, b) => b.answer.length > a.answer.length ? b : a);
      order.remove(opener);
      final grid = _Grid(maxSize)..place(opener, 0, 0, random.nextBool(), 0);
      for (final candidate in order) {
        if (grid.words.length >= target) break;
        final options = grid.placementsFor(candidate.answer);
        if (options.isEmpty) continue;
        options.sort((a, b) {
          final byCrossings = b.crossings.compareTo(a.crossings);
          return byCrossings != 0 ? byCrossings : a.area.compareTo(b.area);
        });
        final top = options.where((option) => option.crossings == options.first.crossings && option.area == options.first.area).toList();
        final pick = top[random.nextInt(top.length)];
        grid.place(candidate, pick.row, pick.col, pick.across, pick.crossings);
      }
      if (best == null || grid.betterThan(best)) best = grid;
      if (best.words.length >= target && best.crossings >= target) break;
    }
    if (best!.words.length < 2) return null;
    return best.toLayout();
  }
}

class _Placement {
  const _Placement(this.row, this.col, this.across, this.crossings, this.area);
  final int row;
  final int col;
  final bool across;
  final int crossings;
  final int area;
}

class _PlacedWord {
  const _PlacedWord(this.candidate, this.row, this.col, this.across);
  final CrosswordCandidate candidate;
  final int row;
  final int col;
  final bool across;
}

class _Grid {
  _Grid(this.maxSize);

  final int maxSize;
  final Map<(int, int), String> letters = {};
  final Map<(int, int), Set<bool>> directions = {};
  final List<_PlacedWord> words = [];
  int crossings = 0;
  int minRow = 0, maxRow = 0, minCol = 0, maxCol = 0;

  int get area => (maxRow - minRow + 1) * (maxCol - minCol + 1);

  bool betterThan(_Grid other) {
    if (words.length != other.words.length) return words.length > other.words.length;
    if (crossings != other.crossings) return crossings > other.crossings;
    return area < other.area;
  }

  void place(CrosswordCandidate candidate, int row, int col, bool across, int newCrossings) {
    if (words.isEmpty) {
      minRow = maxRow = row;
      minCol = maxCol = col;
    }
    for (var i = 0; i < candidate.answer.length; i++) {
      final cell = across ? (row, col + i) : (row + i, col);
      letters[cell] = candidate.answer[i];
      (directions[cell] ??= <bool>{}).add(across);
      minRow = min(minRow, cell.$1);
      maxRow = max(maxRow, cell.$1);
      minCol = min(minCol, cell.$2);
      maxCol = max(maxCol, cell.$2);
    }
    words.add(_PlacedWord(candidate, row, col, across));
    crossings += newCrossings;
  }

  List<_Placement> placementsFor(String answer) {
    final found = <_Placement>[];
    for (final MapEntry(key: cell, value: letter) in letters.entries) {
      for (var i = 0; i < answer.length; i++) {
        if (answer[i] != letter) continue;
        for (final across in const [true, false]) {
          if (directions[cell]!.contains(across)) continue;
          final row = across ? cell.$1 : cell.$1 - i;
          final col = across ? cell.$2 - i : cell.$2;
          final placement = _check(answer, row, col, across);
          if (placement != null) found.add(placement);
        }
      }
    }
    return found;
  }

  _Placement? _check(String answer, int row, int col, bool across) {
    final (dr, dc) = across ? (0, 1) : (1, 0);
    final endRow = row + dr * (answer.length - 1);
    final endCol = col + dc * (answer.length - 1);
    final top = min(minRow, row), bottom = max(maxRow, endRow);
    final left = min(minCol, col), right = max(maxCol, endCol);
    if (bottom - top + 1 > maxSize || right - left + 1 > maxSize) return null;
    // Nothing directly before or after the word.
    if (letters.containsKey((row - dr, col - dc)) || letters.containsKey((endRow + dr, endCol + dc))) return null;
    var crossed = 0;
    for (var i = 0; i < answer.length; i++) {
      final cell = (row + dr * i, col + dc * i);
      final existing = letters[cell];
      if (existing != null) {
        if (existing != answer[i] || directions[cell]!.contains(across)) return null;
        crossed += 1;
        continue;
      }
      // A new letter may not touch a neighbour side-on.
      if (letters.containsKey((cell.$1 + dc, cell.$2 + dr)) || letters.containsKey((cell.$1 - dc, cell.$2 - dr))) return null;
    }
    if (crossed == 0 || crossed == answer.length) return null;
    return _Placement(row, col, across, crossed, (bottom - top + 1) * (right - left + 1));
  }

  CrosswordLayout toLayout() {
    final starts = <(int, int)>{
      for (final word in words) (word.row - minRow, word.col - minCol),
    }.toList()
      ..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
    final numbers = {for (final (i, cell) in starts.indexed) cell: i + 1};
    final slots = [
      for (final word in words)
        CrosswordSlot(
          id: word.candidate.id,
          number: numbers[(word.row - minRow, word.col - minCol)]!,
          answer: word.candidate.answer,
          clue: word.candidate.clue,
          row: word.row - minRow,
          col: word.col - minCol,
          across: word.across,
        ),
    ]..sort((a, b) {
        if (a.across != b.across) return a.across ? -1 : 1;
        return a.number.compareTo(b.number);
      });
    return CrosswordLayout(rows: maxRow - minRow + 1, cols: maxCol - minCol + 1, slots: slots);
  }
}
