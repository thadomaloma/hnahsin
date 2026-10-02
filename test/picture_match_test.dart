import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/game_words.dart';

WordEntry _word(String id, String word, String gloss, String emoji) =>
    WordEntry(
      id: id,
      word: word,
      meaningMizo: '$word awmzia.',
      englishGloss: gloss,
      exampleMizo: '$word hi a ni.',
      emoji: emoji,
      category: WordCategory.nunphung,
    );

void main() {
  final khuang = _word('word.khuang', 'khuang', 'Drum', '🥁');
  final catalog = [
    khuang,
    _word('word.khaum', 'khaûm', 'Drum', '🥁'),
    _word('word.khuangpui', 'khuangpui', 'Big drum', '🥁'),
    _word('word.darkhuang', 'darkhuang', 'Gong / drum', '🔔'),
    _word('word.in', 'in', 'House', '🏠'),
    _word('word.ui', 'ui', 'Dog', '🐕'),
    _word('word.ni', 'ni', 'Sun', '☀️'),
    _word('word.thla', 'thla', 'Moon', '🌙'),
  ];

  test('a wrong answer never shows the same picture or means the same', () {
    for (var seed = 0; seed < 50; seed += 1) {
      final wrong = pictureMatchDistractors(khuang, catalog,
          rating: 4, random: Random(seed));

      // Not khaûm or khuangpui (🥁), nor darkhuang (also “drum”).
      expect(wrong, hasLength(3));
      expect(wrong.map((word) => word.id),
          everyElement(isIn(['word.in', 'word.ui', 'word.ni', 'word.thla'])));
    }
  });

  test('pictureKey tells apart words that look the same on screen', () {
    expect(pictureKey(catalog[0]), pictureKey(catalog[1]));
    expect(pictureKey(catalog[0]), isNot(pictureKey(catalog[4])));
  });
}
