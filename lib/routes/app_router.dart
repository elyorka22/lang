import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/games/presentation/screens/games_hub_screen.dart';
import '../features/games/presentation/screens/image_word_screen.dart';
import '../features/games/presentation/screens/match_meaning_screen.dart';
import '../features/games/presentation/screens/memory_cards_screen.dart';
import '../features/games/presentation/screens/word_builder_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/vocabulary/presentation/screens/flashcards_screen.dart';
import '../features/vocabulary/presentation/screens/vocabulary_screen.dart';
import '../features/vocabulary/presentation/screens/word_detail_screen.dart';
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
          (loc == '/welcome' ||
              loc.startsWith('/auth/login') ||
              loc.startsWith('/auth/register'))) {
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
                path: '/words',
                builder: (_, __) => const VocabularyScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => WordDetailScreen(
                      wordId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/practice',
                builder: (_, __) => const FlashcardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/games',
                builder: (_, __) => const GamesHubScreen(),
                routes: [
                  GoRoute(
                    path: 'match-meaning',
                    builder: (_, __) => const MatchMeaningScreen(),
                  ),
                  GoRoute(
                    path: 'image-word',
                    builder: (_, __) => const ImageWordScreen(),
                  ),
                  GoRoute(
                    path: 'word-builder',
                    builder: (_, __) => const WordBuilderScreen(),
                  ),
                  GoRoute(
                    path: 'memory-cards',
                    builder: (_, __) => const MemoryCardsScreen(),
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
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      // Legacy redirects
      GoRoute(path: '/vocabulary', redirect: (_, __) => '/words'),
      GoRoute(path: '/chats', redirect: (_, __) => '/home'),
      GoRoute(path: '/ai', redirect: (_, __) => '/practice'),
      GoRoute(path: '/games/flashcards', redirect: (_, __) => '/practice'),
    ],
  );
});

class AuthRefresh extends ChangeNotifier {
  AuthRefresh(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}
