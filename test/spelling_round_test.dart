import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/src/data.dart';
import 'package:thumal_quest/src/spelling_round.dart';

WordEntry _word(String id, String word, {String meaning = '', String gloss = ''}) => WordEntry(
      id: id,
      word: word,
      meaningMizo: meaning,
      englishGloss: gloss,
      exampleMizo: '',
      emoji: '',
      category: WordCategory.values.first,
      review: ContentReview.approved,
    );

List<SpellingQuestion> _round(List<WordEntry> catalog, {int seed = 0, double rating = 1}) =>
    buildSpellingRound(
      catalog: catalog,
      knownWords: const <String>{},
      rating: rating,
      random: Random(seed),
      pick: (pool, count) => pool.take(count).toList(),
    );

void main() {
  test('every question is fair across many rounds of the bundled words', () {
    final known = wordEntries.map((entry) => entry.word.trim().toUpperCase()).toSet();
    for (var seed = 0; seed < 40; seed++) {
      for (final rating in const [1.0, 4.0, 7.0]) {
        final round = _round(wordEntries, seed: seed, rating: rating);
        expect(round, isNotEmpty);
        expect(round.map((q) => q.word).toSet(), hasLength(round.length),
            reason: 'a spelling only comes up once per round');
        for (final question in round) {
          expect(known, contains(question.word));
          expect(question.options, contains(question.answer));
          expect(question.options.toSet(), hasLength(question.options.length));
          for (final option in question.options.where((o) => o != question.answer)) {
            expect(known, isNot(contains(question.masked.replaceFirst('_', option))),
                reason: '$option would spell another real word in ${question.masked}');
          }
          final clueWords = RegExp(r'\p{L}+', unicode: true)
              .allMatches(question.hint)
              .map((match) => foldMizo(match[0]!));
          expect(clueWords, isNot(contains(foldMizo(question.word))),
              reason: 'the clue “${question.hint}” names ${question.word}');
        }
      }
    }
  });

  test('aw, ch and ng are blanked as whole letters', () {
    final answers = {
      for (var seed = 0; seed < 30; seed++) ..._round([_word('w.chaw', 'chaw', gloss: 'rice')], seed: seed).map((q) => q.answer),
    };
    expect(answers, {'CH', 'AW'});
  });

  test('a letter that makes another real word is never offered', () {
    final catalog = [
      _word('w.bawng', 'bâwng', gloss: 'cow'),
      _word('w.bawng2', 'bawng', gloss: 'other'),
    ];
    for (var seed = 0; seed < 30; seed++) {
      for (final question in _round(catalog, seed: seed, rating: 7)) {
        if (question.word == 'BÂWNG' && question.answer == 'ÂW') {
          expect(question.options, isNot(contains('AW')));
        }
      }
    }
  });

  test('clues are English early on and Mizo, answer hidden, later', () {
    final catalog = [_word('w.thleng', 'thlêng', meaning: 'Thlêng chu ei dawn atana hmanraw a ni.', gloss: 'plate')];
    expect(_round(catalog).single.hint, 'plate');
    expect(_round(catalog, rating: 4).single.hint, '…… chu ei dawn atana hmanraw a ni.');
  });

  test('an English gloss that is only the word falls back to Mizo', () {
    final jam = _word('w.jam', 'jam', meaning: 'Thei chi hrang hrang atanga siam thil tui.', gloss: 'jam');
    expect(_round([jam]).single.hint, 'Thei chi hrang hrang atanga siam thil tui.');
    final mizo = _word('w.mizo', 'Mizo', meaning: 'Hnam hming.', gloss: 'Mizo (the people/identity)');
    expect(_round([mizo]).single.hint, '…… (the people/identity)');
  });

  test('the built-in fallback hides its answers too', () {
    final round = _round(const <WordEntry>[]);
    final teacher = round.firstWhere((q) => q.word == 'ZIRTÎRTU');
    expect(teacher.hint, isNot(contains('zirtîrtu')));
    expect(round.firstWhere((q) => q.answer == 'AW').word, 'KHAWVÊL');
  });
}
