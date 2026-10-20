import 'dart:typed_data';

import '../features/content_sync/domain/delivery_models.dart';
import '../l10n/translations.dart';
import 'app_text.dart';

/// Text for one game, in simple English. Every field can be overridden per game on the
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
      subtitle: 'Match pictures and words',
      prompt: 'What is this?',
      hint: 'Hint: it means “{gloss}”.',
      instructions: <String>[
        'Look at the picture and pick its name.',
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
        'Swipe across a word, or tap its letters one by one.',
        'Find all five words.'
      ]),
  'word_groups': GameCopy(
      title: 'Word Groups',
      subtitle: 'Sort 16 Mizo words into 4 groups',
      prompt: 'Find four groups of four.',
      hint: 'Hint: one group is “{gloss}”.',
      instructions: <String>[
        'Pick four words that belong together and tap Submit.',
        'Find all four groups. You can make four mistakes.'
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
  'sentence_builder': GameCopy(
      title: 'Sentence Builder',
      subtitle: 'Put the word tiles in order',
      prompt: 'BUILD THIS MEANING',
      hint: 'We placed the first word for you.',
      instructions: <String>[
        'Read the English meaning and pick the Mizo word tiles.',
        'Put them in a natural order, then check.'
      ]),
  'odd_one_out': GameCopy(
      title: 'Odd One Out',
      subtitle: 'Find the word that doesn\'t belong',
      prompt: 'Which word doesn\'t belong?',
      hint: 'Hint: three of them are {gloss}.',
      instructions: <String>[
        'Read the four words. Three of them are the same kind of thing.',
        'Pick the one that doesn\'t belong.'
      ]),
  'common': GameCopy(correctFeedback: 'Correct!', retryFeedback: 'Try again'),
};

/// The games' English text keyed as translations key it
/// (game.<id>.<field>, steps as step1, step2…), for checking lib/l10n.
Map<String, String> englishGameTexts() => {
      for (final MapEntry(key: id, value: copy)
          in _defaultGameCopy.entries) ...{
        if (copy.title.isNotEmpty) 'game.$id.title': copy.title,
        if (copy.subtitle.isNotEmpty) 'game.$id.subtitle': copy.subtitle,
        if (copy.prompt.isNotEmpty) 'game.$id.prompt': copy.prompt,
        if (copy.hint.isNotEmpty) 'game.$id.hint': copy.hint,
        for (final (i, step) in copy.instructions.indexed)
          'game.$id.step${i + 1}': step,
        if (copy.correctFeedback.isNotEmpty)
          'game.$id.correctFeedback': copy.correctFeedback,
        if (copy.retryFeedback.isNotEmpty)
          'game.$id.retryFeedback': copy.retryFeedback,
      },
    };

/// App-wide game text: built-in defaults overridden by the reviewed
/// content Sheet text from the active content pack.
abstract final class GameText {
  static Map<String, DeliveredGameCopy> _delivered =
      const <String, DeliveredGameCopy>{};

  static void update(Map<String, DeliveredGameCopy> delivered) =>
      _delivered = delivered;

  /// [gameId]'s text in [AppText.locale]. The Sheet edits the English;
  /// other languages use their translation (game.<id>.<field> in lib/l10n),
  /// field by field, or the English where a field has none.
  static GameCopy of(String gameId) {
    final english = _defaultGameCopy[gameId] ?? const GameCopy();
    if (AppText.locale == 'en') return english._override(_delivered[gameId]);
    final strings = translations[AppText.locale] ?? const <String, String>{};
    String field(String name, String fallback) {
      final text = strings['game.$gameId.$name'];
      return text != null &&
              appTextPlaceholders(text).length ==
                  appTextPlaceholders(fallback).length &&
              appTextPlaceholders(text)
                  .containsAll(appTextPlaceholders(fallback))
          ? text
          : fallback;
    }

    return GameCopy(
      title: field('title', english.title),
      subtitle: field('subtitle', english.subtitle),
      prompt: field('prompt', english.prompt),
      hint: field('hint', english.hint),
      instructions: [
        for (final (i, step) in english.instructions.indexed)
          field('step${i + 1}', step),
      ],
      correctFeedback: field('correctFeedback', english.correctFeedback),
      retryFeedback: field('retryFeedback', english.retryFeedback),
    );
  }

  static GameCopy get common => of('common');
}

/// Verified picture bytes (by SHA-256) for words with an uploaded picture.
abstract final class WordImages {
  static Map<String, Uint8List> _bytes = const <String, Uint8List>{};

  static void update(Map<String, Uint8List> bytes) => _bytes = bytes;

  static Uint8List? of(String? checksum) =>
      checksum == null ? null : _bytes[checksum];
}
