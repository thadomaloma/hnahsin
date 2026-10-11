import '../features/content_sync/domain/delivery_models.dart';
import 'data.dart';
import 'meaning_round.dart' show blankOutWord;

/// Which of the content Sheet's sentences use which catalog words, so a
/// word card can show the word in real sentences and Sentence Builder can
/// blank a word out of one.
class SentenceIndex {
  SentenceIndex(List<DeliveredSentence> sentences, List<WordEntry> catalog) {
    final byToken = <String, List<DeliveredSentence>>{};
    for (final sentence in sentences) {
      for (final token in _tokens(sentence.textMizo).toSet()) {
        (byToken[token] ??= <DeliveredSentence>[]).add(sentence);
      }
    }
    final spellings = <String, int>{};
    for (final entry in catalog) {
      final spelling = foldMizo(entry.word.trim());
      spellings[spelling] = (spellings[spelling] ?? 0) + 1;
    }
    for (final entry in catalog) {
      final first = _tokens(entry.word).firstOrNull;
      if (first == null) continue;
      final found = [
        for (final sentence in byToken[first] ?? const <DeliveredSentence>[])
          if (blankWholeWord(sentence.textMizo, entry.word) != null) sentence,
      ];
      if (found.isEmpty) continue;
      _uses[entry.id] = found;
      for (final sentence in found) {
        (_wordsIn[sentence.id] ??= <WordEntry>[]).add(entry);
      }
      if (spellings[foldMizo(entry.word.trim())]! > 1) _homonyms.add(entry.id);
    }
  }

  /// A word in more sentences than this is a little grammar word (“ka”,
  /// “lo”, “ni”) in most of them, whatever the catalog says it means.
  static const tooCommon = 20;

  final _uses = <String, List<DeliveredSentence>>{};
  final _wordsIn = <String, List<WordEntry>>{};
  final _homonyms = <String>{};

  static final _letters = RegExp(r'\p{L}+', unicode: true);
  static Iterable<String> _tokens(String text) =>
      _letters.allMatches(foldMizo(text)).map((match) => match[0]!);

  bool _common(WordEntry entry) => (_uses[entry.id]?.length ?? 0) > tooCommon;

  /// Up to [count] sentences that use [entry]'s word, shortest first. None
  /// for a spelling the catalog has more than once (“in” house or drink),
  /// since a sentence may use the other meaning, nor for grammar words.
  List<DeliveredSentence> sentencesUsing(WordEntry entry, {int count = 2}) {
    if (_homonyms.contains(entry.id) || _common(entry)) {
      return const <DeliveredSentence>[];
    }
    return ([...?_uses[entry.id]]
          ..sort((a, b) => a.textMizo.length.compareTo(b.textMizo.length)))
        .take(count)
        .toList();
  }

  /// The word to blank out of [sentence]: the catalog word it uses that
  /// the fewest sentences use (the one carrying its meaning rather than
  /// its grammar), the longer one on a tie.
  WordEntry? gapWordIn(DeliveredSentence sentence) {
    final words = (_wordsIn[sentence.id] ?? const <WordEntry>[])
        .where((entry) => !_common(entry))
        .toList();
    if (words.isEmpty) return null;
    words.sort((a, b) {
      final uses = _uses[a.id]!.length.compareTo(_uses[b.id]!.length);
      return uses != 0 ? uses : b.word.length.compareTo(a.word.length);
    });
    return words.first;
  }
}

/// [text] with [word] blanked out (see [blankOutWord]), or null when the
/// word only appears joined to another: “custom-te”'s “te” or “pate’n”'s
/// “pate” are part of a longer word, not the word itself.
String? blankWholeWord(String text, String word) {
  final blanked = blankOutWord(text, word);
  if (blanked == null) return null;
  return _joined.hasMatch(blanked) ? null : blanked;
}

final _joined = RegExp('[-‐’\'`]____|____[-‐’\'`]');

/// The English words that carry [gloss]'s meaning: “To jump over; to
/// hurdle” is jump, hurdle. Two words sharing one may both fit a sentence.
Set<String> meaningWords(String gloss) => {
      for (final match in RegExp('[a-z]{3,}').allMatches(gloss.toLowerCase()))
        if (!_glossFiller.contains(match[0])) match[0]!,
    };

const _glossFiller = {
  'the',
  'and',
  'for',
  'with',
  'from',
  'into',
  'over',
  'out',
  'off',
  'one',
  'oneself',
  'someone',
  'something',
  'thing',
  'things',
  'very',
  'make',
  'get',
  'have',
  'also',
  'not',
  'are',
  'its',
  'his',
  'her',
  'their',
  'about',
  'kind',
  'form',
  'modified',
  'person',
  'who',
  'which',
  'that',
  'this',
  'esp',
};
