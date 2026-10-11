import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/content_sync/domain/delivery_models.dart';
import 'package:hnahsin/src/data.dart';
import 'package:hnahsin/src/word_sentences.dart';

WordEntry _word(String id, String word, String gloss) => WordEntry(
      id: id,
      word: word,
      meaningMizo: 'Awmzia',
      englishGloss: gloss,
      exampleMizo: 'Entirna.',
      emoji: '',
      category: WordCategory.khawvel,
    );

DeliveredSentence _sentence(String id, String text) => DeliveredSentence(
    id: id, textMizo: text, englishSupport: 'English', difficulty: 2);

void main() {
  final ui = _word('word.ui', 'ui', 'dog');
  final ka = _word('word.ka', 'ka', 'mouth');
  final in1 = _word('word.in', 'in', 'house');
  final in2 = _word('word.in-2', 'in', 'drink');
  final tlangval = _word('word.tlangval', 'tlângval', 'young man');

  test('a word card shows sentences using its word, shortest first', () {
    final index = SentenceIndex([
      _sentence('s.1', 'Ka ui chu a lian hle mai.'),
      _sentence('s.2', 'Ui a tap.'),
      _sentence('s.3', 'Uite chu a te.'),
      _sentence('s.4', 'Tlangval chu a lo kal.'),
    ], [
      ui,
      tlangval
    ]);

    expect(index.sentencesUsing(ui).map((s) => s.id), ['s.2', 's.1'],
        reason: 'whole words only, so “Uite” is not “ui”');
    expect(index.sentencesUsing(tlangval).map((s) => s.id), ['s.4'],
        reason: 'accents are optional');
  });

  test('no sentences for a spelling with two meanings or a grammar word', () {
    final index = SentenceIndex([
      for (var i = 0; i <= SentenceIndex.tooCommon; i++)
        _sentence('s.$i', 'Ka in a ni.'),
    ], [
      ka,
      in1,
      in2
    ]);

    expect(index.sentencesUsing(in1), isEmpty);
    expect(index.sentencesUsing(ka), isEmpty);
  });

  test('the gap is the sentence\'s least used word', () {
    final sentences = [
      _sentence('s.1', 'Ka ui chu tlangval a ni.'),
      _sentence('s.2', 'Ka ui a tap.'),
      _sentence('s.3', 'Ka tap.'),
    ];
    final index = SentenceIndex(sentences, [ka, ui, tlangval]);

    expect(index.gapWordIn(sentences[0]), tlangval);
    expect(index.gapWordIn(sentences[1]), ui);
    expect(index.gapWordIn(_sentence('s.4', 'A tap.')), isNull);
  });
}
