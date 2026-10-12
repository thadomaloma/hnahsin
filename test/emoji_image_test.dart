import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/emoji_assets.dart';

void main() {
  test('emoji the app carries resolve to their picture, with or without FE0F', () {
    expect(emojiAsset('🐕'), 'assets/emoji/1f415.webp');
    expect(emojiAsset('🌬️'), emojiAsset('🌬'));
    expect(emojiAsset('🪿'), isNotNull, reason: 'a newer emoji that old phones lack');
  });

  testWidgets('a carried emoji is a picture, a pair sits side by side, '
      'and anything else is the phone\'s emoji', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Column(children: [
      EmojiImage('🐕', size: 40),
      EmojiImage('🐕🗣️', size: 40),
      EmojiImage('🪢', size: 40),
    ])));
    expect(find.byType(Image), findsNWidgets(3));
    expect(find.text('🪢'), findsOneWidget);
  });
}
