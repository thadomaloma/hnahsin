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
import 'app_text.dart';
import 'data.dart';
import 'game_session.dart';
import 'game_text.dart';

class QuestController extends ChangeNotifier {
  QuestController({
    QuestRepository? repository,
    ContentSyncService? contentSyncService,
    DateTime Function()? clock,
  })  : _repository = repository ?? InMemoryQuestRepository(),
        _contentSyncService = contentSyncService,
        _clock = clock ?? DateTime.now;

  /// Local time; tests pass a fixed one to step through days.
  final DateTime Function() _clock;

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

  /// Local day (YYYY-MM-DD) of the last finished round.
  String? playDay;
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
  /// Single words only: phrases such as “buh leh bal” have no one word to
  /// chain from.
  Set<String> get chainVocabulary => <String>{
        ...chainDictionary,
        ...wordCatalog
            .where((entry) => ContentPolicy.playable(entry.review))
            .where((entry) => entry.supportsGame('word_chain'))
            .map((entry) => normalizeMizo(entry.word))
            .where(_singleWord.hasMatch),
      };

  static final _singleWord = RegExp(r'^[a-zâêîôûṭ]+$');

  bool get _deliveredCatalogReady {
    final delivered =
        _contentSyncService?.activeWords ?? const <DeliveredWord>[];
    return delivered.length >= 20 &&
        delivered.where((word) => word.difficulty == 1).length >= 5;
  }

  int get level => (xp ~/ 250) + 1;
  double get levelProgress => (xp % 250) / 250;
  /// Rounds finished today; yesterday's count doesn't carry over.
  int get roundsToday => playDay == _dayKey(_clock()) ? dailyProgress : 0;

  /// Days in a row with at least one round, still alive while today's or
  /// yesterday's round counts; 0 once a day has been missed.
  int get currentStreak {
    final today = _clock();
    final alive = playDay == _dayKey(today) ||
        playDay == _dayKey(today.subtract(const Duration(days: 1)));
    return alive ? streak : 0;
  }

  /// Rounds played today against the daily goal (one round for each goal
  /// “minute”, as rounds take about a minute).
  double get dailyGoalProgress =>
      (roundsToday / profile.dailyGoalMinutes).clamp(0, 1).toDouble();

  /// Which day it is since 1970 in local time, so “today's game” changes at
  /// local midnight.
  int get dayNumber {
    final now = _clock();
    return DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  }

  /// Words whose next look is due: missed in a game or ready for a refresh.
  int get wordsToReplay {
    final now = _clock().toUtc();
    return learningState.masteries.values
        .where((item) => item.stage != MasteryStage.unseen && item.isDue(now))
        .length;
  }

  static String _dayKey(DateTime local) =>
      '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';

  DailyLessonPlan get dailyPlan {
    final playable = wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .toList();
    // A word's difficulty (1–7, from its tq_level) is the level it belongs
    // to: difficulty 1 is Level 1, difficulty 3 is Level 3.
    return _lessonPlanner.build(
      state: learningState,
      allItemIds: playable.map((entry) => entry.id).toList(),
      itemLevels: <String, int>{
        for (final entry in playable)
          entry.id: (entry.difficulty - 1).clamp(0, LearningLevel.values.length - 1),
      },
      now: _clock().toUtc(),
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

  /// Reviewed Tawng Upa questions written in the content Sheet.
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
            contentId: question.id,
          ),
      ];

  /// Reviewed Sentence Builder sentences written in the content Sheet.
  List<DeliveredSentence> get deliveredSentences =>
      _contentSyncService?.activeSentences ?? const <DeliveredSentence>[];

  void _publishDeliveredContent() {
    final service = _contentSyncService;
    if (service == null) return;
    GameText.update(service.activeGameCopy);
    AppText.update(service.activeAppText);
    WordImages.update(service.activeImages);
  }

  /// How long a sync stays fresh. The app checks again this often while it
  /// is open, so content published from the Sheet reaches the next game
  /// round within about a minute of going live.
  static const contentRecheckAfter = Duration(minutes: 1);

  /// Checks for newly published content unless it checked within
  /// [contentRecheckAfter]. An unchanged pack costs one small 304 response.
  Future<void> refreshContentIfStale({DateTime? now}) async {
    final last = _contentSyncService?.state.lastAttemptAt;
    final current = (now ?? DateTime.now()).toUtc();
    // A little slack, so the once-a-minute timer isn't skipped for firing
    // a few milliseconds before a full minute has passed.
    const slack = Duration(seconds: 5);
    if (last != null && current.difference(last) < contentRecheckAfter - slack) return;
    await refreshContent();
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
    playDay = progress.playDay;
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
        playDay: playDay,
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
        MizoProficiency.newLearner => LearningLevel.level1,
        MizoProficiency.understandsSome => LearningLevel.level2,
        MizoProficiency.speaks => LearningLevel.level3,
        MizoProficiency.readsAndWrites => LearningLevel.level4,
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
      LearningLevel.level1 || LearningLevel.level2 => LearningTrack.beginner,
      LearningLevel.level3 ||
      LearningLevel.level4 ||
      LearningLevel.level5 =>
        LearningTrack.explorer,
      LearningLevel.level6 ||
      LearningLevel.level7 ||
      LearningLevel.level8 =>
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
    final now = _clock();
    final reviewed = _scheduler.review(
      itemId: itemId,
      rating: rating,
      now: now.toUtc(),
      current: learningState.masteries[itemId],
    );
    learningState = _withOutcomes(
      learningState.copyWith(
        masteries: <String, ItemMastery>{
          ...learningState.masteries,
          itemId: reviewed,
        },
      ),
      <bool>[rating != ReviewRating.again],
    );
    journeyState = _journeyEngine.recordAction(
      state: journeyState,
      action: JourneyAction.review,
      now: now,
    );
    notifyListeners();
    await Future.wait(<Future<void>>[
      _repository.saveLearningState(learningState),
      _repository.saveJourneyState(journeyState),
    ]);
  }

  /// Remembers how a game round went for each word it asked about, so
  /// later rounds bring missed words back and show mastered ones less (see
  /// pickWordsForLevel). Only the words' memory changes; the learner's level
  /// and journey still come from lessons.
  Future<void> recordWordsPlayed(List<WordPlay> words) async {
    if (words.isEmpty) return;
    final now = DateTime.now().toUtc();
    final masteries = <String, ItemMastery>{...learningState.masteries};
    for (final play in words) {
      masteries[play.id] = _scheduler.review(
        itemId: play.id,
        rating: play.missed
            ? ReviewRating.again
            : play.hinted
                ? ReviewRating.hard
                : ReviewRating.good,
        now: now,
        current: masteries[play.id],
      );
    }
    learningState = learningState.copyWith(masteries: masteries);
    notifyListeners();
    await _repository.saveLearningState(learningState);
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
    for (final itemId in itemIds) {
      masteries[itemId] = _scheduler.review(
        itemId: itemId,
        rating: ReviewRating.good,
        now: now,
        current: masteries[itemId],
      );
    }
    return _withOutcomes(
      learningState.copyWith(masteries: masteries),
      List<bool>.filled(itemIds.length, true),
    );
  }

  /// Adds [outcomes] to the last eight answers and moves the level if they
  /// call for it. A move starts the window afresh, so the level changes once
  /// for a run of answers rather than once for every answer after the fifth.
  LearningState _withOutcomes(LearningState state, List<bool> outcomes) {
    final all = <bool>[...state.recentOutcomes, ...outcomes];
    final trimmed = all.length > 8 ? all.sublist(all.length - 8) : all;
    final level = _adaptiveDifficulty.recommend(
      current: state.level,
      recentOutcomes: trimmed,
    );
    return state.copyWith(
      level: level,
      recentOutcomes: level == state.level ? trimmed : const <bool>[],
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
    final now = _clock();
    final today = _dayKey(now);
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
    final next = _progress.copyWith(
      xp: xp + xpAwarded,
      dailyProgress:
          (roundsToday + 1).clamp(0, profile.dailyGoalMinutes).toInt(),
      streak: playDay == today
          ? streak
          : playDay == yesterday
              ? streak + 1
              : 1,
      playDay: today,
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
