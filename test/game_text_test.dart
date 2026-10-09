import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/src/app_text.dart';
import 'package:hnahsin/l10n/translations.dart';
import 'package:hnahsin/features/content_sync/domain/delivery_models.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/game_text.dart';

void main() {
  tearDown(() {
    GameText.update(const {});
    WordImages.update(const {});
  });

  test('built-in game text is used until Studio overrides a field', () {
    expect(GameText.of('picture_match').prompt, 'What is this?');
    expect(GameText.common.correctFeedback, 'Correct!');

    GameText.update({
      'picture_match': const DeliveredGameCopy(
        gameId: 'picture_match',
        fields: {'prompt': 'Name this'},
      ),
    });

    expect(GameText.of('picture_match').prompt, 'Name this');
    expect(GameText.of('picture_match').title, 'Picture Match', reason: 'untouched fields keep defaults');
    expect(GameText.of('picture_match').instructions, isNotEmpty);
  });

  test('placeholders are filled', () {
    expect(fillGameText('“{word}” tih hian eng nge a kawh?', word: 'Sakei'), '“Sakei” tih hian eng nge a kawh?');
    expect(fillGameText('Chhanna chu “{first}…”', answer: 'Hnial'), 'Chhanna chu “H…”');
  });

  test('a word with an uploaded picture becomes a picture-game word', () {
    const entry = WordEntry(
      id: 'word.favah',
      word: 'Favah2',
      meaningMizo: 'Buh atna',
      englishGloss: 'sickle',
      exampleMizo: 'Favah hmangin kan at.',
      emoji: '',
      category: WordCategory.nunphung,
      imageChecksum: 'abc',
    );
    expect(hasWordPicture(entry.copyWithoutIllustration), isFalse);
    WordImages.update({'abc': Uint8List.fromList([1, 2, 3])});
    expect(hasWordPicture(entry.copyWithoutIllustration), isTrue);
  });
  test('every language has every game text, with its placeholders', () {
    addTearDown(() => AppText.locale = 'en');
    final english = englishGameTexts();
    for (final MapEntry(key: code, value: strings) in translations.entries) {
      for (final MapEntry(:key, :value) in english.entries) {
        expect(strings[key], isNotNull, reason: '$code is missing $key');
        expect(appTextPlaceholders(strings[key]!), appTextPlaceholders(value), reason: '$code $key');
      }
    }
    AppText.locale = 'ja';
    expect(GameText.of('picture_match').prompt, translations['ja']!['game.picture_match.prompt']);
    expect(GameText.common.correctFeedback, translations['ja']!['game.common.correctFeedback']);
  });
}

extension on WordEntry {
  /// Same word under an ID with no bundled illustration.
  WordEntry get copyWithoutIllustration => WordEntry(
        id: 'word.test-only',
        word: word,
        meaningMizo: meaningMizo,
        englishGloss: englishGloss,
        exampleMizo: exampleMizo,
        emoji: emoji,
        category: category,
        imageChecksum: imageChecksum,
      );

}
