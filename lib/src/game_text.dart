import 'dart:typed_data';

import '../features/content_sync/domain/delivery_models.dart';

/// Mizo text for one game. Every field can be overridden per game in
/// Editorial Studio (content type "Game text"); anything left empty there
/// falls back to these built-in defaults, which mirror
/// `content/game_copy/default_game_copy.json`.
class GameCopy {
  const GameCopy({
    this.title = '',
    this.subtitle = '',
    this.instructions = const <String>[],
    this.prompt = '',
    this.hint = '',
    this.correctFeedback = '',
    this.retryFeedback = '',
  });

  final String title;
  final String subtitle;
  final List<String> instructions;
  final String prompt;
  final String hint;
  final String correctFeedback;
  final String retryFeedback;

  GameCopy _override(DeliveredGameCopy? delivered) {
    if (delivered == null) return this;
    String pick(String key, String fallback) =>
        delivered.fields[key] ?? fallback;
    return GameCopy(
      title: pick('title', title),
      subtitle: pick('subtitle', subtitle),
      instructions: delivered.instructions.isEmpty
          ? instructions
          : delivered.instructions,
      prompt: pick('prompt', prompt),
      hint: pick('hint', hint),
      correctFeedback: pick('correct_feedback', correctFeedback),
      retryFeedback: pick('retry_feedback', retryFeedback),
    );
  }
}

/// Fills `{word}`, `{gloss}`, `{answer}` and `{first}` placeholders.
String fillGameText(String template,
        {String word = '', String gloss = '', String answer = ''}) =>
    template
        .replaceAll('{word}', word)
        .replaceAll('{gloss}', gloss)
        .replaceAll('{answer}', answer)
        .replaceAll('{first}', answer.isEmpty ? '' : answer.substring(0, 1));

const _defaultGameCopy = <String, GameCopy>{
  'picture_match': GameCopy(
      title: 'Picture Match',
      subtitle: 'Thlalak leh thumal zawm',
      prompt: 'He thlalak hming hi eng nge?',
      hint: 'Hint: English-ah “{gloss}” tihna a ni.',
      instructions: <String>[
        'Picture en la, a hming Mizo thlang rawh.',
        'Chhanna zawhah awmzia leh sentence chhiar rawh.'
      ]),
  'spelling': GameCopy(
      title: 'Spelling',
      subtitle: 'Hawrawp ruak dah khat',
      prompt: 'Hawrawp remchâng thlang rawh',
      hint: 'Hint: Hawrawp dik lo pahnih kan paih e.',
      instructions: <String>[
        'Thumal leh clue chhiar rawh.',
        'Hawrawp ruak dahtu tûr thlang rawh.'
      ]),
  'word_search': GameCopy(
      title: 'Word Search',
      subtitle: 'Grid-ah thumal zawn',
      hint: 'Hint: “{word}” chu box sen atangin a inṭan.',
      instructions: <String>[
        'Letter bul hnai indawtin tap rawh.',
        'Thumal pangnga zawng hmu vek rawh.'
      ]),
  'word_chain': GameCopy(
      title: 'Word Chain',
      subtitle: 'Thumal inzawm tîr',
      hint: 'Hint: {word}',
      instructions: <String>[
        'Thumal tawpna unit en rawh.',
        'Chumi unit hmanga thumal thar bulṭan rawh.'
      ]),
  'tawng_upa': GameCopy(
      title: 'Tawng Upa',
      subtitle: 'Awmzia hriatna quiz',
      prompt: '“{word}” tih hian eng nge a kawh?',
      hint: 'Hint: Chhanna dik lo pahnih kan paih e.',
      instructions: <String>[
        'Thumal leh zawhna chhiar rawh.',
        'Awmzia dik thlang la, hrilhfiahna chhiar rawh.'
      ]),
  'crossword': GameCopy(
      title: 'Crossword',
      subtitle: 'Clue atanga thumal ziak',
      hint: 'Hint: Box pakhat kan dah khat sak e.',
      instructions: <String>[
        'Box pakhat tap la, a clue chhiar rawh. Vawi hnih i tap chuan across leh down a inthlak.',
        'Keyboard hmangin hawrawp ziak rawh. Thumal i ziak kim veleh a dik em tih kan en nghal ang.'
      ]),
  'thumal_kawp': GameCopy(
      title: 'Thumal Kawp',
      subtitle: 'Memory card kawp zawn',
      prompt:
          'Card pahnih let la, thumal leh a kawp zawng rawh. A kawp i hmuh tawh chu theihnghilh suh!',
      instructions: <String>[
        'Card pahnih let la, thumal leh a picture emaw awmzia kawp zawng rawh.',
        'Card i hmuh tawh theihnghilh suh — a kawp i hriat tawh chu hmu nghal rawh.'
      ]),
  'sentence_builder': GameCopy(
      title: 'Sentence Builder',
      subtitle: 'Thumal tiles rem khâwm',
      prompt: 'BUILD THIS MEANING',
      hint: 'Sentence thumal hmasa kan dah sak e.',
      instructions: <String>[
        'English meaning chhiar la, Mizo thumal tiles thlang rawh.',
        'Sentence natural taka a indawtin rem khâwm la, check rawh.'
      ]),
  'common':
      GameCopy(correctFeedback: 'A dik e!', retryFeedback: 'Tum leh rawh'),
};

/// App-wide game text: built-in defaults overridden by the reviewed
/// Editorial Studio text from the active content pack.
abstract final class GameText {
  static Map<String, DeliveredGameCopy> _delivered =
      const <String, DeliveredGameCopy>{};

  static void update(Map<String, DeliveredGameCopy> delivered) =>
      _delivered = delivered;

  static GameCopy of(String gameId) =>
      (_defaultGameCopy[gameId] ?? const GameCopy())
          ._override(_delivered[gameId]);

  static GameCopy get common => of('common');
}

/// Verified picture bytes (by SHA-256) for words with an uploaded picture.
abstract final class WordImages {
  static Map<String, Uint8List> _bytes = const <String, Uint8List>{};

  static void update(Map<String, Uint8List> bytes) => _bytes = bytes;

  static Uint8List? of(String? checksum) =>
      checksum == null ? null : _bytes[checksum];
}
