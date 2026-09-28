import 'dart:math';

class SentenceTile {
  const SentenceTile({required this.id, required this.text});

  final String id;
  final String text;
}

class SentenceBuilderEngine {
  const SentenceBuilderEngine();

  static final _edgePunctuation =
      RegExp('^[“”"‘’\'(\\[]+|[“”"‘’\'()\\].,!?;:]+\$');

  /// A word as its tile shows it: without the punctuation around it, and the
  /// sentence's first word without its capital unless it is a name
  /// ([names]), so neither gives away where a tile goes.
  static String tileText(String token,
      {required bool first, Set<String> names = const <String>{}}) {
    final bare = token.replaceAll(_edgePunctuation, '');
    // A name also covers its endings (Mizo → Mizote, Pathian → Pathianin).
    final isName = names.contains(bare) ||
        names.any((name) => name.length >= 3 && bare.startsWith(name));
    if (!first || bare.isEmpty || isName) return bare;
    return '${bare[0].toLowerCase()}${bare.substring(1)}';
  }

  List<SentenceTile> shuffledTiles(
    SentenceExercise exercise,
    Random random, {
    Set<String> names = const <String>{},
  }) {
    final tiles = [
      for (final (index, token) in exercise.tokens.indexed)
        SentenceTile(
          id: '${exercise.id}.$index',
          text: tileText(token, first: index == 0, names: names),
        ),
    ];
    tiles.shuffle(random);
    if (tiles.length > 1 && evaluate(exercise, tiles)) {
      final first = tiles.removeAt(0);
      tiles.add(first);
    }
    return List<SentenceTile>.unmodifiable(tiles);
  }

  /// Right when the tiles read as the sentence does; two tiles showing the
  /// same word are interchangeable.
  bool evaluate(SentenceExercise exercise, List<SentenceTile> answer) {
    String plain(String text) =>
        text.replaceAll(_edgePunctuation, '').toLowerCase();
    final expected = exercise.tokens.map(plain).toList();
    final given = answer.map((tile) => plain(tile.text)).toList();
    if (given.length != expected.length) return false;
    for (var i = 0; i < expected.length; i++) {
      if (given[i] != expected[i]) return false;
    }
    return true;
  }

  String readableAnswer(List<SentenceTile> answer) =>
      answer.map((tile) => tile.text).join(' ');
}

class SentenceExercise {
  const SentenceExercise({
    required this.id,
    required this.textMizo,
    required this.englishSupport,
    required this.tqLevel,
    this.keyWord,
  });

  final String id;
  final String textMizo;
  final String englishSupport;
  final int tqLevel;

  /// Set for a word's example sentence, which has no translation: the word
  /// it teaches, shown in place of a meaning to build.
  final String? keyWord;

  /// The words to arrange; a stray mark on its own (“—”) is not a tile.
  List<String> get tokens => [
        for (final token in textMizo.trim().split(RegExp(r'\s+')))
          if (token.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '').isNotEmpty)
            token,
      ];
}

/// Short, low-ambiguity prototype sentences. They still remain behind the
/// app's existing production content gate until qualified Mizo review.
const sentenceExercises = <SentenceExercise>[
  SentenceExercise(id: 'sentence.002', textMizo: 'Ka nu chu a hlim.', englishSupport: 'My mother is happy.', tqLevel: 0),
  SentenceExercise(id: 'sentence.003', textMizo: 'Ka pa chu a kal.', englishSupport: 'My father is going.', tqLevel: 0),
  SentenceExercise(id: 'sentence.001', textMizo: 'Kan inah lo kal rawh.', englishSupport: 'Please come to our house.', tqLevel: 1),
  SentenceExercise(id: 'sentence.local.001', textMizo: 'Lehkhabu ka chhiar.', englishSupport: 'I read a book.', tqLevel: 1),
  SentenceExercise(id: 'sentence.local.002', textMizo: 'Tui thianghlim in rawh.', englishSupport: 'Please drink clean water.', tqLevel: 1),
  SentenceExercise(id: 'sentence.013', textMizo: 'Mizo tawng ka zir.', englishSupport: 'I learn Mizo.', tqLevel: 0),
];
