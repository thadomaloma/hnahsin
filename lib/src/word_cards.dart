import 'dart:math';

import 'package:flutter/material.dart';

import 'app_text.dart';
import 'controller.dart';
import 'data.dart';
import 'theme.dart';
import 'widgets.dart';

/// One word's card: its picture and the Mizo word, gold once mastered. A
/// card not yet collected shows only a question mark.
class WordCard extends StatelessWidget {
  const WordCard(
      {super.key,
      required this.entry,
      required this.level,
      this.onTap,
      this.small = false});

  final WordEntry entry;

  /// 0 not collected, [WordCards.collected] or [WordCards.gold].
  final int level;
  final VoidCallback? onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final gold = level == WordCards.gold;
    final collected = level > 0;
    return Semantics(
      button: onTap != null,
      label: collected
          ? AppText.of(gold ? 'cards.goldSpoken' : 'cards.cardSpoken',
              {'word': entry.word})
          : AppText.of('cards.lockedSpoken'),
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: gold
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                          Color(0xFFFFE9A8),
                          QuestColors.gold,
                          Color(0xFFFFF4CF)
                        ])
                  : null,
              color: gold
                  ? null
                  : (collected ? Colors.white : const Color(0xFFE7EEF5)),
              borderRadius: BorderRadius.circular(small ? 12 : 16),
              border: Border.all(
                  color: gold
                      ? QuestColors.goldDeep
                      : (collected
                          ? QuestColors.line
                          : const Color(0xFFD5DFE8)),
                  width: gold ? 2 : 1.5),
              boxShadow: collected ? QuestShadows.card : null,
            ),
            padding: EdgeInsets.all(small ? 6 : 8),
            child: collected
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Expanded(
                            child: FittedBox(
                                child: WordPicture(
                                    entry: entry, size: small ? 30 : 40))),
                        const SizedBox(height: 4),
                        // Long words shrink to fit rather than lose letters.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(entry.word,
                              maxLines: 1,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: small ? 12 : 13.5,
                                  color: gold
                                      ? QuestColors.midnight
                                      : QuestColors.ink)),
                        ),
                      ])
                : Center(
                    child: Icon(Icons.question_mark_rounded,
                        color: const Color(0xFFAEBBC8), size: small ? 22 : 28)),
          ),
        ),
      ),
    );
  }
}

/// A card turning over to show its face, for cards a round just earned.
class FlipInCard extends StatelessWidget {
  const FlipInCard(
      {super.key, required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final total = motionFor(context, const Duration(milliseconds: 650)) +
        motionFor(context, delay);
    if (total == Duration.zero) return child;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (context, t, child) {
        final p = Curves.easeOutBack
            .transform(((t - start) / (1 - start)).clamp(0, 1).toDouble());
        final angle = (1 - p) * pi / 2;
        return Opacity(
          opacity: p.clamp(0, 1).toDouble(),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0015)
              ..rotateY(angle),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// The result sheet's row of cards a round earned.
class NewCardsRow extends StatelessWidget {
  const NewCardsRow(
      {super.key,
      required this.controller,
      required this.collected,
      required this.gold});
  final QuestController controller;
  final List<String> collected;
  final List<String> gold;

  @override
  Widget build(BuildContext context) {
    final byId = {for (final entry in controller.wordCatalog) entry.id: entry};
    final cards = [
      for (final id in gold)
        if (byId[id] case final entry?) (entry, WordCards.gold),
      for (final id in collected)
        if (byId[id] case final entry?) (entry, WordCards.collected),
    ];
    if (cards.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(AppText.of('cards.new'),
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: QuestColors.navy)),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => WordCardsScreen(controller: controller))),
          child: Text(AppText.of('cards.open')),
        ),
      ]),
      SizedBox(
        height: 86,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) => SizedBox(
            width: 70,
            child: FlipInCard(
              delay: Duration(milliseconds: 250 + 160 * min(i, 6)),
              child:
                  WordCard(entry: cards[i].$1, level: cards[i].$2, small: true),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// The word card album: every word, by topic, collected or not.
class WordCardsScreen extends StatefulWidget {
  const WordCardsScreen({super.key, required this.controller});
  final QuestController controller;

  @override
  State<WordCardsScreen> createState() => _WordCardsScreenState();
}

class _WordCardsScreenState extends State<WordCardsScreen> {
  WordCategory? category;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final cards = widget.controller.wordCards;
          final all = widget.controller.wordCatalog
              .where((entry) => ContentPolicy.playable(entry.review))
              .toList();
          // Collected first, gold before them; the rest keep the catalog's order.
          int rank(WordEntry entry) => -(cards[entry.id] ?? 0);
          final shown = (category == null
              ? all
              : all.where((entry) => entry.category == category).toList())
            ..sort((a, b) => rank(a).compareTo(rank(b)));
          int have(Iterable<WordEntry> entries) =>
              entries.where((entry) => (cards[entry.id] ?? 0) > 0).length;
          final gold =
              all.where((entry) => cards[entry.id] == WordCards.gold).length;
          return QuestPage(
            title: AppText.of('cards.title'),
            subtitle: AppText.of('cards.count',
                {'n': have(all), 'total': all.length, 'gold': gold}),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppText.of('cards.how'),
                  style:
                      const TextStyle(color: QuestColors.slate, height: 1.35)),
              const SizedBox(height: 14),
              SizedBox(
                height: 42,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                          '${AppText.of('library.all')} ${have(all)}/${all.length}'),
                      selected: category == null,
                      onSelected: (_) => setState(() => category = null),
                    ),
                  ),
                  for (final item in WordCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                            '${item.label} ${have(all.where((e) => e.category == item))}/${all.where((e) => e.category == item).length}'),
                        selected: category == item,
                        onSelected: (_) => setState(() => category = item),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shown.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 104,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: .82),
                itemBuilder: (context, i) {
                  final entry = shown[i];
                  final level = cards[entry.id] ?? 0;
                  return WordCard(
                    entry: entry,
                    level: level,
                    onTap: level == 0
                        ? null
                        : () => _showCard(context, entry, level),
                  );
                },
              ),
            ]),
          );
        },
      );

  void _showCard(BuildContext context, WordEntry entry, int level) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        isScrollControlled: true,
        builder: (sheetContext) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  width: 120,
                  height: 146,
                  child: WordCard(entry: entry, level: level)),
              const SizedBox(height: 14),
              Text(entry.word,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900)),
              if (entry.englishGloss.trim().isNotEmpty)
                Text(entry.englishGloss,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: QuestColors.tealDark,
                        fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(entry.meaningMizo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (entry.exampleMizo.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('“${entry.exampleMizo}”',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: QuestColors.slate, fontStyle: FontStyle.italic)),
              ],
              // The word at work in real sentences, with their meaning.
              if (widget.controller.sentenceIndex.sentencesUsing(entry)
                  case final sentences when sentences.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(AppText.of('cards.seenIn'),
                    style: const TextStyle(
                        color: QuestColors.slate,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8)),
                for (final sentence in sentences) ...[
                  const SizedBox(height: 6),
                  Text('“${sentence.textMizo}”',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(sentence.englishSupport,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: QuestColors.slate, fontSize: 13)),
                ],
              ],
            ]),
          ),
        ),
      );
}

/// Learn's way into the album: how many cards so far.
class WordCardsTile extends StatelessWidget {
  const WordCardsTile({super.key, required this.controller});
  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    final all = controller.wordCatalog
        .where((entry) => ContentPolicy.playable(entry.review))
        .toList();
    final cards = controller.wordCards;
    final have = all.where((entry) => (cards[entry.id] ?? 0) > 0).toList();
    final gold =
        have.where((entry) => cards[entry.id] == WordCards.gold).length;
    // A few collected cards fanned out, as on a sticker book's cover.
    final recent = have.take(3).toList();
    return PremiumCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => WordCardsScreen(controller: controller))),
      gradient:
          const LinearGradient(colors: [Color(0xFFFFF4CF), Color(0xFFFFFBF0)]),
      child: Row(children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(children: [
            for (final (i, entry) in recent.indexed)
              Positioned(
                left: i * 9.0,
                top: i * 3.0,
                child: SizedBox(
                    width: 44,
                    height: 56,
                    child: WordCard(
                        entry: entry, level: cards[entry.id]!, small: true)),
              ),
            if (recent.isEmpty)
              const SizedBox(
                  width: 44,
                  height: 56,
                  child: Icon(Icons.style_rounded,
                      color: QuestColors.goldDeep, size: 34)),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppText.of('cards.title'),
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 3),
            Text(
                AppText.of('cards.count',
                    {'n': have.length, 'total': all.length, 'gold': gold}),
                style: const TextStyle(color: QuestColors.slate)),
          ]),
        ),
        const Icon(Icons.arrow_forward_rounded, color: QuestColors.goldDeep),
      ]),
    );
  }
}
