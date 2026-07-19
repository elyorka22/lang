import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/l10n/app_strings.dart';
import '../../../../shared/models/conversation.dart';
import '../../../../shared/models/game_room.dart';
import '../../../../shared/models/social_models.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../../chat/application/chat_controller.dart';
import '../../../social/application/social_controller.dart';
import '../../application/game_rooms_controller.dart';

/// Rooms hub: groups, practice tables, and game rooms.
class RoomsHubScreen extends ConsumerStatefulWidget {
  const RoomsHubScreen({super.key});

  @override
  ConsumerState<RoomsHubScreen> createState() => _RoomsHubScreenState();
}

class _RoomsHubScreenState extends ConsumerState<RoomsHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    final conversations = ref.watch(conversationsProvider);
    final groups = conversations.where((c) => c.isGroup).toList();
    final dms = conversations.where((c) => !c.isGroup).toList();
    final social = ref.watch(socialControllerProvider);
    final gameRooms = ref.watch(gameRoomsProvider);
    final mafiaRooms =
        gameRooms.where((r) => r.kind == GameKind.mafia).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(s.navRooms),
        actions: [
          IconButton(
            tooltip: s.findGroups,
            onPressed: () => context.push('/discover'),
            icon: const Icon(Icons.explore_outlined),
          ),
          IconButton(
            tooltip: s.directInbox,
            onPressed: () => context.push('/chats'),
            icon: Badge(
              isLabelVisible: dms.any((c) => c.unreadCount > 0),
              child: const Icon(Icons.mail_outline_rounded),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: '${s.roomGroups} (${groups.length})'),
            Tab(text: '${s.roomTables} (${social.tables.length})'),
            Tab(text: '${s.roomGames} (${mafiaRooms.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onFab(context),
        icon: Icon(_fabIcon),
        label: Text(_fabLabel(s)),
      ),
      body: SafeBody(
        child: TabBarView(
          controller: _tabs,
          children: [
            _GroupsTab(groups: groups),
            _TablesTab(tables: social.tables, loading: social.isLoading),
            _GamesTab(rooms: mafiaRooms),
          ],
        ),
      ),
    );
  }

  IconData get _fabIcon {
    switch (_tabs.index) {
      case 1:
        return Icons.table_restaurant_outlined;
      case 2:
        return Icons.casino_outlined;
      default:
        return Icons.group_add_outlined;
    }
  }

  String _fabLabel(AppStrings s) {
    switch (_tabs.index) {
      case 1:
        return s.hostTable;
      case 2:
        return s.createMafia;
      default:
        return s.newGroup;
    }
  }

  void _onFab(BuildContext context) {
    switch (_tabs.index) {
      case 1:
        context.push('/social/host');
        break;
      case 2:
        context.push('/rooms/games/mafia/create');
        break;
      default:
        context.push('/groups/create');
    }
  }
}

class _GroupsTab extends ConsumerWidget {
  const _GroupsTab({required this.groups});

  final List<ChatConversation> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);

    if (groups.isEmpty) {
      return EmptyState(
        icon: Icons.groups_outlined,
        title: s.roomGroups,
        subtitle: s.findGroups,
        action: FilledButton.icon(
          onPressed: () => context.push('/groups/create'),
          icon: const Icon(Icons.group_add),
          label: Text(s.newGroup),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 100,
      ),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final c = groups[i];
        final preview = c.lastMessage?.text ?? '';
        return ListTile(
          onTap: () => context.push('/chat/${c.id}'),
          leading: AppAvatar(
            name: c.displayTitle,
            url: c.avatarUrl,
            size: 52,
            isGroup: true,
          ),
          title: Text(
            c.displayTitle,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
    );
  }
}

class _TablesTab extends ConsumerWidget {
  const _TablesTab({required this.tables, required this.loading});

  final List<PracticeTable> tables;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tables.isEmpty) {
      return EmptyState(
        icon: Icons.table_restaurant_outlined,
        title: s.roomTables,
        subtitle: s.hostTable,
        action: FilledButton.icon(
          onPressed: () => context.push('/social/host'),
          icon: const Icon(Icons.add),
          label: Text(s.hostTable),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tables.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _TableRoomCard(table: tables[i]),
      ),
    );
  }
}

class _TableRoomCard extends ConsumerWidget {
  const _TableRoomCard({required this.table});

  final PracticeTable table;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s.roomTables,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${table.language} · ${table.levelHint} · ${table.seatsLeft} ${s.seatsLeft}',
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
                  mins <= 0 ? s.starting : s.inMinutes(mins),
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${s.host}: ${table.host.displayName.split(' ').first}',
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
                    child: Text(s.leave),
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
                              ok ? s.joinedTable : s.tableFull,
                              isError: !ok,
                            );
                          },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(table.isJoinable ? s.join : s.full),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesTab extends ConsumerWidget {
  const _GamesTab({required this.rooms});

  final List<GameRoom> rooms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Text(s.mafia, style: context.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(s.mafiaHint, style: context.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        if (rooms.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: EmptyState(
              icon: Icons.casino_outlined,
              title: s.mafia,
              subtitle: s.createMafia,
              action: FilledButton.icon(
                onPressed: () => context.push('/rooms/games/mafia/create'),
                icon: const Icon(Icons.add),
                label: Text(s.createMafia),
              ),
            ),
          )
        else
          ...rooms.map(
            (room) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GameRoomCard(room: room),
            ),
          ),
      ],
    );
  }
}

class _GameRoomCard extends ConsumerWidget {
  const _GameRoomCard({required this.room});

  final GameRoom room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final joined = room.players.any((p) => p.user.id == 'me');
    final statusLabel = switch (room.status) {
      GameRoomStatus.open => s.lobby,
      GameRoomStatus.playing => s.playing,
      GameRoomStatus.ended => s.ended,
    };

    return Material(
      color: context.isDark
          ? AppColors.surfaceElevatedDark
          : AppColors.surfaceElevated,
      borderRadius: AppRadius.borderXl,
      child: InkWell(
        onTap: () => context.push('/rooms/games/mafia/${room.id}'),
        borderRadius: AppRadius.borderXl,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderXl,
            border: Border.all(
              color: context.isDark ? AppColors.borderDark : AppColors.border,
            ),
            boxShadow: context.isDark ? null : AppShadows.soft,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(room.kind.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      room.title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: room.status == GameRoomStatus.playing
                          ? AppColors.error.withOpacity(0.12)
                          : AppColors.primarySurface,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      statusLabel,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: room.status == GameRoomStatus.playing
                            ? AppColors.error
                            : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${room.kind.label} · ${room.language} · '
                '${room.players.length}/${room.kind.maxPlayers}',
                style: context.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ...room.players.take(5).map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AppAvatar(
                            name: p.user.displayName,
                            url: p.user.avatarUrl,
                            size: 28,
                          ),
                        ),
                      ),
                  const Spacer(),
                  if (joined)
                    FilledButton(
                      onPressed: () =>
                          context.push('/rooms/games/mafia/${room.id}'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(s.open),
                    )
                  else
                    FilledButton(
                      onPressed: !room.isJoinable
                          ? null
                          : () {
                              final ok = ref
                                  .read(gameRoomsProvider.notifier)
                                  .join(room.id);
                              if (ok) {
                                context.push('/rooms/games/mafia/${room.id}');
                              } else {
                                context.showSnack(s.tableFull, isError: true);
                              }
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(room.isJoinable ? s.join : s.full),
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
