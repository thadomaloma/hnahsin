import 'dart:math';

class SentenceTile {
  const SentenceTile({required this.id, required this.text});

  final String id;
  final String text;
}

class SentenceBuilderEngine {
  const SentenceBuilderEngine();

  List<SentenceTile> shuffledTiles(
    SentenceExercise exercise,
    Random random,
  ) {
    final tiles = exercise.tokens
        .asMap()
        .entries
        .map(
          (entry) => SentenceTile(
            id: '${exercise.id}.${entry.key}',
            text: entry.value,
          ),
        )
        .toList();
    tiles.shuffle(random);
    if (tiles.length > 1 && evaluate(exercise, tiles)) {
      final first = tiles.removeAt(0);
      tiles.add(first);
    }
    return List<SentenceTile>.unmodifiable(tiles);
  }

  bool evaluate(SentenceExercise exercise, List<SentenceTile> answer) =>
      answer.map((tile) => tile.text).join(' ') == exercise.textMizo;

  String readableAnswer(List<SentenceTile> answer) =>
      answer.map((tile) => tile.text).join(' ');
}

class SentenceExercise {
  const SentenceExercise({
    required this.id,
    required this.textMizo,
    required this.englishSupport,
    required this.tqLevel,
  });

  final String id;
  final String textMizo;
  final String englishSupport;
  final int tqLevel;

  List<String> get tokens => textMizo.split(' ');
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
