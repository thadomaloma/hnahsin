import 'dart:math';

import '../features/games/engine/game_difficulty.dart';
import 'data.dart';

/// A letter of the Mizo alphabet (aw, âw, ch and ng included), as
/// opposed to a space or hyphen.
final _alphabetLetter = RegExp(r'^([a-zâêîôûṭ]|[aâ]w|ch|ng)$');

/// Builds a spelling round from the live/reviewed word catalog, so newly
/// reviewed and published content shows up here too. Falls back to the
/// prototype `spellingQuestions` only if the catalog has nothing usable.
List<SpellingQuestion> buildSpellingRound({
  required List<WordEntry> catalog,
  required Set<String> knownWords,
  required double rating,
  required Random random,
  required List<WordEntry> Function(List<WordEntry> pool, int count) pick,
}) {
  // One question per spelling: homographs (lo, tho, in…) would repeat.
  final spellings = <String>{};
  final pool = catalog
      .where((entry) => ContentPolicy.playable(entry.review))
      .where((entry) => entry.supportsGame('spelling'))
      .where((entry) {
    final word = normalizeMizo(entry.word);
    return mizoLetters(word).where(_alphabetLetter.hasMatch).length >= 2 &&
        spellings.add(word);
  }).toList();
  if (pool.isEmpty) {
    return [
      for (final question in spellingQuestions)
        SpellingQuestion(
          masked: question.masked,
          options: question.options,
          answer: question.answer,
          hint: maskWordInClue(question.hint, question.word),
        ),
    ]..shuffle(random);
  }

  final letterBag = <String>{
    for (final entry in catalog)
      for (final letter in mizoLetters(entry.word))
        if (_alphabetLetter.hasMatch(letter)) letter.toUpperCase(),
  };
  if (letterBag.length < 4) {
    letterBag.addAll(const ['A', 'E', 'I', 'K', 'N', 'T', 'M', 'R']);
  }

  final known = <String>{
    ...catalog.map((entry) => entry.word.trim().toUpperCase()),
    ...knownWords.map((word) => word.toUpperCase()),
  };

  return [
    for (final entry in pick(pool, 10))
      _spellingQuestionFor(entry, random, rating, letterBag, known),
  ];
}

/// Blanks out one letter of the Mizo alphabet — ch, ng and aw count as
/// one letter, as they do in the alphabet learners are taught.
SpellingQuestion _spellingQuestionFor(
  WordEntry entry,
  Random random,
  double rating,
  Set<String> letterBag,
  Set<String> knownWords,
) {
  final letters = [
    for (final letter in mizoLetters(entry.word.trim())) letter.toUpperCase(),
  ];
  final positions = [
    for (var i = 0; i < letters.length; i++)
      if (_alphabetLetter.hasMatch(letters[i].toLowerCase())) i,
  ];
  // Higher levels hide the letters learners confuse most (â/a, aw/o…).
  final tricky = positions
      .where((i) => GameDifficulty.confusableLetters.containsKey(letters[i]))
      .toList();
  final maskIndex =
      tricky.isNotEmpty && random.nextDouble() < GameDifficulty.hardness(rating)
          ? tricky[random.nextInt(tricky.length)]
          : positions[random.nextInt(positions.length)];
  final correct = letters[maskIndex];
  String spell(String letter) => ([...letters]..[maskIndex] = letter).join();
  // A letter that spells another real word (e.g. a/â pairs) would mark a
  // right answer wrong, so it is never offered.
  final letterOptions = <String>{
    ...letterBag,
    ...?GameDifficulty.confusableLetters[correct],
  }
      .difference(<String>{correct})
      .where((letter) => !knownWords.contains(spell(letter)))
      .toList();
  final distractors = GameDifficulty.distractors(correct, letterOptions,
      rating: rating,
      count: 3,
      similarity: GameDifficulty.letterSimilarity,
      random: random);
  final options = <String>{correct, ...distractors}.toList()..shuffle(random);
  // Levels 1–2 clue in English; from level 3 the Mizo meaning, with the
  // word itself blanked (“Thlêng chu …” would give it away).
  final gloss = entry.englishGloss.trim();
  final english = maskWordInClue(gloss, entry.word);
  final mizo = maskWordInClue(entry.meaningMizo.trim(), entry.word);
  // A gloss that is only the word itself (“jam”) says nothing once hidden.
  final englishUsable = english.contains(RegExp(r'\p{L}', unicode: true));
  return SpellingQuestion(
    masked: spell('_'),
    options: options,
    answer: correct,
    hint: (rating < 3 && englishUsable) || mizo.isEmpty ? english : mizo,
    gloss: gloss,
    contentId: entry.id,
  );
}
