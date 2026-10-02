import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/games/engine/phase2b_engine.dart';

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

  test('tiles give away neither the first word nor the last', () {
    const engine = SentenceBuilderEngine();
    const exercise = SentenceExercise(
      id: 'sentence.test',
      textMizo: 'Tho la, sikul kal rawh.',
      englishSupport: 'Wake up and go to school.',
      tqLevel: 0,
    );
    final texts = engine.shuffledTiles(exercise, Random(3)).map((tile) => tile.text);
    expect(texts, unorderedEquals(['tho', 'la', 'sikul', 'kal', 'rawh']));
  });

  test('names keep their capital even at the start', () {
    const engine = SentenceBuilderEngine();
    const exercise = SentenceExercise(
        id: 's', textMizo: 'Mizo tawng ka zir.', englishSupport: 'I learn Mizo.', tqLevel: 0);
    final texts = engine.shuffledTiles(exercise, Random(1), names: {'Mizo'}).map((tile) => tile.text);
    expect(texts, contains('Mizo'));
  });

  test('two tiles showing the same word are interchangeable', () {
    const engine = SentenceBuilderEngine();
    const exercise = SentenceExercise(
        id: 's', textMizo: 'Ka pi leh ka pu an lo kal.', englishSupport: '', tqLevel: 0);
    final tiles = engine.shuffledTiles(exercise, Random(5));
    SentenceTile tile(String id) => tiles.firstWhere((t) => t.id == 's.$id');
    // The sentence's own second “ka” placed first still reads right.
    final answer = [tile('3'), tile('1'), tile('2'), tile('0'), tile('4'), tile('5'), tile('6'), tile('7')];
    expect(engine.evaluate(exercise, answer), isTrue);
  });

  test('stray spaces and marks never become tiles', () {
    const exercise = SentenceExercise(
        id: 's', textMizo: '  Ka nu  chu — a hlim. ', englishSupport: '', tqLevel: 0);
    expect(exercise.tokens, ['Ka', 'nu', 'chu', 'a', 'hlim.']);
  });
}
