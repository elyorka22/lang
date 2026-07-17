import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/mock_data.dart';
import '../../../shared/models/conversation.dart';
import '../../../shared/models/learning_stats.dart';
import '../../../shared/models/user_profile.dart';

class HomeState {
  const HomeState({
    required this.goal,
    required this.suggestions,
    required this.recommended,
    required this.online,
    required this.recentChats,
    required this.reviewCount,
    this.isLoading = false,
  });

  final DailyGoal goal;
  final List<String> suggestions;
  final List<UserProfile> recommended;
  final List<UserProfile> online;
  final List<ChatConversation> recentChats;
  final int reviewCount;
  final bool isLoading;
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController()..load();
});

class HomeController extends StateNotifier<HomeState> {
  HomeController()
      : super(
          const HomeState(
            goal: MockData.dailyGoal,
            suggestions: [],
            recommended: [],
            online: [],
            recentChats: [],
            reviewCount: 0,
            isLoading: true,
          ),
        );

  Future<void> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    state = HomeState(
      goal: MockData.dailyGoal,
      suggestions: MockData.aiSuggestions,
      recommended: MockData.users.take(4).toList(),
      online: MockData.users
          .where((u) => u.status == OnlineStatus.online)
          .toList(),
      recentChats: MockData.conversations(),
      reviewCount: MockData.vocabulary.length,
      isLoading: false,
    );
  }
}
