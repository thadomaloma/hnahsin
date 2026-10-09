import 'package:flutter/services.dart';

import 'data.dart';

/// Mizo words the games know are real without teaching them
/// (assets/mizo_words.txt, from the words in J.F. Laldailova's English–Lushai
/// dictionary; tool/mizo_lexicon.py). Word Chain accepts them, so a real
/// word a player types isn't turned away because the content Sheet doesn't
/// have it yet. Kept with accents folded: the dictionary seldom marks them.
abstract final class MizoLexicon {
  static Set<String> _words = const <String>{};

  static int get length => _words.length;

  /// Whether [word] is a known Mizo word, accents optional.
  static bool contains(String word) => _words.contains(foldMizo(word));

  static void use(Iterable<String> words) => _words = {for (final word in words) foldMizo(word)};

  /// Loads the bundled list; the games work without it, as before.
  static Future<void> load([AssetBundle? bundle]) async {
    try {
      final text = await (bundle ?? rootBundle).loadString('assets/mizo_words.txt');
      use(text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty));
    } catch (_) {
      // Missing in some tests; Word Chain then knows the catalog's words only.
    }
  }
}
