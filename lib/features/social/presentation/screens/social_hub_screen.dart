import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/social_models.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/social_controller.dart';

class SocialHubScreen extends ConsumerWidget {
  const SocialHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final social = ref.watch(socialControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
        actions: [
          IconButton(
            tooltip: 'Mentors',
            onPressed: () => context.push('/social/mentors'),
            icon: const Icon(Icons.military_tech_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/social/host'),
        icon: const Icon(Icons.table_restaurant_outlined),
        label: const Text('Host a table'),
      ),
      body: social.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeBody(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(socialControllerProvider.notifier).load(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [
                    _KarmaCard(
                      karma: social.myKarma,
                      helped: social.myCorrectionsHelped,
                      isMentor: social.iAmMentor,
                    ),
                    const SizedBox(height: 20),
                    Text('Language rooms', style: context.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Topic lounges: Travel, Jobs, Social',
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    ...social.rooms.map(
                      (room) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RoomCard(
                          room: room,
                          onTap: () => context.push('/social/rooms/${room.id}'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Open tables',
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/social/host'),
                          child: const Text('Host'),
                        ),
                      ],
                    ),
                    Text(
                      '30 min · max 4 people · one topic',
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    ...social.tables.map(
                      (table) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TableCard(table: table),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _KarmaCard extends StatelessWidget {
  const _KarmaCard({
    required this.karma,
    required this.helped,
    required this.isMentor,
  });

  final int karma;
  final int helped;
  final bool isMentor;

  @override
  Widget build(BuildContext context) {
    final progress = (karma / mentorKarmaThreshold).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.borderXl,
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Correction karma',
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (isMentor)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Mentor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$karma karma · $helped helpful corrections',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isMentor
                ? 'You unlocked the Mentor badge'
                : '${mentorKarmaThreshold - karma} karma to Mentor badge',
            style: context.textTheme.labelSmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.onTap});

  final LanguageRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.isDark
          ? AppColors.surfaceElevatedDark
          : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(room.topic.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.title, style: context.textTheme.titleSmall),
                    Text(
                      room.topic.blurb,
                      style: context.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${room.onlineCount} online',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.online,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${room.memberCount} members',
                    style: context.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableCard extends ConsumerWidget {
  const _TableCard({required this.table});

  final PracticeTable table;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joined = table.participants.any((p) => p.id == 'me');
    final mins = table.startsAt.difference(DateTime.now()).inMinutes;

    return Material(
      color: context.isDark
          ? AppColors.surfaceElevatedDark
          : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(table.topic.emoji),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(table.title, style: context.textTheme.titleSmall),
                ),
                Text(
                  '${table.durationMinutes} min',
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${table.language} · ${table.levelHint} · ${table.seatsLeft} seats left',
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...table.participants.take(4).map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: AppAvatar(
                          name: p.displayName,
                          url: p.avatarUrl,
                          size: 28,
                        ),
                      ),
                    ),
                const Spacer(),
                Text(
                  mins <= 0 ? 'Starting' : 'in ${mins}m',
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                AppAvatar(
                  name: table.host.displayName,
                  url: table.host.avatarUrl,
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  'Host: ${table.host.displayName.split(' ').first}',
                  style: context.textTheme.labelSmall,
                ),
                const Spacer(),
                if (joined)
                  TextButton(
                    onPressed: () {
                      ref
                          .read(socialControllerProvider.notifier)
                          .leaveTable(table.id);
                    },
                    child: const Text('Leave'),
                  )
                else
                  FilledButton(
                    onPressed: !table.isJoinable
                        ? null
                        : () {
                            final ok = ref
                                .read(socialControllerProvider.notifier)
                                .joinTable(table.id);
                            context.showSnack(
                              ok ? 'Joined the table' : 'Table is full',
                              isError: !ok,
                            );
                          },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(table.isJoinable ? 'Join' : 'Full'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
