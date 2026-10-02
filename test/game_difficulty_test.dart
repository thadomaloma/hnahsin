import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/games/engine/game_difficulty.dart';

void main() {
  group('rating', () {
    test('starts from the placement level', () {
      expect(GameDifficulty.initialRating(0), 1);
      expect(GameDifficulty.initialRating(3), 4);
      expect(GameDifficulty.initialRating(12), 7);
    });

    test('rises after strong rounds, falls after weak ones, holds near target',
        () {
      const start = 3.0;
      expect(GameDifficulty.nextRating(start, correct: 10, attempts: 10),
          greaterThan(start));
      expect(GameDifficulty.nextRating(start, correct: 3, attempts: 10),
          lessThan(start));
      final nearTarget =
          GameDifficulty.nextRating(start, correct: 8, attempts: 10);
      expect((nearTarget - start).abs(), lessThan(.1));
    });

    test('losing every heart always steps down, and bounds hold', () {
      expect(
          GameDifficulty.nextRating(4, correct: 9, attempts: 10, failed: true),
          lessThan(4));
      expect(GameDifficulty.nextRating(7, correct: 10, attempts: 10), 7);
      expect(GameDifficulty.nextRating(1, correct: 0, attempts: 10), 1);
    });

    test('rounds quit before three answers do not move the rating', () {
      expect(GameDifficulty.nextRating(2.5, correct: 0, attempts: 2), 2.5);
    });

    test('a steady learner climbs a level within a few strong rounds', () {
      var rating = 1.0;
      for (var round = 0; round < 3; round++) {
        rating = GameDifficulty.nextRating(rating, correct: 10, attempts: 10);
      }
      expect(rating, greaterThanOrEqualTo(2.5));
    });
  });

  group('pick', () {
    final pool = [
      for (var d = 1; d <= 7; d++)
        for (var i = 0; i < 30; i++) (d, i)
    ];
    int difficultyOf((int, int) item) => item.$1;

    double averageDifficulty(double rating) {
      var total = 0.0;
      for (var seed = 0; seed < 40; seed++) {
        final picked = GameDifficulty.pick(pool,
            rating: rating,
            count: 10,
            difficultyOf: difficultyOf,
            random: Random(seed));
        total +=
            picked.map(difficultyOf).reduce((a, b) => a + b) / picked.length;
      }
      return total / 40;
    }

    test('centres rounds on the learner rating', () {
      expect(averageDifficulty(1), lessThan(2));
      expect(averageDifficulty(4), inInclusiveRange(3.6, 4.9));
      expect(averageDifficulty(7), greaterThan(6));
    });

    test('orders a round from easiest to hardest without duplicates', () {
      final picked = GameDifficulty.pick(pool,
          rating: 3, count: 10, difficultyOf: difficultyOf, random: Random(7));
      expect(picked.toSet().length, 10);
      for (var i = 1; i < picked.length; i++) {
        expect(picked[i].$1, greaterThanOrEqualTo(picked[i - 1].$1));
      }
    });
  });

  test('distractors get more similar as the rating rises', () {
    final candidates = [for (var i = 0; i < 40; i++) i];
    double similarity(int answer, int candidate) => candidate < 4 ? 1 : 0;
    int similarHits(double rating) {
      var hits = 0;
      for (var seed = 0; seed < 50; seed++) {
        hits += GameDifficulty.distractors(0, candidates,
                rating: rating,
                count: 3,
                similarity: similarity,
                random: Random(seed))
            .where((c) => c < 4)
            .length;
      }
      return hits;
    }

    expect(similarHits(7), greaterThan(similarHits(1) * 3));
  });

  test('circumflex and ṭ letters are the most confusable', () {
    expect(GameDifficulty.letterSimilarity('A', 'Â'), 1);
    expect(GameDifficulty.letterSimilarity('T', 'Ṭ'), 1);
    expect(GameDifficulty.letterSimilarity('A', 'K'), 0);
  });
}
