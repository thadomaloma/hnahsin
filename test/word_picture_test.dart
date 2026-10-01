import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thumal_quest/src/data.dart';
import 'package:thumal_quest/src/widgets.dart';

WordEntry _word(String id, String word, {String emoji = ''}) => WordEntry(
      id: id,
      word: word,
      meaningMizo: 'Awmzia',
      englishGloss: 'Gloss',
      exampleMizo: 'Entirna.',
      emoji: emoji,
      category: WordCategory.khawvel,
    );

void main() {
  test('illustrations resolve by stable id so homonyms get their own picture', () {
    expect(illustrationFor(_word('word.fu', 'Fu')), 'assets/illustrations/word.fu.png');
    expect(illustrationFor(_word('word.fu-2', 'Fu')), 'assets/illustrations/word.fu-2.png');
  });

  test('words without an emoji or illustration are not picture-game words', () {
    expect(hasWordPicture(_word('word.tlawmngai', 'Tlawmngai')), isFalse);
    expect(hasWordPicture(_word('word.ar-2', 'Âr', emoji: '🐔')), isTrue);
    expect(hasWordPicture(_word('word.favah', 'Favah')), isTrue);
  });

  testWidgets('a word without a picture shows its topic icon', (tester) async {
    await tester.pumpWidget(MaterialApp(home: WordPicture(entry: _word('word.tlawmngai', 'Tlawmngai'))));
    expect(find.byIcon(categoryIcon(WordCategory.khawvel)), findsOneWidget);
    expect(find.text('T'), findsNothing);
  });
}
