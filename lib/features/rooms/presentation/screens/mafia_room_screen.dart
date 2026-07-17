import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/game_room.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/lingua_button.dart';
import '../../../../shared/widgets/safe_body.dart';
import '../../application/game_rooms_controller.dart';

class CreateMafiaRoomScreen extends ConsumerStatefulWidget {
  const CreateMafiaRoomScreen({super.key});

  @override
  ConsumerState<CreateMafiaRoomScreen> createState() =>
      _CreateMafiaRoomScreenState();
}

class _CreateMafiaRoomScreenState extends ConsumerState<CreateMafiaRoomScreen> {
  final _title = TextEditingController(text: 'Mafia night');
  String _language = 'English';

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.createMafia)),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(s.mafiaHint, style: context.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _title,
              decoration: InputDecoration(
                labelText: s.roomTitle,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _language,
              decoration: InputDecoration(
                labelText: s.language,
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Russian', child: Text('Русский')),
                DropdownMenuItem(value: 'Uzbek', child: Text("O‘zbek")),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _language = v);
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${s.minPlayers}: ${GameKind.mafia.minPlayers} · '
              '${s.maxPlayers}: ${GameKind.mafia.maxPlayers}',
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            LinguaButton(
              label: s.createMafia,
              onPressed: () {
                final id = ref.read(gameRoomsProvider.notifier).createMafiaRoom(
                      title: _title.text,
                      language: _language,
                    );
                context.pushReplacement('/rooms/games/mafia/$id');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MafiaRoomScreen extends ConsumerWidget {
  const MafiaRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final rooms = ref.watch(gameRoomsProvider);
    GameRoom? room;
    for (final r in rooms) {
      if (r.id == roomId) room = r;
    }

    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.mafia)),
        body: Center(child: Text(s.roomNotFound)),
      );
    }

    final me = room.players.where((p) => p.user.id == 'me').firstOrNull;
    final isHost = room.host.id == 'me';
    final myRole = me?.role;

    return Scaffold(
      appBar: AppBar(
        title: Text(room.title),
        actions: [
          if (me != null && room.status == GameRoomStatus.open)
            TextButton(
              onPressed: () {
                ref.read(gameRoomsProvider.notifier).leave(roomId);
                context.pop();
              },
              child: Text(s.leave),
            ),
        ],
      ),
      body: SafeBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _PhaseBanner(room: room),
            const SizedBox(height: 16),
            if (myRole != null && room.status == GameRoomStatus.playing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.yourRole}: ${myRole.label}',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(myRole.hint, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              '${s.players} (${room.players.length}/${room.kind.maxPlayers})',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...room.players.map((p) {
              final dead = !p.isAlive;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Opacity(
                  opacity: dead ? 0.4 : 1,
                  child: AppAvatar(
                    name: p.user.displayName,
                    url: p.user.avatarUrl,
                    size: 44,
                  ),
                ),
                title: Text(
                  p.user.displayName,
                  style: TextStyle(
                    decoration: dead ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  p.user.id == room!.host.id
                      ? s.host
                      : (dead ? s.eliminated : s.alive),
                ),
                trailing: room.status == GameRoomStatus.ended && p.role != null
                    ? Text(p.role!.label)
                    : null,
              );
            }),
            const SizedBox(height: AppSpacing.lg),
            if (room.status == GameRoomStatus.open) ...[
              if (isHost)
                LinguaButton(
                  label: s.startGame,
                  onPressed: () {
                    final ok = ref
                        .read(gameRoomsProvider.notifier)
                        .startMafia(roomId);
                    if (!ok) {
                      context.showSnack(s.needPlayersHint, isError: true);
                    }
                  },
                )
              else
                Text(
                  s.waitingHost,
                  style: context.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
            ],
            if (room.status == GameRoomStatus.playing) ...[
              if (room.phase == MafiaPhase.night) ...[
                Text(s.nightPhase, style: context.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (myRole == MafiaRole.mafia && (me?.isAlive ?? false))
                  ...room.players
                      .where((p) =>
                          p.isAlive &&
                          p.user.id != 'me' &&
                          p.role != MafiaRole.mafia)
                      .map(
                        (p) => ListTile(
                          leading: AppAvatar(
                            name: p.user.displayName,
                            url: p.user.avatarUrl,
                            size: 36,
                          ),
                          title: Text(p.user.displayName),
                          trailing: FilledButton(
                            onPressed: () {
                              ref
                                  .read(gameRoomsProvider.notifier)
                                  .resolveNight(
                                    roomId,
                                    killTargetId: p.user.id,
                                  );
                            },
                            child: Text(s.eliminate),
                          ),
                        ),
                      )
                else
                  LinguaButton(
                    label: s.skipNight,
                    onPressed: () {
                      ref
                          .read(gameRoomsProvider.notifier)
                          .resolveNight(roomId);
                    },
                  ),
              ],
              if (room.phase == MafiaPhase.day ||
                  room.phase == MafiaPhase.voting) ...[
                Text(s.dayVote, style: context.textTheme.titleSmall),
                const SizedBox(height: 8),
                if (me?.isAlive ?? false)
                  ...room.players
                      .where((p) => p.isAlive && p.user.id != 'me')
                      .map(
                        (p) => ListTile(
                          leading: AppAvatar(
                            name: p.user.displayName,
                            url: p.user.avatarUrl,
                            size: 36,
                          ),
                          title: Text(p.user.displayName),
                          trailing: OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(gameRoomsProvider.notifier)
                                  .castVote(roomId, p.user.id);
                            },
                            child: Text(s.vote),
                          ),
                        ),
                      )
                else
                  Text(s.youAreOut, style: context.textTheme.bodyMedium),
              ],
            ],
            if (room.status == GameRoomStatus.ended) ...[
              Text(
                room.lastEvent,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              LinguaButton(
                label: s.backToRooms,
                onPressed: () => context.go('/rooms'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhaseBanner extends StatelessWidget {
  const _PhaseBanner({required this.room});

  final GameRoom room;

  @override
  Widget build(BuildContext context) {
    final color = switch (room.phase) {
      MafiaPhase.night => const Color(0xFF1E1B4B),
      MafiaPhase.day || MafiaPhase.voting => AppColors.warning,
      MafiaPhase.ended => AppColors.success,
      MafiaPhase.lobby => AppColors.primary,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.phase.name.toUpperCase() +
                (room.round > 0 ? ' · Round ${room.round}' : ''),
            style: context.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (room.lastEvent.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(room.lastEvent, style: context.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
