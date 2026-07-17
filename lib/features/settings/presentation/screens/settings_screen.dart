import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../auth/application/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Preferences'),
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(themeMode.name),
            onTap: () async {
              final selected = await showModalBottomSheet<ThemeMode>(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ThemeMode.values
                        .map(
                          (m) => ListTile(
                            title: Text(m.name),
                            onTap: () => Navigator.pop(ctx, m),
                          ),
                        )
                        .toList(),
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
            title: const Text('App language'),
            subtitle: const Text('English'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () => context.push('/notifications'),
          ),
          const Divider(),
          const ListTile(title: Text('Privacy & security'), dense: true),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.devices_outlined),
            title: const Text('Device sessions'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('Blocked users'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Premium'),
            onTap: () => context.push('/premium'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text('Lingua v${AppConstants.appVersion}'),
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                LinguaButton(
                  label: 'Log out',
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
                        title: const Text('Delete account?'),
                        content: const Text(
                          'This permanently deletes your Lingua account.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Delete account',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
