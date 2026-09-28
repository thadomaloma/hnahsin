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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                label: 'DUE',
                value: '${plan.reviewItemIds.length}',
              ),
              _LearningMetric(
                label: 'NEW',
                value: '${plan.newItemIds.length}',
              ),
              _LearningMetric(
                label: 'MASTERED',
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
                    ? 'Start Daily Lesson'
                    : 'Find My Mizo Level',
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
                child: const Text('Retake Placement Check'),
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
    questions = _buildQuestions(limit: 10, corpus: widget.controller.wordCatalog);
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

  Future<void> _startAtTq0() async {
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
        title: 'Placement Check',
        child: PremiumCard(
          child: Text('Learning content is not available yet.'),
        ),
      );
    }
    if (finished) return _result(context);
    final question = questions[index];
    final answered = selected != null;
    return QuestPage(
      title: 'Placement Check',
      subtitle: 'Question ${index + 1} of ${questions.length}',
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
                  'Choose the closest meaning',
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
                onTap: answered ? null : () => setState(() => selected = option),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: selected == null || saving ? null : _next,
              child: Text(
                index == questions.length - 1 ? 'See My Level' : 'Next',
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: saving ? null : _startAtTq0,
              child: const Text('Skip and start at TQ0'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _result(BuildContext context) {
    final level = widget.controller.learningState.level;
    return QuestPage(
      title: 'Your Starting Level',
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
                  '$correct/${questions.length} correct • ${level.mizoDescription}',
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
              label: const Text('Continue Learning'),
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
    final byId = <String, WordEntry>{
      for (final item in widget.controller.wordCatalog) item.id: item,
    };
    final items = widget.controller.dailyPlan.itemIds
        .map((id) => byId[id])
        .whereType<WordEntry>()
        .toList();
    questions = _questionsForItems(items);
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
      title: 'Daily Lesson',
      subtitle: '${index + 1} of ${questions.length}',
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
                Text(
                  question.item.word,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  question.item.meaningMizo,
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
                onTap: answered ? null : () => setState(() => selected = option),
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
                index == questions.length - 1 ? 'Finish Lesson' : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) => QuestPage(
        title: 'Daily Lesson',
        child: Column(
          children: <Widget>[
            const PremiumCard(
              child: Column(
                children: <Widget>[
                  Icon(Icons.task_alt_rounded, color: QuestColors.success, size: 50),
                  SizedBox(height: 10),
                  Text('All caught up!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  SizedBox(height: 6),
                  Text('Vawiin review tur i zo vek tawh e.', textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Learn'),
            ),
          ],
        ),
      );

  Widget _complete(BuildContext context) => QuestPage(
        title: 'Lesson Complete',
        child: Column(
          children: <Widget>[
            PremiumCard(
              gradient: const LinearGradient(
                colors: <Color>[QuestColors.midnight, QuestColors.indigo],
              ),
              child: Column(
                children: <Widget>[
                  const Icon(Icons.verified_rounded, color: QuestColors.gold, size: 52),
                  const SizedBox(height: 10),
                  const Text(
                    'Daily lesson complete!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '$correct/${questions.length} correct • Review hun leh tur automatic-in ruahman a ni.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFDDF3FF), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      );
}

class _LearningQuestion {
  const _LearningQuestion({
    required this.item,
    required this.options,
  });

  final WordEntry item;
  final List<String> options;
  String get answer => item.englishGloss;
}

List<_LearningQuestion> _buildQuestions({
  required int limit,
  List<WordEntry> corpus = wordEntries,
}) {
  final playableCorpus = corpus
      .where((item) => ContentPolicy.playable(item.review))
      .toList();
  if (playableCorpus.length < 4) return const <_LearningQuestion>[];
  final count = playableCorpus.length < limit ? playableCorpus.length : limit;
  final items = <WordEntry>[];
  for (var index = 0; index < count; index += 1) {
    items.add(playableCorpus[(index * 3) % playableCorpus.length]);
  }
  return _questionsForItems(items, corpus: playableCorpus);
}

List<_LearningQuestion> _questionsForItems(
  List<WordEntry> items, {
  List<WordEntry>? corpus,
}) {
  final source = corpus ??
      wordEntries
          .where((item) => ContentPolicy.playable(item.review))
          .toList();
  if (source.length < 4) return const <_LearningQuestion>[];
  return List<_LearningQuestion>.generate(items.length, (questionIndex) {
    final target = items[questionIndex];
    final targetIndex = source.indexWhere((item) => item.id == target.id);
    final start = targetIndex < 0 ? questionIndex : targetIndex;
    final choices = <String>{target.englishGloss};
    var offset = 1;
    while (choices.length < 4 && offset <= source.length) {
      choices.add(source[(start + offset) % source.length].englishGloss);
      offset += 1;
    }
    final options = choices.toList();
    final shift = questionIndex % options.length;
    final rotated = <String>[
      ...options.sublist(shift),
      ...options.sublist(0, shift),
    ];
    return _LearningQuestion(
      item: target,
      options: List<String>.unmodifiable(rotated),
    );
  });
}
