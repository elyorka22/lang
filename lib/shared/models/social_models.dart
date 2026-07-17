import 'package:equatable/equatable.dart';

import 'user_profile.dart';

enum RoomTopic { travel, jobs, social }

enum TableStatus { open, full, live, ended }

extension RoomTopicX on RoomTopic {
  String get label {
    switch (this) {
      case RoomTopic.travel:
        return 'Travel';
      case RoomTopic.jobs:
        return 'Jobs';
      case RoomTopic.social:
        return 'Social';
    }
  }

  String get emoji {
    switch (this) {
      case RoomTopic.travel:
        return '✈️';
      case RoomTopic.jobs:
        return '💼';
      case RoomTopic.social:
        return '☕';
    }
  }

  String get blurb {
    switch (this) {
      case RoomTopic.travel:
        return 'Airports, hotels, directions, culture';
      case RoomTopic.jobs:
        return 'Interviews, meetings, email tone';
      case RoomTopic.social:
        return 'Daily chat, hobbies, meeting people';
    }
  }
}

class LanguageRoom extends Equatable {
  const LanguageRoom({
    required this.id,
    required this.topic,
    required this.title,
    required this.language,
    required this.memberCount,
    required this.onlineCount,
    this.description = '',
  });

  final String id;
  final RoomTopic topic;
  final String title;
  final String language;
  final String description;
  final int memberCount;
  final int onlineCount;

  @override
  List<Object?> get props => [id, topic, memberCount, onlineCount];
}

class PracticeTable extends Equatable {
  const PracticeTable({
    required this.id,
    required this.topic,
    required this.title,
    required this.host,
    required this.startsAt,
    required this.durationMinutes,
    required this.maxSeats,
    required this.participants,
    this.language = 'English',
    this.status = TableStatus.open,
    this.levelHint = 'A2–B2',
  });

  final String id;
  final RoomTopic topic;
  final String title;
  final UserProfile host;
  final DateTime startsAt;
  final int durationMinutes;
  final int maxSeats;
  final List<UserProfile> participants;
  final String language;
  final TableStatus status;
  final String levelHint;

  int get seatsLeft => maxSeats - participants.length;
  bool get isJoinable =>
      status == TableStatus.open && seatsLeft > 0;

  PracticeTable copyWith({
    List<UserProfile>? participants,
    TableStatus? status,
  }) {
    return PracticeTable(
      id: id,
      topic: topic,
      title: title,
      host: host,
      startsAt: startsAt,
      durationMinutes: durationMinutes,
      maxSeats: maxSeats,
      participants: participants ?? this.participants,
      language: language,
      status: status ?? this.status,
      levelHint: levelHint,
    );
  }

  @override
  List<Object?> get props => [id, participants.length, status];
}

class MentorProfile extends Equatable {
  const MentorProfile({
    required this.user,
    required this.karma,
    required this.correctionsHelped,
    required this.isMentor,
  });

  final UserProfile user;
  final int karma;
  final int correctionsHelped;
  final bool isMentor;

  @override
  List<Object?> get props => [user.id, karma, isMentor];
}
