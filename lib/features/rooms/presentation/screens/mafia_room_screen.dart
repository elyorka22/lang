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
  bool _showVotePanel = false;

  @override
  void dispose() {
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

    ref.listen(gameRoomsProvider, (prev, next) {
      _scrollChatToEnd();
    });

    final me = _findMe(room);
    final isHost = room.host.id == 'me';
    final isNight = room.phase == MafiaPhase.night;
    final isDay = room.phase == MafiaPhase.day || room.phase == MafiaPhase.voting;
    final theme = _MafiaTheme.forPhase(room.phase, context.isDark);

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
              room.title,
              style: TextStyle(
                color: theme.fg,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _phaseLabel(s, room),
              style: TextStyle(
                color: theme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (me != null && room.status == GameRoomStatus.open)
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
          _PhaseHeader(room: room, theme: theme, s: s, me: me),
          _PlayersStrip(room: room, theme: theme),
          Expanded(
            child: _ChatPane(
              room: room,
              theme: theme,
              scrollController: _chatScroll,
              s: s,
            ),
          ),
          if (room.status == GameRoomStatus.open)
            _LobbyActions(
              theme: theme,
              s: s,
              isHost: isHost,
              onStart: () {
                final ok =
                    ref.read(gameRoomsProvider.notifier).startMafia(widget.roomId);
                if (!ok) {
                  context.showSnack(s.needPlayersHint, isError: true);
                }
              },
            ),
          if (room.status == GameRoomStatus.playing && isNight)
            _NightActions(
              room: room,
              theme: theme,
              s: s,
              me: me,
              onKill: (id) {
                ref
                    .read(gameRoomsProvider.notifier)
                    .resolveNight(widget.roomId, killTargetId: id);
              },
              onSkip: () {
                ref.read(gameRoomsProvider.notifier).resolveNight(widget.roomId);
              },
            ),
          if (room.status == GameRoomStatus.playing && isDay) ...[
            if (_showVotePanel)
              _VotePanel(
                room: room,
                theme: theme,
                s: s,
                me: me,
                onVote: (id) {
                  ref
                      .read(gameRoomsProvider.notifier)
                      .castVote(widget.roomId, id);
                  setState(() => _showVotePanel = false);
                },
                onClose: () => setState(() => _showVotePanel = false),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: (me?.isAlive ?? false)
                        ? () => setState(() => _showVotePanel = true)
                        : null,
                    icon: const Icon(Icons.how_to_vote_rounded),
                    label: Text(s.vote),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
          ],
          if (room.status == GameRoomStatus.ended)
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
            enabled: room.chatOpen && (me?.isAlive ?? true),
            hint: !room.chatOpen
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
              } else if (!room.chatOpen) {
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
    switch (room.phase) {
      case MafiaPhase.lobby:
        return s.lobby;
      case MafiaPhase.night:
        return '${s.nightPhase} · ${room.round}';
      case MafiaPhase.day:
      case MafiaPhase.voting:
        return '${s.dayVote} · ${room.round}';
      case MafiaPhase.ended:
        return s.ended;
    }
  }
}

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

  static _MafiaTheme forPhase(MafiaPhase phase, bool isDark) {
    if (phase == MafiaPhase.night) {
      return const _MafiaTheme(
        bg: Color(0xFF0F0C1D),
        card: Color(0xFF1A1530),
        fg: Color(0xFFF3EEFF),
        muted: Color(0xFF9B93B0),
        accent: Color(0xFF8B5CF6),
        bubbleMine: Color(0xFF5B21B6),
        bubbleOther: Color(0xFF241B3E),
      );
    }
    if (phase == MafiaPhase.day || phase == MafiaPhase.voting) {
      return _MafiaTheme(
        bg: isDark ? const Color(0xFF1A1428) : const Color(0xFFFFF8F0),
        card: isDark ? const Color(0xFF241C38) : Colors.white,
        fg: isDark ? const Color(0xFFF5F3FF) : const Color(0xFF1E1333),
        muted: isDark ? const Color(0xFFA89BC4) : AppColors.textSecondary,
        accent: const Color(0xFFEAB308),
        bubbleMine: const Color(0xFF7C3AED),
        bubbleOther:
            isDark ? const Color(0xFF2A2140) : const Color(0xFFF3E8FF),
      );
    }
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (me?.role != null && room.status == GameRoomStatus.playing)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${s.yourRole}: ${me!.role!.label}',
                style: TextStyle(
                  color: theme.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          if (room.lastEvent.isNotEmpty)
            Text(
              room.lastEvent,
              style: TextStyle(color: theme.fg, height: 1.35),
            ),
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

class _NightActions extends StatelessWidget {
  const _NightActions({
    required this.room,
    required this.theme,
    required this.s,
    required this.me,
    required this.onKill,
    required this.onSkip,
  });

  final GameRoom room;
  final _MafiaTheme theme;
  final AppStrings s;
  final GameRoomPlayer? me;
  final void Function(String id) onKill;
  final VoidCallback onSkip;

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
            s.nightPhase,
            style: TextStyle(
              color: theme.fg,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (isMafia)
            ...targets.map(
              (p) => Padding(
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
                      onPressed: () => onKill(p.user.id),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(s.eliminate),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSkip,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.fg,
                  side: BorderSide(color: theme.accent.withOpacity(0.5)),
                ),
                child: Text(s.skipNight),
              ),
            ),
        ],
      ),
    );
  }
}

/// Vote list with fixed layout so names never overflow/break.
class _VotePanel extends StatelessWidget {
  const _VotePanel({
    required this.room,
    required this.theme,
    required this.s,
    required this.me,
    required this.onVote,
    required this.onClose,
  });

  final GameRoom room;
  final _MafiaTheme theme;
  final AppStrings s;
  final GameRoomPlayer? me;
  final void Function(String id) onVote;
  final VoidCallback onClose;

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
        border: Border.all(color: theme.accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.dayVote,
                  style: TextStyle(
                    color: theme.fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close, color: theme.muted),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
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
