import 'dart:math';

import '../features/games/engine/game_difficulty.dart';
import '../features/learning/domain/learning_state.dart';
import 'controller.dart';
import 'data.dart';

/// How alike two words are (0–1), used to make wrong answers trickier as a
/// learner's level rises: same topic, similar length, same first letter.
double wordSimilarity(WordEntry a, WordEntry b) {
  var score = 0.0;
  if (a.category == b.category) score += .45;
  if ((a.word.length - b.word.length).abs() <= 1) score += .3;
  if (a.word.isNotEmpty &&
      b.word.isNotEmpty &&
      normalizeMizo(a.word)[0] == normalizeMizo(b.word)[0]) score += .25;
  return score;
}

/// The separate senses in an English gloss: “to tease / pester” → {to tease, pester}.
Set<String> glossSenses(String gloss) => {
      for (final sense in gloss
          .toLowerCase()
          .replaceAll(RegExp(r'\(.*?\)'), ' ')
          .split(RegExp(r'[/,;]|\bor\b')))
        if (sense.trim().isNotEmpty)
          sense.trim().replaceFirst(RegExp(r'^to '), ''),
    };

/// What a word's picture shows, in [WordPicture]'s order (uploaded
/// picture, built-in illustration, emoji): two words with the same key look
/// the same on screen.
String pictureKey(WordEntry entry) => entry.hasUploadedPicture
    ? 'upload:${entry.imageChecksum}'
    : (illustrationFor(entry) ?? entry.emoji.trim());

/// Wrong answers for a Picture Match question: never a word that shows the
/// same picture or shares a meaning with [question], since that would make
/// it right too (🥁 is khuang and khaûm; both mean drum).
List<WordEntry> pictureMatchDistractors(
  WordEntry question,
  Iterable<WordEntry> catalog, {
  required double rating,
  required Random random,
  int count = 3,
}) {
  final picture = pictureKey(question);
  final senses = glossSenses(question.englishGloss);
  final seen = <String>{normalizeMizo(question.word)};
  final others = catalog
      .where((word) => ContentPolicy.playable(word.review))
      .where((word) => pictureKey(word) != picture)
      .where(
          (word) => glossSenses(word.englishGloss).intersection(senses).isEmpty)
      .where((word) => seen.add(normalizeMizo(word.word)))
      .toList();
  return GameDifficulty.distractors(question, others,
      rating: rating, count: count, similarity: wordSimilarity, random: random);
}

/// Words for one round of [gameId], centred on the learner's adaptive level
/// for that game and ordered easiest first. What the player remembers
/// steers the pick ([wordMemoryBoost]), so playing is also practising.
/// [difficultyOf] replaces the words' own level (see [spreadLevels]).
List<WordEntry> pickWordsForLevel(
  QuestController controller,
  String gameId,
  Iterable<WordEntry> pool,
  int count,
  Random random, {
  int Function(WordEntry entry)? difficultyOf,
}) {
  final now = DateTime.now().toUtc();
  final masteries = controller.learningState.masteries;
  return GameDifficulty.pick(
    pool.toList(),
    rating: controller.gameSkill(gameId),
    count: count,
    difficultyOf: difficultyOf ?? (entry) => entry.difficulty,
    random: random,
    boost: (entry) => wordMemoryBoost(masteries[entry.id], now),
  );
}

/// Levels 1–7 for a game's own words, spread so each level has about the
/// same number: easiest by the words' level, then the shorter word first.
/// A game whose words are mostly level 1 (Picture Match's pictures are)
/// would otherwise show its few level 5–7 words in every hard round.
Map<String, int> spreadLevels(Iterable<WordEntry> pool) {
  final ranked = pool.toList()
    ..sort((a, b) {
      final level = a.difficulty.compareTo(b.difficulty);
      if (level != 0) return level;
      final length =
          normalizeMizo(a.word).length.compareTo(normalizeMizo(b.word).length);
      return length != 0 ? length : a.id.compareTo(b.id);
    });
  final levels = GameDifficulty.maxRating.toInt();
  return {
    for (final (index, entry) in ranked.indexed)
      entry.id: 1 + index * levels ~/ ranked.length,
  };
}

/// How much more (or less) likely a word is to come up, from what the
/// player remembers: a word they missed comes back soon, one due for a
/// refresh a little more often, and one they know well rarely.
double wordMemoryBoost(ItemMastery? memory, DateTime now) {
  if (memory == null || memory.stage == MasteryStage.unseen) return 1;
  if (memory.stage == MasteryStage.learning && memory.lapses > 0) return 3;
  if (memory.isDue(now)) return 2;
  return switch (memory.stage) {
    MasteryStage.strong || MasteryStage.mastered => .35,
    _ => .7,
  };
}
