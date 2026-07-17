import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'shared/models/app_language.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final container = ProviderContainer();
  await container.read(localStorageProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LinguaApp(),
    ),
  );
}

class LinguaApp extends ConsumerWidget {
  const LinguaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final appLang = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // Material widgets need a locale with Global*Localizations.
      // Preference may be uz (no Material pack yet) → fall back safely.
      locale: AppLanguages.materialLocaleFor(appLang),
      supportedLocales: AppLanguages.materialSupportedLocales,
      localeResolutionCallback: (locale, supported) {
        return AppLanguages.resolveMaterialLocale(locale, supported);
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
