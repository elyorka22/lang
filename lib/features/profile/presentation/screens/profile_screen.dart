import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authControllerProvider).user ?? MockData.currentUser;
    final isSelf = userId == null || userId == 'me' || userId == me.id;
    final user = isSelf
        ? me
        : MockData.users.firstWhere(
            (u) => u.id == userId,
            orElse: () => MockData.users.first,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelf ? 'Profile' : user.displayName),
        actions: [
          if (isSelf)
            IconButton(
              onPressed: () => context.push('/settings'),
              icon: const Icon(Icons.settings_outlined),
            )
          else
            PopupMenuButton<String>(
              onSelected: (v) {
                context.showSnack(v);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'Follow', child: Text('Follow')),
                PopupMenuItem(value: 'Block', child: Text('Block')),
                PopupMenuItem(value: 'Report', child: Text('Report')),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: AppAvatar(
              name: user.displayName,
              url: user.avatarUrl,
              size: 96,
              status: user.status,
              showStatus: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall,
          ),
          Text(
            '@${user.username}',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (user.country != null)
            Text(
              user.country!,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(label: 'Streak', value: '${user.streak}'),
              _Stat(label: 'XP', value: '${user.xp}'),
              _Stat(label: 'Level', value: '${user.level}'),
            ],
          ),
          const SizedBox(height: 16),
          if (!isSelf) ...[
            LinguaButton(
              label: 'Message',
              onPressed: () => context.push('/chat/c_${user.id}'),
            ),
            const SizedBox(height: 8),
            LinguaButton(
              label: user.isFriend ? 'Friends' : 'Add friend',
              isOutlined: true,
              onPressed: () => context.showSnack('Friend request sent'),
            ),
            const SizedBox(height: 16),
          ] else ...[
            LinguaButton(
              label: 'Edit profile',
              isOutlined: true,
              onPressed: () => context.push('/profile/edit'),
            ),
            const SizedBox(height: 8),
            LinguaButton(
              label: 'Learning stats',
              onPressed: () => context.push('/learning'),
            ),
            const SizedBox(height: 16),
          ],
          Text(user.bio, style: context.textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Languages', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_outlined),
            title: Text('Native: ${user.nativeLanguage}'),
          ),
          ...user.learningLanguages.map(
            (l) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.school_outlined),
              title: Text('${l.name} · ${l.level.name.toUpperCase()}'),
            ),
          ),
          const SizedBox(height: 8),
          Text('Interests', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.interests.map((e) => Chip(label: Text(e))).toList(),
          ),
          if (user.badges.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Badges', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: user.badges
                  .map(
                    (b) => Chip(
                      avatar: const Icon(Icons.military_tech_outlined, size: 16),
                      label: Text(b.replaceAll('_', ' ')),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: context.textTheme.headlineSmall),
        Text(label, style: context.textTheme.bodySmall),
      ],
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  var _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final user = ref.read(authControllerProvider).user ?? MockData.currentUser;
    _name = TextEditingController(text: user.displayName);
    _bio = TextEditingController(text: user.bio);
    _ready = true;
  }

  @override
  void dispose() {
    if (_ready) {
      _name.dispose();
      _bio.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bio,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Bio'),
          ),
          const SizedBox(height: 24),
          LinguaButton(
            label: 'Save',
            onPressed: () {
              context.showSnack('Profile updated');
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
