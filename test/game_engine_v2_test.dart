import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';

void main() {
  test('seed makes round randomness reproducible', () {
    final first = GameEngine(
      const GameSessionConfig(gameId: 'picture_match', seed: 42),
    );
    final second = GameEngine(
      const GameSessionConfig(gameId: 'picture_match', seed: 42),
    );

    final firstOrder = List<int>.generate(10, (index) => index)
      ..shuffle(first.random);
    final secondOrder = List<int>.generate(10, (index) => index)
      ..shuffle(second.random);
    expect(firstOrder, secondOrder);
  });

  test('snapshot round-trip preserves session state', () {
    final engine = GameEngine(
      const GameSessionConfig(
        gameId: 'spelling',
        seed: 91,
        contentIds: <String>['word-1', 'word-2'],
      ),
    );
    engine.registerAnswer(isCorrect: true);
    engine.registerAnswer(isCorrect: false);

    final encoded = engine.snapshot(
      currentIndex: 1,
      payload: const <String, Object?>{'selected': 'A'},
    ).toJson();
    final restored = GameEngine.restore(GameSessionSnapshot.fromJson(encoded));

    expect(restored.sessionId, engine.sessionId);
    expect(restored.score, 100);
    expect(restored.hearts, 2);
    expect(restored.attempts, 2);
    expect(restored.config.contentIds, <String>['word-1', 'word-2']);
  });

  test('terminal session rejects later answers', () {
    final engine = GameEngine(
      const GameSessionConfig(gameId: 'word_chain', seed: 7),
    );
    engine.registerAnswer(isCorrect: true);
    engine.finish(baseXp: 40);

    expect(engine.registerAnswer(isCorrect: true), isFalse);
    expect(engine.attempts, 1);
  });

  test('relaxed mode teaches without removing hearts', () {
    final engine = GameEngine(
      const GameSessionConfig(
        gameId: 'tawng_upa',
        mode: GameMode.relaxed,
        seed: 11,
      ),
    );

    for (var index = 0; index < 5; index += 1) {
      engine.registerAnswer(isCorrect: false);
    }

    expect(engine.hearts, 3);
    expect(engine.status, GameSessionStatus.active);
  });

  test('combo bonus is capped at one hundred points', () {
    final engine = GameEngine(
      const GameSessionConfig(gameId: 'spelling', seed: 17),
    );
    for (var index = 0; index < 7; index += 1) {
      engine.registerAnswer(isCorrect: true);
    }

    // 100 + 125 + 150 + 175 + 200 + 200 + 200
    expect(engine.score, 1150);
  });

  test('hint-assisted answer earns sixty and breaks combo', () {
    final engine = GameEngine(
      const GameSessionConfig(gameId: 'picture_match', seed: 19),
    );
    engine.registerAnswer(isCorrect: true);
    engine.registerAnswer(isCorrect: true, usedHint: true);

    expect(engine.score, 160);
    expect(engine.combo, 0);
    expect(engine.bestCombo, 1);
  });

  test('zero-attempt timed result does not award XP', () {
    final engine = GameEngine(
      const GameSessionConfig(
        gameId: 'word_search',
        mode: GameMode.timed,
        seed: 23,
      ),
    );

    expect(engine.finish(baseXp: 45).xp, 0);
  });
}
