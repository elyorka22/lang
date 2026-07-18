import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/data/mock_data.dart';
import '../../../shared/models/game_room.dart';
import '../../../shared/models/user_profile.dart';

final gameRoomsProvider =
    StateNotifierProvider<GameRoomsController, List<GameRoom>>((ref) {
  return GameRoomsController()..seed();
});

class GameRoomsController extends StateNotifier<List<GameRoom>> {
  GameRoomsController() : super(const []);

  final _uuid = const Uuid();
  final _random = Random();

  void seed() {
    final now = DateTime.now();
    state = [
      GameRoom(
        id: 'gr_mafia_1',
        kind: GameKind.mafia,
        title: 'Night Mafia · EN',
        host: MockData.users[0],
        language: 'English',
        createdAt: now.subtract(const Duration(minutes: 8)),
        players: [
          GameRoomPlayer(user: MockData.users[0]),
          GameRoomPlayer(user: MockData.users[1]),
          GameRoomPlayer(user: MockData.users[2]),
          GameRoomPlayer(user: MockData.users[3]),
        ],
        messages: [
          GameRoomMessage(
            id: 'm0',
            senderId: 'system',
            senderName: 'System',
            text: 'Waiting for more players…',
            sentAt: now.subtract(const Duration(minutes: 7)),
            isSystem: true,
          ),
        ],
      ),
      GameRoom(
        id: 'gr_mafia_2',
        kind: GameKind.mafia,
        title: 'Мафия · RU',
        host: MockData.users[3],
        language: 'Russian',
        createdAt: now.subtract(const Duration(minutes: 20)),
        players: [
          GameRoomPlayer(user: MockData.users[3]),
          GameRoomPlayer(user: MockData.users[4]),
          GameRoomPlayer(user: MockData.users[0]),
          GameRoomPlayer(user: MockData.users[2]),
          GameRoomPlayer(user: MockData.users[1]),
          GameRoomPlayer(user: MockData.currentUser),
        ],
        messages: [
          GameRoomMessage(
            id: 'm1',
            senderId: MockData.users[3].id,
            senderName: MockData.users[3].displayName.split(' ').first,
            text: 'Готовы? Давайте начнём!',
            sentAt: now.subtract(const Duration(minutes: 18)),
          ),
          GameRoomMessage(
            id: 'm2',
            senderId: MockData.users[0].id,
            senderName: MockData.users[0].displayName.split(' ').first,
            text: 'Я готов 👍',
            sentAt: now.subtract(const Duration(minutes: 17)),
          ),
        ],
      ),
    ];
  }

  GameRoom? byId(String id) {
    for (final room in state) {
      if (room.id == id) return room;
    }
    return null;
  }

  String createMafiaRoom({
    required String title,
    String language = 'English',
  }) {
    final me = MockData.currentUser;
    final id = 'gr_${_uuid.v4().substring(0, 8)}';
    final room = GameRoom(
      id: id,
      kind: GameKind.mafia,
      title: title.trim().isEmpty ? 'Mafia room' : title.trim(),
      host: me,
      language: language,
      createdAt: DateTime.now(),
      players: [GameRoomPlayer(user: me)],
      messages: [
        GameRoomMessage(
          id: _uuid.v4(),
          senderId: 'system',
          senderName: 'System',
          text: 'Room created. Invite friends or start when ready.',
          sentAt: DateTime.now(),
          isSystem: true,
        ),
      ],
    );
    state = [room, ...state];
    return id;
  }

  bool join(String roomId) {
    final room = byId(roomId);
    if (room == null || !room.isJoinable) return false;
    final me = MockData.currentUser;
    if (room.players.any((p) => p.user.id == me.id)) return true;
    final next = room.copyWith(
      players: [...room.players, GameRoomPlayer(user: me)],
      messages: [
        ...room.messages,
        GameRoomMessage(
          id: _uuid.v4(),
          senderId: 'system',
          senderName: 'System',
          text: '${me.displayName.split(' ').first} joined the room.',
          sentAt: DateTime.now(),
          isSystem: true,
        ),
      ],
    );
    _replace(next);
    return true;
  }

  void leave(String roomId) {
    final room = byId(roomId);
    if (room == null) return;
    final me = MockData.currentUser;
    if (room.host.id == me.id && room.status == GameRoomStatus.open) {
      state = state.where((r) => r.id != roomId).toList();
      return;
    }
    final players =
        room.players.where((p) => p.user.id != me.id).toList();
    if (players.isEmpty) {
      state = state.where((r) => r.id != roomId).toList();
      return;
    }
    _replace(room.copyWith(players: players));
  }

  /// Send a chat message. Allowed in lobby, day, voting, ended.
  bool sendChat(String roomId, String text) {
    final room = byId(roomId);
    if (room == null || !room.chatOpen) return false;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final me = MockData.currentUser;
    final myPlayer = room.players.where((p) => p.user.id == me.id);
    if (myPlayer.isEmpty) return false;
    if (room.status == GameRoomStatus.playing && !myPlayer.first.isAlive) {
      return false;
    }

    final msg = GameRoomMessage(
      id: _uuid.v4(),
      senderId: me.id,
      senderName: me.displayName.split(' ').first,
      text: trimmed,
      sentAt: DateTime.now(),
    );
    var next = room.copyWith(messages: [...room.messages, msg]);
    _replace(next);

    // Light demo: bots reply during day discussion.
    if (room.phase == MafiaPhase.day || room.phase == MafiaPhase.voting) {
      _scheduleBotReply(roomId);
    }
    return true;
  }

  void _scheduleBotReply(String roomId) {
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      final room = byId(roomId);
      if (room == null || !room.chatOpen) return;
      if (room.phase != MafiaPhase.day && room.phase != MafiaPhase.voting) {
        return;
      }
      final bots = room.players
          .where((p) => p.isAlive && p.user.id != 'me')
          .toList();
      if (bots.isEmpty) return;
      final bot = bots[_random.nextInt(bots.length)];
      const lines = [
        'I think we should look at who was quiet last night.',
        'Кто-то ведёт себя подозрительно…',
        'Not sure yet — need more clues.',
        'Давайте обсудим перед голосованием.',
        'I trust the detective if they speak up.',
        'Maybe we vote carefully this round.',
      ];
      final reply = GameRoomMessage(
        id: _uuid.v4(),
        senderId: bot.user.id,
        senderName: bot.shortName,
        text: lines[_random.nextInt(lines.length)],
        sentAt: DateTime.now(),
      );
      final latest = byId(roomId);
      if (latest == null) return;
      _replace(latest.copyWith(messages: [...latest.messages, reply]));
    });
  }

  bool startMafia(String roomId) {
    final room = byId(roomId);
    if (room == null || room.status != GameRoomStatus.open) return false;
    if (room.host.id != MockData.currentUser.id) return false;

    var players = [...room.players];
    if (players.length < room.kind.minPlayers) {
      for (final user in MockData.users) {
        if (players.length >= room.kind.minPlayers) break;
        if (players.any((p) => p.user.id == user.id)) continue;
        players.add(GameRoomPlayer(user: user));
      }
    }
    if (players.length < room.kind.minPlayers) return false;

    final assigned = _assignMafiaRoles(players);
    _replace(
      room.copyWith(
        players: assigned,
        status: GameRoomStatus.playing,
        phase: MafiaPhase.night,
        round: 1,
        lastEvent: 'Night 1 — mafia wakes up.',
        messages: [
          ...room.messages,
          GameRoomMessage(
            id: _uuid.v4(),
            senderId: 'system',
            senderName: 'System',
            text: 'Game started. Night falls — discussion paused.',
            sentAt: DateTime.now(),
            isSystem: true,
          ),
        ],
      ),
    );
    return true;
  }

  void resolveNight(String roomId, {String? killTargetId}) {
    final room = byId(roomId);
    if (room == null || room.phase != MafiaPhase.night) return;

    final living = room.players.where((p) => p.isAlive).toList();
    final civilians =
        living.where((p) => p.role != MafiaRole.mafia).toList();
    if (civilians.isEmpty) {
      _end(room, townWins: false);
      return;
    }

    var targetId = killTargetId ?? '';
    if (targetId.isEmpty ||
        !civilians.any((p) => p.user.id == targetId)) {
      targetId = civilians[_random.nextInt(civilians.length)].user.id;
    }

    final nextPlayers = room.players.map((p) {
      if (p.user.id == targetId) return p.copyWith(isAlive: false);
      return p;
    }).toList();

    final victim = nextPlayers.firstWhere((p) => p.user.id == targetId);
    final event =
        '${victim.shortName} was eliminated at night. Discuss and vote.';
    final updated = room.copyWith(
      players: nextPlayers,
      phase: MafiaPhase.day,
      lastEvent: event,
      messages: [
        ...room.messages,
        GameRoomMessage(
          id: _uuid.v4(),
          senderId: 'system',
          senderName: 'System',
          text: '☀️ Day ${room.round}: $event',
          sentAt: DateTime.now(),
          isSystem: true,
        ),
      ],
    );

    if (_checkWin(updated)) return;
    _replace(updated);
  }

  void castVote(String roomId, String accusedId) {
    final room = byId(roomId);
    if (room == null) return;
    if (room.phase != MafiaPhase.day && room.phase != MafiaPhase.voting) {
      return;
    }

    final living = room.players.where((p) => p.isAlive).toList();
    if (!living.any((p) => p.user.id == accusedId)) return;

    final nextPlayers = room.players.map((p) {
      if (p.user.id == accusedId) return p.copyWith(isAlive: false);
      return p;
    }).toList();

    final accused = nextPlayers.firstWhere((p) => p.user.id == accusedId);
    final roleBit =
        accused.role != null ? ' (${accused.role!.label})' : '';
    final event = 'Town voted out ${accused.shortName}$roleBit.';
    final nextRound = room.round + 1;
    final updated = room.copyWith(
      players: nextPlayers,
      phase: MafiaPhase.night,
      round: nextRound,
      lastEvent: '$event Night $nextRound begins.',
      messages: [
        ...room.messages,
        GameRoomMessage(
          id: _uuid.v4(),
          senderId: 'system',
          senderName: 'System',
          text: '🗳️ $event Night falls again.',
          sentAt: DateTime.now(),
          isSystem: true,
        ),
      ],
    );

    if (_checkWin(updated)) return;
    _replace(updated);
  }

  List<GameRoomPlayer> _assignMafiaRoles(List<GameRoomPlayer> players) {
    final shuffled = [...players]..shuffle(_random);
    final n = shuffled.length;
    final mafiaCount = n >= 8 ? 2 : 1;
    final roles = <MafiaRole>[];

    for (var i = 0; i < mafiaCount; i++) {
      roles.add(MafiaRole.mafia);
    }
    roles.add(MafiaRole.detective);
    if (n >= 6) roles.add(MafiaRole.doctor);
    while (roles.length < n) {
      roles.add(MafiaRole.citizen);
    }
    roles.shuffle(_random);

    return [
      for (var i = 0; i < n; i++)
        shuffled[i].copyWith(role: roles[i], isAlive: true),
    ];
  }

  bool _checkWin(GameRoom room) {
    final living = room.players.where((p) => p.isAlive).toList();
    final mafiaAlive =
        living.where((p) => p.role == MafiaRole.mafia).length;
    final townAlive = living.length - mafiaAlive;

    if (mafiaAlive == 0) {
      _end(room, townWins: true);
      return true;
    }
    if (mafiaAlive >= townAlive) {
      _end(room, townWins: false);
      return true;
    }
    return false;
  }

  void _end(GameRoom room, {required bool townWins}) {
    final text = townWins ? 'Town wins!' : 'Mafia wins!';
    _replace(
      room.copyWith(
        status: GameRoomStatus.ended,
        phase: MafiaPhase.ended,
        lastEvent: text,
        messages: [
          ...room.messages,
          GameRoomMessage(
            id: _uuid.v4(),
            senderId: 'system',
            senderName: 'System',
            text: '🏁 $text',
            sentAt: DateTime.now(),
            isSystem: true,
          ),
        ],
      ),
    );
  }

  void _replace(GameRoom room) {
    state = [
      for (final r in state)
        if (r.id == room.id) room else r,
    ];
  }
}

UserProfile get mePlayer => MockData.currentUser;
