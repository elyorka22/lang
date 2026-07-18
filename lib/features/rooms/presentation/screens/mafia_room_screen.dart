import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/l10n/app_strings.dart';
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

class MafiaRoomScreen extends ConsumerStatefulWidget {
  const MafiaRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<MafiaRoomScreen> createState() => _MafiaRoomScreenState();
}

class _MafiaRoomScreenState extends ConsumerState<MafiaRoomScreen> {
  final _chatCtrl = TextEditingController();
  final _chatScroll = ScrollController();
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Refresh countdown UI every second while phases auto-advance.
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _chatCtrl.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  void _scrollChatToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScroll.hasClients) return;
      _chatScroll.animateTo(
        _chatScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(appStringsProvider);
    final rooms = ref.watch(gameRoomsProvider);
    GameRoom? room;
    for (final r in rooms) {
      if (r.id == widget.roomId) room = r;
    }

    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.mafia)),
        body: Center(child: Text(s.roomNotFound)),
      );
    }

    final GameRoom active = room;

    ref.listen(gameRoomsProvider, (prev, next) {
      _scrollChatToEnd();
    });

    final me = _findMe(active);
    final isHost = active.host.id == 'me';
    final isNight = active.phase == MafiaPhase.night;
    final isVoting = active.phase == MafiaPhase.voting;
    final theme = _MafiaTheme.of(context.isDark);

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.bg,
        foregroundColor: theme.fg,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              active.title,
              style: TextStyle(
                color: theme.fg,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _phaseLabel(s, active),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (me != null && active.status == GameRoomStatus.open)
            TextButton(
              onPressed: () {
                ref.read(gameRoomsProvider.notifier).leave(widget.roomId);
                context.pop();
              },
              child: Text(s.leave, style: TextStyle(color: theme.fg)),
            ),
        ],
      ),
      body: Column(
        children: [
          _PhaseHeader(room: active, theme: theme, s: s, me: me),
          _PlayersStrip(room: active, theme: theme),
          Expanded(
            child: _ChatPane(
              room: active,
              theme: theme,
              scrollController: _chatScroll,
              s: s,
            ),
          ),
          if (active.status == GameRoomStatus.open)
            _LobbyActions(
              theme: theme,
              s: s,
              isHost: isHost,
              onStart: () {
                final ok = ref
                    .read(gameRoomsProvider.notifier)
                    .startMafia(widget.roomId);
                if (!ok) {
                  context.showSnack(s.needPlayersHint, isError: true);
                }
              },
            ),
          if (active.status == GameRoomStatus.playing && isNight)
            _NightPickPanel(
              room: active,
              theme: theme,
              s: s,
              me: me,
              onSelect: (id) {
                ref
                    .read(gameRoomsProvider.notifier)
                    .selectNightTarget(widget.roomId, id);
              },
            ),
          if (active.status == GameRoomStatus.playing && isVoting)
            _VotePanel(
              room: active,
              theme: theme,
              s: s,
              me: me,
              onVote: (id) {
                ref
                    .read(gameRoomsProvider.notifier)
                    .castVote(widget.roomId, id);
              },
            ),
          if (active.status == GameRoomStatus.ended)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: LinguaButton(
                label: s.backToRooms,
                onPressed: () => context.go('/rooms'),
              ),
            ),
          _ChatComposer(
            controller: _chatCtrl,
            theme: theme,
            s: s,
            enabled: active.chatOpen && (me?.isAlive ?? true),
            hint: !active.chatOpen
                ? s.nightSilence
                : (me != null && !me.isAlive ? s.youAreOut : s.discussHint),
            onSend: () {
              final text = _chatCtrl.text;
              final ok = ref
                  .read(gameRoomsProvider.notifier)
                  .sendChat(widget.roomId, text);
              if (ok) {
                _chatCtrl.clear();
                _scrollChatToEnd();
              } else if (!active.chatOpen) {
                context.showSnack(s.nightSilence, isError: true);
              }
            },
          ),
        ],
      ),
    );
  }

  GameRoomPlayer? _findMe(GameRoom room) {
    for (final p in room.players) {
      if (p.user.id == 'me') return p;
    }
    return null;
  }

  String _phaseLabel(AppStrings s, GameRoom room) {
    final sec = room.secondsLeft;
    final timer = room.phaseEndsAt != null && sec > 0 ? ' · ${sec}s' : '';
    switch (room.phase) {
      case MafiaPhase.lobby:
        return s.lobby;
      case MafiaPhase.night:
        return '${s.nightPhase}$timer';
      case MafiaPhase.day:
        return '${s.dayDiscuss}$timer';
      case MafiaPhase.voting:
        return '${s.dayVote}$timer';
      case MafiaPhase.ended:
        return s.ended;
    }
  }
}

/// Stable brand theme — does NOT flip to dark for night.
class _MafiaTheme {
  const _MafiaTheme({
    required this.bg,
    required this.card,
    required this.fg,
    required this.muted,
    required this.accent,
    required this.bubbleMine,
    required this.bubbleOther,
  });

  final Color bg;
  final Color card;
  final Color fg;
  final Color muted;
  final Color accent;
  final Color bubbleMine;
  final Color bubbleOther;

  static _MafiaTheme of(bool isDark) {
    return _MafiaTheme(
      bg: isDark ? AppColors.backgroundDark : AppColors.background,
      card: isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceElevated,
      fg: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      muted: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      accent: AppColors.primary,
      bubbleMine: AppColors.primary,
      bubbleOther:
          isDark ? AppColors.surfaceElevatedDark : AppColors.primarySurface,
    );
  }
}

class _PhaseHeader extends StatelessWidget {
  const _PhaseHeader({
    required this.room,
    required this.theme,
    required this.s,
    required this.me,
  });

  final GameRoom room;
  final _MafiaTheme theme;
  final AppStrings s;
  final GameRoomPlayer? me;

  @override
  Widget build(BuildContext context) {
    final sec = room.secondsLeft;
    final showTimer =
        room.status == GameRoomStatus.playing && room.phaseEndsAt != null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (me?.role != null && room.status == GameRoomStatus.playing)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${s.yourRole}: ${me!.role!.label}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              const Spacer(),
              if (showTimer)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${s.autoIn} ${sec}s',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          if (room.phaseHint.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              room.phaseHint,
              style: TextStyle(
                color: theme.fg,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (room.lastEvent.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              room.lastEvent,
              style: TextStyle(color: theme.muted, height: 1.3, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlayersStrip extends StatelessWidget {
  const _PlayersStrip({required this.room, required this.theme});

  final GameRoom room;
  final _MafiaTheme theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: room.players.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = room.players[i];
          final dead = !p.isAlive;
          return SizedBox(
            width: 64,
            child: Column(
              children: [
                Opacity(
                  opacity: dead ? 0.35 : 1,
                  child: Stack(
                    children: [
                      AppAvatar(
                        name: p.user.displayName,
                        url: p.user.avatarUrl,
                        size: 48,
                      ),
                      if (dead)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.35),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p.shortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    decoration: dead ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChatPane extends StatelessWidget {
  const _ChatPane({
    required this.room,
    required this.theme,
    required this.scrollController,
    required this.s,
  });

  final GameRoom room;
  final _MafiaTheme theme;
  final ScrollController scrollController;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    if (room.messages.isEmpty) {
      return Center(
        child: Text(
          s.discussHint,
          style: TextStyle(color: theme.muted),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      itemCount: room.messages.length,
      itemBuilder: (_, i) {
        final m = room.messages[i];
        if (m.isSystem) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  m.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }

        final mine = m.senderId == 'me';
        return Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              color: mine ? theme.bubbleMine : theme.bubbleOther,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(mine ? 16 : 4),
                bottomRight: Radius.circular(mine ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!mine)
                  Text(
                    m.senderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mine ? Colors.white70 : theme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                Text(
                  m.text,
                  style: TextStyle(
                    color: mine ? Colors.white : theme.fg,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.theme,
    required this.s,
    required this.enabled,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final _MafiaTheme theme;
  final AppStrings s;
  final bool enabled;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: theme.card,
          border: Border(
            top: BorderSide(color: theme.accent.withOpacity(0.15)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 3,
                style: TextStyle(color: theme.fg),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: theme.muted, fontSize: 14),
                  filled: true,
                  fillColor: theme.bg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: enabled ? (_) => onSend() : null,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enabled ? onSend : null,
              style: IconButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: theme.muted.withOpacity(0.3),
              ),
              icon: const Icon(Icons.send_rounded),
              tooltip: s.send,
            ),
          ],
        ),
      ),
    );
  }
}

class _LobbyActions extends StatelessWidget {
  const _LobbyActions({
    required this.theme,
    required this.s,
    required this.isHost,
    required this.onStart,
  });

  final _MafiaTheme theme;
  final AppStrings s;
  final bool isHost;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: isHost
          ? FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: theme.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(s.startGame),
            )
          : Text(
              s.waitingHost,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.muted),
            ),
    );
  }
}

/// Mafia can lock a target; night still ends on the timer.
class _NightPickPanel extends StatelessWidget {
  const _NightPickPanel({
    required this.room,
    required this.theme,
    required this.s,
    required this.me,
    required this.onSelect,
  });

  final GameRoom room;
  final _MafiaTheme theme;
  final AppStrings s;
  final GameRoomPlayer? me;
  final void Function(String id) onSelect;

  @override
  Widget build(BuildContext context) {
    final isMafia = me?.role == MafiaRole.mafia && (me?.isAlive ?? false);
    final targets = room.players
        .where(
          (p) =>
              p.isAlive && p.user.id != 'me' && p.role != MafiaRole.mafia,
        )
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMafia ? s.pickTargetHint : s.waitNightHint,
            style: TextStyle(
              color: theme.fg,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isMafia) ...[
            const SizedBox(height: 8),
            ...targets.map(
              (p) {
                final selected = room.pendingNightTargetId == p.user.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      AppAvatar(
                        name: p.user.displayName,
                        url: p.user.avatarUrl,
                        size: 36,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          p.shortName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.fg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => onSelect(p.user.id),
                        style: FilledButton.styleFrom(
                          backgroundColor: selected
                              ? AppColors.success
                              : AppColors.primary,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(selected ? s.locked : s.pickTarget),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _VotePanel extends StatelessWidget {
  const _VotePanel({
    required this.room,
    required this.theme,
    required this.s,
    required this.me,
    required this.onVote,
  });

  final GameRoom room;
  final _MafiaTheme theme;
  final AppStrings s;
  final GameRoomPlayer? me;
  final void Function(String id) onVote;

  @override
  Widget build(BuildContext context) {
    final candidates = room.players
        .where((p) => p.isAlive && p.user.id != 'me')
        .toList();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 280),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${s.dayVote} · ${room.secondsLeft}s',
            style: TextStyle(
              color: theme.fg,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (!(me?.isAlive ?? false))
            Text(s.youAreOut, style: TextStyle(color: theme.muted))
          else
            Expanded(
              child: ListView.separated(
                itemCount: candidates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = candidates[i];
                  return Material(
                    color: theme.bg,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          AppAvatar(
                            name: p.user.displayName,
                            url: p.user.avatarUrl,
                            size: 40,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              p.shortName,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.fg,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => onVote(p.user.id),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.accent,
                              foregroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                            child: Text(s.vote),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
