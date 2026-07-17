import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../shared/models/user_profile.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dio: ref.watch(dioProvider),
    secureStorage: ref.watch(secureStorageProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.error,
  });

  final AuthStatus status;
  final UserProfile? user;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState()) {
    bootstrap();
  }

  final AuthRepository _repo;

  Future<void> bootstrap() async {
    final authed = await _repo.isAuthenticated();
    if (!authed) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    final result = await _repo.getCurrentUser();
    result.when(
      success: (user) {
        state = AuthState(
          status: user != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          user: user,
        );
      },
      failure: (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      },
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repo.loginWithEmail(email, password);
    return result.when(
      success: (user) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
        return true;
      },
      failure: (f) {
        state = state.copyWith(isLoading: false, error: f.message);
        return false;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repo.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    return result.when(
      success: (user) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
        return true;
      },
      failure: (f) {
        state = state.copyWith(isLoading: false, error: f.message);
        return false;
      },
    );
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repo.loginWithGoogle();
    return _applyAuthResult(result);
  }

  Future<bool> loginWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repo.loginWithApple();
    return _applyAuthResult(result);
  }

  Future<bool> continueAsGuest() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repo.continueAsGuest();
    return _applyAuthResult(result);
  }

  Future<void> forgotPassword(String email) async {
    await _repo.forgotPassword(email);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  bool _applyAuthResult(dynamic result) {
    return result.when(
      success: (user) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
        );
        return true;
      },
      failure: (f) {
        state = state.copyWith(isLoading: false, error: f.message);
        return false;
      },
    );
  }
}
