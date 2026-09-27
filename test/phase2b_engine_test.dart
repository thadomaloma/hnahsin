import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/features/games/engine/phase2b_engine.dart';

void main() {
  test('sentence builder preserves duplicate-safe tiles and validates order', () {
    const engine = SentenceBuilderEngine();
    const exercise = SentenceExercise(
      id: 'sentence.test',
      textMizo: 'Ka nu chu a hlim.',
      englishSupport: 'My mother is happy.',
      tqLevel: 0,
    );
    final shuffled = engine.shuffledTiles(exercise, Random(17));
    final ordered = exercise.tokens
        .asMap()
        .entries
        .map(
          (entry) => SentenceTile(
            id: '${exercise.id}.${entry.key}',
            text: entry.value,
          ),
        )
        .toList();

    expect(shuffled.map((tile) => tile.id).toSet().length, shuffled.length);
    expect(engine.evaluate(exercise, shuffled), isFalse);
    expect(engine.evaluate(exercise, ordered), isTrue);
    expect(engine.readableAnswer(ordered), exercise.textMizo);
  });
}
