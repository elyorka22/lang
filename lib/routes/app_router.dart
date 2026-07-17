import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
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
import '../features/home/presentation/screens/home_screen.dart';
import '../features/learning/presentation/screens/learning_screen.dart';
import '../features/memorizer/presentation/screens/memorizer_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/vocabulary/presentation/screens/flashcards_screen.dart';
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
                path: '/discover',
                builder: (_, __) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (_, __) => const ChatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saves',
                builder: (_, __) => const MemorizerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai',
                builder: (_, __) => const AiScreen(),
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
        builder: (_, __) => const FlashcardsScreen(),
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
