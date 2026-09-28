import 'dart:math';

/// Keeps every game in the learner's "flow zone": rounds should land at
/// roughly [targetAccuracy] correct — hard enough to stretch, easy enough to
/// keep going. Each game has its own skill rating on the same 1–7 scale as
/// word `difficulty`, so a rating of 3.4 means "mostly difficulty-3 words,
/// some 4s, a few warm-up 2s".
abstract final class GameDifficulty {
  static const minRating = 1.0;
  static const maxRating = 7.0;
  static const targetAccuracy = .78;

  /// Where a game starts before the learner has played it: their placement
  /// level (TQ0 → 1.0, TQ3 → 4.0 …).
  static double initialRating(int levelIndex) =>
      (levelIndex + 1).clamp(minRating, maxRating).toDouble();

  /// Rating after a finished round. Moves up after strong rounds, down after
  /// weak ones and stays put near the target; very short rounds (quit early)
  /// don't count.
  static double nextRating(
    double rating, {
    required int correct,
    required int attempts,
    bool failed = false,
  }) {
    if (attempts < 3) return rating;
    final accuracy = correct / attempts;
    var step = (accuracy - targetAccuracy) * 3;
    if (failed) step = min(step, -.4);
    step = step.clamp(-.9, .75).toDouble();
    return (rating + step).clamp(minRating, maxRating).toDouble();
  }

  /// 0 at the easiest rating, 1 at the hardest.
  static double hardness(double rating) =>
      ((rating - minRating) / (maxRating - minRating)).clamp(0, 1).toDouble();

  /// Picks [count] items weighted towards the rating (slightly above it, so
  /// every round stretches a little), then orders them easiest first so a
  /// round warms up before it gets hard.
  static List<T> pick<T>(
    List<T> pool, {
    required double rating,
    required int count,
    required int Function(T item) difficultyOf,
    required Random random,
  }) {
    if (pool.length <= count) {
      return [...pool]
        ..sort((a, b) => difficultyOf(a).compareTo(difficultyOf(b)));
    }
    final centre = rating + .3;
    const spread = .85;
    final keyed = <(double, T)>[
      for (final item in pool)
        (
          // Efraimidis–Spirakis weighted sampling without replacement.
          pow(random.nextDouble(),
                  1 / _weight(difficultyOf(item), centre, spread))
              .toDouble(),
          item,
        ),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    final chosen = [for (final entry in keyed.take(count)) entry.$2];
    return chosen..sort((a, b) => difficultyOf(a).compareTo(difficultyOf(b)));
  }

  static double _weight(int difficulty, double centre, double spread) {
    final distance = difficulty - centre;
    return max(1e-6, exp(-(distance * distance) / (2 * spread * spread)));
  }

  /// Wrong options for a question. At low ratings they are picked at random
  /// (clearly different from the answer); as the rating rises they are drawn
  /// more and more from the candidates most [similarity] to the answer.
  static List<T> distractors<T>(
    T answer,
    List<T> candidates, {
    required double rating,
    required int count,
    required double Function(T answer, T candidate) similarity,
    required Random random,
  }) {
    final pressure = hardness(rating) * .9;
    final ranked = <(double, T)>[
      for (final candidate in candidates)
        (
          similarity(answer, candidate) * pressure +
              random.nextDouble() * (1 - pressure),
          candidate
        ),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final entry in ranked.take(count)) entry.$2];
  }

  /// Mizo alphabet letters learners confuse: plain vs circumflex vowels,
  /// aw vs o (they sound alike), n vs ng at a word's end, and t vs ṭ.
  static const confusableLetters = <String, List<String>>{
    'A': ['Â'],
    'Â': ['A'],
    'AW': ['ÂW', 'O'],
    'ÂW': ['AW', 'O'],
    'E': ['Ê'],
    'Ê': ['E'],
    'I': ['Î'],
    'Î': ['I'],
    'O': ['Ô', 'AW'],
    'Ô': ['O'],
    'U': ['Û'],
    'Û': ['U'],
    'N': ['NG'],
    'NG': ['N'],
    'T': ['Ṭ'],
    'Ṭ': ['T'],
  };

  static const _vowels = {'A', 'AW', 'E', 'I', 'O', 'U', 'Â', 'ÂW', 'Ê', 'Î', 'Ô', 'Û'};

  /// How alike two letters are for spelling distractors (1 = easily confused).
  static double letterSimilarity(String a, String b) {
    if (confusableLetters[a]?.contains(b) ?? false) return 1;
    final bothVowels = _vowels.contains(a) && _vowels.contains(b);
    final bothConsonants = !_vowels.contains(a) && !_vowels.contains(b);
    return bothVowels || bothConsonants ? .6 : 0;
  }
}
