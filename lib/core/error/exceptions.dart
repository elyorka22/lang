class ServerException implements Exception {
  ServerException([this.message = 'Server error', this.statusCode]);
  final String message;
  final int? statusCode;
}

class CacheException implements Exception {
  CacheException([this.message = 'Cache error']);
  final String message;
}

class AuthException implements Exception {
  AuthException([this.message = 'Auth error']);
  final String message;
}

class NetworkException implements Exception {
  NetworkException([this.message = 'Network error']);
  final String message;
}
