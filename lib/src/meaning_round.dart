import 'dart:math';

import '../features/games/engine/game_difficulty.dart';
import 'data.dart';
import 'game_text.dart';
import 'game_words.dart';

/// Builds a Tawng Upa round: “what does this word mean?” with one right
/// meaning and three wrong ones. Levels 1–2 answer with English meanings,
/// level 3 up with Mizo ones. Questions written in Editorial Studio
/// ([written]) join the round, picked by level alongside the generated ones.
List<ChoiceQuestion> buildMeaningRound({
  required List<WordEntry> catalog,
  required List<ChoiceQuestion> written,
  required double rating,
  required Random random,
  required List<WordEntry> Function(List<WordEntry> pool, int count) pick,
}) {
  final english = rating < 3;
  final pool = catalog
      .where((entry) => ContentPolicy.playable(entry.review))
      .where((entry) => entry.meaningMizo.trim().isNotEmpty)
      .where((entry) => !english || entry.englishGloss.trim().isNotEmpty)
      .toList();
  final distinctMeanings = {
    for (final entry in pool) _meaningOf(entry, english: english)
  };
  if (pool.isEmpty || distinctMeanings.length < 4) {
    return <ChoiceQuestion>[...written, ...oldWordQuestions]..shuffle(random);
  }
  // A Mizo meaning several words share (“Kan taksa chhiah pakhat.”) can't
  // tell them apart, so those words are asked with English meanings.
  final mizoUses = <String, int>{};
  for (final entry in pool) {
    final meaning = _meaningOf(entry, english: false);
    mizoUses[meaning] = (mizoUses[meaning] ?? 0) + 1;
  }
  // Likewise a Mizo meaning that still needs its word blanked out, since
  // the blank would mark the right option.
  bool askInEnglish(WordEntry entry) {
    if (english) return true;
    final mizo = _meaningOf(entry, english: false);
    return entry.englishGloss.trim().isNotEmpty &&
        (mizoUses[mizo]! > 1 || mizo.contains('……'));
  }

  // Any reviewed meaning can be a wrong option; only words tagged for
  // Tawng Upa (or untagged) are asked about, each spelling once.
  final asked = <String>{};
  final askable = pool
      .where((entry) => entry.supportsGame('tawng_upa'))
      .where((entry) => asked.add(foldMizo(entry.word)))
      .toList();
  final generated = [
    for (final entry in pick(askable, 10))
      _questionFor(entry, pool,
          rating: rating, english: askInEnglish(entry), random: random),
  ];
  if (written.isEmpty) return generated;
  return GameDifficulty.pick(
    [...generated, ...written],
    rating: rating,
    count: 10,
    difficultyOf: (question) => question.difficulty,
    random: random,
  );
}

/// A meaning as an option: meanings often open with their own word
/// (“Thlêng chu …”), which would point straight at the right option, so
/// every option leaves its word out.
String _meaningOf(WordEntry entry, {required bool english}) => english
    ? maskWordInClue(entry.englishGloss.trim(), entry.word)
    : meaningWithoutWord(entry.meaningMizo, entry.word);

/// The separate senses in an English gloss: “to tease / pester” → {to tease, pester}.
Set<String> _senses(String gloss) => {
      for (final sense in gloss
          .toLowerCase()
          .replaceAll(RegExp(r'\(.*?\)'), ' ')
          .split(RegExp(r'[/,;]|\bor\b')))
        if (sense.trim().isNotEmpty)
          sense.trim().replaceFirst(RegExp(r'^to '), ''),
    };

ChoiceQuestion _questionFor(
  WordEntry entry,
  List<WordEntry> pool, {
  required double rating,
  required bool english,
  required Random random,
}) {
  final correct = _meaningOf(entry, english: english);
  final word = foldMizo(entry.word);
  final senses = _senses(entry.englishGloss);
  final seen = <String>{correct};
  // A wrong option must really be wrong: not another sense of the same
  // spelling (kut, kut-2) and not a word that shares an English meaning.
  final candidates = pool.where((other) {
    if (foldMizo(other.word) == word) return false;
    if (_senses(other.englishGloss).intersection(senses).isNotEmpty)
      return false;
    if (english && other.englishGloss.trim().isEmpty) return false;
    return seen.add(_meaningOf(other, english: english));
  }).toList();
  final distractors = GameDifficulty.distractors(entry, candidates,
          rating: rating, count: 3, similarity: wordSimilarity, random: random)
      .map((other) => _meaningOf(other, english: english))
      .toList();
  if (distractors.length < 3 && !english) {
    final fallback = oldWordQuestions
        .expand((question) => question.options)
        .where((option) => !seen.contains(option))
        .toSet()
        .toList()
      ..shuffle(random);
    distractors.addAll(fallback.take(3 - distractors.length));
  }
  final gloss = entry.englishGloss.trim();
  return ChoiceQuestion(
    prompt: fillGameText(GameText.of('tawng_upa').prompt, word: entry.word),
    options: [correct, ...distractors]..shuffle(random),
    answer: correct,
    explanation:
        '“${entry.word}”: ${entry.meaningMizo.trim()}${gloss.isEmpty ? '' : ' ($gloss)'}',
    difficulty: entry.difficulty,
    // From level 4 the picture no longer gives the meaning away.
    emoji: entry.emoji.trim().isEmpty || rating >= 4 ? '💬' : entry.emoji,
    review: entry.review,
    contentId: entry.id,
  );
}
