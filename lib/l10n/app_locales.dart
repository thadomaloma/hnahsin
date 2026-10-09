import 'dart:ui';

/// A language the app's labels come in: its code in lib/l10n, its own name,
/// and the [Locale] Flutter knows it by.
class AppLocale {
  const AppLocale(this.code, this.name, this.locale);
  final String code;
  final String name;
  final Locale locale;
}

/// English first (the built-in text), then the translations.
const appLocales = <AppLocale>[
  AppLocale('en', 'English', Locale('en')),
  AppLocale('ja', '日本語', Locale('ja')),
  AppLocale('zh_Hans', '简体中文', Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')),
  AppLocale('zh_Hant', '繁體中文', Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
  AppLocale('ko', '한국어', Locale('ko')),
  AppLocale('hi', 'हिन्दी', Locale('hi')),
  AppLocale('my', 'မြန်မာ', Locale('my')),
  AppLocale('th', 'ไทย', Locale('th')),
  AppLocale('id', 'Bahasa Indonesia', Locale('id')),
  AppLocale('vi', 'Tiếng Việt', Locale('vi')),
  AppLocale('es', 'Español', Locale('es')),
  AppLocale('fr', 'Français', Locale('fr')),
  AppLocale('de', 'Deutsch', Locale('de')),
  AppLocale('pt', 'Português', Locale('pt')),
  AppLocale('ar', 'العربية', Locale('ar')),
  AppLocale('ru', 'Русский', Locale('ru')),
];

AppLocale appLocaleOf(String code) =>
    appLocales.firstWhere((locale) => locale.code == code, orElse: () => appLocales.first);

/// The app language for a phone set to [device]: its own when we have it
/// (Taiwan and Hong Kong Chinese get traditional characters), else English.
String localeCodeFor(Locale device) {
  if (device.languageCode == 'zh') {
    final traditional = device.scriptCode == 'Hant' ||
        const {'TW', 'HK', 'MO'}.contains(device.countryCode);
    return traditional ? 'zh_Hant' : 'zh_Hans';
  }
  return appLocales.any((locale) => locale.code == device.languageCode) ? device.languageCode : 'en';
}

/// The languages written right to left.
bool isRightToLeft(String code) => code == 'ar';
