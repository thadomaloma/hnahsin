// Prints every text the translations in l10n/ cover, in English, as JSON:
// the app texts (lib/src/app_text.dart) and the games' text
// (game.<id>.<field>). tool/check_l10n.py compares each language with it.
//
//   dart run tool/l10n_english.dart
import 'dart:convert';
import 'dart:io';

import '../lib/src/app_text.dart';
import '../lib/src/game_text.dart';

void main() {
  stdout.writeln(jsonEncode({
    for (final MapEntry(:key, :value) in appTextDefaults.entries) key: value.text,
    ...englishGameTexts(),
  }));
}
