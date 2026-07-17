import 'package:dio/dio.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required Dio dio,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  })  : _dio = dio,
        _secure = secureStorage,
        _local = localStorage;

  final Dio _dio;
  final SecureStorageService _secure;
  final LocalStorageService _local;

  @override
  Future<Result<UserProfile>> loginWithEmail(
    String email,
    String password,
  ) async {
    if (EnvConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await _secure.saveTokens(
        accessToken: 'mock_access',
        refreshToken: 'mock_refresh',
      );
      await _secure.saveUserId(MockData.currentUser.id);
      await _local.setGuest(false);
      return Result.success(MockData.currentUser);
    }

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      await _persistSession(res.data!);
      return Result.success(
        UserProfile.fromJson(res.data!['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Result.failure(
        Failure.auth(e.response?.data?['message']?.toString() ?? 'Login failed'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (EnvConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final user = MockData.currentUser.copyWith(displayName: displayName);
      await _secure.saveTokens(
        accessToken: 'mock_access',
        refreshToken: 'mock_refresh',
      );
      await _secure.saveUserId(user.id);
      return Result.success(user);
    }

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
        },
      );
      await _persistSession(res.data!);
      return Result.success(
        UserProfile.fromJson(res.data!['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Result.failure(
        Failure.auth(
          e.response?.data?['message']?.toString() ?? 'Registration failed',
        ),
      );
    }
  }

  @override
  Future<Result<UserProfile>> loginWithGoogle() async {
    // Wire GoogleSignIn SDK here; exchange idToken with NestJS /auth/google
    if (EnvConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await _secure.saveTokens(
        accessToken: 'mock_google',
        refreshToken: 'mock_refresh',
      );
      await _secure.saveUserId(MockData.currentUser.id);
      return Result.success(MockData.currentUser);
    }
    return Result.failure(
      Failure.auth('Configure Google Sign-In client IDs'),
    );
  }

  @override
  Future<Result<UserProfile>> loginWithApple() async {
    if (EnvConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await _secure.saveTokens(
        accessToken: 'mock_apple',
        refreshToken: 'mock_refresh',
      );
      await _secure.saveUserId(MockData.currentUser.id);
      return Result.success(MockData.currentUser);
    }
    return Result.failure(
      Failure.auth('Configure Apple Sign-In capability'),
    );
  }

  @override
  Future<Result<UserProfile>> continueAsGuest() async {
    await _local.setGuest(true);
    await _secure.saveTokens(
      accessToken: 'guest_token',
      refreshToken: 'guest_refresh',
    );
    await _secure.saveUserId('guest');
    return Result.success(
      MockData.currentUser.copyWith(displayName: 'Guest'),
    );
  }

  @override
  Future<Result<bool>> forgotPassword(String email) async {
    if (EnvConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return Result.success(true);
    }
    try {
      await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
      return Result.success(true);
    } on DioException catch (e) {
      return Result.failure(
        Failure.server(e.message ?? 'Could not send reset email'),
      );
    }
  }

  @override
  Future<Result<bool>> logout() async {
    await _secure.clearAll();
    await _local.setGuest(false);
    return Result.success(true);
  }

  @override
  Future<Result<UserProfile?>> getCurrentUser() async {
    final token = await _secure.getAccessToken();
    if (token == null) return Result.success(null);
    if (EnvConfig.useMockData) {
      return Result.success(MockData.currentUser);
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      return Result.success(UserProfile.fromJson(res.data!));
    } on DioException {
      return Result.success(null);
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secure.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    await _secure.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    final user = data['user'] as Map<String, dynamic>?;
    if (user != null) {
      await _secure.saveUserId(user['id'] as String);
    }
    await _local.setGuest(false);
  }
}
