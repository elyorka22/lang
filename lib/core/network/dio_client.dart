import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

/// Configured Dio client with JWT interceptors for NestJS API.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(ref.read(secureStorageProvider)),
  );
  dio.interceptors.add(
    LogInterceptor(
      requestBody: !EnvConfig.isProduction,
      responseBody: !EnvConfig.isProduction,
      error: true,
      requestHeader: false,
      responseHeader: false,
    ),
  );

  return dio;
});

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final SecureStorageService _storage;
  bool _refreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_refreshing) {
      _refreshing = true;
      try {
        final refreshed = await _tryRefresh(err.requestOptions);
        if (refreshed != null) {
          handler.resolve(refreshed);
          return;
        }
      } finally {
        _refreshing = false;
      }
    }
    handler.next(err);
  }

  Future<Response<dynamic>?> _tryRefresh(RequestOptions request) async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null) return null;

    try {
      final dio = Dio(BaseOptions(baseUrl: EnvConfig.apiBaseUrl));
      final res = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final access = res.data?['accessToken'] as String?;
      final newRefresh = res.data?['refreshToken'] as String?;
      if (access == null) return null;

      await _storage.saveTokens(
        accessToken: access,
        refreshToken: newRefresh ?? refresh,
      );

      request.headers['Authorization'] = 'Bearer $access';
      return Dio().fetch(request);
    } catch (_) {
      await _storage.clearTokens();
      return null;
    }
  }
}
