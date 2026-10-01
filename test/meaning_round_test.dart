import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/src/data.dart';
import 'package:thumal_quest/src/meaning_round.dart';

WordEntry _word(String id, String word, String meaning, String gloss) => WordEntry(
      id: id,
      word: word,
      meaningMizo: meaning,
      englishGloss: gloss,
      exampleMizo: '',
      emoji: '',
      category: WordCategory.values.first,
      review: ContentReview.approved,
    );

final _catalog = [
  _word('w.kut', 'kut', 'Kut chu ban tawpa zungtang nei hi a ni.', 'hand'),
  _word('w.kut-2', 'kut', 'Kum tin hlim taka hman lawmna.', 'festival'),
  _word('w.hlimna', 'hlimna', 'Rilru lawm leh nuam taka awm dan.', 'happiness'),
  _word('w.nawmsakna', 'nawmsakna', 'Nuam taka hun hman dan.', 'fun / happiness'),
  _word('w.lu', 'lu', 'Kan taksa chhiah pakhat.', 'head'),
  _word('w.ke', 'ke', 'Kan taksa chhiah pakhat.', 'leg / foot'),
  _word('w.tui', 'tui', 'In theih thil hlum.', 'water'),
  _word('w.ui', 'ui', 'Ran vulh, a hau ṭhin.', 'dog'),
  _word('w.ar', 'ar', 'Ran vulh, tui a tlan ṭhin.', 'chicken'),
  _word('w.thing', 'thing', 'Ram hmuna hring leh sang.', 'tree'),
];

List<ChoiceQuestion> _round({double rating = 1, int seed = 0, List<WordEntry>? catalog}) => buildMeaningRound(
      catalog: catalog ?? _catalog,
      written: const <ChoiceQuestion>[],
      rating: rating,
      random: Random(seed),
      pick: (pool, count) => pool.take(count).toList(),
    );

ChoiceQuestion _about(List<ChoiceQuestion> round, String id) => round.firstWhere((q) => q.contentId == id);

void main() {
  test('every option is a different meaning and one is right', () {
    for (var seed = 0; seed < 30; seed++) {
      for (final rating in const [1.0, 5.0]) {
        for (final question in _round(rating: rating, seed: seed)) {
          expect(question.options, contains(question.answer));
          expect(question.options.toSet(), hasLength(question.options.length));
          expect(question.options, hasLength(4));
        }
      }
    }
  });

  test('another sense of the same spelling is never a wrong option', () {
    for (var seed = 0; seed < 30; seed++) {
      for (final rating in const [1.0, 5.0]) {
        final kut = _about(_round(rating: rating, seed: seed), 'w.kut');
        expect(kut.options, isNot(contains('festival')));
        expect(kut.options.where((o) => o.contains('lawmna')), isEmpty);
      }
    }
  });

  test('a word sharing an English meaning is never a wrong option', () {
    for (var seed = 0; seed < 30; seed++) {
      final happiness = _about(_round(rating: 5, seed: seed), 'w.hlimna');
      expect(happiness.options.where((o) => o.contains('Nuam taka hun')), isEmpty);
    }
  });

  test('levels 1–2 answer in English, level 3 up in Mizo with the word hidden', () {
    expect(_about(_round(rating: 1), 'w.kut').answer, 'hand');
    expect(_about(_round(rating: 5), 'w.kut').answer, 'Ban tawpa zungtang nei hi a ni.');
  });

  test('a Mizo meaning several words share is asked in English', () {
    expect(_about(_round(rating: 5), 'w.lu').answer, 'head');
  });

  test('a Mizo meaning that would need a blank is asked in English', () {
    final catalog = [..._catalog, _word('w.farnu', 'farnu', 'A unaute zinga hmeichhia hi a farnu an ti.', 'sister')];
    expect(_about(_round(rating: 5, catalog: catalog), 'w.farnu').answer, 'sister');
  });

  test('each spelling is asked once', () {
    final round = _round(rating: 5);
    expect(round.where((q) => q.prompt.contains('“kut”')), hasLength(1));
  });

  test('falls back to the built-in questions without enough words', () {
    expect(_round(catalog: _catalog.take(2).toList()), hasLength(oldWordQuestions.length));
  });

  test('falls back to the built-in questions when no word is tagged for it', () {
    final tagged = [
      for (final w in _catalog)
        WordEntry(
            id: w.id,
            word: w.word,
            meaningMizo: w.meaningMizo,
            englishGloss: w.englishGloss,
            exampleMizo: '',
            emoji: '',
            category: w.category,
            review: w.review,
            gameModes: const {'spelling'}),
    ];
    expect(_round(catalog: tagged), hasLength(oldWordQuestions.length));
  });

  test('built-in answers never name the word they are about', () {
    for (final question in oldWordQuestions) {
      final word = RegExp('“(.+?)”').firstMatch(question.prompt)![1]!;
      expect(foldMizo(question.answer), isNot(contains(foldMizo(word))));
      expect(question.options, contains(question.answer));
      expect(question.options.toSet(), hasLength(4));
    }
  });
}
