import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hnahsin/l10n/app_locales.dart';
import 'package:hnahsin/l10n/translations.dart';
import 'package:hnahsin/features/games/engine/game_engine.dart';
import 'package:hnahsin/features/journey/domain/journey_engine.dart';
import 'package:hnahsin/src/app_text.dart';

void main() {
  tearDown(() => AppText.update(const <String, String>{}));

  test('built-in text is simple English and fills its placeholders', () {
    expect(AppText.of('home.play'), 'Play');
    expect(AppText.of('home.streak', {'n': 4}), '4 day streak');
  });

  test('another language shows its translation, not the Sheet\'s English', () {
    addTearDown(() => AppText.locale = 'en');
    AppText.update(const {'home.play': 'Play now'});
    AppText.locale = 'ja';

    expect(AppText.of('home.play'), translations['ja']!['home.play']);
    expect(AppText.of('home.streak', {'n': 4}), isNot(contains('{n}')));
  });

  test('every language translates every text with the same placeholders', () {
    final english = {
      for (final MapEntry(:key, :value) in appTextDefaults.entries) key: value.text,
    };
    for (final code in appLocales.map((locale) => locale.code).where((code) => code != 'en')) {
      final strings = translations[code];
      expect(strings, isNotNull, reason: code);
      for (final MapEntry(:key, :value) in english.entries) {
        expect(strings![key], isNotNull, reason: '$code is missing $key');
        expect(appTextPlaceholders(strings[key]!), appTextPlaceholders(value), reason: '$code $key');
      }
    }
  });

  test('phones get their language, Taiwan and Hong Kong traditional Chinese', () {
    expect(localeCodeFor(const Locale('ja', 'JP')), 'ja');
    expect(localeCodeFor(const Locale('zh', 'CN')), 'zh_Hans');
    expect(localeCodeFor(const Locale('zh', 'TW')), 'zh_Hant');
    expect(localeCodeFor(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')), 'zh_Hant');
    expect(localeCodeFor(const Locale('pt', 'BR')), 'pt');
    expect(localeCodeFor(const Locale('sw')), 'en');
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
