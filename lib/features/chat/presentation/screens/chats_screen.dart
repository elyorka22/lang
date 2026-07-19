import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/conversation.dart';
import '../../../../shared/models/user_profile.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../application/chat_controller.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key, this.inboxOnly = false});

  /// When true, shows only direct (1:1) chats.
  final bool inboxOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(conversationsProvider);
    final chats = inboxOnly ? all.where((c) => !c.isGroup).toList() : all;
    final s = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(inboxOnly ? s.directInbox : s.chats),
        actions: [
          if (!inboxOnly) ...[
            IconButton(
              tooltip: s.newGroup,
              onPressed: () => context.push('/groups/create'),
              icon: const Icon(Icons.group_add_outlined),
            ),
            IconButton(
              onPressed: () => context.push('/discover'),
              icon: const Icon(Icons.person_add_alt_1_outlined),
            ),
          ],
        ],
      ),
      floatingActionButton: inboxOnly
          ? null
          : FloatingActionButton(
              onPressed: () => _showNewMenu(context, s),
              child: const Icon(Icons.edit_outlined),
            ),
      body: chats.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: inboxOnly ? s.directInbox : s.chats,
              subtitle: s.emptyChatsHint,
              action: inboxOnly
                  ? null
                  : FilledButton.icon(
                      onPressed: () => context.push('/groups/create'),
                      icon: const Icon(Icons.group_add),
                      label: Text(s.newGroup),
                    ),
            )
          : ListView.separated(
              padding: EdgeInsets.only(
                top: 8,
                bottom: MediaQuery.paddingOf(context).bottom + 88,
              ),
              itemCount: chats.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 86,
                color: context.isDark ? AppColors.dividerDark : AppColors.divider,
              ),
              itemBuilder: (_, i) {
                final c = chats[i];
                final preview = c.lastMessage?.type.name == 'system'
                    ? (c.lastMessage?.text ?? '')
                    : c.lastMessage?.text ??
                        (c.lastMessage?.type.name == 'voice'
                            ? '🎙 ${s.voiceMessage}'
                            : '');
                final previewLine = c.isGroup &&
                        c.lastMessage != null &&
                        c.lastMessage!.senderId != 'me' &&
                        c.lastMessage!.senderId != 'system'
                    ? '${_shortName(c, c.lastMessage!.senderId)}: $preview'
                    : preview;
                final online = c.peer?.status == OnlineStatus.online;

                return InkWell(
                  onTap: () => context.push('/chat/${c.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        c.isGroup
                            ? AppAvatar(
                                name: c.displayTitle,
                                url: c.avatarUrl,
                                size: 56,
                                isGroup: true,
                              )
                            : AppAvatar(
                                name: c.peer?.displayName ?? '?',
                                url: c.peer?.avatarUrl,
                                status: c.peer?.status,
                                showStatus: true,
                                size: 56,
                              ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      c.displayTitle,
                                      style:
                                          context.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    c.updatedAt?.chatTime ?? '',
                                    style:
                                        context.textTheme.labelSmall?.copyWith(
                                      color: c.unreadCount > 0
                                          ? AppColors.primary
                                          : null,
                                      fontWeight: c.unreadCount > 0
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (!c.isGroup && online) ...[
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: const BoxDecoration(
                                        color: AppColors.online,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                  Expanded(
                                    child: Text(
                                      previewLine,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          context.textTheme.bodyMedium?.copyWith(
                                        color: c.unreadCount > 0
                                            ? (context.isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimary)
                                            : (context.isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.textSecondary),
                                        fontWeight: c.unreadCount > 0
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  if (c.unreadCount > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: AppRadius.borderFull,
                                      ),
                                      child: Text(
                                        '${c.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _shortName(ChatConversation c, String senderId) {
    for (final m in c.members) {
      if (m.id == senderId) {
        return m.displayName.split(' ').first;
      }
    }
    return 'Member';
  }

  void _showNewMenu(BuildContext context, AppStrings s) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.group_add_outlined),
                title: Text(s.newGroup),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/groups/create');
                },
              ),
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(s.findGroups),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/discover');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
