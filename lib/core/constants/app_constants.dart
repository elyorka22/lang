/// Global app constants for Lingua.
class AppConstants {
  AppConstants._();

  static const String appName = 'Lingua';
  static const String appTagline = 'Learn. Remember. Pronounce.';
  static const String appVersion = '1.0.0';

  /// NestJS API base URL — replace with your backend endpoint.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.lingua.app/v1',
  );

  /// Socket.IO server URL for realtime chat.
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://api.lingua.app',
  );

  /// Cloudflare R2 / DO Spaces public CDN for media.
  static const String mediaCdnUrl = String.fromEnvironment(
    'MEDIA_CDN_URL',
    defaultValue: 'https://cdn.lingua.app',
  );

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;
  static const int pageSize = 20;

  static const int freeAiRequestsPerDay = 10;
  static const int freeTranslationsPerDay = 20;
  static const int freeVocabLimit = 50;

  static const Duration typingDebounce = Duration(milliseconds: 400);
  static const Duration onlineHeartbeat = Duration(seconds: 30);
}
