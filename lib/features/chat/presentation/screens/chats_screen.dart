import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
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
            onPressed: () => context.go('/discover'),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      body: chats.isEmpty
          ? EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              subtitle: 'Find a language partner to start chatting',
              action: FilledButton(
                onPressed: () => context.go('/discover'),
                child: const Text('Discover partners'),
              ),
            )
          : ListView.separated(
              itemCount: chats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = chats[i];
                final preview = c.lastMessage?.text ??
                    (c.lastMessage?.type.name == 'voice'
                        ? '🎙 Voice message'
                        : '');
                return ListTile(
                  onTap: () => context.push('/chat/${c.id}'),
                  leading: AppAvatar(
                    name: c.peer.displayName,
                    url: c.peer.avatarUrl,
                    status: c.peer.status,
                    showStatus: true,
                    size: 52,
                  ),
                  title: Text(
                    c.peer.displayName,
                    style: context.textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    preview,
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
}
