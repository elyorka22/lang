import 'package:flutter/material.dart';

/// Supported languages in Lingua (practice + app UI).
/// Add new entries here when expanding language support.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.countryCode,
  });

  /// ISO 639-1 style code: en, ru, uz…
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  /// Flag / region code for Discover chips (UZ, RU, GB…).
  final String countryCode;

  String get shortLabel => code.toUpperCase();

  String get chipLabel => '$flag $name';
}

/// Central catalog — extend this list to add more languages later.
class AppLanguages {
  AppLanguages._();

  static const english = AppLanguage(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: '🇬🇧',
    countryCode: 'GB',
  );

  static const russian = AppLanguage(
    code: 'ru',
    name: 'Russian',
    nativeName: 'Русский',
    flag: '🇷🇺',
    countryCode: 'RU',
  );

  static const uzbek = AppLanguage(
    code: 'uz',
    name: 'Uzbek',
    nativeName: 'Oʻzbekcha',
    flag: '🇺🇿',
    countryCode: 'UZ',
  );

  static const spanish = AppLanguage(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
    countryCode: 'ES',
  );

  static const french = AppLanguage(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    flag: '🇫🇷',
    countryCode: 'FR',
  );

  static const german = AppLanguage(
    code: 'de',
    name: 'German',
    nativeName: 'Deutsch',
    flag: '🇩🇪',
    countryCode: 'DE',
  );

  static const portuguese = AppLanguage(
    code: 'pt',
    name: 'Portuguese',
    nativeName: 'Português',
    flag: '🇧🇷',
    countryCode: 'BR',
  );

  static const japanese = AppLanguage(
    code: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
    flag: '🇯🇵',
    countryCode: 'JP',
  );

  static const italian = AppLanguage(
    code: 'it',
    name: 'Italian',
    nativeName: 'Italiano',
    flag: '🇮🇹',
    countryCode: 'IT',
  );

  static const korean = AppLanguage(
    code: 'ko',
    name: 'Korean',
    nativeName: '한국어',
    flag: '🇰🇷',
    countryCode: 'KR',
  );

  static const chinese = AppLanguage(
    code: 'zh',
    name: 'Chinese',
    nativeName: '中文',
    flag: '🇨🇳',
    countryCode: 'CN',
  );

  static const arabic = AppLanguage(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    flag: '🇸🇦',
    countryCode: 'SA',
  );

  /// All practice / profile languages (onboarding, learning).
  /// Russian & Uzbek are listed near the top for visibility.
  static const List<AppLanguage> all = [
    english,
    russian,
    uzbek,
    spanish,
    french,
    german,
    portuguese,
    japanese,
    italian,
    korean,
    chinese,
    arabic,
  ];

  /// Languages currently offered for the app UI locale.
  /// More can be enabled here later without touching call sites.
  static const List<AppLanguage> appUi = [
    english,
    russian,
    uzbek,
  ];

  /// Discover flag row (plus “All” handled in UI).
  static const List<AppLanguage> discoverFilters = [
    spanish,
    russian,
    uzbek,
    german,
    french,
    english,
    portuguese,
    japanese,
    italian,
    korean,
  ];

  static AppLanguage? byCode(String? code) {
    if (code == null || code.isEmpty) return null;
    final lower = code.toLowerCase();
    for (final lang in all) {
      if (lang.code == lower) return lang;
    }
    return null;
  }

  static AppLanguage byCodeOrEnglish(String? code) {
    return byCode(code) ?? english;
  }

  static List<String> get names => all.map((l) => l.name).toList();

  /// Locales that Flutter Material / Cupertino ship translations for.
  /// Uzbek is kept as a user preference but Material UI falls back to English.
  static const List<Locale> materialSupportedLocales = [
    Locale('en'),
    Locale('ru'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('pt'),
    Locale('ja'),
    Locale('it'),
    Locale('ko'),
    Locale('zh'),
    Locale('ar'),
  ];

  /// Locale used by MaterialApp widgets (must have Global*Localizations).
  static Locale materialLocaleFor(AppLanguage language) {
    if (language.code == 'uz') return const Locale('en');
    for (final locale in materialSupportedLocales) {
      if (locale.languageCode == language.code) return locale;
    }
    return const Locale('en');
  }

  static Locale resolveMaterialLocale(
    Locale? locale,
    Iterable<Locale> supported,
  ) {
    if (locale == null) return const Locale('en');
    for (final item in supported) {
      if (item.languageCode == locale.languageCode) return item;
    }
    // uz and any future codes without Material packs
    return const Locale('en');
  }
}
