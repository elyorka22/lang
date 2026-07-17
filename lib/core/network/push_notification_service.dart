/// Push notification service stub.
///
/// Wire Firebase Cloud Messaging when google-services.json /
/// GoogleService-Info.plist are added:
/// 1. Uncomment firebase_core & firebase_messaging in pubspec.yaml
/// 2. Call [PushNotificationService.initialize] from main.dart
/// 3. POST the FCM token to NestJS `/notifications/fcm-token`
class PushNotificationService {
  PushNotificationService._();

  static Future<void> initialize({
    required Future<void> Function(String token) onToken,
  }) async {
    // TODO: Firebase.initializeApp();
    // TODO: request permission
    // TODO: FirebaseMessaging.instance.getToken() -> onToken
    // TODO: onMessage / onMessageOpenedApp handlers
  }
}
