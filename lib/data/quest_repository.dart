import '../features/games/engine/game_engine.dart';
import '../features/journey/domain/journey_state.dart';
import '../features/learning/domain/learning_state.dart';
import '../features/onboarding/domain/learner_profile.dart';
import '../features/progress/domain/quest_progress.dart';

abstract interface class QuestRepository {
  Future<LearnerProfile> loadProfile();

  Future<void> saveProfile(LearnerProfile profile);

  Future<QuestProgress> loadProgress();

  Future<void> saveProgress(QuestProgress progress);

  Future<LearningState> loadLearningState();

  Future<void> saveLearningState(LearningState state);

  Future<JourneyState> loadJourneyState();

  Future<void> saveJourneyState(JourneyState state);

  Future<bool> commitReward({
    required String transactionId,
    required String gameId,
    required QuestProgress progress,
  });

  Future<void> saveSession(GameSessionSnapshot snapshot);

  Future<GameSessionSnapshot?> loadSession(String gameId);

  Future<void> clearSession(String sessionId);

  Future<void> resetAll();

  Future<void> close();
}

class InMemoryQuestRepository implements QuestRepository {
  InMemoryQuestRepository({
    LearnerProfile? profile,
    QuestProgress? progress,
    LearningState? learningState,
    JourneyState? journeyState,
  })  : _profile = profile ?? LearnerProfile.fresh(),
        _progress = progress ?? QuestProgress.empty(),
        _learningState = learningState ?? LearningState.fresh(),
        _journeyState = journeyState ?? JourneyState.fresh();

  LearnerProfile _profile;
  QuestProgress _progress;
  LearningState _learningState;
  JourneyState _journeyState;
  final Set<String> _rewardTransactions = <String>{};
  final Map<String, GameSessionSnapshot> _sessions =
      <String, GameSessionSnapshot>{};

  @override
  Future<LearnerProfile> loadProfile() async => _profile;

  @override
  Future<void> saveProfile(LearnerProfile profile) async {
    _profile = profile;
  }

  @override
  Future<QuestProgress> loadProgress() async => _progress;

  @override
  Future<void> saveProgress(QuestProgress progress) async {
    _progress = progress;
  }

  @override
  Future<LearningState> loadLearningState() async => _learningState;

  @override
  Future<void> saveLearningState(LearningState state) async {
    _learningState = state;
  }

  @override
  Future<JourneyState> loadJourneyState() async => _journeyState;

  @override
  Future<void> saveJourneyState(JourneyState state) async {
    _journeyState = state;
  }

  @override
  Future<bool> commitReward({
    required String transactionId,
    required String gameId,
    required QuestProgress progress,
  }) async {
    if (!_rewardTransactions.add(transactionId)) return false;
    _progress = progress;
    return true;
  }

  @override
  Future<void> saveSession(GameSessionSnapshot snapshot) async {
    _sessions[snapshot.gameId] = snapshot;
  }

  @override
  Future<GameSessionSnapshot?> loadSession(String gameId) async =>
      _sessions[gameId];

  @override
  Future<void> clearSession(String sessionId) async {
    _sessions.removeWhere((_, snapshot) => snapshot.sessionId == sessionId);
  }

  @override
  Future<void> resetAll() async {
    _profile = LearnerProfile.fresh();
    _progress = QuestProgress.empty();
    _learningState = LearningState.fresh();
    _journeyState = JourneyState.fresh();
    _rewardTransactions.clear();
    _sessions.clear();
  }

  @override
  Future<void> close() async {}
}
