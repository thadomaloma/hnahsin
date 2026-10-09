import 'dart:math';

/// Today's puzzle for a game: the same for everyone with the same content,
/// built from the day rather than from the player. Easiest on Monday,
/// hardest on Sunday, like newspaper puzzles.
class DailyPuzzle {
  DailyPuzzle({required this.gameId, required DateTime day})
      : day = DateTime(day.year, day.month, day.day);

  /// Today's puzzle in local time.
  factory DailyPuzzle.today(String gameId, DateTime now) =>
      DailyPuzzle(gameId: gameId, day: now);

  /// Puzzle #1.
  static final firstDay = DateTime(2026, 10, 9);

  final String gameId;
  final DateTime day;

  /// The puzzle's number, counted from [firstDay].
  int get number =>
      DateTime.utc(day.year, day.month, day.day)
          .difference(DateTime.utc(firstDay.year, firstDay.month, firstDay.day))
          .inDays +
      1;

  String get dayKey =>
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  /// Where its result is kept.
  String get key => '$gameId.$dayKey';

  /// Where a half-played one is saved: yesterday's never resumes as today's.
  String get sessionId => '$gameId.daily.$dayKey';

  /// Seeds the puzzle's choices: the same for everyone today.
  int get seed {
    var hash = 17;
    for (final unit in key.codeUnits) {
      hash = (hash * 31 + unit) & 0x3fffffff;
    }
    return hash;
  }

  Random get random => Random(seed);

  /// The level it is built at: 1.5 on Monday up to 5 on Sunday.
  double get rating =>
      const [1.5, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0][day.weekday - 1];
}

/// How a daily puzzle went: one mark per word (in the puzzle's order), the
/// time taken and the hints used. It names no words, so sharing it spoils
/// nothing.
class DailyResult {
  const DailyResult(
      {required this.marks, required this.seconds, required this.hints});

  /// Solved straight away.
  static const clean = '🟩';

  /// Solved after a mistake or with a hint.
  static const helped = '🟨';

  final List<String> marks;
  final int seconds;
  final int hints;

  String get time =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  String encode() => '${marks.join()}|$seconds|$hints';

  static DailyResult? decode(String? value) {
    final parts = value?.split('|');
    if (parts == null || parts.length != 3) return null;
    final seconds = int.tryParse(parts[1]);
    final hints = int.tryParse(parts[2]);
    if (seconds == null || hints == null) return null;
    return DailyResult(
      marks: [for (final rune in parts[0].runes) String.fromCharCode(rune)],
      seconds: seconds,
      hints: hints,
    );
  }
}
