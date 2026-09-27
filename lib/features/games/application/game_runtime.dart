import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../src/controller.dart';
import '../../../src/game_session.dart';
import '../engine/game_engine.dart';

typedef GamePayloadReader = Map<String, Object?> Function();
typedef GameSnapshotRestorer = void Function(GameSessionSnapshot snapshot);

/// Shared presentation runtime for save/resume, lifecycle, timed mode and
/// hint-assisted scoring. Game widgets only provide their serializable state.
class GameRuntime with WidgetsBindingObserver {
  GameRuntime({
    required this.controller,
    required this.gameId,
    required this.mode,
    required this.onChanged,
    required this.onTimedOut,
    this.timedSeconds = 90,
  })  : remainingSeconds = timedSeconds,
        session = GameSession(gameId: gameId, mode: mode);

  final QuestController controller;
  final String gameId;
  final GameMode mode;
  final VoidCallback onChanged;
  final Future<void> Function() onTimedOut;
  final int timedSeconds;

  GameSession session;
  int remainingSeconds;
  int hintsUsed = 0;
  bool hintRevealed = false;
  bool restoredSession = false;
  bool ready = false;

  Timer? _timer;
  Future<void> _saveQueue = Future<void>.value();
  bool _disposed = false;
  bool _initialized = false;
  late int Function() _currentIndex;
  late GamePayloadReader _readPayload;
  late GameSnapshotRestorer _restorePayload;

  bool get isTimed => session.mode == GameMode.timed;

  Future<void> initialize({
    required int Function() currentIndex,
    required GamePayloadReader readPayload,
    required GameSnapshotRestorer restorePayload,
  }) async {
    _currentIndex = currentIndex;
    _readPayload = readPayload;
    _restorePayload = restorePayload;
    WidgetsBinding.instance.addObserver(this);

    GameSessionSnapshot? snapshot;
    try {
      snapshot = await controller.loadSession(gameId);
    } catch (error, stackTrace) {
      debugPrint('Saved $gameId session could not be loaded: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    if (_disposed) return;
    if (snapshot != null &&
        (snapshot.status == GameSessionStatus.active ||
            snapshot.status == GameSessionStatus.paused)) {
      session = GameSession.restore(snapshot);
      remainingSeconds =
          (snapshot.payload['_remainingSeconds'] as num?)?.toInt() ??
              timedSeconds;
      hintsUsed = (snapshot.payload['_hintsUsed'] as num?)?.toInt() ?? 0;
      hintRevealed = snapshot.payload['_hintRevealed'] as bool? ?? false;
      restoredSession = true;
      _restorePayload(snapshot);
      session.resume();
    }
    _initialized = true;
    ready = true;
    _startTimer();
    onChanged();
  }

  bool answer(bool isCorrect) {
    if (!ready) return false;
    final accepted = session.registerAnswer(
      isCorrect,
      usedHint: hintRevealed,
    );
    hintRevealed = false;
    unawaited(persist());
    return accepted;
  }

  Future<void> revealHint() async {
    if (!ready || hintRevealed || session.status != GameSessionStatus.active) {
      return;
    }
    hintRevealed = true;
    hintsUsed += 1;
    onChanged();
    await persist();
  }

  Future<GameResult> finish({
    required int baseXp,
    GameEndReason? reason,
  }) async {
    _timer?.cancel();
    final result = session.finish(baseXp: baseXp, reason: reason);
    await _saveQueue;
    return result;
  }

  Future<void> persist() {
    if (!_initialized || _disposed) return Future<void>.value();
    if (session.status != GameSessionStatus.active &&
        session.status != GameSessionStatus.paused) {
      return Future<void>.value();
    }
    final snapshot = session.snapshot(
      currentIndex: _currentIndex(),
      payload: <String, Object?>{
        ..._readPayload(),
        '_remainingSeconds': remainingSeconds,
        '_hintsUsed': hintsUsed,
        '_hintRevealed': hintRevealed,
      },
    );
    _saveQueue = _saveQueue.then((_) async {
      try {
        await controller.saveSession(snapshot);
      } catch (error, stackTrace) {
        debugPrint('$gameId session could not be saved: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
    return _saveQueue;
  }

  void _startTimer() {
    _timer?.cancel();
    if (!isTimed || remainingSeconds <= 0 || _disposed) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_disposed || session.status != GameSessionStatus.active) return;
      remainingSeconds -= 1;
      onChanged();
      if (remainingSeconds > 0) {
        if (remainingSeconds % 5 == 0) unawaited(persist());
        return;
      }
      timer.cancel();
      unawaited(_expireTimedSession());
    });
  }

  Future<void> _expireTimedSession() async {
    await persist();
    if (!_disposed) await onTimedOut();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized || _disposed) return;
    switch (state) {
      case AppLifecycleState.resumed:
        session.resume();
        _startTimer();
        onChanged();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _timer?.cancel();
        session.pause();
        unawaited(persist());
    }
  }

  void dispose() {
    if (_disposed) return;
    if (_initialized && session.status == GameSessionStatus.active) {
      session.pause();
      unawaited(persist());
    }
    _disposed = true;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
