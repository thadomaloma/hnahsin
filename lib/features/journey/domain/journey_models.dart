enum JourneyReviewState { draft, reviewRequired, approved }

enum JourneyAction { story, review, culture }

enum QuestCadence { daily, weekly }

enum CultureTopic {
  communityValues,
  community,
  heritage,
  celebration,
  language,
}

extension JourneyActionKey on JourneyAction {
  String get key => name;
}

class StoryChoice {
  const StoryChoice({
    required this.id,
    required this.mizo,
    required this.english,
    required this.replyMizo,
    required this.isNatural,
  });

  final String id;
  final String mizo;
  final String english;
  final String replyMizo;
  final bool isNatural;
}

class StoryBeat {
  const StoryBeat({
    required this.id,
    required this.speaker,
    required this.mizo,
    required this.english,
    required this.choices,
  });

  final String id;
  final String speaker;
  final String mizo;
  final String english;
  final List<StoryChoice> choices;
}

class StoryEpisode {
  const StoryEpisode({
    required this.id,
    required this.nodeId,
    required this.titleMizo,
    required this.titleEnglish,
    required this.introductionMizo,
    required this.introductionEnglish,
    required this.targetWordIds,
    required this.beats,
    required this.cultureNoteMizo,
    required this.cultureNoteEnglish,
    required this.review,
  });

  final String id;
  final String nodeId;
  final String titleMizo;
  final String titleEnglish;
  final String introductionMizo;
  final String introductionEnglish;
  final List<String> targetWordIds;
  final List<StoryBeat> beats;
  final String cultureNoteMizo;
  final String cultureNoteEnglish;
  final JourneyReviewState review;

  int get naturalChoiceCount => beats
      .expand((beat) => beat.choices)
      .where((choice) => choice.isNatural)
      .length;
}

class JourneyNode {
  const JourneyNode({
    required this.id,
    required this.regionId,
    required this.order,
    required this.titleMizo,
    required this.titleEnglish,
    required this.subtitleMizo,
    required this.storyId,
    required this.prerequisiteNodeIds,
    required this.minimumLevel,
    required this.rewardId,
    required this.review,
  });

  final String id;
  final String regionId;
  final int order;
  final String titleMizo;
  final String titleEnglish;
  final String subtitleMizo;
  final String storyId;
  final List<String> prerequisiteNodeIds;
  final int minimumLevel;
  final String rewardId;
  final JourneyReviewState review;
}

class JourneyRegion {
  const JourneyRegion({
    required this.id,
    required this.titleMizo,
    required this.titleEnglish,
    required this.subtitleMizo,
    required this.emoji,
    required this.nodeIds,
  });

  final String id;
  final String titleMizo;
  final String titleEnglish;
  final String subtitleMizo;
  final String emoji;
  final List<String> nodeIds;
}

class JourneyReward {
  const JourneyReward({
    required this.id,
    required this.emoji,
    required this.childLabel,
    required this.adultLabel,
  });

  final String id;
  final String emoji;
  final String childLabel;
  final String adultLabel;

  String labelFor({required bool isChild}) =>
      isChild ? childLabel : adultLabel;
}

class EngagementQuest {
  const EngagementQuest({
    required this.id,
    required this.title,
    required this.instructionMizo,
    required this.action,
    required this.target,
    required this.cadence,
    required this.rewardMarks,
  });

  final String id;
  final String title;
  final String instructionMizo;
  final JourneyAction action;
  final int target;
  final QuestCadence cadence;
  final int rewardMarks;
}

class QuestProgressView {
  const QuestProgressView({
    required this.quest,
    required this.progress,
    required this.claimKey,
    required this.claimed,
  });

  final EngagementQuest quest;
  final int progress;
  final String claimKey;
  final bool claimed;

  bool get completed => progress >= quest.target;
  double get fraction =>
      quest.target == 0
          ? 0.0
          : (progress / quest.target).clamp(0, 1).toDouble();
}

class CultureCard {
  const CultureCard({
    required this.id,
    required this.titleMizo,
    required this.titleEnglish,
    required this.shortMeaningMizo,
    required this.contextMizo,
    required this.englishSupport,
    required this.exampleMizo,
    required this.topic,
    required this.emoji,
    required this.minimumLevel,
    required this.review,
  });

  final String id;
  final String titleMizo;
  final String titleEnglish;
  final String shortMeaningMizo;
  final String contextMizo;
  final String englishSupport;
  final String exampleMizo;
  final CultureTopic topic;
  final String emoji;
  final int minimumLevel;
  final JourneyReviewState review;
}

class CollectionMilestone {
  const CollectionMilestone({
    required this.id,
    required this.requiredCards,
    required this.emoji,
    required this.childLabel,
    required this.adultLabel,
  });

  final String id;
  final int requiredCards;
  final String emoji;
  final String childLabel;
  final String adultLabel;

  String labelFor({required bool isChild}) =>
      isChild ? childLabel : adultLabel;
}

class AvatarStyle {
  const AvatarStyle({
    required this.id,
    required this.emoji,
    required this.requiredMarks,
    required this.childLabel,
    required this.adultLabel,
  });

  final String id;
  final String emoji;
  final int requiredMarks;
  final String childLabel;
  final String adultLabel;

  String labelFor({required bool isChild}) =>
      isChild ? childLabel : adultLabel;
}

class SeasonalTrail {
  const SeasonalTrail({
    required this.id,
    required this.title,
    required this.descriptionMizo,
    required this.cardIds,
    required this.archiveAvailable,
    required this.review,
  });

  final String id;
  final String title;
  final String descriptionMizo;
  final List<String> cardIds;
  final bool archiveAvailable;
  final JourneyReviewState review;
}
