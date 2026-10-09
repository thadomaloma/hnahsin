import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/mizo_lexicon.dart';

void main() {
  test('the bundled word list holds Mizo words, not English ones', () {
    MizoLexicon.use(File('assets/mizo_words.txt').readAsLinesSync().where((line) => line.isNotEmpty));
    addTearDown(() => MizoLexicon.use(const <String>[]));

    expect(MizoLexicon.length, greaterThan(5000));
    for (final word in ['thian', 'lehkhabu', 'nula', 'ṭha', 'ṭhian']) {
      expect(MizoLexicon.contains(word), isTrue, reason: word);
    }
    for (final word in ['electric', 'the', 'and', 'of']) {
      expect(MizoLexicon.contains(word), isFalse, reason: word);
    }
  });
}
