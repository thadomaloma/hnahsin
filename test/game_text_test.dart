import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/content_sync/domain/delivery_models.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/game_text.dart';

void main() {
  tearDown(() {
    GameText.update(const {});
    WordImages.update(const {});
  });

  test('built-in game text is used until Studio overrides a field', () {
    expect(GameText.of('picture_match').prompt, 'He thlalak hming hi eng nge?');
    expect(GameText.common.correctFeedback, 'A dik e!');

    GameText.update({
      'picture_match': const DeliveredGameCopy(
        gameId: 'picture_match',
        fields: {'prompt': 'Hei hi eng nge?'},
      ),
    });

    expect(GameText.of('picture_match').prompt, 'Hei hi eng nge?');
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
