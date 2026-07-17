import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/data/mock_data.dart';
import '../../../shared/models/social_models.dart';

/// Karma needed to unlock Mentor badge.
const int mentorKarmaThreshold = 120;
const int karmaPerThanks = 15;

final socialControllerProvider =
    StateNotifierProvider<SocialController, SocialState>((ref) {
  return SocialController()..load();
});

class SocialState {
  const SocialState({
    this.rooms = const [],
    this.tables = const [],
    this.mentors = const [],
    this.myKarma = 0,
    this.myCorrectionsHelped = 0,
    this.isLoading = true,
  });

  final List<LanguageRoom> rooms;
  final List<PracticeTable> tables;
  final List<MentorProfile> mentors;
  final int myKarma;
  final int myCorrectionsHelped;
  final bool isLoading;

  bool get iAmMentor => myKarma >= mentorKarmaThreshold;

  SocialState copyWith({
    List<LanguageRoom>? rooms,
    List<PracticeTable>? tables,
    List<MentorProfile>? mentors,
    int? myKarma,
    int? myCorrectionsHelped,
    bool? isLoading,
  }) {
    return SocialState(
      rooms: rooms ?? this.rooms,
      tables: tables ?? this.tables,
      mentors: mentors ?? this.mentors,
      myKarma: myKarma ?? this.myKarma,
      myCorrectionsHelped: myCorrectionsHelped ?? this.myCorrectionsHelped,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SocialController extends StateNotifier<SocialState> {
  SocialController() : super(const SocialState());

  final _uuid = const Uuid();

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    state = SocialState(
      isLoading: false,
      myKarma: 45,
      myCorrectionsHelped: 3,
      rooms: const [
        LanguageRoom(
          id: 'room_travel',
          topic: RoomTopic.travel,
          title: 'Travel Desk',
          language: 'Multi',
          description: 'Airports, hotels, getting around, small talk abroad',
          memberCount: 1284,
          onlineCount: 46,
        ),
        LanguageRoom(
          id: 'room_jobs',
          topic: RoomTopic.jobs,
          title: 'Jobs & Career',
          language: 'EN / ES / DE',
          description: 'Interviews, meetings, polite email phrases',
          memberCount: 892,
          onlineCount: 31,
        ),
        LanguageRoom(
          id: 'room_social',
          topic: RoomTopic.social,
          title: 'Social Lounge',
          language: 'Multi',
          description: 'Hobbies, weekend plans, making friends naturally',
          memberCount: 2103,
          onlineCount: 67,
        ),
      ],
      tables: [
        PracticeTable(
          id: 't1',
          topic: RoomTopic.travel,
          title: 'Airport check-in roleplay',
          host: MockData.users[0],
          startsAt: now.add(const Duration(minutes: 12)),
          durationMinutes: 30,
          maxSeats: 4,
          participants: [MockData.users[0], MockData.users[3]],
          language: 'Spanish',
          levelHint: 'A2–B1',
        ),
        PracticeTable(
          id: 't2',
          topic: RoomTopic.jobs,
          title: 'Mock interview warm-up',
          host: MockData.users[1],
          startsAt: now.add(const Duration(minutes: 40)),
          durationMinutes: 30,
          maxSeats: 4,
          participants: [MockData.users[1]],
          language: 'English',
          levelHint: 'B1–C1',
        ),
        PracticeTable(
          id: 't3',
          topic: RoomTopic.social,
          title: 'Weekend plans chat',
          host: MockData.users[3],
          startsAt: now.add(const Duration(hours: 1)),
          durationMinutes: 30,
          maxSeats: 4,
          participants: [
            MockData.users[3],
            MockData.users[2],
            MockData.currentUser,
          ],
          language: 'French',
          levelHint: 'A2–B2',
        ),
      ],
      mentors: [
        MentorProfile(
          user: MockData.users[0].copyWith(
            badges: [...MockData.users[0].badges, 'mentor'],
          ),
          karma: 420,
          correctionsHelped: 86,
          isMentor: true,
        ),
        MentorProfile(
          user: MockData.users[1].copyWith(
            badges: [...MockData.users[1].badges, 'mentor'],
          ),
          karma: 310,
          correctionsHelped: 54,
          isMentor: true,
        ),
        MentorProfile(
          user: MockData.users[3],
          karma: 95,
          correctionsHelped: 12,
          isMentor: false,
        ),
      ],
    );
  }

  Future<PracticeTable> hostTable({
    required String title,
    required RoomTopic topic,
    required String language,
    String levelHint = 'A2–B2',
    int durationMinutes = 30,
    int maxSeats = 4,
  }) async {
    final table = PracticeTable(
      id: 't_${_uuid.v4().substring(0, 8)}',
      topic: topic,
      title: title.trim(),
      host: MockData.currentUser,
      startsAt: DateTime.now().add(const Duration(minutes: 5)),
      durationMinutes: durationMinutes,
      maxSeats: maxSeats.clamp(2, 4),
      participants: [MockData.currentUser],
      language: language,
      levelHint: levelHint,
    );
    state = state.copyWith(tables: [table, ...state.tables]);
    return table;
  }

  bool joinTable(String tableId) {
    final updated = <PracticeTable>[];
    var joined = false;
    for (final t in state.tables) {
      if (t.id != tableId) {
        updated.add(t);
        continue;
      }
      if (!t.isJoinable || t.participants.any((p) => p.id == 'me')) {
        updated.add(t);
        continue;
      }
      final seats = [...t.participants, MockData.currentUser];
      updated.add(
        t.copyWith(
          participants: seats,
          status: seats.length >= t.maxSeats
              ? TableStatus.full
              : TableStatus.open,
        ),
      );
      joined = true;
    }
    if (joined) state = state.copyWith(tables: updated);
    return joined;
  }

  void leaveTable(String tableId) {
    state = state.copyWith(
      tables: [
        for (final t in state.tables)
          if (t.id == tableId)
            t.copyWith(
              participants:
                  t.participants.where((p) => p.id != 'me').toList(),
              status: TableStatus.open,
            )
          else
            t,
      ],
    );
  }

  /// Thanks for a useful correction → helper gains karma (+ Mentor badge).
  void awardCorrectionKarma({
    required String helperUserId,
    int amount = karmaPerThanks,
  }) {
    if (helperUserId == 'me' || helperUserId == 'system') {
      final karma = state.myKarma + amount;
      state = state.copyWith(
        myKarma: karma,
        myCorrectionsHelped: state.myCorrectionsHelped + 1,
      );
      return;
    }

    final next = <MentorProfile>[];
    var found = false;
    for (final m in state.mentors) {
      if (m.user.id != helperUserId) {
        next.add(m);
        continue;
      }
      found = true;
      final newKarma = m.karma + amount;
      final badges = List<String>.from(m.user.badges);
      if (newKarma >= mentorKarmaThreshold && !badges.contains('mentor')) {
        badges.add('mentor');
      }
      next.add(
        MentorProfile(
          user: m.user.copyWith(badges: badges, xp: m.user.xp + amount),
          karma: newKarma,
          correctionsHelped: m.correctionsHelped + 1,
          isMentor: newKarma >= mentorKarmaThreshold,
        ),
      );
    }

    if (!found) {
      final user = MockData.users.firstWhere(
        (u) => u.id == helperUserId,
        orElse: () => MockData.users.first,
      );
      final newKarma = amount;
      next.add(
        MentorProfile(
          user: user.copyWith(
            badges: newKarma >= mentorKarmaThreshold
                ? [...user.badges, 'mentor']
                : user.badges,
            xp: user.xp + amount,
          ),
          karma: newKarma,
          correctionsHelped: 1,
          isMentor: newKarma >= mentorKarmaThreshold,
        ),
      );
    }

    next.sort((a, b) => b.karma.compareTo(a.karma));
    state = state.copyWith(mentors: next);
  }
}
