import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/social_models.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/social_controller.dart';

class RoomDetailScreen extends ConsumerWidget {
  const RoomDetailScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final social = ref.watch(socialControllerProvider);
    LanguageRoom? room;
    for (final r in social.rooms) {
      if (r.id == roomId) room = r;
    }
    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Room')),
        body: const Center(child: Text('Room not found')),
      );
    }

    final related = social.tables
        .where((t) => t.topic == room!.topic)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(room.title)),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              '${room.topic.emoji}  ${room.topic.label}',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(room.description, style: context.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(
              '${room.onlineCount} online · ${room.memberCount} members · ${room.language}',
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            LinguaButton(
              label: 'Enter lounge chat',
              onPressed: () => context.push('/chat/room_$roomId'),
            ),
            const SizedBox(height: 8),
            LinguaButton(
              label: 'Host a table here',
              isOutlined: true,
              onPressed: () => context.push('/social/host?topic=${room!.topic.name}'),
            ),
            const SizedBox(height: 24),
            Text('Tables in this room', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (related.isEmpty)
              Text(
                'No open tables yet — be the first host.',
                style: context.textTheme.bodyMedium,
              )
            else
              ...related.map(
                (t) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(t.topic.emoji, style: const TextStyle(fontSize: 22)),
                  title: Text(t.title),
                  subtitle: Text(
                    '${t.participants.length}/${t.maxSeats} · ${t.language}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/social'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
