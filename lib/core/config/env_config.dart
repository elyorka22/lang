import '../constants/app_constants.dart';

/// Runtime environment configuration.
class EnvConfig {
  EnvConfig._();

  static bool get useMockData =>
      const bool.fromEnvironment('USE_MOCK', defaultValue: true);

  static String get apiBaseUrl => AppConstants.apiBaseUrl;
  static String get socketUrl => AppConstants.socketUrl;
  static String get mediaCdnUrl => AppConstants.mediaCdnUrl;

  static bool get isProduction =>
      const bool.fromEnvironment('PRODUCTION', defaultValue: false);
}
