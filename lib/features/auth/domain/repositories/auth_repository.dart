import '../../../../core/utils/result.dart';
import '../../../../shared/models/user_profile.dart';

abstract class AuthRepository {
  Future<Result<UserProfile>> loginWithEmail(String email, String password);
  Future<Result<UserProfile>> register({
    required String email,
    required String password,
    required String displayName,
  });
  Future<Result<UserProfile>> loginWithGoogle();
  Future<Result<UserProfile>> loginWithApple();
  Future<Result<UserProfile>> continueAsGuest();
  Future<Result<bool>> forgotPassword(String email);
  Future<Result<bool>> logout();
  Future<Result<UserProfile?>> getCurrentUser();
  Future<bool> isAuthenticated();

  /// Persist local profile edits (name, bio, avatar path).
  Future<Result<UserProfile>> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool clearAvatar = false,
  });
}
