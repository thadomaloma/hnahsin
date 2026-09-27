import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/games/engine/game_engine.dart';
import '../features/journey/domain/journey_state.dart';
import '../features/learning/domain/learning_state.dart';
import '../features/onboarding/domain/learner_profile.dart';
import '../features/progress/domain/quest_progress.dart';
import 'quest_repository.dart';

class PreferencesQuestRepository implements QuestRepository {
  PreferencesQuestRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;
  static const _profileKey = 'phase1.profile';
  static const _progressKey = 'phase1.progress';
  static const _rewardsKey = 'phase1.reward_transactions';
  static const _learningKey = 'phase2a.learning_state';
  static const _journeyKey = 'phase3a.journey_state';

  @override
  Future<LearnerProfile> loadProfile() async {
    final payload = await _preferences.getString(_profileKey);
    if (payload == null) return LearnerProfile.fresh();
    return LearnerProfile.fromJson(
      Map<String, Object?>.from(jsonDecode(payload) as Map),
    );
  }

  @override
  Future<void> saveProfile(LearnerProfile profile) =>
      _preferences.setString(_profileKey, jsonEncode(profile.toJson()));

  @override
  Future<QuestProgress> loadProgress() async {
    final payload = await _preferences.getString(_progressKey);
    if (payload != null) {
      return QuestProgress.fromJson(
        Map<String, Object?>.from(jsonDecode(payload) as Map),
      );
    }

    // One-time compatibility read for V0.3 local progress.
    final legacyScores = <String, int>{};
    for (final item
        in await _preferences.getStringList('bestScores') ?? const <String>[]) {
      final separator = item.lastIndexOf(':');
      if (separator > 0) {
        legacyScores[item.substring(0, separator)] =
            int.tryParse(item.substring(separator + 1)) ?? 0;
      }
    }
    final progress = QuestProgress(
      xp: await _preferences.getInt('xp') ?? 0,
      streak: await _preferences.getInt('streak') ?? 1,
      completedLessons: await _preferences.getInt('completedLessons') ?? 0,
      dailyProgress: await _preferences.getInt('dailyProgress') ?? 0,
      trackIndex: await _preferences.getInt('track') ?? 0,
      completedGames: Set<String>.unmodifiable(
        await _preferences.getStringList('completedGames') ??
                const <String>[],
      ),
      bestScores: Map<String, int>.unmodifiable(legacyScores),
    );
    await saveProgress(progress);
    return progress;
  }

  @override
  Future<void> saveProgress(QuestProgress progress) =>
      _preferences.setString(_progressKey, jsonEncode(progress.toJson()));

  @override
  Future<LearningState> loadLearningState() async {
    final payload = await _preferences.getString(_learningKey);
    if (payload == null) return LearningState.fresh();
    return LearningState.fromJson(
      Map<String, Object?>.from(jsonDecode(payload) as Map),
    );
  }

  @override
  Future<void> saveLearningState(LearningState state) =>
      _preferences.setString(_learningKey, jsonEncode(state.toJson()));

  @override
  Future<JourneyState> loadJourneyState() async {
    final payload = await _preferences.getString(_journeyKey);
    if (payload == null) return JourneyState.fresh();
    return JourneyState.fromJson(
      Map<String, Object?>.from(jsonDecode(payload) as Map),
    );
  }

  @override
  Future<void> saveJourneyState(JourneyState state) =>
      _preferences.setString(_journeyKey, jsonEncode(state.toJson()));

  @override
  Future<bool> commitReward({
    required String transactionId,
    required String gameId,
    required QuestProgress progress,
  }) async {
    final transactions =
        await _preferences.getStringList(_rewardsKey) ?? const <String>[];
    if (transactions.contains(transactionId)) return false;
    await saveProgress(progress);
    await _preferences.setStringList(
      _rewardsKey,
      <String>[...transactions, transactionId],
    );
    return true;
  }

  String _sessionKey(String gameId) => 'phase1.session.$gameId';

  @override
  Future<void> saveSession(GameSessionSnapshot snapshot) => _preferences.setString(
        _sessionKey(snapshot.gameId),
        jsonEncode(snapshot.toJson()),
      );

  @override
  Future<GameSessionSnapshot?> loadSession(String gameId) async {
    final payload = await _preferences.getString(_sessionKey(gameId));
    if (payload == null) return null;
    return GameSessionSnapshot.fromJson(
      Map<String, Object?>.from(jsonDecode(payload) as Map),
    );
  }

  @override
  Future<void> clearSession(String sessionId) async {
    // Preference fallback keeps at most one snapshot per known game. Remove the
    // matching value without clearing unrelated application preferences.
    for (final gameId in const <String>[
      'picture_match',
      'spelling',
      'word_search',
      'word_chain',
      'tawng_upa',
      'crossword',
      'listen_pick', // retired game: clears sessions saved before its removal
      'thumal_kawp',
      'sentence_builder',
    ]) {
      final snapshot = await loadSession(gameId);
      if (snapshot?.sessionId == sessionId) {
        await _preferences.remove(_sessionKey(gameId));
      }
    }
  }

  @override
  Future<void> resetAll() async {
    final keys = <String>{
      _profileKey,
      _progressKey,
      _rewardsKey,
      _learningKey,
      _journeyKey,
      'xp',
      'streak',
      'completedLessons',
      'dailyProgress',
      'track',
      'completedGames',
      'bestScores',
      ...const <String>[
        'picture_match',
        'spelling',
        'word_search',
        'word_chain',
        'tawng_upa',
        'crossword',
        'listen_pick', // retired game: clears sessions saved before its removal
        'thumal_kawp',
        'sentence_builder',
      ].map(_sessionKey),
    };
    await _preferences.clear(allowList: keys);
  }

  @override
  Future<void> close() async {}
}
