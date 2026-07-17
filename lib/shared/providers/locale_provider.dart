import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_storage_service.dart';
import '../models/app_language.dart';

final appLocaleProvider =
    StateNotifierProvider<AppLocaleController, AppLanguage>((ref) {
  final storage = ref.watch(localStorageProvider);
  final saved = storage.localeCode;
  // Prefer English Material-safe default if stored code is corrupt/empty.
  final initial = AppLanguages.byCode(saved) ?? AppLanguages.english;
  return AppLocaleController(storage, initial);
});

class AppLocaleController extends StateNotifier<AppLanguage> {
  AppLocaleController(this._storage, AppLanguage initial) : super(initial);

  final LocalStorageService _storage;

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await _storage.setLocale(language.code);
  }
}
