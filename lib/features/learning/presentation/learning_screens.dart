import 'dart:math';

import 'package:flutter/material.dart';

import '../../../src/controller.dart';
import '../../../src/data.dart';
import '../../../src/theme.dart';
import '../../../src/widgets.dart';
import '../domain/learning_state.dart';

class LearningOverviewCard extends StatelessWidget {
  const LearningOverviewCard({super.key, required this.controller});

  final QuestController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.learningState;
    final plan = controller.dailyPlan;
    return PremiumCard(
      gradient: const LinearGradient(
        colors: <Color>[QuestColors.midnight, QuestColors.indigo],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: QuestColors.gold,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  state.level.code,
                  style: const TextStyle(
                    color: QuestColors.midnight,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.level.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.level.mizoDescription,
            style: const TextStyle(color: Color(0xFFDDF3FF), height: 1.4),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _LearningMetric(
                label: 'EN LEH TUR',
                value: '${plan.reviewItemIds.length}',
              ),
              _LearningMetric(
                label: 'THAR',
                value: '${plan.newItemIds.length}',
              ),
              _LearningMetric(
                label: 'THIAM TAWH',
                value: '${state.masteredCount}',
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: QuestColors.gold,
                foregroundColor: QuestColors.midnight,
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => state.placementCompleted
                      ? DailyReviewScreen(controller: controller)
                      : PlacementScreen(controller: controller),
                ),
              ),
              icon: Icon(
                state.placementCompleted
                    ? Icons.school_rounded
                    : Icons.tune_rounded,
              ),
              label: Text(
                state.placementCompleted
                    ? 'Vawiin zirna ṭan rawh'
                    : 'I level hre chhuak rawh',
              ),
            ),
          ),
          if (state.placementCompleted)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PlacementScreen(controller: controller),
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Level en leh rawh'),
              ),
            ),
        ],
      ),
    );
  }
}

class _LearningMetric extends StatelessWidget {
  const _LearningMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 88),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: QuestColors.teal,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
          ],
        ),
      );
}

class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key, required this.controller});

  final QuestController controller;

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  late final List<_LearningQuestion> questions;
  int index = 0;
  int correct = 0;
  String? selected;
  bool saving = false;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    questions =
        _placementQuestions(_playableWords(widget.controller), Random());
  }

  Future<void> _next() async {
    if (selected == null || saving) return;
    if (selected == questions[index].answer) correct += 1;
    if (index < questions.length - 1) {
      setState(() {
        index += 1;
        selected = null;
      });
      return;
    }
    setState(() => saving = true);
    await widget.controller.completePlacement(
      correct: correct,
      total: questions.length,
    );
    if (!mounted) return;
    setState(() {
      saving = false;
      finished = true;
    });
  }

  Future<void> _startAtLevel1() async {
    if (saving) return;
    setState(() => saving = true);
    await widget.controller.completePlacement(
      correct: 0,
      total: questions.isEmpty ? 10 : questions.length,
    );
    if (!mounted) return;
    setState(() {
      saving = false;
      finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const QuestPage(
        title: 'Level enna',
        child: PremiumCard(
          child: Text('Zirna tur thumal a la awm lo.'),
        ),
      );
    }
    if (finished) return _result(context);
    final question = questions[index];
    final answered = selected != null;
    return QuestPage(
      title: 'Level enna',
      subtitle: 'Zawhna ${index + 1}/${questions.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LinearProgressIndicator(
            value: (index + 1) / questions.length,
            minHeight: 9,
            borderRadius: BorderRadius.circular(99),
          ),
          const SizedBox(height: 20),
          PremiumCard(
            child: Column(
              children: <Widget>[
                WordPicture(entry: question.item, size: 48),
                const SizedBox(height: 10),
                const Text(
                  'A awmzia hnai ber thlang rawh',
                  style: TextStyle(color: QuestColors.slate),
                ),
                const SizedBox(height: 6),
                Text(
                  question.item.word,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...question.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnswerButton(
                label: option,
                selected: selected == option,
                onTap:
                    answered ? null : () => setState(() => selected = option),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selected == null || saving ? null : _next,
              child: Text(
                index == questions.length - 1 ? 'I level en rawh' : 'A dawt',
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: saving ? null : _startAtLevel1,
              child: const Text('Level 1 atangin ṭan nghal rawh'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _result(BuildContext context) {
    final level = widget.controller.learningState.level;
    return QuestPage(
      title: 'I ṭanna level',
      child: Column(
        children: <Widget>[
          PremiumCard(
            gradient: const LinearGradient(
              colors: <Color>[QuestColors.midnight, QuestColors.indigo],
            ),
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.explore_rounded,
                  color: QuestColors.gold,
                  size: 54,
                ),
                const SizedBox(height: 12),
                Text(
                  level.code,
                  style: const TextStyle(
                    color: QuestColors.teal,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  level.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${questions.length} zingah $correct i chhang dik • ${level.mizoDescription}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFDDF3FF), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Zir chhunzawm rawh'),
            ),
          ),
        ],
      ),
    );
  }
}

class DailyReviewScreen extends StatefulWidget {
  const DailyReviewScreen({super.key, required this.controller});

  final QuestController controller;

  @override
  State<DailyReviewScreen> createState() => _DailyReviewScreenState();
}

class _DailyReviewScreenState extends State<DailyReviewScreen> {
  late final List<_LearningQuestion> questions;
  int index = 0;
  int correct = 0;
  String? selected;
  bool saving = false;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    final playable = _playableWords(widget.controller);
    final byId = <String, WordEntry>{
      for (final item in playable) item.id: item
    };
    final plan = widget.controller.dailyPlan;
    final items =
        plan.itemIds.map((id) => byId[id]).whereType<WordEntry>().toList();
    questions = _questionsFor(
      items,
      playable,
      Random(),
      newIds: plan.newItemIds.toSet(),
    );
  }

  Future<void> _continue() async {
    if (selected == null || saving) return;
    final wasCorrect = selected == questions[index].answer;
    setState(() => saving = true);
    await widget.controller.recordReview(
      itemId: questions[index].item.id,
      rating: wasCorrect ? ReviewRating.good : ReviewRating.again,
    );
    if (wasCorrect) correct += 1;
    if (!mounted) return;
    if (index < questions.length - 1) {
      setState(() {
        index += 1;
        selected = null;
        saving = false;
      });
      return;
    }
    await widget.controller.completeLesson();
    if (!mounted) return;
    setState(() {
      saving = false;
      finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return _empty(context);
    if (finished) return _complete(context);
    final question = questions[index];
    final answered = selected != null;
    return QuestPage(
      title: 'Vawiin zirna',
      subtitle: '${index + 1}/${questions.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LinearProgressIndicator(
            value: (index + 1) / questions.length,
            minHeight: 9,
            borderRadius: BorderRadius.circular(99),
          ),
          const SizedBox(height: 20),
          PremiumCard(
            child: Column(
              children: <Widget>[
                if (question.isNew) ...<Widget>[
                  const _NewWordChip(),
                  const SizedBox(height: 10),
                ],
                WordPicture(entry: question.item, size: 48),
                const SizedBox(height: 10),
                Text(
                  question.item.word,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 6),
                // A new word is taught with its meaning; a word coming back
                // is asked first and its meaning shown once answered.
                Text(
                  question.isNew || answered
                      ? question.item.meaningMizo
                      : 'A awmzia thlang rawh',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: QuestColors.slate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...question.options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnswerButton(
                label: option,
                selected: selected == option,
                correct: answered
                    ? option == question.answer
                        ? true
                        : selected == option
                            ? false
                            : null
                    : null,
                onTap:
                    answered ? null : () => setState(() => selected = option),
              ),
            ),
          ),
          if (answered) ...<Widget>[
            FeedbackCard(
              correct: selected == question.answer,
              message: selected == question.answer
                  ? 'A dik e! “${question.item.exampleMizo}”'
                  : 'A dik chu “${question.answer}” a ni. ${question.item.exampleMizo}',
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selected == null || saving ? null : _continue,
              child: Text(
                index == questions.length - 1 ? 'Zirna tihfel rawh' : 'A dawt',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => QuestPage(
        title: 'Vawiin zirna',
        child: Column(
          children: <Widget>[
            const PremiumCard(
              child: Column(
                children: <Widget>[
                  Icon(Icons.task_alt_rounded,
                      color: QuestColors.success, size: 50),
                  SizedBox(height: 10),
                  Text('I zo vek tawh e!',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  SizedBox(height: 6),
                  Text('Tunah hian en leh tur thumal a awm lo.',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kir leh rawh'),
            ),
          ],
        ),
      );

  Widget _complete(BuildContext context) => QuestPage(
        title: 'Zirna zo',
        child: Column(
          children: <Widget>[
            PremiumCard(
              gradient: const LinearGradient(
                colors: <Color>[QuestColors.midnight, QuestColors.indigo],
              ),
              child: Column(
                children: <Widget>[
                  const Icon(Icons.verified_rounded,
                      color: QuestColors.gold, size: 52),
                  const SizedBox(height: 10),
                  const Text(
                    'Vawiin zirna i zo ta!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${questions.length} zingah $correct i chhang dik • Heng thumalte hi a hun takah kan rawn tilang leh ang.',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(color: Color(0xFFDDF3FF), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Zir chhunzawm rawh'),
              ),
            ),
          ],
        ),
      );
}

class _NewWordChip extends StatelessWidget {
  const _NewWordChip();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: QuestColors.gold,
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Text(
          'THUMAL THAR',
          style: TextStyle(
            color: QuestColors.midnight,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
      );
}

class _LearningQuestion {
  const _LearningQuestion({
    required this.item,
    required this.options,
    this.isNew = false,
  });

  final WordEntry item;
  final List<String> options;

  /// Shown for the first time, so it is taught rather than tested.
  final bool isNew;

  String get answer => item.englishGloss;
}

List<WordEntry> _playableWords(QuestController controller) =>
    controller.wordCatalog
        .where((item) => ContentPolicy.playable(item.review))
        .toList();

/// Up to [limit] different words from easiest to hardest, spread evenly over
/// the catalog, so the score shows how far up the learner gets.
List<_LearningQuestion> _placementQuestions(
  List<WordEntry> corpus,
  Random random, {
  int limit = 10,
}) {
  if (corpus.length < 4) return const <_LearningQuestion>[];
  final sorted = <WordEntry>[...corpus]
    ..shuffle(random)
    ..sort((a, b) => a.difficulty.compareTo(b.difficulty));
  final count = min(limit, sorted.length);
  return _questionsFor(
    <WordEntry>[
      for (var index = 0; index < count; index += 1)
        sorted[index * sorted.length ~/ count],
    ],
    sorted,
    random,
  );
}

/// One question per item, with its English gloss among the options.
List<_LearningQuestion> _questionsFor(
  List<WordEntry> items,
  List<WordEntry> corpus,
  Random random, {
  Set<String> newIds = const <String>{},
}) {
  if (corpus.length < 4) return const <_LearningQuestion>[];
  return <_LearningQuestion>[
    for (final item in items)
      _LearningQuestion(
        item: item,
        options: _optionsFor(item, corpus, random),
        isNew: newIds.contains(item.id),
      ),
  ];
}

/// [item]'s gloss and three different ones, preferring words of the same
/// category so the wrong answers are believable, in a random order.
List<String> _optionsFor(
    WordEntry item, List<WordEntry> corpus, Random random) {
  String key(String gloss) => gloss.trim().toLowerCase();
  final others = <WordEntry>[...corpus]..shuffle(random);
  final options = <String>[item.englishGloss];
  final seen = <String>{key(item.englishGloss)};
  for (final other in <WordEntry>[
    ...others.where((other) => other.category == item.category),
    ...others.where((other) => other.category != item.category),
  ]) {
    if (options.length == 4) break;
    if (seen.add(key(other.englishGloss))) options.add(other.englishGloss);
  }
  return List<String>.unmodifiable(options..shuffle(random));
}
