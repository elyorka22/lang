import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/game_models.dart';

class GamesState {
  const GamesState({
    this.unlockedLevel = 1,
    this.completedQuestIds = const {},
    this.totalXp = 0,
    this.activeQuestId,
    this.messages = const [],
    this.completedGoalIds = const {},
    this.isReplying = false,
    this.questJustCompleted = false,
  });

  final int unlockedLevel;
  final Set<String> completedQuestIds;
  final int totalXp;
  final String? activeQuestId;
  final List<QuestChatMessage> messages;
  final Set<String> completedGoalIds;
  final bool isReplying;
  final bool questJustCompleted;

  AiQuest? get activeQuest {
    if (activeQuestId == null) return null;
    for (final q in GameCatalog.quests) {
      if (q.id == activeQuestId) return q;
    }
    return null;
  }

  bool isUnlocked(AiQuest quest) => quest.level <= unlockedLevel;

  bool isCompleted(AiQuest quest) => completedQuestIds.contains(quest.id);

  GamesState copyWith({
    int? unlockedLevel,
    Set<String>? completedQuestIds,
    int? totalXp,
    String? activeQuestId,
    List<QuestChatMessage>? messages,
    Set<String>? completedGoalIds,
    bool? isReplying,
    bool? questJustCompleted,
    bool clearActive = false,
  }) {
    return GamesState(
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      completedQuestIds: completedQuestIds ?? this.completedQuestIds,
      totalXp: totalXp ?? this.totalXp,
      activeQuestId:
          clearActive ? null : (activeQuestId ?? this.activeQuestId),
      messages: messages ?? this.messages,
      completedGoalIds: completedGoalIds ?? this.completedGoalIds,
      isReplying: isReplying ?? this.isReplying,
      questJustCompleted: questJustCompleted ?? this.questJustCompleted,
    );
  }
}

final gamesControllerProvider =
    StateNotifierProvider<GamesController, GamesState>((ref) {
  return GamesController();
});

class GamesController extends StateNotifier<GamesState> {
  GamesController() : super(const GamesState());

  final _uuid = const Uuid();

  void addXp(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(totalXp: state.totalXp + amount);
  }

  void startQuest(String questId) {
    AiQuest? quest;
    for (final q in GameCatalog.quests) {
      if (q.id == questId) quest = q;
    }
    if (quest == null || !state.isUnlocked(quest)) return;

    state = GamesState(
      unlockedLevel: state.unlockedLevel,
      completedQuestIds: state.completedQuestIds,
      totalXp: state.totalXp,
      activeQuestId: quest.id,
      messages: [
        QuestChatMessage(
          id: _uuid.v4(),
          role: 'assistant',
          content: quest.intro,
          createdAt: DateTime.now(),
        ),
      ],
      completedGoalIds: {},
      isReplying: false,
      questJustCompleted: false,
    );
  }

  void leaveQuest() {
    state = state.copyWith(
      clearActive: true,
      messages: const [],
      completedGoalIds: {},
      isReplying: false,
      questJustCompleted: false,
    );
  }

  void clearJustCompletedFlag() {
    state = state.copyWith(questJustCompleted: false);
  }

  Future<void> sendMessage(String text) async {
    final quest = state.activeQuest;
    if (quest == null || text.trim().isEmpty || state.isReplying) return;
    if (state.questJustCompleted) return;

    final userText = text.trim();
    final userMsg = QuestChatMessage(
      id: _uuid.v4(),
      role: 'user',
      content: userText,
      createdAt: DateTime.now(),
    );

    final newlyDone = <String>{};
    for (final goal in quest.goals) {
      if (state.completedGoalIds.contains(goal.id)) continue;
      if (_matchesGoal(userText, goal)) newlyDone.add(goal.id);
    }

    final goalsAfter = {...state.completedGoalIds, ...newlyDone};
    final allDone = quest.goals.every((g) => goalsAfter.contains(g.id));

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      completedGoalIds: goalsAfter,
      isReplying: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 650));

    final reply = _npcReply(quest, userText, newlyDone, allDone);
    var next = state.copyWith(
      isReplying: false,
      messages: [
        ...state.messages,
        QuestChatMessage(
          id: _uuid.v4(),
          role: 'assistant',
          content: reply,
          createdAt: DateTime.now(),
        ),
      ],
    );

    if (allDone && !state.completedQuestIds.contains(quest.id)) {
      final unlocked = state.unlockedLevel < quest.level + 1
          ? quest.level + 1
          : state.unlockedLevel;
      next = next.copyWith(
        completedQuestIds: {...state.completedQuestIds, quest.id},
        totalXp: state.totalXp + quest.xpReward,
        unlockedLevel: unlocked > state.unlockedLevel
            ? unlocked
            : state.unlockedLevel,
        questJustCompleted: true,
      );
    }

    state = next;
  }

  bool _matchesGoal(String text, QuestGoal goal) {
    final lower = text.toLowerCase();
    for (final k in goal.keywords) {
      if (lower.contains(k.toLowerCase())) return true;
    }
    return false;
  }

  String _npcReply(
    AiQuest quest,
    String userText,
    Set<String> newlyDone,
    bool allDone,
  ) {
    if (allDone) {
      return 'Perfect — you completed every step. '
          '+${quest.xpReward} XP. Level ${quest.level + 1} is unlocked!';
    }

    if (newlyDone.isNotEmpty) {
      final labels = quest.goals
          .where((g) => newlyDone.contains(g.id))
          .map((g) => g.label)
          .join(', ');
      return 'Nice — goal checked: $labels. '
          'Keep going in natural English. What else do you need?';
    }

    // Gentle NPC push toward missing goals
    for (final goal in quest.goals) {
      if (!state.completedGoalIds.contains(goal.id)) {
        switch (quest.id) {
          case 'q1_hotel':
            return _hotelHint(goal.id);
          case 'q2_bank':
            return _bankHint(goal.id);
          case 'q3_cafe':
            return _cafeHint(goal.id);
          case 'q4_clinic':
            return _clinicHint(goal.id);
          case 'q5_job':
            return _jobHint(goal.id);
          case 'q6_complaint':
            return _complaintHint(goal.id);
        }
      }
    }

    return 'Could you say that another way? I’m listening.';
  }

  String _hotelHint(String goalId) {
    switch (goalId) {
      case 'g1':
        return 'Of course. Would you like to book a room with us?';
      case 'g2':
        return 'Which dates would you like to stay? Or how many nights?';
      default:
        return 'Will that be a single or double room? How many guests?';
    }
  }

  String _bankHint(String goalId) {
    switch (goalId) {
      case 'g1':
        return 'We can help you open a debit or credit card. Which do you need?';
      case 'g2':
        return 'I’ll need an ID or passport and your phone number, please.';
      default:
        return 'Shall I confirm a Visa debit card for you today?';
    }
  }

  String _cafeHint(String goalId) {
    switch (goalId) {
      case 'g1':
        return 'Our specials today are latte and cappuccino. What would you like?';
      case 'g2':
        return 'What size — small, medium, or large? Any milk preference?';
      default:
        return 'Any allergies I should know about? And is that for here or to go?';
    }
  }

  String _clinicHint(String goalId) {
    switch (goalId) {
      case 'g1':
        return 'Can you describe the pain or symptom in more detail?';
      case 'g2':
        return 'How many days has this been going on?';
      default:
        return 'I can suggest medicine or a pharmacy visit. What would help you most?';
    }
  }

  String _jobHint(String goalId) {
    switch (goalId) {
      case 'g1':
        return 'Tell me about your experience — what roles have you worked in?';
      case 'g2':
        return 'Why are you interested in this company and role?';
      default:
        return 'Do you have any questions about the team or next steps?';
    }
  }

  String _complaintHint(String goalId) {
    switch (goalId) {
      case 'g1':
        return 'I’m sorry to hear that. Was the package delayed or missing?';
      case 'g2':
        return 'Would you like a refund, a replacement, or a discount?';
      default:
        return 'I’ve noted that. Anything else before we confirm?';
    }
  }
}
