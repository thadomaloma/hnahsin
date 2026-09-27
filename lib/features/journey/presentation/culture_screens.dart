import 'package:flutter/material.dart';

import '../../../src/controller.dart';
import '../../../src/theme.dart';
import '../../../src/widgets.dart';
import '../../onboarding/domain/learner_profile.dart';
import '../domain/journey_content.dart';
import '../domain/journey_models.dart';

class CultureTrailScreen extends StatelessWidget {
  const CultureTrailScreen({super.key, required this.controller});

  final QuestController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final playable = cultureCards
              .where((card) => CultureTrailPolicy.playable(card.review))
              .toList(growable: false);
          final collected = playable
              .where(
                (card) => controller.journeyState.collectedCultureCardIds
                    .contains(card.id),
              )
              .length;
          return QuestPage(
            title: 'Culture Trail',
            subtitle: '$collected/${playable.length} cards collected',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PremiumCard(
                  gradient: const LinearGradient(
                    colors: <Color>[QuestColors.midnight, QuestColors.indigo],
                  ),
                  child: Row(
                    children: <Widget>[
                      const Text('🏵️', style: TextStyle(fontSize: 42)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'MIZO CULTURE TRAIL',
                              style: TextStyle(
                                color: QuestColors.teal,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Thumal, hnam nun leh a hman dân zir rawh.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '${controller.journeyState.trailMarks} Trail Marks • Lessons stay open',
                              style: const TextStyle(color: Color(0xFFC4D0EA)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (!CultureTrailPolicy.releaseReady) ...<Widget>[
                  const _CultureReviewNotice(),
                  const SizedBox(height: 18),
                ],
                ...seasonalTrails
                    .where(
                      (trail) => CultureTrailPolicy.playable(trail.review),
                    )
                    .map((trail) => _SeasonalArchiveCard(trail: trail)),
                const SizedBox(height: 22),
                const SectionTitle('Culture Cards'),
                const SizedBox(height: 12),
                ...playable.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CultureCardTile(
                      controller: controller,
                      card: card,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class _CultureReviewNotice extends StatelessWidget {
  const _CultureReviewNotice();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5D8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.rate_review_rounded, color: Color(0xFF9A6800)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Preview content — language leh culture reviewer pawmna a la nghah mêk.',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
}

class _SeasonalArchiveCard extends StatelessWidget {
  const _SeasonalArchiveCard({required this.trail});

  final SeasonalTrail trail;

  @override
  Widget build(BuildContext context) => PremiumCard(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF1BE), QuestColors.cream],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.celebration_rounded, color: Color(0xFF9A6800)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          trail.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (trail.archiveAvailable)
                        const Chip(label: Text('NO DEADLINE')),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    trail.descriptionMizo,
                    style: const TextStyle(color: QuestColors.slate),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _CultureCardTile extends StatelessWidget {
  const _CultureCardTile({required this.controller, required this.card});

  final QuestController controller;
  final CultureCard card;

  @override
  Widget build(BuildContext context) {
    final unlocked = controller.cultureCardUnlocked(card);
    final collected =
        controller.journeyState.collectedCultureCardIds.contains(card.id);
    return PremiumCard(
      onTap: unlocked
          ? () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CultureCardScreen(
                    controller: controller,
                    card: card,
                  ),
                ),
              )
          : null,
      child: Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked ? const Color(0xFFE3F8F5) : QuestColors.mist,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Text(
              unlocked ? card.emoji : '🔒',
              style: const TextStyle(fontSize: 25),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  unlocked ? card.titleMizo : 'Unlock at TQ${card.minimumLevel}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  unlocked ? card.shortMeaningMizo : 'Zirna level chhunzawm rawh.',
                  style: const TextStyle(
                    color: QuestColors.slate,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            collected
                ? Icons.bookmark_added_rounded
                : unlocked
                    ? Icons.arrow_forward_rounded
                    : Icons.lock_rounded,
            color: collected ? QuestColors.success : QuestColors.indigo,
          ),
        ],
      ),
    );
  }
}

class CultureCardScreen extends StatefulWidget {
  const CultureCardScreen({
    super.key,
    required this.controller,
    required this.card,
  });

  final QuestController controller;
  final CultureCard card;

  @override
  State<CultureCardScreen> createState() => _CultureCardScreenState();
}

class _CultureCardScreenState extends State<CultureCardScreen> {
  bool recordedThisVisit = false;

  bool get showEnglish => widget.controller.profile.supportLanguage ==
      SupportLanguage.english;

  Future<void> _record() async {
    if (recordedThisVisit) return;
    final saved = await widget.controller.collectCultureCard(widget.card.id);
    if (!mounted || !saved) return;
    setState(() => recordedThisVisit = true);
  }

  @override
  Widget build(BuildContext context) {
    final collected = widget.controller.journeyState.collectedCultureCardIds
        .contains(widget.card.id);
    return QuestPage(
      title: 'Culture Card',
      subtitle: widget.card.titleEnglish,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F8F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                widget.card.emoji,
                style: const TextStyle(fontSize: 46),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.card.titleMizo,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 5),
          Text(
            widget.card.shortMeaningMizo,
            style: const TextStyle(
              color: QuestColors.tealDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'A hman dân leh a nihna',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(widget.card.contextMizo),
                if (showEnglish) ...<Widget>[
                  const Divider(height: 28),
                  Text(
                    widget.card.englishSupport,
                    style: const TextStyle(color: QuestColors.slate),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          PremiumCard(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFFFF1BE), QuestColors.cream],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Example',
                  style: TextStyle(
                    color: Color(0xFF9A6800),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '“${widget.card.exampleMizo}”',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: recordedThisVisit ? null : _record,
              icon: Icon(
                recordedThisVisit
                    ? Icons.check_circle_rounded
                    : Icons.bookmark_add_rounded,
              ),
              label: Text(
                recordedThisVisit
                    ? 'Read Today'
                    : collected
                        ? 'Read Again'
                        : 'Add to Collection',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton.icon(
              onPressed: () => widget.controller.reportContent(
                widget.card.id,
                reason: 'culture wording or context',
              ),
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Report a Content Issue'),
            ),
          ),
        ],
      ),
    );
  }
}

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.controller});

  final QuestController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final collectedCards = cultureCards
              .where(
                (card) => controller.journeyState.collectedCultureCardIds
                    .contains(card.id),
              )
              .toList(growable: false);
          final storyRewards = journeyRewards
              .where(
                (reward) => controller.journeyState.unlockedRewardIds.contains(
                  reward.id,
                ),
              )
              .toList(growable: false);
          return QuestPage(
            title: 'My Collection',
            subtitle:
                '${collectedCards.length}/${cultureCards.length} culture cards',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PremiumCard(
                  gradient: const LinearGradient(
                    colors: <Color>[QuestColors.midnight, QuestColors.indigo],
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        controller.selectedAvatar.emoji,
                        style: const TextStyle(fontSize: 46),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              controller.selectedAvatar.labelFor(
                                isChild: controller.profile.isChild,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${controller.journeyState.trailMarks} Trail Marks',
                              style: const TextStyle(color: QuestColors.teal),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Recognition only • No lesson is locked',
                              style: TextStyle(
                                color: Color(0xFFC4D0EA),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Choose My Style'),
                const SizedBox(height: 12),
                ...avatarStyles.map(
                  (avatar) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AvatarOption(
                      controller: controller,
                      avatar: avatar,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const SectionTitle('Milestones'),
                const SizedBox(height: 12),
                PremiumCard(
                  child: Column(
                    children: collectionMilestones
                        .map(
                          (milestone) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  collectedCards.length >=
                                          milestone.requiredCards
                                      ? milestone.emoji
                                      : '🔒',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    milestone.labelFor(
                                      isChild: controller.profile.isChild,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${collectedCards.length.clamp(0, milestone.requiredCards)}/${milestone.requiredCards}',
                                  style: const TextStyle(
                                    color: QuestColors.tealDark,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Culture Cards'),
                const SizedBox(height: 12),
                PremiumCard(
                  child: collectedCards.isEmpty
                      ? const Text(
                          'Culture Trail-ah card pakhat chhiar hmasa rawh.',
                          style: TextStyle(color: QuestColors.slate),
                        )
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: collectedCards
                              .map(
                                (card) => Chip(
                                  avatar: Text(card.emoji),
                                  label: Text(card.titleMizo),
                                ),
                              )
                              .toList(growable: false),
                        ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Story Rewards'),
                const SizedBox(height: 12),
                PremiumCard(
                  child: storyRewards.isEmpty
                      ? const Text(
                          'Story Quest zawh hmasak berah reward i hmu ang.',
                          style: TextStyle(color: QuestColors.slate),
                        )
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: storyRewards
                              .map(
                                (reward) => Chip(
                                  avatar: Text(reward.emoji),
                                  label: Text(
                                    reward.labelFor(
                                      isChild: controller.profile.isChild,
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                ),
              ],
            ),
          );
        },
      );
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({required this.controller, required this.avatar});

  final QuestController controller;
  final AvatarStyle avatar;

  @override
  Widget build(BuildContext context) {
    final unlocked = controller.journeyState.trailMarks >= avatar.requiredMarks;
    final selected = controller.journeyState.selectedAvatarId == avatar.id;
    return AnswerButton(
      label:
          '${unlocked ? avatar.emoji : '🔒'}  ${avatar.labelFor(isChild: controller.profile.isChild)}${unlocked ? '' : ' • ${avatar.requiredMarks} marks'}',
      selected: selected,
      correct: selected ? true : null,
      onTap: unlocked ? () => controller.selectJourneyAvatar(avatar.id) : null,
    );
  }
}
