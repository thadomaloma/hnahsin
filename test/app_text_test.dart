import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/features/journey/domain/journey_engine.dart';
import 'package:hnahsin/src/app_text.dart';

void main() {
  tearDown(() => AppText.update(const <String, String>{}));

  test('built-in text is simple English and fills its placeholders', () {
    expect(AppText.of('home.play'), 'Play');
    expect(AppText.of('home.streak', {'n': 4}), '4 day streak');
  });

  test('Mizo shows the built-in Mizo, not the Sheet\'s English', () {
    addTearDown(() => AppText.language = AppLanguage.english);
    AppText.update(const {'home.play': 'Play now'});
    AppText.language = AppLanguage.mizo;

    expect(AppText.of('home.play'), 'Khel rawh');
    expect(AppText.of('home.streak', {'n': 4}), 'Ni 4 indawt');
  });

  test('every text has the same placeholders in English and Mizo', () {
    for (final MapEntry(:key, :value) in appTextDefaults.entries) {
      expect(appTextPlaceholders(value.mizo), appTextPlaceholders(value.text), reason: key);
    }
  });

  test('Sheet text replaces the built-in text', () {
    AppText.update(const {'home.play': 'Play now', 'home.streak': '{n} days in a row'});

    expect(AppText.of('home.play'), 'Play now');
    expect(AppText.of('home.streak', {'n': 4}), '4 days in a row');
  });

  test('Sheet text with other placeholders is ignored', () {
    AppText.update(const {'home.streak': 'Streak', 'home.play': 'Play {now}'});

    expect(AppText.of('home.streak', {'n': 4}), '4 day streak');
    expect(AppText.of('home.play'), 'Play');
  });

  test('every text the code asks for has a built-in text', () {
    final asked = <String>{};
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      asked.addAll(RegExp(r"AppText\.of\(\s*'([\w.]+)'")
          .allMatches(file.readAsStringSync())
          .map((match) => match[1]!));
      // The ternaries that pick an ID: AppText.of(x ? 'a' : 'b').
      for (final match in RegExp(r"AppText\.of\(([^()]*?\?[^()]*?)[,)]")
          .allMatches(file.readAsStringSync())) {
        asked.addAll(RegExp(r"'([a-z][\w]*\.[\w.]+)'")
            .allMatches(match[1]!)
            .map((id) => id[1]!));
      }
    }
    // IDs built at run time.
    asked.addAll(GameMode.values.map((mode) => 'launcher.modeName.${mode.name}'));
    for (final quest in [...dailyQuestCatalog, ...weeklyQuestCatalog]) {
      asked.addAll([quest.textId, '${quest.textId}.note']);
    }

    expect(asked.length, greaterThan(300));
    expect(asked.where((id) => !appTextDefaults.containsKey(id)), isEmpty);
  });
}
