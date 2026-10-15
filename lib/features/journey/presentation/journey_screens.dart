import 'dart:math';

import 'package:flutter/material.dart';

import '../../../src/controller.dart';
import '../../../src/data.dart';
import '../../../src/emoji_assets.dart';
import '../../../src/word_cards.dart';
import '../../../src/theme.dart';
import '../../../src/widgets.dart';
import '../../onboarding/domain/learner_profile.dart';
import '../domain/journey_content.dart';
import '../domain/journey_engine.dart';
import '../domain/journey_models.dart';
import 'culture_screens.dart';
import '../../../src/app_text.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key, required this.controller});

  final QuestController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) => QuestPage(
          title: AppText.of('journey.title'),
          subtitle: AppText.of('journey.subtitle'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _JourneyHero(controller: controller),
              if (controller.showComeback) ...<Widget>[
                const SizedBox(height: 14),
                const _ComebackCard(),
              ],
              const SizedBox(height: 24),
              SectionTitle(AppText.of('journey.todaysQuests')),
              const SizedBox(height: 12),
              _DailyQuestCard(controller: controller),
              const SizedBox(height: 26),
              SectionTitle(AppText.of('journey.map')),
              const SizedBox(height: 12),
              if (!JourneyContentPolicy.releaseReady)
                const _ReviewNotice(),
              ...controller.journey.regions.map(
                (region) => _RegionSection(
                  controller: controller,
                  region: region,
                ),
              ),
              if (!CultureTrailPolicy.isProduction ||
                  CultureTrailPolicy.releaseReady) ...<Widget>[
                const SizedBox(height: 8),
                SectionTitle(AppText.of('journey.cultureTrail')),
                const SizedBox(height: 12),
                PremiumCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CultureTrailScreen(controller: controller),
                    ),
                  ),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFFFFF1BE), QuestColors.cream],
                  ),
                  child: Row(
                    children: <Widget>[
                      const Text('🏵️', style: TextStyle(fontSize: 34)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppText.of('journey.cultureTrailNote'),
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppText.of('journey.cultureCount', {'collected': controller.journeyState.collectedCultureCardIds.where((id) => id.startsWith('culture.')).length, 'total': cultureCards.length}),
                              style: const TextStyle(
                                color: QuestColors.slate,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF9A6800),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _CollectionCard(controller: controller),
            ],
          ),
        ),
      );
}

class _JourneyHero extends StatelessWidget {
  const _JourneyHero({required this.controller});

  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    final complete = controller.journeyDone;
    final total = controller.journey.nodes.length;
    return PremiumCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          QuestColors.midnight,
          QuestColors.navy,
          QuestColors.indigo,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x22FFFFFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text('🧭', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppText.of('journey.eyebrow'),
                      style: const TextStyle(
                        color: QuestColors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppText.of('journey.progress', {'done': complete, 'total': total}),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: total == 0 ? 0.0 : complete / total,
            minHeight: 9,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: const Color(0xFF32486E),
            valueColor: const AlwaysStoppedAnimation<Color>(QuestColors.gold),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              Pill(
                icon: Icons.local_fire_department_rounded,
                label: controller.profile.gentleMode
                    ? AppText.of('journey.rhythm')
                    : AppText.of('journey.rhythmDays', {'n': controller.journeyState.streakDays}),
                color: const Color(0xFFFFF0BD),
              ),
              Pill(
                icon: Icons.shield_moon_rounded,
                label: controller.journeyState.graceAvailable
                    ? AppText.of('journey.graceReady')
                    : AppText.of('journey.graceUsed'),
                color: const Color(0xFFDDF3FF),
              ),
              Pill(
                icon: Icons.calendar_view_week_rounded,
                label: AppText.of('journey.thisWeek', {'n': controller.weeklyStoryCount}),
                color: Colors.white,
              ),
              Pill(
                icon: Icons.stars_rounded,
                label: AppText.of('journey.trailMarks', {'n': controller.journeyState.trailMarks}),
                color: const Color(0xFFE9E4FF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComebackCard extends StatelessWidget {
  const _ComebackCard();

  @override
  Widget build(BuildContext context) => PremiumCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.waving_hand_rounded, color: QuestColors.gold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppText.of('journey.welcomeBack'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppText.of('journey.welcomeBackNote'),
                    style: const TextStyle(color: QuestColors.slate),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DailyQuestCard extends StatelessWidget {
  const _DailyQuestCard({required this.controller});

  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    final daily = controller.dailyJourneyQuests;
    final weekly = controller.weeklyJourneyQuests;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            controller.profile.gentleMode
                ? AppText.of('journey.dailyGentle')
                : AppText.of('journey.daily'),
            style: const TextStyle(
              color: QuestColors.tealDark,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          ...daily.map(_questRow),
          const Divider(height: 30),
          Text(
            controller.profile.gentleMode
                ? AppText.of('journey.weeklyGentle')
                : AppText.of('journey.weekly'),
            style: const TextStyle(
              color: QuestColors.tealDark,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          ...weekly.map(_questRow),
        ],
      ),
    );
  }

  Widget _questRow(QuestProgressView item) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: <Widget>[
            Icon(
              item.completed
                  ? Icons.check_circle_rounded
                  : _questIcon(item.quest.action),
              color:
                  item.completed ? QuestColors.success : QuestColors.indigo,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.quest.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.quest.instructionMizo,
                    style: const TextStyle(
                      color: QuestColors.slate,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (item.claimed)
              const Icon(Icons.verified_rounded, color: QuestColors.success)
            else if (item.completed)
              TextButton(
                onPressed: () => controller.claimJourneyQuest(item.claimKey),
                child: Text(AppText.of('journey.claim', {'n': item.quest.rewardMarks})),
              )
            else
              Text(
                '${item.progress.clamp(0, item.quest.target)}/${item.quest.target}',
                style: const TextStyle(
                  color: QuestColors.tealDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
      );

  IconData _questIcon(JourneyAction action) => switch (action) {
        JourneyAction.story => Icons.auto_stories_rounded,
        JourneyAction.review => Icons.psychology_alt_rounded,
        JourneyAction.culture => Icons.museum_rounded,
      };
}

class _ReviewNotice extends StatelessWidget {
  const _ReviewNotice();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5D8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.rate_review_rounded, color: const Color(0xFF9A6800)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppText.of('journey.preview'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
}

class _RegionSection extends StatelessWidget {
  const _RegionSection({required this.controller, required this.region});

  final QuestController controller;
  final JourneyRegion region;

  @override
  Widget build(BuildContext context) {
    final nodes = controller.journey.nodes
        .where((node) => region.nodeIds.contains(node.id))
        .where((node) => JourneyContentPolicy.playable(node.review))
        .toList(growable: false);
    if (nodes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(region.emoji, style: const TextStyle(fontSize: 25)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppText.pick(mizo: region.titleMizo, english: region.titleEnglish),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if ([region.titleMizo, region.subtitleEnglish]
                              .where((part) => part.isNotEmpty)
                              .join(' • ')
                          case final line when line.isNotEmpty)
                        Text(
                          line,
                          style: const TextStyle(
                            color: QuestColors.slate,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...nodes.map(
              (node) => _JourneyNodeTile(
                controller: controller,
                node: node,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyNodeTile extends StatelessWidget {
  const _JourneyNodeTile({required this.controller, required this.node});

  final QuestController controller;
  final JourneyNode node;

  @override
  Widget build(BuildContext context) {
    final status = controller.journeyStatus(node);
    final locked = status == JourneyNodeStatus.locked;
    final complete = status == JourneyNodeStatus.completed;
    return Semantics(
      button: !locked,
      enabled: !locked,
      label: AppText.of('journey.nodeSpoken', {'title': AppText.pick(mizo: node.titleMizo, english: node.titleEnglish), 'status': status.name}),
      child: InkWell(
        onTap: locked
            ? null
            : () {
                final story = controller.journey.storyById(node.storyId);
                if (story == null) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StoryQuestScreen(
                      controller: controller,
                      node: node,
                      story: story,
                    ),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: complete
                ? const Color(0xFFE5F7F1)
                : locked
                    ? QuestColors.mist
                    : const Color(0xFFE9EDFF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: complete
                    ? QuestColors.success
                    : locked
                        ? QuestColors.slate
                        : QuestColors.indigo,
                foregroundColor: Colors.white,
                child: Icon(
                  complete
                      ? Icons.check_rounded
                      : locked
                          ? Icons.lock_rounded
                          : Icons.play_arrow_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      [
                        if (node.emoji.isNotEmpty) node.emoji,
                        AppText.pick(mizo: node.titleMizo, english: node.titleEnglish),
                      ].join(' '),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      [node.titleMizo, node.subtitleEnglish]
                          .where((part) => part.isNotEmpty)
                          .join(' • '),
                      style: const TextStyle(
                        color: QuestColors.slate,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                locked
                    ? (controller.collectedCardCount < node.cardsNeeded
                        ? AppText.of('journey.nodeCards', {
                            'have': controller.collectedCardCount,
                            'n': node.cardsNeeded,
                          })
                        : AppText.of('journey.nodeLevel', {'n': node.minimumLevel + 1}))
                    : complete
                        ? AppText.of('journey.replay')
                        : AppText.of('journey.start'),
                style: const TextStyle(
                  color: QuestColors.indigo,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.controller});

  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    final unlocked = controller.journey.rewards
        .where(
          (reward) => controller.journeyState.unlockedRewardIds.contains(
            reward.id,
          ),
        )
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionTitle(
          AppText.of('journey.collection'),
          trailing: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CollectionScreen(controller: controller),
              ),
            ),
            child: Text(AppText.of('journey.viewAll')),
          ),
        ),
        const SizedBox(height: 12),
        PremiumCard(
          child: unlocked.isEmpty
              ? Row(
                  children: <Widget>[
                    const Icon(Icons.lock_open_rounded, color: QuestColors.indigo),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppText.of('journey.firstReward'),
                        style: const TextStyle(color: QuestColors.slate),
                      ),
                    ),
                  ],
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: unlocked
                      .map(
                        (reward) => Semantics(
                          label: reward.labelFor(
                            isChild: controller.profile.isChild,
                          ),
                          child: Chip(
                            avatar: Text(reward.emoji),
                            label: Text(
                              reward.labelFor(
                                isChild: controller.profile.isChild,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }
}

class StoryQuestScreen extends StatefulWidget {
  const StoryQuestScreen({
    super.key,
    required this.controller,
    required this.node,
    required this.story,
  });

  final QuestController controller;
  final JourneyNode node;
  final StoryEpisode story;

  @override
  State<StoryQuestScreen> createState() => _StoryQuestScreenState();
}

class _StoryQuestScreenState extends State<StoryQuestScreen> {
  int beatIndex = 0;
  String? selectedChoiceId;
  String? feedback;
  bool completed = false;
  bool cultureRecorded = false;

  bool get showEnglish => widget.controller.profile.supportLanguage ==
      SupportLanguage.english;

  StoryBeat get beat => widget.story.beats[beatIndex];

  /// The chapter's words that the catalog has, by id or (the built-in
  /// stories) by spelling.
  late final List<WordEntry> storyWords = () {
    final catalog = widget.controller.wordCatalog;
    final byId = {for (final entry in catalog) entry.id: entry};
    final bySpelling = {
      for (final entry in catalog.reversed) normalizeMizo(entry.word): entry
    };
    return [
      for (final id in widget.story.targetWordIds)
        if (byId[id] ?? bySpelling[normalizeMizo(id)] case final entry?) entry,
    ];
  }();

  /// The same replies in a mixed order, so the right one isn't always first.
  List<StoryChoice> get choices =>
      [...beat.choices]..shuffle(Random(beat.id.hashCode));

  void _openWord(WordEntry entry) =>
      showWordDetails(context, widget.controller, entry);

  /// [text] with the chapter's words in colour; tapping one opens its card.
  Widget _withStoryWords(String text, TextStyle style) {
    final words = {
      for (final entry in storyWords)
        if (!entry.word.trim().contains(' ')) foldMizo(entry.word): entry
    };
    if (words.isEmpty) return Text(text, style: style);
    final spans = <InlineSpan>[];
    var last = 0;
    for (final match
        in RegExp(r'\p{L}+', unicode: true).allMatches(text)) {
      final entry = words[foldMizo(match[0]!)];
      if (entry == null) continue;
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: GestureDetector(
          onTap: () => _openWord(entry),
          child: Text(match[0]!,
              style: style.copyWith(
                  color: QuestColors.indigo,
                  decoration: TextDecoration.underline,
                  decorationColor: QuestColors.indigo.withValues(alpha: .4))),
        ),
      ));
      last = match.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(TextSpan(style: style, children: spans));
  }

  void _choose(StoryChoice choice) {
    if (completed) return;
    setState(() {
      selectedChoiceId = choice.id;
      feedback = choice.replyMizo.isNotEmpty || choice.isNatural
          ? choice.replyMizo
          : AppText.of('story.tryAgain');
    });
  }

  Future<void> _continue() async {
    final choice = beat.choices
        .where((item) => item.id == selectedChoiceId)
        .firstOrNull;
    if (choice == null || !choice.isNatural) return;
    if (beatIndex < widget.story.beats.length - 1) {
      setState(() {
        beatIndex += 1;
        selectedChoiceId = null;
        feedback = null;
      });
      return;
    }
    await widget.controller.completeJourneyStory(
      nodeId: widget.node.id,
      choicesMade: widget.story.beats.length,
    );
    if (!mounted) return;
    setState(() => completed = true);
  }

  Future<void> _recordCulture() async {
    if (cultureRecorded) return;
    cultureRecorded = true;
    await widget.controller.markCultureNoteRead();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (completed) return _buildCompletion(context);
    final selected = beat.choices
        .where((choice) => choice.id == selectedChoiceId)
        .firstOrNull;
    return QuestPage(
      title: AppText.of('story.title'),
      subtitle: '${widget.story.titleMizo} • ${widget.story.titleEnglish}',
      hud: _StoryProgress(
        current: beatIndex + 1,
        total: widget.story.beats.length,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (beatIndex == 0) ...<Widget>[
            PremiumCard(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFDDF3FF), Color(0xFFF4F7FF)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.story.introductionMizo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (showEnglish) ...<Widget>[
                    const SizedBox(height: 7),
                    Text(
                      widget.story.introductionEnglish,
                      style: const TextStyle(color: QuestColors.slate),
                    ),
                  ],
                  if (storyWords.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      AppText.of('story.words'),
                      style: const TextStyle(
                        color: QuestColors.tealDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in storyWords)
                          ActionChip(
                            avatar: entry.emoji.trim().isEmpty
                                ? null
                                : EmojiImage(entry.emoji, size: 18),
                            label: Text(entry.word,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            onPressed: () => _openWord(entry),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            beat.speaker.toUpperCase(),
            style: const TextStyle(
              color: QuestColors.tealDark,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _withStoryWords(
                  '“${beat.mizo}”',
                  const TextStyle(
                    fontSize: 21,
                    height: 1.35,
                    fontWeight: FontWeight.w900,
                    color: QuestColors.ink,
                  ),
                ),
                if (showEnglish) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    beat.english,
                    style: const TextStyle(color: QuestColors.slate),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            AppText.of('story.chooseReply'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...choices.map(
            (choice) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnswerButton(
                label: showEnglish
                    ? '${choice.mizo}\n${choice.english}'
                    : choice.mizo,
                selected: selectedChoiceId == choice.id,
                correct: selectedChoiceId == choice.id
                    ? choice.isNatural
                    : null,
                onTap: () => _choose(choice),
              ),
            ),
          ),
          if (feedback != null) ...<Widget>[
            const SizedBox(height: 4),
            Semantics(
              liveRegion: true,
              child: Text(
                feedback!,
                style: TextStyle(
                  color: selected?.isNatural == true
                      ? QuestColors.success
                      : QuestColors.coral,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selected?.isNatural == true ? _continue : null,
              child: Text(
                beatIndex == widget.story.beats.length - 1
                    ? AppText.of('story.complete')
                    : AppText.of('common.continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletion(BuildContext context) {
    final reward = widget.controller.journey.rewardById(widget.node.rewardId);
    return QuestPage(
      title: AppText.of('story.completeTitle'),
      subtitle: widget.story.titleMizo,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 12),
          EmojiImage(reward?.emoji ?? '✨', size: 64),
          const SizedBox(height: 12),
          Text(
            AppText.of('story.wellDone'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            reward?.labelFor(isChild: widget.controller.profile.isChild) ??
                AppText.of('story.reward'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: QuestColors.tealDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (widget.controller.lastJourneyCards case final cards
              when !cards.isEmpty) ...<Widget>[
            const SizedBox(height: 18),
            NewCardsRow(
              controller: widget.controller,
              collected: cards.collected,
              gold: cards.gold,
            ),
          ],
          const SizedBox(height: 22),
          if (widget.story.cultureNoteMizo.isNotEmpty)
          PremiumCard(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFFFF1BE), Color(0xFFFFFAEC)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.museum_rounded, color: const Color(0xFF9A6800)),
                    const SizedBox(width: 8),
                    Text(
                      AppText.of('story.cultureMoment'),
                      style: const TextStyle(
                        color: const Color(0xFF9A6800),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.story.cultureNoteMizo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                if (showEnglish) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    widget.story.cultureNoteEnglish,
                    style: const TextStyle(color: QuestColors.slate),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: cultureRecorded ? null : _recordCulture,
                  icon: Icon(
                    cultureRecorded
                        ? Icons.check_circle_rounded
                        : Icons.bookmark_add_rounded,
                  ),
                  label: Text(cultureRecorded ? AppText.of('story.saved') : AppText.of('story.read')),
                ),
              ],
            ),
          ),
          if (widget.story.cultureNoteMizo.isNotEmpty)
            const SizedBox(height: 18),
          PremiumCard(
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.nightlight_round,
                  color: QuestColors.indigo,
                ),
                const SizedBox(height: 8),
                Text(
                  AppText.of('story.stop'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  AppText.of('story.stopNote'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: QuestColors.slate),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await widget.controller.acknowledgeHealthyStop();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Text(AppText.of('story.finish')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryProgress extends StatelessWidget {
  const _StoryProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) => Semantics(
        label: AppText.of('story.stepSpoken', {'n': current, 'total': total}),
        child: ExcludeSemantics(
          child: PremiumCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.auto_stories_rounded,
                      color: QuestColors.indigo,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        AppText.of('story.conversation', {'n': current, 'total': total}),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: current / total,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(99),
                ),
              ],
            ),
          ),
        ),
      );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
