import 'dart:typed_data';

import '../features/content_sync/domain/delivery_models.dart';
import 'app_text.dart';

/// Text for one game. Every field can be overridden per game on the
/// content Sheet's “Game text” tab; anything left empty there falls back to
/// these built-in defaults.
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
      subtitle: 'Milem leh thumal zawm',
      prompt: 'Milem hming hi eng nge?',
      hint: 'Ṭanpuina: English-ah “{gloss}” tihna a ni.',
      instructions: <String>[
        'Milem en la, a hming Mizo-in thlang rawh.',
        'I chhan zawhah a awmzia leh entîrna chhiar rawh.'
      ]),
  'spelling': GameCopy(
      title: 'Spelling',
      subtitle: 'Hawrawp ruak dah khat',
      prompt: 'Hawrawp remchâng thlang rawh',
      hint: 'Ṭanpuina: Hawrawp dik chu “{answer}” a ni.',
      instructions: <String>[
        'Thumal leh a kawhhmuhna chhiar rawh.',
        'Hawrawp ruak dah khat tûr thlang rawh.'
      ]),
  'word_search': GameCopy(
      title: 'Word Search',
      subtitle: 'Thumal zawn',
      hint: 'Ṭanpuina: “{word}” tih thumal hi zawng rawh.',
      instructions: <String>[
        'Hawrawp bul hnai te indawtin hmet rawh.',
        'Thumal panga zawng hmu vek rawh.'
      ]),
  'word_chain': GameCopy(
      title: 'Word Chain',
      subtitle: 'Thumal inzawm tîr',
      hint: 'Ṭanpuina: {word}',
      instructions: <String>[
        'Thumal tawpna hawrawp en rawh.',
        'Chu hawrawp hmangin thumal thar bulṭan rawh.'
      ]),
  'tawng_upa': GameCopy(
      title: 'Tawng Upa',
      subtitle: 'Mizo tawng upa awmzia',
      prompt: '“{word}” tih hian eng nge a kawh?',
      hint: 'Ṭanpuina: Chhanna dik chu “{first}…” tiin a bulṭan.',
      instructions: <String>[
        'Tawng upa leh a zawhna chhiar rawh.',
        'A awmzia dik thlang la, hrilhfiahna chhiar rawh.'
      ]),
  'crossword': GameCopy(
      title: 'Crossword',
      subtitle: 'Kawhhmuhna aṭanga thumal ziak',
      hint: 'Ṭanpuina: Box pakhat kan dah khat sak e.',
      instructions: <String>[
        'Box pakhat hmet la, a kawhhmuhna chhiar rawh. Vawi hnih i hmet chuan vang leh dung a inthlak.',
        'Hawrawp ziak rawh. Thumal i ziak kim veleh a dik em tih kan en nghal ang.'
      ]),
  'thumal_kawp': GameCopy(
      title: 'Thumal Kawp',
      subtitle: 'Card kawp zawn',
      prompt:
          'Card pahnih let la, thumal leh a kawp zawng rawh. A kawp i hmuh tawh chu theihnghilh suh!',
      instructions: <String>[
        'Card pahnih let la, thumal leh a milem emaw a awmzia kawp zawng rawh.',
        'Card i hmuh tawh theihnghilh suh — a kawp i hriat tawh chu hmu nghal rawh.'
      ]),
  'sentence_builder': GameCopy(
      title: 'Sentence Builder',
      subtitle: 'Thumal rem khâwm',
      prompt: 'HE AWMZIA HI SIAM RAWH',
      hint: 'Sentence thumal hmasa kan dah sak e.',
      instructions: <String>[
        'English awmzia chhiar la, Mizo thumal te thlang rawh.',
        'A indawt dik takin rem khâwm la, en rawh.'
      ]),
  'common':
      GameCopy(correctFeedback: 'A dik e!', retryFeedback: 'Tum leh rawh'),
};

/// The games' text for [AppLanguage.english]. The Sheet's game text is
/// Mizo, so it doesn't apply here.
const _englishGameCopy = <String, GameCopy>{
  'picture_match': GameCopy(
      title: 'Picture Match',
      subtitle: 'Match pictures and words',
      prompt: 'What is this called in Mizo?',
      hint: 'Hint: it means “{gloss}” in English.',
      instructions: <String>[
        'Look at the picture and pick its Mizo name.',
        'After you answer, read the meaning and the example.'
      ]),
  'spelling': GameCopy(
      title: 'Spelling',
      subtitle: 'Fill in the missing letter',
      prompt: 'Pick the missing letter',
      hint: 'Hint: the letter is “{answer}”.',
      instructions: <String>[
        'Read the word and its clue.',
        'Pick the letter that fills the gap.'
      ]),
  'word_search': GameCopy(
      title: 'Word Search',
      subtitle: 'Find words in the grid',
      hint: 'Hint: look for “{word}”.',
      instructions: <String>[
        'Tap letters next to each other, in order.',
        'Find all five words.'
      ]),
  'word_chain': GameCopy(
      title: 'Word Chain',
      subtitle: 'Link words together',
      hint: 'Hint: {word}',
      instructions: <String>[
        'Look at the last letter of the word.',
        'Type a new word that starts with it.'
      ]),
  'tawng_upa': GameCopy(
      title: 'Tawng Upa',
      subtitle: 'What old Mizo sayings mean',
      prompt: 'What does “{word}” mean?',
      hint: 'Hint: the answer starts with “{first}…”.',
      instructions: <String>[
        'Read the saying and the question.',
        'Pick the right meaning, then read the explanation.'
      ]),
  'crossword': GameCopy(
      title: 'Crossword',
      subtitle: 'Write words from clues',
      hint: 'Hint: we filled in one box for you.',
      instructions: <String>[
        'Tap a box and read its clue. Tap it again to switch across and down.',
        'Type the letters. We check each word as soon as it is full.'
      ]),
  'thumal_kawp': GameCopy(
      title: 'Thumal Kawp',
      subtitle: 'Memory card pairs',
      prompt:
          'Turn over two cards to find a word and its pair. Remember the cards you have seen!',
      instructions: <String>[
        'Turn over two cards to match a word with its picture or meaning.',
        'Remember every card you have seen — match it as soon as you find its pair.'
      ]),
  'sentence_builder': GameCopy(
      title: 'Sentence Builder',
      subtitle: 'Put the word tiles in order',
      prompt: 'BUILD THIS MEANING',
      hint: 'We placed the first word for you.',
      instructions: <String>[
        'Read the English meaning and pick the Mizo word tiles.',
        'Put them in a natural order, then check.'
      ]),
  'common': GameCopy(correctFeedback: 'Correct!', retryFeedback: 'Try again'),
};

/// App-wide game text: built-in defaults overridden by the reviewed
/// content Sheet text from the active content pack.
abstract final class GameText {
  static Map<String, DeliveredGameCopy> _delivered =
      const <String, DeliveredGameCopy>{};

  static void update(Map<String, DeliveredGameCopy> delivered) =>
      _delivered = delivered;

  static GameCopy of(String gameId) => AppText.language == AppLanguage.english
      ? _englishGameCopy[gameId] ?? const GameCopy()
      : (_defaultGameCopy[gameId] ?? const GameCopy())
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
