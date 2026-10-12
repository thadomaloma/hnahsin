import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/game_words.dart';
import 'package:hnahsin/src/odd_one_out.dart';
import 'package:hnahsin/src/word_groups.dart';

WordEntry _word(String id, String word, String gloss,
        {String emoji = '', WordCategory category = WordCategory.nungcha}) =>
    WordEntry(
      id: id,
      word: word,
      meaningMizo: 'Awmzia',
      englishGloss: gloss,
      exampleMizo: 'Entirna.',
      emoji: emoji,
      category: category,
      gameModes: const {'picture_match'},
    );

void main() {
  final catalog = [
    _word('w.ui', 'ui', 'dog', emoji: '🐕'),
    _word('w.vawk', 'vawk', 'pig', emoji: '🐖'),
    _word('w.zawhte', 'zawhte', 'cat', emoji: '🐈'),
    _word('w.sava', 'sava', 'bird', emoji: '🐦'),
    _word('w.sangha', 'sangha', 'fish', emoji: '🐟'),
    _word('w.sa', 'sa', 'meat', emoji: '🥩', category: WordCategory.khawvel),
    _word('w.sa2', 'sâ', 'to build'),
  ];
  List<String> wrong(PictureMatchQuestion q) =>
      q.options.where((o) => o != q.entry.word).toList();

  test('Picture Match gets trickier by level', () {
    PictureMatchQuestion at(int level, WordEntry entry) =>
        pictureMatchQuestion(entry, catalog,
            rating: level.toDouble(),
            random: Random(1),
            isRealWord: (_) => false);

    expect(at(1, catalog[0]).options, hasLength(3));
    // Levels 3–4: a real word spelt almost the same.
    expect(wrong(at(3, catalog[5])), contains('sâ'));
    // Levels 5–6: the name, and four different pictures to pick from.
    final pictures = at(5, catalog[0]);
    expect(pictures.asksForPicture, isTrue);
    expect(pictures.pictures!.map(pictureKey).toSet(), hasLength(4));
    expect(pictures.options, contains('ui'));
    // Level 7: misspellings too, never the word itself.
    final hard = at(7, catalog[2]);
    expect(hard.options, hasLength(4));
    expect(
        wrong(hard).where((o) => !catalog.any((w) => w.word == o)), isNotEmpty);
  });

  test('misspellings use the usual slips first and are never real words', () {
    final slips = misspellings('kaikuang',
        random: Random(1), isRealWord: (w) => w == 'kaikuan');
    expect(slips, isNot(contains('kaikuan')));
    expect(slips, isNot(contains('kaikuang')));
    // The dropped h comes before any swapped letters.
    expect(
        misspellings('hmarcha', random: Random(1), isRealWord: (_) => false)
            .first,
        'marcha');
  });

  test('Odd One Out: three of a group and one from another', () {
    WordEntry member(String id) => _word(id, id.split('.').last, id);
    final words = [
      for (final group in wordGroups)
        for (final id in group.wordIds.take(4)) member(id),
    ];
    for (final level in [1, 5]) {
      final round = buildOddOneOutRound(
          catalog: words,
          rating: level.toDouble(),
          random: Random(level),
          pick: (pool, count) => pool.take(count).toList());
      expect(round, hasLength(6));
      for (final q in round) {
        expect(q.options, hasLength(4));
        expect(q.options, contains(q.odd));
        expect(q.group.wordIds, isNot(contains(q.odd.id)));
        expect(
            q.options
                .where((o) => o != q.odd)
                .every((o) => q.group.wordIds.contains(o.id)),
            isTrue);
        if (level == 1) expect(q.oddGroup.family, isNot(q.group.family));
      }
    }
  });
}
