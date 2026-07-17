import 'package:equatable/equatable.dart';

import 'user_profile.dart';

/// Kind of multiplayer game room. Add new values as games ship.
enum GameKind { mafia }

enum GameRoomStatus { open, playing, ended }

enum MafiaRole { citizen, mafia, detective, doctor }

enum MafiaPhase { lobby, night, day, voting, ended }

extension GameKindX on GameKind {
  String get label {
    switch (this) {
      case GameKind.mafia:
        return 'Mafia';
    }
  }

  String get emoji {
    switch (this) {
      case GameKind.mafia:
        return '🕵️';
    }
  }

  int get minPlayers {
    switch (this) {
      case GameKind.mafia:
        return 5;
    }
  }

  int get maxPlayers {
    switch (this) {
      case GameKind.mafia:
        return 10;
    }
  }
}

extension MafiaRoleX on MafiaRole {
  String get label {
    switch (this) {
      case MafiaRole.citizen:
        return 'Citizen';
      case MafiaRole.mafia:
        return 'Mafia';
      case MafiaRole.detective:
        return 'Detective';
      case MafiaRole.doctor:
        return 'Doctor';
    }
  }

  String get hint {
    switch (this) {
      case MafiaRole.citizen:
        return 'Find the mafia and vote them out.';
      case MafiaRole.mafia:
        return 'Eliminate citizens at night. Stay hidden.';
      case MafiaRole.detective:
        return 'Check one player each night.';
      case MafiaRole.doctor:
        return 'Save one player each night.';
    }
  }
}

class GameRoomPlayer extends Equatable {
  const GameRoomPlayer({
    required this.user,
    this.role,
    this.isAlive = true,
  });

  final UserProfile user;
  final MafiaRole? role;
  final bool isAlive;

  GameRoomPlayer copyWith({
    MafiaRole? role,
    bool? isAlive,
  }) {
    return GameRoomPlayer(
      user: user,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
    );
  }

  @override
  List<Object?> get props => [user.id, role, isAlive];
}

/// Multiplayer game session treated as a room (like groups & tables).
class GameRoom extends Equatable {
  const GameRoom({
    required this.id,
    required this.kind,
    required this.title,
    required this.host,
    required this.players,
    required this.createdAt,
    this.language = 'English',
    this.status = GameRoomStatus.open,
    this.phase = MafiaPhase.lobby,
    this.round = 0,
    this.lastEvent = '',
  });

  final String id;
  final GameKind kind;
  final String title;
  final UserProfile host;
  final List<GameRoomPlayer> players;
  final DateTime createdAt;
  final String language;
  final GameRoomStatus status;
  final MafiaPhase phase;
  final int round;
  final String lastEvent;

  int get seatsLeft => kind.maxPlayers - players.length;
  bool get isJoinable =>
      status == GameRoomStatus.open && seatsLeft > 0;
  bool get canStart =>
      status == GameRoomStatus.open &&
      players.length >= kind.minPlayers;

  GameRoom copyWith({
    List<GameRoomPlayer>? players,
    GameRoomStatus? status,
    MafiaPhase? phase,
    int? round,
    String? lastEvent,
  }) {
    return GameRoom(
      id: id,
      kind: kind,
      title: title,
      host: host,
      players: players ?? this.players,
      createdAt: createdAt,
      language: language,
      status: status ?? this.status,
      phase: phase ?? this.phase,
      round: round ?? this.round,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }

  @override
  List<Object?> get props =>
      [id, status, phase, round, players.length, lastEvent];
}
