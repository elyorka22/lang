import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/conversation.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../application/chat_controller.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key, this.inboxOnly = false});

  /// When true, shows only direct (1:1) chats — used as Rooms → Inbox.
  final bool inboxOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(conversationsProvider);
    final chats = inboxOnly
        ? all.where((c) => !c.isGroup).toList()
        : all;
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
              icon: Icons.chat_bubble_outline,
              title: inboxOnly ? s.directInbox : s.chats,
              subtitle: s.findGroups,
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
                bottom: MediaQuery.paddingOf(context).bottom + 88,
              ),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = chats[i];
                final preview = c.lastMessage?.type.name == 'system'
                    ? (c.lastMessage?.text ?? '')
                    : c.lastMessage?.text ??
                        (c.lastMessage?.type.name == 'voice'
                            ? '🎙 Voice message'
                            : '');
                final previewLine = c.isGroup &&
                        c.lastMessage != null &&
                        c.lastMessage!.senderId != 'me' &&
                        c.lastMessage!.senderId != 'system'
                    ? '${_shortName(c, c.lastMessage!.senderId)}: $preview'
                    : preview;

                return ListTile(
                  onTap: () => context.push('/chat/${c.id}'),
                  leading: c.isGroup
                      ? AppAvatar(
                          name: c.displayTitle,
                          url: c.avatarUrl,
                          size: 52,
                          isGroup: true,
                        )
                      : AppAvatar(
                          name: c.peer?.displayName ?? '?',
                          url: c.peer?.avatarUrl,
                          status: c.peer?.status,
                          showStatus: true,
                          size: 52,
                        ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.displayTitle,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    previewLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        c.updatedAt?.chatTime ?? '',
                        style: context.textTheme.labelSmall,
                      ),
                      if (c.unreadCount > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
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
