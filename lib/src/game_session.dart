import 'dart:math';

import '../features/games/engine/game_engine.dart';

enum GameEndReason { completed, heartsExhausted, timedOut, quit }

/// One word a round asked about and how it went, so the game can remember
/// it (missed words come back sooner) and show it on the result screen.
class WordPlay {
  const WordPlay({required this.id, required this.word, this.missed = false, this.hinted = false});

  final String id;
  final String word;

  /// Answered wrong at least once this round.
  final bool missed;

  /// Got right only with a hint.
  final bool hinted;

  Map<String, Object?> toJson() => {'id': id, 'word': word, 'missed': missed, 'hinted': hinted};

  static WordPlay? fromJson(Object? value) {
    if (value is! Map || value['id'] is! String || value['word'] is! String) return null;
    return WordPlay(
        id: value['id'] as String,
        word: value['word'] as String,
        missed: value['missed'] == true,
        hinted: value['hinted'] == true);
  }
}

class GameResult {
  const GameResult({
    required this.sessionId,
    required this.rewardTransactionId,
    required this.score,
    required this.correctAnswers,
    required this.attempts,
    required this.bestCombo,
    required this.heartsLeft,
    required this.xp,
    required this.endReason,
    this.words = const <WordPlay>[],
  });

  final String sessionId;
  final String rewardTransactionId;
  final int score;
  final int correctAnswers;
  final int attempts;
  final int bestCombo;
  final int heartsLeft;
  final int xp;
  final GameEndReason endReason;

  /// The words this round asked about.
  final List<WordPlay> words;

  GameResult withWords(List<WordPlay> value) => GameResult(
        sessionId: sessionId,
        rewardTransactionId: rewardTransactionId,
        score: score,
        correctAnswers: correctAnswers,
        attempts: attempts,
        bestCombo: bestCombo,
        heartsLeft: heartsLeft,
        xp: xp,
        endReason: endReason,
        words: List<WordPlay>.unmodifiable(value),
      );

  double get accuracy => attempts == 0 ? 0.0 : correctAnswers / attempts;
  int get stars => accuracy >= .9 ? 3 : (accuracy >= .65 ? 2 : 1);
}

/// Compatibility façade for existing screens while they migrate to the
/// resumable Phase 1 game engine.
class GameSession {
  GameSession({
    this.startingHearts = 3,
    String gameId = 'legacy_game',
    GameMode mode = GameMode.standard,
    int? seed,
  }) : _engine = GameEngine(
          GameSessionConfig(
            gameId: gameId,
            mode: mode,
            startingHearts: startingHearts,
            seed: seed,
          ),
        );

  GameSession.restore(GameSessionSnapshot snapshot)
      : startingHearts = snapshot.startingHearts,
        _engine = GameEngine.restore(snapshot);

  final int startingHearts;
  final GameEngine _engine;

  int get hearts => _engine.hearts;
  int get score => _engine.score;
  int get correctAnswers => _engine.correctAnswers;
  int get attempts => _engine.attempts;
  int get combo => _engine.combo;
  int get bestCombo => _engine.bestCombo;
  bool get hasHearts => _engine.hasHearts;
  GameMode get mode => _engine.config.mode;
  Random get random => _engine.random;
  String get sessionId => _engine.sessionId;
  String get rewardTransactionId => _engine.rewardTransactionId;
  GameSessionStatus get status => _engine.status;

  bool registerAnswer(bool isCorrect, {bool usedHint = false}) =>
      _engine.registerAnswer(isCorrect: isCorrect, usedHint: usedHint);

  void pause() => _engine.pause();

  void resume() => _engine.resume();

  GameSessionSnapshot snapshot({
    int currentIndex = 0,
    Map<String, Object?> payload = const <String, Object?>{},
  }) =>
      _engine.snapshot(currentIndex: currentIndex, payload: payload);

  GameResult finish({
    required int baseXp,
    GameEndReason? reason,
  }) {
    final result = _engine.finish(baseXp: baseXp);
    return GameResult(
      sessionId: result.sessionId,
      rewardTransactionId: result.rewardTransactionId,
      score: result.score,
      correctAnswers: result.correctAnswers,
      attempts: result.attempts,
      bestCombo: result.bestCombo,
      heartsLeft: result.heartsLeft,
      xp: result.xp,
      endReason: reason ??
          (result.heartsLeft > 0
              ? GameEndReason.completed
              : GameEndReason.heartsExhausted),
    );
  }
}
