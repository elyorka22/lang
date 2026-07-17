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

  /// Assign roles and move to night phase.
  /// If seats are short, fills with mock players so a solo host can demo.
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
      ),
    );
    return true;
  }

  /// Demo night: mafia picks a random living citizen-side target.
  void resolveNight(String roomId, {String? killTargetId}) {
    final room = byId(roomId);
    if (room == null || room.phase != MafiaPhase.night) return;

    final living = room.players.where((p) => p.isAlive).toList();
    final civilians = living
        .where((p) => p.role != MafiaRole.mafia)
        .toList();
    if (civilians.isEmpty) {
      _end(room, townWins: false);
      return;
    }

    String targetId = killTargetId ?? '';
    if (targetId.isEmpty ||
        !civilians.any((p) => p.user.id == targetId)) {
      targetId = civilians[_random.nextInt(civilians.length)].user.id;
    }

    final nextPlayers = room.players.map((p) {
      if (p.user.id == targetId) return p.copyWith(isAlive: false);
      return p;
    }).toList();

    final victim = nextPlayers.firstWhere((p) => p.user.id == targetId);
    final updated = room.copyWith(
      players: nextPlayers,
      phase: MafiaPhase.day,
      lastEvent:
          '${victim.user.displayName.split(' ').first} was eliminated at night.',
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

    final accused =
        nextPlayers.firstWhere((p) => p.user.id == accusedId);
    final updated = room.copyWith(
      players: nextPlayers,
      phase: MafiaPhase.night,
      round: room.round + 1,
      lastEvent:
          'Town voted out ${accused.user.displayName.split(' ').first}'
          '${accused.role != null ? ' (${accused.role!.label})' : ''}.',
    );

    if (_checkWin(updated)) return;
    _replace(
      updated.copyWith(
        lastEvent:
            '${updated.lastEvent} Night ${updated.round} begins.',
      ),
    );
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
    _replace(
      room.copyWith(
        status: GameRoomStatus.ended,
        phase: MafiaPhase.ended,
        lastEvent: townWins ? 'Town wins!' : 'Mafia wins!',
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

/// Current user profile helper for game UIs.
UserProfile get mePlayer => MockData.currentUser;
