/// NestJS REST API endpoint map.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String google = '/auth/google';
  static const String apple = '/auth/apple';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String guest = '/auth/guest';

  // Users / Profile
  static const String me = '/users/me';
  static const String updateProfile = '/users/me';
  static String user(String id) => '/users/$id';
  static const String uploadAvatar = '/users/me/avatar'; // returns R2 presigned URL flow

  // Discover
  static const String discover = '/discover';
  static const String onlineUsers = '/discover/online';

  // Friends
  static const String friends = '/friends';
  static const String friendRequests = '/friends/requests';
  static String acceptFriend(String id) => '/friends/requests/$id/accept';
  static String rejectFriend(String id) => '/friends/requests/$id/reject';
  static String follow(String id) => '/friends/$id/follow';
  static String block(String id) => '/users/$id/block';
  static String report(String id) => '/users/$id/report';

  // Chat
  static const String conversations = '/chat/conversations';
  static String messages(String conversationId) =>
      '/chat/conversations/$conversationId/messages';
  static String message(String id) => '/chat/messages/$id';
  static const String mediaPresign = '/media/presign'; // R2/Spaces upload

  // Groups (Telegram-style)
  static const String groups = '/groups';
  static String group(String id) => '/groups/$id';
  static String groupMembers(String id) => '/groups/$id/members';
  static String leaveGroup(String id) => '/groups/$id/leave';
  static String groupMessages(String id) => '/groups/$id/messages';

  // AI
  static const String aiChat = '/ai/chat';
  static const String aiTranslate = '/ai/translate';
  static const String aiGrammar = '/ai/grammar';
  static const String aiExplain = '/ai/explain';
  static const String aiImprove = '/ai/improve';
  static const String aiPronounce = '/ai/pronounce';
  static const String aiVoiceAnalysis = '/ai/voice-analysis';
  static const String aiLesson = '/ai/lessons';
  static const String aiQuiz = '/ai/quiz';
  static const String aiRoleplay = '/ai/roleplay';

  // Vocabulary
  static const String vocabulary = '/vocabulary';
  static String vocabItem(String id) => '/vocabulary/$id';
  static const String vocabReview = '/vocabulary/review';
  static const String flashcards = '/vocabulary/flashcards';

  // Запоминалка (clips from chat)
  static const String memorizer = '/memorizer';
  static String memorizerItem(String id) => '/memorizer/$id';

  // Learning
  static const String dailyGoal = '/learning/daily-goal';
  static const String stats = '/learning/stats';
  static const String achievements = '/learning/achievements';
  static const String leaderboard = '/learning/leaderboard';
  static const String streak = '/learning/streak';

  // Notifications
  static const String notifications = '/notifications';
  static const String fcmToken = '/notifications/fcm-token';

  // Premium
  static const String subscription = '/billing/subscription';
  static const String products = '/billing/products';
}
