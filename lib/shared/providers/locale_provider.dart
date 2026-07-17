import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_storage_service.dart';
import '../models/app_language.dart';

final appLocaleProvider =
    StateNotifierProvider<AppLocaleController, AppLanguage>((ref) {
  final storage = ref.watch(localStorageProvider);
  final saved = storage.localeCode;
  return AppLocaleController(storage, AppLanguages.byCodeOrEnglish(saved));
});

class AppLocaleController extends StateNotifier<AppLanguage> {
  AppLocaleController(this._storage, AppLanguage initial) : super(initial);

  final LocalStorageService _storage;

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await _storage.setLocale(language.code);
  }

  Locale get materialLocale => Locale(state.code);
}
