import 'dart:math';

import '../features/games/application/daily_puzzle.dart';
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
/// Levels are spread over the game's own words ([spreadLevels]).
List<WordEntry> pickWordsForLevel(
  QuestController controller,
  String gameId,
  Iterable<WordEntry> pool,
  int count,
  Random random,
) {
  final now = DateTime.now().toUtc();
  final masteries = controller.learningState.masteries;
  final words = pool.toList();
  return GameDifficulty.pick(
    words,
    rating: controller.gameSkill(gameId),
    count: count,
    difficultyOf: spreadLevels(words),
    random: random,
    boost: (entry) => wordMemoryBoost(masteries[entry.id], now),
  );
}

/// Words for [daily]: picked by the day's level and seed only, so everyone
/// gets the same ones (what a player remembers doesn't steer them).
List<WordEntry> pickDailyWords(
        List<WordEntry> pool, DailyPuzzle daily, int count) =>
    GameDifficulty.pick(
      pool,
      rating: daily.rating,
      count: count,
      difficultyOf: spreadLevels(pool),
      random: daily.random,
    );

/// Levels 1–7 for a game's own words, spread so each level has about the
/// same number ([GameDifficulty.spread]): easiest by the words' level, then
/// the shorter word first.
int Function(WordEntry entry) spreadLevels(List<WordEntry> pool) =>
    GameDifficulty.spread(
      pool,
      difficultyOf: (entry) => entry.difficulty,
      tieBreak: (a, b) {
        final length = normalizeMizo(a.word)
            .length
            .compareTo(normalizeMizo(b.word).length);
        return length != 0 ? length : a.id.compareTo(b.id);
      },
    );

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

/// One Picture Match question. Levels 1–4 show the picture and ask for its
/// name; levels 5–6 turn it round, showing the name and asking for its
/// picture ([pictures]).
class PictureMatchQuestion {
  const PictureMatchQuestion(
      {required this.entry, required this.options, this.pictures});

  final WordEntry entry;

  /// The names to choose from (the right one is [entry]'s word), or for a
  /// picture question the words whose pictures are shown.
  final List<String> options;

  /// For a picture question: the words whose pictures to choose from.
  final List<WordEntry>? pictures;

  bool get asksForPicture => pictures != null;
}

/// [question] as a Picture Match question at [rating]:
/// levels 1–2 three names; 3–4 four, one a real word spelt almost the same
/// (sa, sâ); 5–6 four pictures for its name, of the same kind where there
/// are enough; 7 four names, with look-alike words and misspellings
/// (bawgn) as the wrong ones.
PictureMatchQuestion pictureMatchQuestion(
  WordEntry question,
  List<WordEntry> catalog, {
  required double rating,
  required Random random,
  bool Function(String word)? isRealWord,
}) {
  final level = rating.floor();
  if (level >= 5 && level <= 6) {
    final wrong = _wrongPictures(question, catalog, random: random);
    if (wrong.length == 3) {
      final pictures = [question, ...wrong]..shuffle(random);
      return PictureMatchQuestion(
          entry: question,
          options: [for (final entry in pictures) entry.word],
          pictures: pictures);
    }
  }
  final wrong = <String>[];
  if (level >= 3) {
    final alike = _lookAlikeWords(question, catalog)..shuffle(random);
    wrong.addAll(alike.take(1).map((entry) => entry.word));
  }
  if (level >= 7) {
    final misspelt = misspellings(question.word,
        random: random,
        isRealWord: (word) =>
            (isRealWord?.call(word) ?? false) ||
            catalog.any((entry) => foldMizo(entry.word) == foldMizo(word)));
    wrong.addAll(misspelt.take(2));
  }
  final count = level <= 2 ? 2 : 3;
  if (wrong.length < count) {
    final others = pictureMatchDistractors(question, catalog,
        rating: rating, random: random, count: count);
    for (final other in others) {
      if (wrong.length >= count) break;
      if (!wrong.contains(other.word)) wrong.add(other.word);
    }
  }
  return PictureMatchQuestion(
      entry: question,
      options: [question.word, ...wrong.take(count)]..shuffle(random));
}

/// Real words spelt almost like [question]'s (one letter or accent apart),
/// that don't show the same picture or share a meaning with it.
List<WordEntry> _lookAlikeWords(WordEntry question, List<WordEntry> catalog) {
  final word = normalizeMizo(question.word);
  final folded = foldMizo(question.word);
  final picture = pictureKey(question);
  final senses = glossSenses(question.englishGloss);
  final seen = <String>{word};
  return [
    for (final other in catalog)
      if (ContentPolicy.playable(other.review) &&
          seen.add(normalizeMizo(other.word)) &&
          pictureKey(other) != picture &&
          glossSenses(other.englishGloss).intersection(senses).isEmpty &&
          _editDistance(foldMizo(other.word), folded) <=
              (folded.length >= 6 ? 2 : 1))
        other,
  ];
}

/// Three other Picture Match words whose pictures are clearly different
/// from [question]'s and that share no meaning with it, of the same topic
/// where there are enough.
List<WordEntry> _wrongPictures(WordEntry question, List<WordEntry> catalog,
    {required Random random}) {
  final senses = glossSenses(question.englishGloss);
  final pictures = <String>{pictureKey(question)};
  final words = <String>{normalizeMizo(question.word)};
  final candidates = [
    for (final other in catalog)
      if (ContentPolicy.playable(other.review) &&
          other.supportsGame('picture_match') &&
          hasWordPicture(other) &&
          glossSenses(other.englishGloss).intersection(senses).isEmpty)
        other,
  ]..shuffle(random);
  candidates.sort((a, b) => (b.category == question.category ? 1 : 0)
      .compareTo(a.category == question.category ? 1 : 0));
  return [
    for (final other in candidates)
      if (pictures.add(pictureKey(other)) && words.add(normalizeMizo(other.word)))
        other,
  ].take(3).toList();
}

/// Spellings of [word] a learner might mix up with it that are not words
/// ([isRealWord] says which are), in a random order: first the usual slips
/// (aw for o, n for ng, ch for chh, a dropped h), then two letters swapped.
List<String> misspellings(String word,
    {required bool Function(String) isRealWord, required Random random}) {
  final w = word.trim();
  final found = <String>{};
  final swapped = <String>{};
  void tryAdd(String candidate, [Set<String>? into]) {
    if (candidate == w || candidate.trim().isEmpty) return;
    if (foldMizo(candidate) == foldMizo(w) || isRealWord(candidate)) return;
    (into ?? found).add(candidate);
  }

  for (final (from, to) in const [
    ('aw', 'o'),
    ('chh', 'ch'),
    ('hl', 'l'),
    ('hm', 'm'),
    ('hn', 'n'),
    ('hr', 'r'),
    ('th', 't'),
    ('kh', 'k'),
  ]) {
    for (final match in RegExp(from).allMatches(w)) {
      tryAdd(w.replaceRange(match.start, match.end, to));
    }
  }
  for (final match in RegExp(r'(?<!a)o').allMatches(w)) {
    tryAdd(w.replaceRange(match.start, match.end, 'aw'));
  }
  if (w.endsWith('ng')) tryAdd(w.substring(0, w.length - 1));
  if (w.endsWith('n')) tryAdd('${w}g');
  // Not the first letter: a word is read from its start.
  for (var i = 1; i + 1 < w.length; i++) {
    final a = w[i], b = w[i + 1];
    if (a == b || a == ' ' || b == ' ') continue;
    tryAdd(w.replaceRange(i, i + 2, '$b$a'), swapped);
  }
  return [
    ...(found.toList()..shuffle(random)),
    ...(swapped.difference(found).toList()..shuffle(random)),
  ];
}

int _editDistance(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      current[j] = [
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
      ].reduce(min);
    }
    previous = current;
  }
  return previous[b.length];
}
