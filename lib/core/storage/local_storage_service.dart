import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Hive + SharedPreferences for non-sensitive local cache.
class LocalStorageService {
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String vocabBox = 'vocabulary';

  late Box<dynamic> _settings;
  late Box<dynamic> _cache;
  SharedPreferences? _prefs;

  Future<void> init() async {
    await Hive.initFlutter();
    _settings = await Hive.openBox(settingsBox);
    _cache = await Hive.openBox(cacheBox);
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme
  String get themeMode => _settings.get('themeMode', defaultValue: 'system') as String;
  Future<void> setThemeMode(String mode) => _settings.put('themeMode', mode);

  // Locale
  String? get localeCode => _settings.get('locale') as String?;
  Future<void> setLocale(String? code) {
    if (code == null) return _settings.delete('locale');
    return _settings.put('locale', code);
  }

  // Onboarding
  bool get hasSeenOnboarding =>
      _settings.get('onboarding', defaultValue: false) as bool;
  Future<void> setOnboardingSeen() => _settings.put('onboarding', true);

  // Guest
  bool get isGuest => _settings.get('guest', defaultValue: false) as bool;
  Future<void> setGuest(bool value) => _settings.put('guest', value);

  // Goal map (long-term level goal)
  String? get goalMapJson => _settings.get('goalMap') as String?;
  Future<void> setGoalMapJson(String? json) {
    if (json == null) return _settings.delete('goalMap');
    return _settings.put('goalMap', json);
  }

  // Saved profile overrides (avatar path, name, bio) for mock/local mode.
  String? get profileOverridesJson =>
      _settings.get('profileOverrides') as String?;
  Future<void> setProfileOverridesJson(String? json) {
    if (json == null) return _settings.delete('profileOverrides');
    return _settings.put('profileOverrides', json);
  }

  // Cache helpers
  Future<void> putCache(String key, dynamic value) => _cache.put(key, value);
  T? getCache<T>(String key) => _cache.get(key) as T?;
  Future<void> clearCache() => _cache.clear();

  // Prefs helpers
  Future<void> setBool(String key, bool value) async =>
      _prefs?.setBool(key, value);
  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs?.getBool(key) ?? defaultValue;
}
