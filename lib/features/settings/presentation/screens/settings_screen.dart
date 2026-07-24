import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/app_language.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../../auth/application/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appLang = ref.watch(appLocaleProvider);
    final s = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: SafeBody(
        child: ListView(
          children: [
            ListTile(
              title: Text(s.preferences),
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(s.theme),
              subtitle: Text(s.themeLabel(themeMode)),
              onTap: () async {
                final selected = await showModalBottomSheet<ThemeMode>(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(s.themeLabel(ThemeMode.system)),
                          onTap: () => Navigator.pop(ctx, ThemeMode.system),
                        ),
                        ListTile(
                          title: Text(s.themeLabel(ThemeMode.light)),
                          onTap: () => Navigator.pop(ctx, ThemeMode.light),
                        ),
                        ListTile(
                          title: Text(s.themeLabel(ThemeMode.dark)),
                          onTap: () => Navigator.pop(ctx, ThemeMode.dark),
                        ),
                      ],
                    ),
                  ),
                );
                if (selected != null) {
                  await ref.read(themeModeProvider.notifier).setMode(selected);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(s.appLanguage),
              subtitle: Text('${appLang.flag} ${appLang.nativeName}'),
              onTap: () async {
                final selected = await showModalBottomSheet<AppLanguage>(
                  context: context,
                  showDragHandle: true,
                  builder: (ctx) {
                    final sheetStrings = ref.read(appStringsProvider);
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(sheetStrings.appLanguage),
                            subtitle: Text(sheetStrings.appLanguageHint),
                          ),
                          ...AppLanguages.appUi.map(
                            (lang) => ListTile(
                              leading: Text(
                                lang.flag,
                                style: const TextStyle(fontSize: 22),
                              ),
                              title: Text(lang.nativeName),
                              subtitle: Text(lang.name),
                              trailing: appLang.code == lang.code
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () => Navigator.pop(ctx, lang),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
                if (selected != null) {
                  await ref
                      .read(appLocaleProvider.notifier)
                      .setLanguage(selected);
                  if (context.mounted) {
                    final next = ref.read(appStringsProvider);
                    context.showSnack(next.languageChanged);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: Text(s.notifications),
              onTap: () => context.push('/notifications'),
            ),
            const Divider(),
            ListTile(title: Text(s.privacySecurity), dense: true),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: Text(s.privacy),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: Text(s.deviceSessions),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: Text(s.premium),
              onTap: () => context.showSnack('Premium coming soon'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(s.about),
              subtitle: Text('Lingua v${AppConstants.appVersion}'),
              onTap: () {},
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  LinguaButton(
                    label: s.logOut,
                    isOutlined: true,
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) context.go('/welcome');
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(s.deleteAccountTitle),
                          content: Text(s.deleteAccountBody),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(s.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(s.delete),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      s.deleteAccount,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
