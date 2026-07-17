import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/ai/presentation/screens/ai_screen.dart';
import '../features/ai/presentation/screens/voice_analysis_screen.dart';
import '../features/chat/presentation/screens/chat_room_screen.dart';
import '../features/chat/presentation/screens/chats_screen.dart';
import '../features/chat/presentation/screens/create_group_screen.dart';
import '../features/chat/presentation/screens/group_info_screen.dart';
import '../features/discover/presentation/screens/discover_screen.dart';
import '../features/games/presentation/screens/games_hub_screen.dart';
import '../features/games/presentation/screens/picture_words_levels_screen.dart';
import '../features/games/presentation/screens/picture_words_play_screen.dart';
import '../features/games/presentation/screens/quest_chat_screen.dart';
import '../features/games/presentation/screens/quest_levels_screen.dart';
import '../features/goal_map/presentation/screens/goal_map_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/learning/presentation/screens/learning_screen.dart';
import '../features/memorizer/presentation/screens/memorizer_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/rooms/presentation/screens/mafia_room_screen.dart';
import '../features/rooms/presentation/screens/rooms_hub_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/social/presentation/screens/host_table_screen.dart';
import '../features/social/presentation/screens/mentors_screen.dart';
import '../features/social/presentation/screens/room_detail_screen.dart';
import '../features/social/presentation/screens/social_hub_screen.dart';
import '../features/vocabulary/presentation/screens/flashcards_screen.dart';
import '../shared/models/social_models.dart';
import '../features/vocabulary/presentation/screens/vocabulary_screen.dart';
import '../shared/widgets/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/welcome',
    refreshListenable: AuthRefresh(ref),
    redirect: (context, state) {
      final status = auth.status;
      final loc = state.matchedLocation;
      final isAuthRoute = loc.startsWith('/auth') ||
          loc == '/welcome' ||
          loc == '/onboarding';

      if (status == AuthStatus.unknown) return null;

      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/welcome';
      }
      if (status == AuthStatus.authenticated &&
          (loc == '/welcome' || loc.startsWith('/auth/login') || loc.startsWith('/auth/register'))) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rooms',
                builder: (_, __) => const RoomsHubScreen(),
                routes: [
                  GoRoute(
                    path: 'inbox',
                    builder: (_, __) => const ChatsScreen(inboxOnly: true),
                  ),
                  GoRoute(
                    path: 'games/mafia/create',
                    builder: (_, __) => const CreateMafiaRoomScreen(),
                  ),
                  GoRoute(
                    path: 'games/mafia/:id',
                    builder: (_, state) => MafiaRoomScreen(
                      roomId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/chats',
        redirect: (_, __) => '/rooms',
      ),
      GoRoute(
        path: '/goal-map',
        builder: (_, __) => const GoalMapScreen(),
      ),
      GoRoute(
        path: '/discover',
        builder: (_, __) => const DiscoverScreen(),
      ),
      GoRoute(
        path: '/saves',
        builder: (_, __) => const MemorizerScreen(),
      ),
      GoRoute(
        path: '/games',
        builder: (_, __) => const GamesHubScreen(),
      ),
      GoRoute(
        path: '/games/flashcards',
        builder: (_, __) => const FlashcardsScreen(),
      ),
      GoRoute(
        path: '/games/quests',
        builder: (_, __) => const QuestLevelsScreen(),
      ),
      GoRoute(
        path: '/games/quests/:id',
        builder: (_, state) => QuestChatScreen(
          questId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/games/picture-words',
        builder: (_, __) => const PictureWordsLevelsScreen(),
      ),
      GoRoute(
        path: '/games/picture-words/:id',
        builder: (_, state) => PictureWordsPlayScreen(
          levelId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/ai',
        builder: (_, __) => const AiScreen(),
      ),
      GoRoute(
        path: '/social',
        builder: (_, __) => const SocialHubScreen(),
      ),
      GoRoute(
        path: '/social/host',
        builder: (_, state) {
          final topicName = state.uri.queryParameters['topic'];
          RoomTopic? topic;
          if (topicName != null) {
            for (final t in RoomTopic.values) {
              if (t.name == topicName) topic = t;
            }
          }
          return HostTableScreen(initialTopic: topic);
        },
      ),
      GoRoute(
        path: '/social/mentors',
        builder: (_, __) => const MentorsScreen(),
      ),
      GoRoute(
        path: '/social/rooms/:id',
        builder: (_, state) => RoomDetailScreen(
          roomId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) => ChatRoomScreen(
          conversationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/groups/create',
        builder: (_, __) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/groups/:id',
        builder: (_, state) => GroupInfoScreen(
          groupId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/users/:id',
        builder: (_, state) => ProfileScreen(
          userId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/vocabulary',
        builder: (_, __) => const VocabularyScreen(),
      ),
      GoRoute(
        path: '/vocabulary/flashcards',
        redirect: (_, __) => '/games/flashcards',
      ),
      GoRoute(
        path: '/ai/voice',
        builder: (_, __) => const VoiceAnalysisScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/learning',
        builder: (_, __) => const LearningScreen(),
      ),
      GoRoute(
        path: '/premium',
        builder: (_, __) => const PremiumScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod auth changes into GoRouter refresh.
class AuthRefresh extends ChangeNotifier {
  AuthRefresh(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}
