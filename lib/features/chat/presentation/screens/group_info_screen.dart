import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/models/conversation.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/chat_controller.dart';

class GroupInfoScreen extends ConsumerWidget {
  const GroupInfoScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(conversationsProvider);
    ChatConversation? group;
    for (final c in chats) {
      if (c.id == groupId && c.isGroup) {
        group = c;
        break;
      }
    }

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group')),
        body: const Center(child: Text('Group not found')),
      );
    }

    final isAdmin = group.adminIds.contains('me');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group info'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              onPressed: () => _addMembers(context, ref, group!),
            ),
        ],
      ),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
          Center(
            child: AppAvatar(
              name: group.displayTitle,
              url: group.avatarUrl,
              size: 96,
              isGroup: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            group.displayTitle,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall,
          ),
          Text(
            '${group.members.length} members',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              group.description,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 24),
          Text('Members', style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...group.members.map((u) {
            final admin = group!.adminIds.contains(u.id);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: u.id == 'me' ? null : () => context.push('/users/${u.id}'),
              leading: AppAvatar(
                name: u.displayName,
                url: u.avatarUrl,
                status: u.status,
                showStatus: true,
              ),
              title: Text(
                u.id == 'me' ? '${u.displayName} (You)' : u.displayName,
              ),
              subtitle: Text(
                admin ? 'Admin · ${u.nativeLanguage}' : u.nativeLanguage,
              ),
              trailing: isAdmin && u.id != 'me'
                  ? IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.error,
                      onPressed: () {
                        ref
                            .read(conversationsProvider.notifier)
                            .removeMember(groupId, u.id);
                      },
                    )
                  : null,
            );
          }),
          const SizedBox(height: 24),
          LinguaButton(
            label: 'Leave group',
            isOutlined: true,
            onPressed: () {
              ref.read(conversationsProvider.notifier).leaveGroup(groupId);
              context.go('/rooms');
            },
          ),
        ],
        ),
      ),
    );
  }

  void _addMembers(
    BuildContext context,
    WidgetRef ref,
    ChatConversation group,
  ) {
    final existing = group.members.map((m) => m.id).toSet();
    final candidates =
        MockData.users.where((u) => !existing.contains(u.id)).toList();
    final picked = <UserProfile>{};

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.7,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Add members',
                        style: ctx.textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: candidates.length,
                        itemBuilder: (_, i) {
                          final u = candidates[i];
                          final on = picked.any((p) => p.id == u.id);
                          return CheckboxListTile(
                            value: on,
                            activeColor: AppColors.primary,
                            secondary: AppAvatar(
                              name: u.displayName,
                              url: u.avatarUrl,
                              size: 40,
                            ),
                            title: Text(u.displayName),
                            onChanged: (_) {
                              setModal(() {
                                if (on) {
                                  picked.removeWhere((p) => p.id == u.id);
                                } else {
                                  picked.add(u);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: LinguaButton(
                        label: 'Add',
                        onPressed: picked.isEmpty
                            ? null
                            : () {
                                ref
                                    .read(conversationsProvider.notifier)
                                    .addMembers(groupId, picked.toList());
                                Navigator.pop(ctx);
                              },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
