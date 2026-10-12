import 'dart:math';

import '../features/games/engine/game_difficulty.dart';
import 'data.dart';
import 'game_words.dart' show misspellings;
import 'mizo_lexicon.dart';

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

/// One question for [entry] at [rating]'s level: levels 1–2 one missing
/// letter of three, 3–4 two missing letters, 5–6 the whole word from its
/// letter tiles and two that don't belong, 7 the right spelling among
/// three slips (kaikuan for kaikuang). A word too short or with spaces
/// for its level's kind gets the one before it.
SpellingQuestion _spellingQuestionFor(
  WordEntry entry,
  Random random,
  double rating,
  Set<String> letterBag,
  Set<String> knownWords,
) {
  final level = rating.floor();
  final letters = [
    for (final letter in mizoLetters(entry.word.trim())) letter.toUpperCase(),
  ];
  final positions = [
    for (var i = 0; i < letters.length; i++)
      if (_alphabetLetter.hasMatch(letters[i].toLowerCase())) i,
  ];
  final clue = _clueFor(entry, rating);
  final gloss = entry.englishGloss.trim();
  final word = letters.join();
  final oneWord = !entry.word.trim().contains(RegExp(r'\s'));

  if (level >= 7 && oneWord) {
    final slips = misspellings(entry.word.trim(),
            random: random,
            isRealWord: (spelling) =>
                knownWords.contains(spelling.toUpperCase()) ||
                MizoLexicon.contains(spelling))
        .map((slip) => slip.toUpperCase())
        .toSet()
        .take(3)
        .toList();
    if (slips.length == 3) {
      return SpellingQuestion(
        kind: SpellingKind.pick,
        masked: '',
        full: word,
        options: [word, ...slips]..shuffle(random),
        answer: word,
        hint: clue,
        gloss: gloss,
        contentId: entry.id,
      );
    }
  }
  if (level >= 5 && oneWord && letters.length >= 3 && letters.length <= 9) {
    // The word's letters and two that don't belong, ones easily mixed up
    // with its own where there are such.
    final own = letters.toSet();
    final near = <String>{
      for (final letter in letters) ...?GameDifficulty.confusableLetters[letter],
    }.difference(own).toList()
      ..shuffle(random);
    final others = letterBag.difference(own).difference(near.toSet()).toList()
      ..shuffle(random);
    final extra = [...near, ...others].take(2);
    return SpellingQuestion(
      kind: SpellingKind.build,
      masked: List.filled(letters.length, '_').join(),
      full: word,
      options: [...letters, ...extra]..shuffle(random),
      answer: letters.join(' '),
      answers: letters,
      hint: clue,
      gloss: gloss,
      contentId: entry.id,
    );
  }
  if (level >= 3 && positions.length >= 4) {
    final picked = [...positions]..shuffle(random);
    final blanks = picked.take(2).toList()..sort();
    final correct = [for (final i in blanks) letters[i]];
    String spell(String a, String b) =>
        ([...letters]..[blanks[0]] = a..[blanks[1]] = b).join();
    // Wrong letters that spell no other real word with the right other one.
    final pool = <String>{
      ...letterBag,
      for (final letter in correct) ...?GameDifficulty.confusableLetters[letter],
    }
        .difference(correct.toSet())
        .where((letter) =>
            !knownWords.contains(spell(letter, correct[1])) &&
            !knownWords.contains(spell(correct[0], letter)))
        .toList();
    final wrong = GameDifficulty.distractors(correct.first, pool,
        rating: rating,
        count: 4,
        similarity: GameDifficulty.letterSimilarity,
        random: random);
    return SpellingQuestion(
      kind: SpellingKind.twoLetters,
      masked: ([...letters]..[blanks[0]] = '_'..[blanks[1]] = '_').join(),
      full: word,
      // A tile for each missing letter, even when both are the same.
      options: [...correct, ...wrong.where((l) => !correct.contains(l))]
        ..shuffle(random),
      answer: correct.join(' '),
      answers: correct,
      hint: clue,
      gloss: gloss,
      contentId: entry.id,
    );
  }
  return _oneLetterQuestion(entry, random, rating, letters, positions,
      letterBag, knownWords, clue, gloss);
}

/// The clue: levels 1–2 the English; from level 3 the Mizo meaning with
/// the word itself blanked (“Thlêng chu …” would give it away).
String _clueFor(WordEntry entry, double rating) {
  final gloss = entry.englishGloss.trim();
  final english = maskWordInClue(gloss, entry.word);
  final mizo = meaningWithoutWord(entry.meaningMizo, entry.word);
  // A gloss that is only the word itself (“jam”) says nothing once hidden.
  final englishUsable = english.contains(RegExp(r'\p{L}', unicode: true));
  // A Mizo meaning holding the word in a longer one (“lehkhabu”) gives it
  // away, so that word keeps its English clue.
  return (englishUsable && (rating < 3 || clueHidesWordIn(mizo, entry.word))) ||
          mizo.isEmpty
      ? english
      : mizo;
}

/// Blanks out one letter of the Mizo alphabet — ch, ng and aw count as
/// one letter, as they do in the alphabet learners are taught.
SpellingQuestion _oneLetterQuestion(
  WordEntry entry,
  Random random,
  double rating,
  List<String> letters,
  List<int> positions,
  Set<String> letterBag,
  Set<String> knownWords,
  String clue,
  String gloss,
) {
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
      count: rating < 3 ? 2 : 3,
      similarity: GameDifficulty.letterSimilarity,
      random: random);
  final options = <String>{correct, ...distractors}.toList()..shuffle(random);
  return SpellingQuestion(
    masked: spell('_'),
    options: options,
    answer: correct,
    hint: clue,
    gloss: gloss,
    contentId: entry.id,
  );
}
