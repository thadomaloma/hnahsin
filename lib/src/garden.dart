import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_text.dart';
import 'controller.dart';
import 'data.dart';
import 'emoji_assets.dart';
import '../features/learning/domain/learning_state.dart';
import 'game_session.dart';
import 'game_sounds.dart';
import 'game_words.dart';
import 'juice.dart';
import 'theme.dart';
import 'widgets.dart';
import 'word_cards.dart';
import 'word_sentences.dart';

/// The learner's garden: a flower for every word card collected, coloured
/// by the word's topic; a gold card is a big flower with a golden heart.
/// More words bring a butterfly, a tree, birds, a house and a rainbow.
/// Tap a flower to see its word.
class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key, required this.controller});
  final QuestController controller;

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

/// What grows at how many flowers.
const gardenSurprises = <(int, String)>[
  (5, '🦋'),
  (15, '🌳'),
  (30, '🐦'),
  (50, '🏡'),
  (100, '🌈'),
];

/// The words with a card, gold ones marked: what the garden grows.
List<(WordEntry, bool)> gardenFlowers(QuestController controller) {
  final byId = {for (final entry in controller.wordCatalog) entry.id: entry};
  return [
    for (final MapEntry(key: id, value: level) in controller.wordCards.entries)
      if (level > 0)
        if (byId[id] case final entry?) (entry, level >= WordCards.gold),
  ];
}

/// Words being learned that have no card yet: sprouts, which bloom into
/// flowers once their card is earned.
List<WordEntry> gardenSprouts(QuestController controller) {
  final masteries = controller.learningState.masteries;
  return [
    for (final entry in controller.wordCatalog)
      if (masteries[entry.id]?.stage == MasteryStage.learning &&
          (controller.wordCards[entry.id] ?? 0) == 0)
        entry
  ].take(28).toList();
}

/// Each topic's bed: its mascot, and the flower counts that earn a star.
const gardenMascots = <WordCategory, String>{
  WordCategory.chhungkua: '🏠',
  WordCategory.sikul: '📚',
  WordCategory.nungcha: '🐕',
  WordCategory.khawvel: '🌍',
  WordCategory.nunphung: '🥁',
  WordCategory.thiltih: '🏃',
};
const gardenBedStars = <int>[5, 15, 30];

/// A bed's mascot comes to the garden at this many flowers.
const gardenMascotAt = 10;

/// Whether [entry]'s word will be due within a day: its flower starts to
/// droop, a warning before it needs water.
bool gardenWiltingSoon(
        QuestController controller, WordEntry entry, DateTime now) =>
    switch (controller.learningState.masteries[entry.id]) {
      final mastery? => !mastery.isDue(now) &&
          mastery.dueAt.isBefore(now.add(const Duration(days: 1))),
      null => false,
    };

/// The word and two others that mean something else, of its topic where
/// there are enough, shuffled.
List<String> gardenOptions(
    QuestController controller, WordEntry entry, Random random) {
  final senses = glossSenses(entry.englishGloss);
  final others = controller.wordCatalog
      .where((other) =>
          ContentPolicy.playable(other.review) &&
          foldMizo(other.word) != foldMizo(entry.word) &&
          !other.word.contains(' ') &&
          glossSenses(other.englishGloss).intersection(senses).isEmpty)
      .toList()
    ..shuffle(random)
    ..sort((a, b) => (b.category == entry.category ? 1 : 0)
        .compareTo(a.category == entry.category ? 1 : 0));
  final words = <String>{entry.word};
  for (final other in others) {
    if (words.length == 3) break;
    words.add(other.word);
  }
  return words.toList()..shuffle(random);
}

/// Flowers already seen this session, so a new card's flower grows in.
Set<String>? _seenFlowers;

/// Whether [entry]'s flower is thirsty: its word is due for review, so
/// answering a question about it waters it.
bool gardenThirsty(QuestController controller, WordEntry entry, DateTime now) =>
    controller.learningState.masteries[entry.id]?.isDue(now) ?? false;

class _GardenScreenState extends State<GardenScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wind =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
        ..repeat();

  /// The words shown under their flowers.
  bool showNames = false;

  /// One topic picked out; the others fade.
  WordCategory? topic;

  /// Cards collected since the garden was last open: they grow in.
  late final Set<String> fresh = () {
    final ids = {
      for (final (entry, _) in gardenFlowers(widget.controller)) entry.id
    };
    final seen = _seenFlowers;
    _seenFlowers = ids;
    return seen == null ? <String>{} : ids.difference(seen);
  }();

  List<WordEntry> get _sprouts => gardenSprouts(widget.controller);

  @override
  void dispose() {
    _wind.dispose();
    super.dispose();
  }

  List<(WordEntry, bool)> get _flowers => gardenFlowers(widget.controller);

  /// Flowers just watered back to life: they hop once.
  final Set<String> revived = <String>{};

  /// When each gold flower's fruit was last picked: it grows back a day
  /// later. Kept on the phone.
  final Map<String, DateTime> picked = <String, DateTime>{};
  static const _pickedKey = 'garden.fruitPicked';

  @override
  void initState() {
    super.initState();
    _loadPicked();
  }

  Future<void> _loadPicked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonDecode(prefs.getString(_pickedKey) ?? '{}') as Map;
      if (!mounted) return;
      setState(() {
        for (final MapEntry(:key, :value) in raw.entries) {
          if (DateTime.tryParse('$value') case final at?) picked['$key'] = at;
        }
      });
    } catch (_) {
      // Without saved picks every gold flower simply has its fruit.
    }
  }

  Future<void> _savePicked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _pickedKey,
          jsonEncode({
            for (final MapEntry(:key, :value) in picked.entries)
              key: value.toIso8601String()
          }));
    } catch (_) {}
  }

  /// A gold flower bears fruit when its word's example sentence can show
  /// the word as a gap, and it wasn't picked in the last day.
  bool _fruiting(WordEntry entry, bool isGold, bool thirsty, DateTime now) =>
      isGold &&
      !thirsty &&
      blankWholeWord(entry.exampleMizo, entry.word) != null &&
      !(picked[entry.id]?.isAfter(now.subtract(const Duration(days: 1))) ??
          false);

  /// Picks [entry]'s fruit: its example sentence with the word left out.
  Future<void> _pickFruit(WordEntry entry) async {
    setState(() => picked[entry.id] = DateTime.now().toUtc());
    unawaited(_savePicked());
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _FruitSheet(controller: widget.controller, entry: entry),
    );
  }

  bool _thirsty(WordEntry entry, DateTime now) =>
      gardenThirsty(widget.controller, entry, now);

  /// Asks about [words] one by one; each right answer waters its flower.
  Future<void> _water(List<WordEntry> words) async {
    final watered = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _WaterSheet(
          controller: widget.controller, words: words.take(5).toList()),
    );
    if (!mounted || watered == null) return;
    setState(() => revived
      ..clear()
      ..addAll(watered));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: widget.controller, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    // Flowers of a topic grow together, in its own bed.
    final flowers = [for (final (i, flower) in _flowers.indexed) (i, flower)]
      ..sort((a, b) {
        final byTopic =
            a.$2.$1.category.index.compareTo(b.$2.$1.category.index);
        return byTopic != 0 ? byTopic : a.$1.compareTo(b.$1);
      });
    return _garden(context, [for (final (_, flower) in flowers) flower]);
  }

  Widget _garden(BuildContext context, List<(WordEntry, bool)> flowers) {
    final now = DateTime.now().toUtc();
    final thirsty = [
      for (final (entry, _) in flowers)
        if (_thirsty(entry, now)) entry
    ];
    final soon = [
      for (final (entry, _) in flowers)
        if (gardenWiltingSoon(widget.controller, entry, now)) entry
    ];
    final fruits = [
      for (final (entry, isGold) in flowers)
        if (_fruiting(entry, isGold, thirsty.contains(entry), now)) entry
    ];
    final gold = flowers.where((flower) => flower.$2).length;
    final sprouts = _sprouts;
    final next =
        gardenSurprises.where((s) => s.$1 > flowers.length).firstOrNull;
    final still = MediaQuery.disableAnimationsOf(context);
    final topics = <WordCategory, int>{};
    for (final (entry, _) in flowers) {
      topics[entry.category] = (topics[entry.category] ?? 0) + 1;
    }
    final freshWords = [
      for (final (entry, _) in flowers)
        if (fresh.contains(entry.id)) entry.word
    ];
    return QuestPage(
      title: AppText.of('garden.title'),
      subtitle: AppText.of('garden.countFull',
          {'flowers': flowers.length, 'gold': gold, 'sprouts': sprouts.length}),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (freshWords.isNotEmpty) ...[
          PopIn(
            child: PremiumCard(
                child: Row(children: [
              const EmojiImage('🌷', size: 36),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(
                      AppText.of(
                          'garden.new', {'words': freshWords.join(', ')}),
                      style: const TextStyle(fontWeight: FontWeight.w800))),
            ])),
          ),
          const SizedBox(height: 12),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: .78,
            child: LayoutBuilder(builder: (context, box) {
              final size = box.biggest;
              return AnimatedBuilder(
                animation: _wind,
                builder: (context, _) {
                  final t = still ? 0.0 : _wind.value * 2 * pi;
                  return Stack(clipBehavior: Clip.none, children: [
                    Positioned.fill(
                        child: CustomPaint(
                            painter: _MeadowPainter(DateTime.now().hour))),
                    ..._surprises(flowers.length, size, t),
                    ..._mascots(topics, size, t),
                    for (final (i, (entry, isGold)) in flowers.indexed)
                      _placed(i, entry, isGold, thirsty.contains(entry), size,
                          t, flowers.length,
                          soon: soon.contains(entry),
                          fruit: fruits.contains(entry)),
                    for (final (i, entry) in sprouts.indexed)
                      _placed(i, entry, false, false, size, t, sprouts.length,
                          sprout: true),
                  ]);
                },
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        if (flowers.isNotEmpty)
          // One row of chips, scrolled sideways.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [
              FilterChip(
                label: Text(AppText.of('garden.names')),
                avatar: const Icon(Icons.label_rounded, size: 16),
                selected: showNames,
                onSelected: (value) => setState(() => showNames = value),
              ),
              for (final MapEntry(key: category, value: count)
                  in topics.entries)
                ChoiceChip(
                  avatar: CircleAvatar(
                      radius: 6, backgroundColor: categoryColors(category).$2),
                  label: Text('${category.label} $count'),
                  selected: topic == category,
                  onSelected: (value) =>
                      setState(() => topic = value ? category : null),
                ),
            ].expand((chip) => [chip, const SizedBox(width: 6)]).toList()),
          ),
        if (showNames && topic == null && flowers.length > _namesAtOnce)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(AppText.of('garden.pickTopic'),
                style: const TextStyle(
                    color: QuestColors.slate, fontWeight: FontWeight.w600)),
          ),
        if (flowers.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Health(
              fresh: flowers.length - thirsty.length, total: flowers.length),
          if (soon.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(AppText.of('garden.soon', {'n': soon.length}),
                  style: const TextStyle(
                      color: QuestColors.slate, fontWeight: FontWeight.w600)),
            ),
        ],
        if (fruits.isNotEmpty) ...[
          const SizedBox(height: 12),
          PremiumCard(
            onTap: () => _pickFruit(fruits.first),
            child: Row(children: [
              const EmojiImage('🍊', size: 40),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(AppText.of('garden.ripe', {'n': fruits.length}),
                      style: const TextStyle(fontWeight: FontWeight.w800))),
              const Icon(Icons.arrow_forward_rounded,
                  color: QuestColors.indigo),
            ]),
          ),
        ],
        const SizedBox(height: 14),
        if (thirsty.isNotEmpty) ...[
          PremiumCard(
            child: Row(children: [
              const EmojiImage('💧', size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppText.of('garden.thirsty', {'n': thirsty.length}),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(AppText.of('garden.thirstyNote'),
                          style: const TextStyle(color: QuestColors.slate)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => _water(thirsty),
            icon: const Icon(Icons.water_drop_rounded),
            label: Text(AppText.of('garden.water')),
          ),
          const SizedBox(height: 14),
        ] else if (flowers.isNotEmpty) ...[
          PremiumCard(
              child: Row(children: [
            const EmojiImage('🌸', size: 40),
            const SizedBox(width: 12),
            Expanded(
                child: Text(AppText.of('garden.allWell'),
                    style: const TextStyle(fontWeight: FontWeight.w700))),
          ])),
          const SizedBox(height: 14),
        ],
        if (sprouts.isNotEmpty) ...[
          PremiumCard(
            child: Row(children: [
              const EmojiImage('🌱', size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppText.of('garden.sprouts', {'n': sprouts.length}),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(AppText.of('garden.sproutsNote'),
                          style: const TextStyle(color: QuestColors.slate)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _water(sprouts),
            icon: const Icon(Icons.spa_rounded),
            label: Text(AppText.of('garden.grow')),
          ),
          const SizedBox(height: 14),
        ],
        if (flowers.isEmpty && sprouts.isEmpty)
          PremiumCard(
              child: Row(children: [
            const EmojiImage('🌱', size: 40),
            const SizedBox(width: 12),
            Expanded(
                child: Text(AppText.of('garden.empty'),
                    style: const TextStyle(fontWeight: FontWeight.w700))),
          ]))
        else if (next != null)
          PremiumCard(
              child: Row(children: [
            EmojiImage(next.$2, size: 40),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    AppText.of('garden.next', {'n': next.$1 - flowers.length}),
                    style: const TextStyle(fontWeight: FontWeight.w700))),
          ])),
        if (flowers.isNotEmpty) ...[
          const SizedBox(height: 18),
          SectionTitle(AppText.of('garden.beds')),
          const SizedBox(height: 8),
          for (final category in WordCategory.values)
            _Bed(
              category: category,
              count: topics[category] ?? 0,
              selected: topic == category,
              onTap: () =>
                  setState(() => topic = topic == category ? null : category),
            ),
        ],
        const SizedBox(height: 8),
      ]),
    );
  }

  /// Where flower [i] grows: spread over the meadow in rows, the first
  /// ones nearest, with a little jitter so it looks planted by hand.
  Widget _placed(int i, WordEntry entry, bool isGold, bool thirsty, Size size,
      double t, int count,
      {bool sprout = false, bool soon = false, bool fruit = false}) {
    final random = Random(entry.id.hashCode);
    if (sprout) {
      // Sprouts line the front edge, apart from the flowers.
      return _plant(entry, false, false, size, t, i, count,
          x: size.width * (i + .5) / max(count, 7) +
              (random.nextDouble() - .5) * 8,
          y: size.height * .985,
          flowerSize: 26,
          sprout: true);
    }
    const perRow = 7;
    final row = i ~/ perRow;
    final rows = max(1, (count + perRow - 1) ~/ perRow);
    final col = i % perRow;
    // Rows climb the hill: nearer rows lower and larger.
    // A small garden stays near the front; a big one fills the hill.
    final depth = rows == 1 ? 0.0 : row * min(.14, 1 / (rows - 1));
    final y = size.height * (.92 - .42 * depth) + random.nextDouble() * 10;
    final x = size.width * ((col + .5 + (row.isOdd ? .5 : 0)) / (perRow + .5)) +
        (random.nextDouble() - .5) * 18;
    final scale = (1 - .4 * depth) * (isGold ? 1.35 : 1);
    return _plant(entry, isGold, thirsty, size, t, i, count,
        x: x, y: y, flowerSize: 44.0 * scale, soon: soon, fruit: fruit);
  }

  /// At most this many names show at once, unless a topic is picked.
  static const _namesAtOnce = 16;

  Widget _plant(WordEntry entry, bool isGold, bool thirsty, Size size, double t,
      int i, int count,
      {required double x,
      required double y,
      required double flowerSize,
      bool sprout = false,
      bool soon = false,
      bool fruit = false}) {
    // A thirsty flower hangs its head, one that soon will starts to droop;
    // the others sway in the wind.
    final sway = thirsty
        ? .35 + sin(t + i) * .02
        : soon
            ? .14 + sin(t + i) * .03
            : sin(t + i * .7) * .08;
    final (_, colour) = categoryColors(entry.category);
    final faded = topic != null && entry.category != topic;
    const labelWidth = 76.0;
    final plant = Positioned(
      left: x - flowerSize / 2,
      top: y - flowerSize * 1.6,
      width: flowerSize,
      height: flowerSize * 1.6,
      child: Semantics(
        button: true,
        label: AppText.of(
            sprout ? 'garden.sproutSpoken' : 'garden.flowerSpoken',
            {'word': entry.word}),
        child: GestureDetector(
          onTap: () => thirsty || sprout
              ? _water([entry])
              : showWordDetails(context, widget.controller, entry),
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(
              child: Cheer(
                active: revived.contains(entry.id),
                child: Transform.rotate(
                  angle: sway,
                  alignment: Alignment.bottomCenter,
                  child: CustomPaint(
                      painter: sprout
                          ? _SproutPainter()
                          : _FlowerPainter(
                              colour: thirsty || soon
                                  ? Color.lerp(colour, const Color(0xFFA8977E),
                                      thirsty ? .65 : .25)!
                                  : colour,
                              gold: isGold && !thirsty,
                              petals: 5 + entry.word.length % 3)),
                ),
              ),
            ),
            if (thirsty)
              Positioned(
                top: -14 + 3 * sin(t * 3 + i),
                left: flowerSize * .55,
                child: const EmojiImage('💧', size: 16),
              ),
            // A ripe fruit hangs by the flower; tap it to pick it.
            if (fruit)
              Positioned(
                top: flowerSize * .55 + 2 * sin(t * 2 + i),
                left: flowerSize * .62,
                child: GestureDetector(
                  onTap: () => _pickFruit(entry),
                  child: const EmojiImage('🍊', size: 18),
                ),
              ),
          ]),
        ),
      ),
    );
    final isFresh = fresh.contains(entry.id);
    final grown = PopIn(
      key: ValueKey('plant${entry.id}'),
      from: isFresh ? 0 : 1,
      delay: Duration(milliseconds: isFresh ? 300 + i * 60 : 0),
      duration: Duration(milliseconds: isFresh ? 900 : 1),
      child: Stack(clipBehavior: Clip.none, children: [plant]),
    );
    return Positioned.fill(
      child: Opacity(
        opacity: faded ? .2 : 1,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(child: grown),
          if (showNames &&
              !faded &&
              !sprout &&
              (topic != null || count <= _namesAtOnce))
            Positioned(
              left: x - labelWidth / 2,
              top: y + 2,
              width: labelWidth,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                        color: const Color(0xCCFFFFFF),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(entry.word,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: QuestColors.ink)),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  /// Each bed's mascot once it has [gardenMascotAt] flowers, wandering on
  /// the hilltop.
  List<Widget> _mascots(Map<WordCategory, int> topics, Size size, double t) => [
        for (final category in WordCategory.values)
          if ((topics[category] ?? 0) >= gardenMascotAt)
            Positioned(
              left: size.width *
                  (.08 + category.index * .15 + .03 * sin(t + category.index)),
              top: size.height * (.4 + .015 * category.index) -
                  3 * sin(t * 4 + category.index).abs(),
              child: EmojiImage(gardenMascots[category]!, size: 30),
            ),
      ];

  /// The surprises earned so far, each in its place.
  List<Widget> _surprises(int count, Size size, double t) => [
        if (count >= 100)
          Positioned(
              left: size.width * .1,
              top: size.height * .06,
              child: const Opacity(
                  opacity: .85, child: EmojiImage('🌈', size: 120))),
        if (count >= 50)
          Positioned(
              right: size.width * .06,
              top: size.height * .36,
              child: const EmojiImage('🏡', size: 64)),
        if (count >= 15)
          Positioned(
              left: size.width * .04,
              top: size.height * .3,
              child: const EmojiImage('🌳', size: 84)),
        if (count >= 30)
          Positioned(
              left: size.width * (.55 + .2 * sin(t)),
              top: size.height * (.12 + .03 * sin(t * 2)),
              child: const EmojiImage('🐦', size: 30)),
        if (count >= 5)
          Positioned(
              left: size.width * (.3 + .25 * sin(t * 1)),
              top: size.height * (.45 + .08 * cos(t * 2)),
              child: Transform.rotate(
                  angle: .2 * sin(t * 6),
                  child: const EmojiImage('🦋', size: 32))),
      ];
}

/// Sky, sun and a green hill.
class _MeadowPainter extends CustomPainter {
  _MeadowPainter(this.hour);

  /// The sky follows the clock: sun by day, a sunset, moon and stars.
  final int hour;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Rect.fromLTWH(0, 0, size.width, size.height);
    final night = hour < 6 || hour >= 19;
    final evening = hour >= 17 && hour < 19;
    canvas.drawRect(
        sky,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: night
                ? const [Color(0xFF14204A), Color(0xFF3A4A86)]
                : evening
                    ? const [Color(0xFFFF9E6B), Color(0xFFFFD9A8)]
                    : const [Color(0xFF9FD8FF), Color(0xFFE6F6FF)],
          ).createShader(sky));
    if (night) {
      final stars = Random(9);
      final star = Paint()..color = const Color(0xCCFFFFFF);
      for (var k = 0; k < 30; k++) {
        canvas.drawCircle(
            Offset(stars.nextDouble() * size.width,
                stars.nextDouble() * size.height * .4),
            stars.nextDouble() * 1.4 + .4,
            star);
      }
      // A crescent moon.
      canvas.drawCircle(Offset(size.width * .8, size.height * .12),
          size.width * .07, Paint()..color = const Color(0xFFFFF4C2));
      canvas.drawCircle(Offset(size.width * .83, size.height * .105),
          size.width * .06, Paint()..color = const Color(0xFF18245A));
    } else {
      canvas.drawCircle(
          Offset(size.width * .82, size.height * (evening ? .3 : .12)),
          size.width * .09,
          Paint()
            ..color =
                evening ? const Color(0xFFFF7A3D) : const Color(0xFFFFE07A));
    }
    final hill = Path()
      ..moveTo(0, size.height * .5)
      ..quadraticBezierTo(size.width * .35, size.height * .38, size.width * .6,
          size.height * .46)
      ..quadraticBezierTo(
          size.width * .85, size.height * .52, size.width, size.height * .44)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        hill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: night
                ? const [Color(0xFF3E7A3A), Color(0xFF2C5A2A)]
                : const [Color(0xFF8FD16A), Color(0xFF5DAE47)],
          ).createShader(sky));
  }

  @override
  bool shouldRepaint(_MeadowPainter old) => old.hour != hour;
}

/// A flower on its stem: petals in the topic's colour, a golden heart and
/// a glow for a gold card.
class _FlowerPainter extends CustomPainter {
  _FlowerPainter(
      {required this.colour, required this.gold, required this.petals});
  final Color colour;
  final bool gold;
  final int petals;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final head = Offset(w / 2, w / 2);
    final stem = Paint()
      ..color = const Color(0xFF3F8F2F)
      ..strokeWidth = w * .07
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w / 2, size.height), head, stem);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * .36, size.height * .78),
            width: w * .3,
            height: w * .14),
        Paint()..color = const Color(0xFF4FA83A));
    if (gold) {
      canvas.drawCircle(
          head,
          w * .5,
          Paint()
            ..color = const Color(0x55FFD54A)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
    final petal = Paint()..color = colour;
    final light = Paint()..color = Color.lerp(colour, Colors.white, .45)!;
    for (var k = 0; k < petals; k++) {
      final a = k * 2 * pi / petals;
      final c = head + Offset(cos(a), sin(a)) * w * .2;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: w * .36, height: w * .24),
          petal);
      canvas.drawOval(
          Rect.fromCenter(
              center: const Offset(-2, 0), width: w * .16, height: w * .1),
          light);
      canvas.restore();
    }
    canvas.drawCircle(
        head,
        w * .13,
        Paint()
          ..color = gold ? const Color(0xFFFFC94A) : const Color(0xFFFFE9A8));
    if (gold) {
      canvas.drawCircle(
          head,
          w * .13,
          Paint()
            ..color = const Color(0xFFF2A516)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_FlowerPainter old) =>
      old.colour != colour || old.gold != gold || old.petals != petals;
}

/// Home's way into the garden: how many flowers, and a peek of a few.
class GardenCard extends StatelessWidget {
  const GardenCard({super.key, required this.controller});
  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    final flowers = gardenFlowers(controller);
    return PremiumCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => GardenScreen(controller: controller))),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: const Color(0xFFE6F5E2),
              borderRadius: BorderRadius.circular(18)),
          child: EmojiImage(flowers.isEmpty ? '🌱' : '🌷', size: 34),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppText.of('garden.title'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(
                AppText.of('garden.count', {
                  'flowers': flowers.length,
                  'gold': flowers.where((flower) => flower.$2).length
                }),
                style: const TextStyle(color: QuestColors.slate)),
          ]),
        ),
        const Icon(Icons.arrow_forward_rounded, color: QuestColors.indigo),
      ]),
    );
  }
}

/// Watering: a quick question for each thirsty word ("Which Mizo word
/// means …?", three to choose from). A right answer waters the flower; the
/// word's memory is updated either way, as if met in a game. Pops with the
/// ids watered.
class _WaterSheet extends StatefulWidget {
  const _WaterSheet({required this.controller, required this.words});
  final QuestController controller;
  final List<WordEntry> words;

  @override
  State<_WaterSheet> createState() => _WaterSheetState();
}

class _WaterSheetState extends State<_WaterSheet> {
  final random = Random();
  int index = 0;
  String? picked;
  final Set<String> watered = <String>{};
  late List<String> options = _optionsFor(widget.words.first);

  WordEntry get word => widget.words[index];
  bool get done => index >= widget.words.length;

  List<String> _optionsFor(WordEntry entry) =>
      gardenOptions(widget.controller, entry, random);

  Future<void> _choose(String option) async {
    if (picked != null) return;
    final right = option == word.word;
    setState(() => picked = option);
    GameSounds.play(right ? GameSound.correct : GameSound.wrong);
    if (right) watered.add(word.id);
    await widget.controller.recordWordsPlayed(
        [WordPlay(id: word.id, word: word.word, missed: !right)]);
    if (right) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) _next();
    }
  }

  void _next() => setState(() {
        index++;
        picked = null;
        if (!done) options = _optionsFor(word);
      });

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (done) ...[
              const EmojiImage('🌸', size: 64),
              const SizedBox(height: 10),
              Text(
                  AppText.of('garden.done',
                      {'n': watered.length, 'total': widget.words.length}),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(watered),
                    child: Text(AppText.of('common.continue'))),
              ),
            ] else ...[
              Row(children: [
                for (var i = 0; i < widget.words.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.water_drop_rounded,
                        size: 18,
                        color: i < index
                            ? QuestColors.indigoBright
                            : QuestColors.line),
                  ),
              ]),
              const SizedBox(height: 12),
              PopIn(
                key: ValueKey('water$index'),
                from: .8,
                child: Column(children: [
                  if (word.emoji.trim().isNotEmpty)
                    EmojiImage(word.emoji, size: 56),
                  const SizedBox(height: 8),
                  Text(
                      AppText.of('garden.question',
                          {'gloss': word.englishGloss.split(';').first.trim()}),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w800)),
                ]),
              ),
              const SizedBox(height: 14),
              for (final (i, option) in options.indexed)
                SlideIn(
                  key: ValueKey('water$index.$i'),
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AnswerButton(
                      label: option,
                      selected: picked == option,
                      correct: picked == option ? option == word.word : null,
                      onTap: picked == null ? () => _choose(option) : null,
                    ),
                  ),
                ),
              if (picked != null && picked != word.word) ...[
                FeedbackCard(
                    correct: false,
                    message: AppText.of('garden.missed', {'word': word.word})),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _next, child: Text(AppText.of('common.next'))),
                ),
              ],
            ],
          ]),
        ),
      );
}

/// A seedling: two leaves on a short stem.
class _SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final base = Offset(w / 2, size.height);
    final top = Offset(w / 2, size.height * .45);
    canvas.drawLine(
        base,
        top,
        Paint()
          ..color = const Color(0xFF3F8F2F)
          ..strokeWidth = w * .09
          ..strokeCap = StrokeCap.round);
    final leaf = Paint()..color = const Color(0xFF6BC24A);
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(top.dx, top.dy);
      canvas.rotate(side * .6);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(side * w * .22, 0),
              width: w * .5,
              height: w * .26),
          leaf);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SproutPainter old) => false;
}

/// How many flowers are fresh, as a bar.
class _Health extends StatelessWidget {
  const _Health({required this.fresh, required this.total});
  final int fresh;
  final int total;

  @override
  Widget build(BuildContext context) {
    final share = total == 0 ? 1.0 : fresh / total;
    return Row(children: [
      Text(AppText.of('garden.health'),
          style: const TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(width: 10),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: share),
            duration: motionFor(context, const Duration(milliseconds: 600)),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: const Color(0xFFE9E1D3),
              color: Color.lerp(
                  const Color(0xFFC9A66B), QuestColors.success, value),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text('${(share * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.w800)),
    ]);
  }
}

/// A topic's bed: its mascot, flowers, stars and the next star's count.
class _Bed extends StatelessWidget {
  const _Bed(
      {required this.category,
      required this.count,
      required this.selected,
      required this.onTap});

  final WordCategory category;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stars = gardenBedStars.where((at) => count >= at).length;
    final next = gardenBedStars.where((at) => count < at).firstOrNull;
    final previous = stars == 0 ? 0 : gardenBedStars[stars - 1];
    final (background, colour) = categoryColors(category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? background : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Opacity(
                opacity: count >= gardenMascotAt ? 1 : .35,
                child: EmojiImage(gardenMascots[category]!, size: 34),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(category.label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15)),
                        ),
                        for (var k = 0; k < gardenBedStars.length; k++)
                          Icon(Icons.star_rounded,
                              size: 18,
                              color: k < stars
                                  ? QuestColors.gold
                                  : QuestColors.line),
                      ]),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: next == null
                              ? 1
                              : (count - previous) / (next - previous),
                          minHeight: 7,
                          backgroundColor: background,
                          color: colour,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                          next == null
                              ? AppText.of('garden.bedFull', {'n': count})
                              : AppText.of('garden.bedNext',
                                  {'n': count, 'left': next - count}),
                          style: const TextStyle(
                              color: QuestColors.slate, fontSize: 12.5)),
                    ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// A fruit picked: the word's example sentence with the word left out, to
/// fill from three. Either way the word's memory is updated, as in a game.
class _FruitSheet extends StatefulWidget {
  const _FruitSheet({required this.controller, required this.entry});
  final QuestController controller;
  final WordEntry entry;

  @override
  State<_FruitSheet> createState() => _FruitSheetState();
}

class _FruitSheetState extends State<_FruitSheet> {
  late final List<String> options =
      gardenOptions(widget.controller, widget.entry, Random());
  String? choice;

  Future<void> _choose(String option) async {
    if (choice != null) return;
    final right = option == widget.entry.word;
    setState(() => choice = option);
    GameSounds.play(right ? GameSound.correct : GameSound.wrong);
    await widget.controller.recordWordsPlayed([
      WordPlay(id: widget.entry.id, word: widget.entry.word, missed: !right)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final right = choice == entry.word;
    final gloss = entry.englishGloss.split(';').first.trim();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const EmojiImage('🍊', size: 48),
          const SizedBox(height: 6),
          Text(AppText.of('garden.fruitTitle'),
              style: const TextStyle(
                  color: QuestColors.slate, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(
              choice == null
                  ? blankWholeWord(entry.exampleMizo, entry.word)!
                  : entry.exampleMizo,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          for (final (i, option) in options.indexed)
            SlideIn(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AnswerButton(
                  label: option,
                  selected: choice == option,
                  correct: choice == option ? option == entry.word : null,
                  onTap: choice == null ? () => _choose(option) : null,
                ),
              ),
            ),
          if (choice != null) ...[
            FeedbackCard(
                correct: right,
                message: AppText.of(
                    right ? 'garden.fruitRight' : 'garden.fruitWrong',
                    {'word': entry.word, 'gloss': gloss})),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppText.of('common.continue'))),
            ),
          ],
        ]),
      ),
    );
  }
}
