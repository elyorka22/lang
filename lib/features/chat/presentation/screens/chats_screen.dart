import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/conversation.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../application/chat_controller.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            tooltip: 'New group',
            onPressed: () => context.push('/groups/create'),
            icon: const Icon(Icons.group_add_outlined),
          ),
          IconButton(
            onPressed: () => context.go('/discover'),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMenu(context),
        child: const Icon(Icons.edit_outlined),
      ),
      body: chats.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              subtitle: 'Start a chat or create a practice group',
              action: FilledButton.icon(
                onPressed: () => context.push('/groups/create'),
                icon: const Icon(Icons.group_add),
                label: const Text('Create group'),
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
                      ? _GroupAvatar(title: c.displayTitle)
                      : AppAvatar(
                          name: c.peer?.displayName ?? '?',
                          url: c.peer?.avatarUrl,
                          status: c.peer?.status,
                          showStatus: true,
                          size: 52,
                        ),
                  title: Row(
                    children: [
                      if (c.isGroup) ...[
                        const Icon(
                          Icons.groups_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          c.displayTitle,
                          style: context.textTheme.titleSmall,
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

  void _showNewMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.group_add_outlined),
                title: const Text('New group'),
                subtitle: const Text('Practice with several partners'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/groups/create');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_search_outlined),
                title: const Text('Find people'),
                subtitle: const Text('Discover language partners'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/discover');
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

class _GroupAvatar extends StatelessWidget {
  const _GroupAvatar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.brandGradientSoft),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title.initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
