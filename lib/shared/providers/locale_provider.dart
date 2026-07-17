import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_storage_service.dart';
import '../l10n/app_strings.dart';
import '../models/app_language.dart';

final appLocaleProvider =
    StateNotifierProvider<AppLocaleController, AppLanguage>((ref) {
  final storage = ref.watch(localStorageProvider);
  final saved = storage.localeCode;
  final initial = AppLanguages.byCode(saved) ?? AppLanguages.english;
  return AppLocaleController(storage, initial);
});

/// UI copy for the currently selected app language.
final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(appLocaleProvider);
  return AppStrings(lang.code);
});

class AppLocaleController extends StateNotifier<AppLanguage> {
  AppLocaleController(this._storage, AppLanguage initial) : super(initial);

  final LocalStorageService _storage;

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await _storage.setLocale(language.code);
  }
}
