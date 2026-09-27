import 'package:flutter/foundation.dart';

import '../data/quest_repository.dart';
import '../features/games/engine/game_difficulty.dart';
import '../features/games/engine/game_engine.dart';
import '../features/content_sync/application/content_sync_service.dart';
import '../features/content_sync/domain/delivery_models.dart';
import '../features/journey/domain/journey_content.dart';
import '../features/journey/domain/journey_engine.dart';
import '../features/journey/domain/journey_models.dart';
import '../features/journey/domain/journey_state.dart';
import '../features/learning/domain/learning_engine.dart';
import '../features/learning/domain/learning_state.dart';
import '../features/onboarding/domain/learner_profile.dart';
import '../features/progress/domain/quest_progress.dart';
import 'data.dart';
import 'game_session.dart';
import 'game_text.dart';

class QuestController extends ChangeNotifier {
  QuestController({
    QuestRepository? repository,
    ContentSyncService? contentSyncService,
  })  : _repository = repository ?? InMemoryQuestRepository(),
        _contentSyncService = contentSyncService;

  final QuestRepository _repository;
  final ContentSyncService? _contentSyncService;
  static const _placementEngine = PlacementEngine();
  static const _scheduler = SpacedRepetitionScheduler();
  static const _adaptiveDifficulty = AdaptiveDifficulty();
  static const _lessonPlanner = DailyLessonPlanner();
  static const _journeyEngine = JourneyEngine();
  LearnerProfile profile = LearnerProfile.fresh();
  LearningState learningState = LearningState.fresh();
  JourneyState journeyState = JourneyState.fresh();
  LearningTrack track = LearningTrack.beginner;
  int xp = 0;
  int streak = 1;
  int completedLessons = 0;
  int dailyProgress = 0;
  final Set<String> completedGames = <String>{};
  final Map<String, int> bestScores = <String, int>{};
  final Map<String, int> gameSkills = <String, int>{};

  /// Adaptive difficulty rating (1–7) for [gameId]; games pick words and
  /// distractors around it. Unplayed games start from the placement level.
  double gameSkill(String gameId) {
    final stored = gameSkills[gameId];
    if (stored != null) return stored / 100;
    return GameDifficulty.initialRating(learningState.level.index);
  }

  /// Whole-number level shown to players for [gameId].
  int gameLevel(String gameId) => gameSkill(gameId).floor();

  ContentSyncState get contentSyncState =>
      _contentSyncService?.state ?? const ContentSyncState();

  bool get contentSyncEnabled => _contentSyncService != null;

  bool get releaseContentReady =>
      ContentPolicy.releaseReady ||
      (_contentSyncService?.state.contentVersion != null &&
          _deliveredCatalogReady);


  List<WordEntry> get wordCatalog {
    final delivered =
        _contentSyncService?.activeWords ?? const <DeliveredWord>[];
    if (!_deliveredCatalogReady) return wordEntries;
    return List<WordEntry>.unmodifiable(delivered.map((word) => WordEntry(
          id: word.id,
          word: word.word,
          meaningMizo: word.meaningMizo,
          englishGloss: word.englishGloss,
          exampleMizo: word.exampleMizo,
          emoji: word.emoji,
          category: WordCategory.values.byName(word.category),
          difficulty: word.difficulty,
          review: ContentReview.approved,
          gameModes: word.gameModes,
          imageChecksum: word.image?.checksum,
        )));
  }

  /// Union of the legacy hardcoded chain words and every playable word in
  /// the live/synced catalog, normalized for chaining. This lets Word
  /// Chain grow with the reviewed content pack instead of staying fixed at
  /// the original 44-word prototype list.
  Set<String> get chainVocabulary => <String>{
        ...chainDictionary,
        ...wordCatalog
            .where((entry) => ContentPolicy.playable(entry.review))
            .where((entry) => entry.supportsGame('word_chain'))
            .map((entry) => normalizeMizo(entry.word)),
      };

  bool get _deliveredCatalogReady {
    final delivered =
        _contentSyncService?.activeWords ?? const <DeliveredWord>[];
    return delivered.length >= 20 &&
        delivered.where((word) => word.difficulty == 1).length >= 5;
  }

  int get level => (xp ~/ 250) + 1;
  double get levelProgress => (xp % 250) / 250;
  double get dailyGoalProgress =>
      (dailyProgress / profile.dailyGoalMinutes).clamp(0, 1).toDouble();

  DailyLessonPlan get dailyPlan {
    final playable = wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .toList();
    final levels = <String, int>{};
    for (var index = 0; index < playable.length; index += 1) {
      final difficulty = playable[index].difficulty;
      levels[playable[index].id] = switch (difficulty) {
        <= 1 => index.isEven ? 0 : 1,
        2 => index.isEven ? 2 : 3,
        _ => 4,
      };
    }
    return _lessonPlanner.build(
      state: learningState,
      allItemIds: playable.map((entry) => entry.id).toList(),
      itemLevels: levels,
      now: DateTime.now().toUtc(),
    );
  }

  List<QuestProgressView> get dailyJourneyQuests =>
      _journeyEngine.dailyQuests(state: journeyState, now: DateTime.now());

  List<QuestProgressView> get weeklyJourneyQuests =>
      _journeyEngine.weeklyQuests(state: journeyState, now: DateTime.now());

  AvatarStyle get selectedAvatar =>
      avatarStyleById(journeyState.selectedAvatarId) ?? avatarStyles.first;

  int get weeklyStoryCount =>
      _journeyEngine.weeklyStoryCount(state: journeyState, now: DateTime.now());

  bool get showComeback => _journeyEngine.shouldShowComeback(
        state: journeyState,
        now: DateTime.now(),
      );

  JourneyNode? get nextJourneyNode {
    for (final node in journeyNodes) {
      if (!JourneyContentPolicy.playable(node.review)) continue;
      if (_journeyEngine.statusFor(
            node: node,
            state: journeyState,
            learningLevel: learningState.level.index,
          ) ==
          JourneyNodeStatus.available) {
        return node;
      }
    }
    return null;
  }

  JourneyNodeStatus journeyStatus(JourneyNode node) => _journeyEngine.statusFor(
        node: node,
        state: journeyState,
        learningLevel: learningState.level.index,
      );

  bool cultureCardUnlocked(CultureCard card) =>
      CultureTrailPolicy.playable(card.review) &&
      learningState.level.index >= card.minimumLevel;

  Future<void> load() async {
    profile = await _repository.loadProfile();
    _applyProgress(await _repository.loadProgress());
    learningState = await _repository.loadLearningState();
    journeyState = await _repository.loadJourneyState();
    await _contentSyncService?.initialize();
    _publishDeliveredContent();
    notifyListeners();
  }

  /// Reviewed Tawng Upa questions written in Editorial Studio.
  List<ChoiceQuestion> get deliveredQuestions => [
        for (final question in _contentSyncService?.activeQuestions ?? const <DeliveredQuestion>[])
          ChoiceQuestion(
            prompt: question.prompt,
            options: question.options,
            answer: question.answer,
            explanation: question.explanation,
            emoji: question.emoji,
            review: ContentReview.approved,
            difficulty: question.difficulty,
          ),
      ];

  /// Reviewed Sentence Builder sentences written in Editorial Studio.
  List<DeliveredSentence> get deliveredSentences =>
      _contentSyncService?.activeSentences ?? const <DeliveredSentence>[];

  void _publishDeliveredContent() {
    final service = _contentSyncService;
    if (service == null) return;
    GameText.update(service.activeGameCopy);
    WordImages.update(service.activeImages);
  }

  Future<void> refreshContent() async {
    final service = _contentSyncService;
    if (service == null || service.state.isChecking) return;
    final pending = service.synchronize();
    notifyListeners();
    await pending;
    _publishDeliveredContent();
    notifyListeners();
  }

  void _applyProgress(QuestProgress progress) {
    xp = progress.xp;
    streak = progress.streak;
    completedLessons = progress.completedLessons;
    dailyProgress = progress.dailyProgress;
    track = LearningTrack.values[
        progress.trackIndex.clamp(0, LearningTrack.values.length - 1).toInt()];
    completedGames
      ..clear()
      ..addAll(progress.completedGames);
    bestScores
      ..clear()
      ..addAll(progress.bestScores);
    gameSkills
      ..clear()
      ..addAll(progress.gameSkills);
  }

  QuestProgress get _progress => QuestProgress(
        xp: xp,
        streak: streak,
        completedLessons: completedLessons,
        dailyProgress: dailyProgress,
        trackIndex: track.index,
        completedGames: Set<String>.unmodifiable(completedGames),
        bestScores: Map<String, int>.unmodifiable(bestScores),
        gameSkills: Map<String, int>.unmodifiable(gameSkills),
      );

  Future<void> completeOnboarding(LearnerProfile value) async {
    profile = value.copyWith(onboardingCompleted: true);
    track = switch (profile.proficiency) {
      MizoProficiency.newLearner => LearningTrack.beginner,
      MizoProficiency.understandsSome => LearningTrack.explorer,
      MizoProficiency.speaks => LearningTrack.explorer,
      MizoProficiency.readsAndWrites => LearningTrack.master,
    };
    if (!learningState.placementCompleted) {
      final provisionalLevel = switch (profile.proficiency) {
        MizoProficiency.newLearner => LearningLevel.tq0,
        MizoProficiency.understandsSome => LearningLevel.tq1,
        MizoProficiency.speaks => LearningLevel.tq2,
        MizoProficiency.readsAndWrites => LearningLevel.tq3,
      };
      learningState = learningState.copyWith(level: provisionalLevel);
    }
    notifyListeners();
    await Future.wait(<Future<void>>[
      _repository.saveProfile(profile),
      _repository.saveProgress(_progress),
      _repository.saveLearningState(learningState),
    ]);
  }

  Future<LearningLevel> completePlacement({
    required int correct,
    required int total,
  }) async {
    final safeTotal = total < 0 ? 0 : total;
    final safeCorrect = correct.clamp(0, safeTotal).toInt();
    final placedLevel = _placementEngine.levelForScore(
      correct: safeCorrect,
      total: safeTotal,
    );
    learningState = learningState.copyWith(
      level: placedLevel,
      placementCompleted: true,
      placementCorrect: safeCorrect,
      placementTotal: safeTotal,
      recentOutcomes: const <bool>[],
    );
    track = switch (placedLevel) {
      LearningLevel.tq0 || LearningLevel.tq1 => LearningTrack.beginner,
      LearningLevel.tq2 ||
      LearningLevel.tq3 ||
      LearningLevel.tq4 =>
        LearningTrack.explorer,
      LearningLevel.tq5 ||
      LearningLevel.tq6 ||
      LearningLevel.tq7 =>
        LearningTrack.master,
    };
    notifyListeners();
    await Future.wait(<Future<void>>[
      _repository.saveLearningState(learningState),
      _repository.saveProgress(_progress),
    ]);
    return placedLevel;
  }

  Future<void> recordReview({
    required String itemId,
    required ReviewRating rating,
  }) async {
    final reviewed = _scheduler.review(
      itemId: itemId,
      rating: rating,
      now: DateTime.now().toUtc(),
      current: learningState.masteries[itemId],
    );
    final outcomes = <bool>[
      ...learningState.recentOutcomes,
      rating != ReviewRating.again,
    ];
    final trimmed =
        outcomes.length > 8 ? outcomes.sublist(outcomes.length - 8) : outcomes;
    final nextLevel = _adaptiveDifficulty.recommend(
      current: learningState.level,
      recentOutcomes: trimmed,
    );
    learningState = learningState.copyWith(
      level: nextLevel,
      masteries: <String, ItemMastery>{
        ...learningState.masteries,
        itemId: reviewed,
      },
      recentOutcomes: trimmed,
    );
    journeyState = _journeyEngine.recordAction(
      state: journeyState,
      action: JourneyAction.review,
      now: DateTime.now(),
    );
    notifyListeners();
    await Future.wait(<Future<void>>[
      _repository.saveLearningState(learningState),
      _repository.saveJourneyState(journeyState),
    ]);
  }

  Future<bool> completeJourneyStory({
    required String nodeId,
    required int choicesMade,
  }) async {
    final node = journeyNodeById(nodeId);
    if (node == null || !JourneyContentPolicy.playable(node.review)) {
      return false;
    }
    final story = journeyStoryById(node.storyId);
    if (story == null || !JourneyContentPolicy.playable(story.review)) {
      return false;
    }
    if (choicesMade < story.beats.length) return false;
    final before = journeyState;
    final alreadyCompleted = before.completedNodeIds.contains(node.id);
    final now = DateTime.now();
    final next = _journeyEngine.completeStory(
      state: before,
      node: node,
      story: story,
      now: now,
      learningLevel: learningState.level.index,
      choicesMade: choicesMade,
    );
    if (identical(next, before)) return false;
    journeyState = alreadyCompleted
        ? next
        : _journeyEngine.recordAction(
            state: next,
            action: JourneyAction.review,
            now: now,
            amount: story.targetWordIds.length,
          );
    if (!alreadyCompleted) {
      learningState = _reviewStoryTargets(story.targetWordIds, now.toUtc());
    }
    notifyListeners();
    await Future.wait(<Future<void>>[
      _repository.saveJourneyState(journeyState),
      if (!alreadyCompleted) _repository.saveLearningState(learningState),
    ]);
    return true;
  }

  LearningState _reviewStoryTargets(List<String> itemIds, DateTime now) {
    final masteries = <String, ItemMastery>{...learningState.masteries};
    final outcomes = <bool>[...learningState.recentOutcomes];
    for (final itemId in itemIds) {
      masteries[itemId] = _scheduler.review(
        itemId: itemId,
        rating: ReviewRating.good,
        now: now,
        current: masteries[itemId],
      );
      outcomes.add(true);
    }
    final trimmed =
        outcomes.length > 8 ? outcomes.sublist(outcomes.length - 8) : outcomes;
    return learningState.copyWith(
      level: _adaptiveDifficulty.recommend(
        current: learningState.level,
        recentOutcomes: trimmed,
      ),
      masteries: masteries,
      recentOutcomes: trimmed,
    );
  }

  Future<void> markCultureNoteRead() async {
    journeyState = _journeyEngine.recordAction(
      state: journeyState,
      action: JourneyAction.culture,
      now: DateTime.now(),
    );
    notifyListeners();
    await _repository.saveJourneyState(journeyState);
  }

  Future<bool> collectCultureCard(String cardId) async {
    final card = cultureCardById(cardId);
    if (card == null || !cultureCardUnlocked(card)) return false;
    journeyState = _journeyEngine.collectCultureCard(
      state: journeyState,
      card: card,
      now: DateTime.now(),
    );
    notifyListeners();
    await _repository.saveJourneyState(journeyState);
    return true;
  }

  Future<bool> claimJourneyQuest(String claimKey) async {
    final quests = <QuestProgressView>[
      ...dailyJourneyQuests,
      ...weeklyJourneyQuests,
    ];
    final matches = quests.where((item) => item.claimKey == claimKey);
    if (matches.isEmpty) return false;
    final before = journeyState;
    final next = _journeyEngine.claimQuest(
      state: before,
      progress: matches.first,
    );
    if (identical(next, before)) return false;
    journeyState = next;
    notifyListeners();
    await _repository.saveJourneyState(journeyState);
    return true;
  }

  Future<bool> selectJourneyAvatar(String avatarId) async {
    final avatar = avatarStyleById(avatarId);
    if (avatar == null) return false;
    final before = journeyState;
    final next = _journeyEngine.selectAvatar(
      state: before,
      avatar: avatar,
    );
    if (identical(next, before)) return false;
    journeyState = next;
    notifyListeners();
    await _repository.saveJourneyState(journeyState);
    return true;
  }

  Future<void> acknowledgeHealthyStop() async {
    journeyState = _journeyEngine.acknowledgeHealthyStop(journeyState);
    notifyListeners();
    await _repository.saveJourneyState(journeyState);
  }

  Future<void> reportContent(
    String contentId, {
    String reason = 'other',
  }) async {
    if (learningState.reportedContentIds.contains(contentId)) return;
    learningState = learningState.copyWith(
      contentReports: <String, String>{
        ...learningState.contentReports,
        contentId: reason,
      },
    );
    notifyListeners();
    await _repository.saveLearningState(learningState);
  }

  Future<void> selectTrack(LearningTrack value) async {
    track = value;
    notifyListeners();
    await _repository.saveProgress(_progress);
  }

  Future<RewardOutcome> reward(String gameId, GameResult result) async {
    final updatedScores = <String, int>{...bestScores};
    if (result.score > (updatedScores[gameId] ?? 0)) {
      updatedScores[gameId] = result.score;
    }
    final previousSkill = gameSkill(gameId);
    final nextSkill = GameDifficulty.nextRating(
      previousSkill,
      correct: result.correctAnswers,
      attempts: result.attempts,
      failed: result.endReason == GameEndReason.heartsExhausted,
    );
    // Harder play earns more: +10% XP per level above the first.
    final xpAwarded = (result.xp * (1 + (previousSkill - 1) * .1)).round();
    final outcome = RewardOutcome(
      xp: xpAwarded,
      previousLevel: previousSkill.floor(),
      level: nextSkill.floor(),
      skill: nextSkill,
    );
    final next = _progress.copyWith(
      xp: xp + xpAwarded,
      dailyProgress:
          (dailyProgress + 1).clamp(0, profile.dailyGoalMinutes).toInt(),
      completedGames: <String>{...completedGames, gameId},
      bestScores: updatedScores,
      gameSkills: <String, int>{...gameSkills, gameId: (nextSkill * 100).round()},
    );
    final committed = await _repository.commitReward(
      transactionId: result.rewardTransactionId,
      gameId: gameId,
      progress: next,
    );
    if (!committed) return outcome;
    _applyProgress(next);
    notifyListeners();
    return outcome;
  }

  Future<void> completeLesson() async {
    completedLessons += 1;
    notifyListeners();
    await _repository.saveProgress(_progress);
  }

  Future<void> updateProfile(LearnerProfile value) async {
    profile = value;
    notifyListeners();
    await _repository.saveProfile(profile);
  }

  Future<void> saveSession(GameSessionSnapshot snapshot) =>
      _repository.saveSession(snapshot);

  Future<GameSessionSnapshot?> loadSession(String gameId) =>
      _repository.loadSession(gameId);

  Future<void> clearSession(String sessionId) =>
      _repository.clearSession(sessionId);

  Future<void> resetAll() async {
    await _repository.resetAll();
    profile = LearnerProfile.fresh();
    _applyProgress(QuestProgress.empty());
    learningState = LearningState.fresh();
    journeyState = JourneyState.fresh();
    notifyListeners();
  }

  @override
  void dispose() {
    _contentSyncService?.close();
    _repository.close();
    super.dispose();
  }
}

/// What a finished round changed: XP actually awarded (after the level
/// bonus) and the game level before and after the adaptive update.
class RewardOutcome {
  const RewardOutcome({
    required this.xp,
    required this.previousLevel,
    required this.level,
    required this.skill,
  });

  final int xp;
  final int previousLevel;
  final int level;
  final double skill;

  bool get levelledUp => level > previousLevel;
  bool get levelledDown => level < previousLevel;
}
