import 'dart:math';

import '../features/games/engine/game_difficulty.dart';
import 'controller.dart';
import 'data.dart';

/// How alike two words are (0–1), used to make wrong answers trickier as a
/// learner's level rises: same topic, similar length, same first letter.
double wordSimilarity(WordEntry a, WordEntry b) {
  var score = 0.0;
  if (a.category == b.category) score += .45;
  if ((a.word.length - b.word.length).abs() <= 1) score += .3;
  if (a.word.isNotEmpty &&
      b.word.isNotEmpty &&
      normalizeMizo(a.word)[0] == normalizeMizo(b.word)[0]) score += .25;
  return score;
}

/// Words for one round of [gameId], centred on the learner's adaptive level
/// for that game and ordered easiest first.
List<WordEntry> pickWordsForLevel(
  QuestController controller,
  String gameId,
  Iterable<WordEntry> pool,
  int count,
  Random random,
) =>
    GameDifficulty.pick(
      pool.toList(),
      rating: controller.gameSkill(gameId),
      count: count,
      difficultyOf: (entry) => entry.difficulty,
      random: random,
    );
