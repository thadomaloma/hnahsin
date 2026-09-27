import 'dart:math';

enum GameMode { relaxed, standard, timed }

enum GameSessionStatus { ready, active, paused, completed, failed, quit }

class GameSessionConfig {
  const GameSessionConfig({
    required this.gameId,
    this.version = 2,
    this.mode = GameMode.standard,
    this.seed,
    this.startingHearts = 3,
    this.contentIds = const <String>[],
  });

  final String gameId;
  final int version;
  final GameMode mode;
  final int? seed;
  final int startingHearts;
  final List<String> contentIds;
}

class GameSessionSnapshot {
  const GameSessionSnapshot({
    required this.sessionId,
    required this.gameId,
    required this.version,
    required this.mode,
    required this.status,
    required this.seed,
    required this.startingHearts,
    required this.hearts,
    required this.score,
    required this.correctAnswers,
    required this.attempts,
    required this.combo,
    required this.bestCombo,
    required this.currentIndex,
    required this.contentIds,
    required this.rewardTransactionId,
    required this.updatedAt,
    this.payload = const <String, Object?>{},
  });

  final String sessionId;
  final String gameId;
  final int version;
  final GameMode mode;
  final GameSessionStatus status;
  final int seed;
  final int startingHearts;
  final int hearts;
  final int score;
  final int correctAnswers;
  final int attempts;
  final int combo;
  final int bestCombo;
  final int currentIndex;
  final List<String> contentIds;
  final String rewardTransactionId;
  final DateTime updatedAt;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => <String, Object?>{
        'sessionId': sessionId,
        'gameId': gameId,
        'version': version,
        'mode': mode.name,
        'status': status.name,
        'seed': seed,
        'startingHearts': startingHearts,
        'hearts': hearts,
        'score': score,
        'correctAnswers': correctAnswers,
        'attempts': attempts,
        'combo': combo,
        'bestCombo': bestCombo,
        'currentIndex': currentIndex,
        'contentIds': contentIds,
        'rewardTransactionId': rewardTransactionId,
        'updatedAt': updatedAt.toIso8601String(),
        'payload': payload,
      };

  factory GameSessionSnapshot.fromJson(Map<String, Object?> json) {
    T enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) {
      for (final value in values) {
        if (value.name == raw) return value;
      }
      return fallback;
    }

    return GameSessionSnapshot(
      sessionId: json['sessionId'] as String,
      gameId: json['gameId'] as String,
      version: (json['version'] as num?)?.toInt() ?? 2,
      mode: enumValue(GameMode.values, json['mode'], GameMode.standard),
      status: enumValue(GameSessionStatus.values, json['status'], GameSessionStatus.ready),
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      startingHearts: (json['startingHearts'] as num?)?.toInt() ?? 3,
      hearts: (json['hearts'] as num?)?.toInt() ?? 3,
      score: (json['score'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      combo: (json['combo'] as num?)?.toInt() ?? 0,
      bestCombo: (json['bestCombo'] as num?)?.toInt() ?? 0,
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      contentIds: List<String>.unmodifiable(
        (json['contentIds'] as List<Object?>? ?? const <Object?>[]).whereType<String>(),
      ),
      rewardTransactionId: json['rewardTransactionId'] as String,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      payload: Map<String, Object?>.unmodifiable(
        Map<String, Object?>.from(json['payload'] as Map<Object?, Object?>? ?? const <Object?, Object?>{}),
      ),
    );
  }
}

class GameEngineResult {
  const GameEngineResult({required this.sessionId, required this.rewardTransactionId, required this.score, required this.correctAnswers, required this.attempts, required this.bestCombo, required this.heartsLeft, required this.xp});
  final String sessionId;
  final String rewardTransactionId;
  final int score;
  final int correctAnswers;
  final int attempts;
  final int bestCombo;
  final int heartsLeft;
  final int xp;
}

class GameEngine {
  GameEngine(this.config, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        seed = config.seed ?? DateTime.now().microsecondsSinceEpoch {
    sessionId = '${config.gameId}_${_now().microsecondsSinceEpoch}_$seed';
    rewardTransactionId = 'reward.$sessionId';
    hearts = config.startingHearts;
    score = 0;
    correctAnswers = 0;
    attempts = 0;
    combo = 0;
    bestCombo = 0;
    random = Random(seed);
    status = GameSessionStatus.active;
  }

  GameEngine.restore(GameSessionSnapshot snapshot, {DateTime Function()? now})
      : config = GameSessionConfig(gameId: snapshot.gameId, version: snapshot.version, mode: snapshot.mode, seed: snapshot.seed, startingHearts: snapshot.startingHearts, contentIds: snapshot.contentIds),
        _now = now ?? DateTime.now,
        seed = snapshot.seed,
        sessionId = snapshot.sessionId,
        rewardTransactionId = snapshot.rewardTransactionId,
        hearts = snapshot.hearts,
        score = snapshot.score,
        correctAnswers = snapshot.correctAnswers,
        attempts = snapshot.attempts,
        combo = snapshot.combo,
        bestCombo = snapshot.bestCombo,
        status = snapshot.status,
        random = Random(snapshot.seed);

  final GameSessionConfig config;
  final DateTime Function() _now;
  final int seed;
  late final String sessionId;
  late final String rewardTransactionId;
  late final Random random;
  late GameSessionStatus status;
  late int hearts;
  late int score;
  late int correctAnswers;
  late int attempts;
  late int combo;
  late int bestCombo;

  bool get hasHearts => hearts > 0;
  bool get canAnswer => status == GameSessionStatus.active && hasHearts;

  bool registerAnswer({required bool isCorrect, bool usedHint = false}) {
    if (!canAnswer) return false;
    attempts += 1;
    if (isCorrect) {
      correctAnswers += 1;
      if (usedHint) {
        combo = 0;
        score += 60;
      } else {
        combo += 1;
        bestCombo = max(bestCombo, combo);
        score += 100 + min(combo - 1, 4) * 25;
      }
    } else {
      combo = 0;
      if (config.mode != GameMode.relaxed) hearts = max(0, hearts - 1);
      if (!hasHearts) status = GameSessionStatus.failed;
    }
    return isCorrect;
  }

  void pause() {
    if (status == GameSessionStatus.active) status = GameSessionStatus.paused;
  }

  void resume() {
    if (status == GameSessionStatus.paused) status = GameSessionStatus.active;
  }

  void quit() {
    if (status == GameSessionStatus.active || status == GameSessionStatus.paused) status = GameSessionStatus.quit;
  }

  GameEngineResult finish({required int baseXp}) {
    if (status == GameSessionStatus.active || status == GameSessionStatus.paused) {
      status = hasHearts ? GameSessionStatus.completed : GameSessionStatus.failed;
    }
    final accuracy = attempts == 0 ? 0.0 : correctAnswers / attempts;
    final xp = attempts == 0
        ? 0
        : max(0, (baseXp * (.5 + accuracy * .5)).round());
    return GameEngineResult(sessionId: sessionId, rewardTransactionId: rewardTransactionId, score: score, correctAnswers: correctAnswers, attempts: attempts, bestCombo: bestCombo, heartsLeft: hearts, xp: xp);
  }

  GameSessionSnapshot snapshot({int currentIndex = 0, Map<String, Object?> payload = const <String, Object?>{}}) {
    return GameSessionSnapshot(sessionId: sessionId, gameId: config.gameId, version: config.version, mode: config.mode, status: status, seed: seed, startingHearts: config.startingHearts, hearts: hearts, score: score, correctAnswers: correctAnswers, attempts: attempts, combo: combo, bestCombo: bestCombo, currentIndex: currentIndex, contentIds: List<String>.unmodifiable(config.contentIds), rewardTransactionId: rewardTransactionId, updatedAt: _now().toUtc(), payload: Map<String, Object?>.unmodifiable(payload));
  }
}
