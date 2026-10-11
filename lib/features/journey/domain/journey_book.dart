import '../../content_sync/domain/delivery_models.dart';
import '../../../src/app_text.dart';
import 'journey_content.dart';
import 'journey_models.dart';

/// The journey being played: the content Sheet's chapters once published,
/// otherwise the app's three built-in stories.
class JourneyBook {
  const JourneyBook({
    required this.regions,
    required this.nodes,
    required this.stories,
    required this.rewards,
  });

  static const builtIn = JourneyBook(
    regions: journeyRegions,
    nodes: journeyNodes,
    stories: journeyStories,
    rewards: journeyRewards,
  );

  /// One path of [chapters], each opening once the one before is done and
  /// enough word cards are collected.
  factory JourneyBook.fromChapters(List<DeliveredStoryChapter> chapters) {
    if (chapters.isEmpty) return builtIn;
    final nodes = <JourneyNode>[];
    final stories = <StoryEpisode>[];
    final rewards = <JourneyReward>[];
    for (final (index, chapter) in chapters.indexed) {
      final emoji = chapter.emoji.isEmpty ? '⭐' : chapter.emoji;
      nodes.add(JourneyNode(
        id: chapter.id,
        regionId: storyRegionId,
        order: index + 1,
        titleMizo: chapter.titleMizo,
        titleEnglish: chapter.titleEnglish,
        subtitleMizo: '',
        subtitleEnglish: '',
        storyId: chapter.id,
        prerequisiteNodeIds: [if (index > 0) chapters[index - 1].id],
        minimumLevel: 0,
        rewardId: 'reward.${chapter.id}',
        review: JourneyReviewState.approved,
        cardsNeeded: chapter.cardsNeeded,
        emoji: emoji,
      ));
      stories.add(StoryEpisode(
        id: chapter.id,
        nodeId: chapter.id,
        titleMizo: chapter.titleMizo,
        titleEnglish: chapter.titleEnglish,
        introductionMizo: chapter.introMizo,
        introductionEnglish: chapter.introEnglish,
        targetWordIds: chapter.wordIds,
        beats: [
          for (final (line, said) in chapter.lines.indexed)
            StoryBeat(
              id: '${chapter.id}.$line',
              speaker: said.speaker,
              mizo: said.mizo,
              english: said.english,
              choices: [
                for (final (n, reply) in said.replies.indexed)
                  StoryChoice(
                    id: '${chapter.id}.$line.$n',
                    mizo: reply.mizo,
                    english: reply.english,
                    replyMizo: reply.answerMizo,
                    isNatural: reply.right,
                  ),
              ],
            ),
        ],
        cultureNoteMizo: chapter.cultureNoteMizo,
        cultureNoteEnglish: chapter.cultureNoteEnglish,
        review: JourneyReviewState.approved,
      ));
      final label = chapter.titleEnglish.isEmpty
          ? chapter.titleMizo
          : chapter.titleEnglish;
      rewards.add(JourneyReward(
        id: 'reward.${chapter.id}',
        emoji: emoji,
        childLabel: label,
        adultLabel: label,
      ));
    }
    return JourneyBook(
      regions: [
        JourneyRegion(
          id: storyRegionId,
          titleMizo: '',
          titleEnglish: AppText.of('journey.chapters'),
          subtitleMizo: '',
          subtitleEnglish: '',
          emoji: '📖',
          nodeIds: [for (final node in nodes) node.id],
        ),
      ],
      nodes: List<JourneyNode>.unmodifiable(nodes),
      stories: List<StoryEpisode>.unmodifiable(stories),
      rewards: List<JourneyReward>.unmodifiable(rewards),
    );
  }

  static const storyRegionId = 'region.story';

  final List<JourneyRegion> regions;
  final List<JourneyNode> nodes;
  final List<StoryEpisode> stories;
  final List<JourneyReward> rewards;

  JourneyNode? nodeById(String id) =>
      nodes.where((node) => node.id == id).firstOrNull;
  StoryEpisode? storyById(String id) =>
      stories.where((story) => story.id == id).firstOrNull;
  JourneyReward? rewardById(String id) =>
      rewards.where((reward) => reward.id == id).firstOrNull;
}
