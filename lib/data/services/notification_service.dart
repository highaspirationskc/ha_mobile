// lib/data/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

/// Top-level function for handling background messages
/// This must be a top-level function (not a class method)
/// Must be registered before runApp() in main()
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: Firebase must be initialized in the background isolate
  // Note: kDebugMode might not be available in background isolate
  try {
    // Initialize Firebase in background isolate if not already initialized
    // (This is a no-op if already initialized)
    print('📱 Handling background message: ${message.messageId}');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');

    // Background messages are handled here
    // You can perform tasks like updating local storage, etc.
  } catch (e) {
    // Silently handle if logging fails
    print('❌ Error in background message handler: $e');
  }
}

/// Service for handling Firebase Cloud Messaging (FCM) push notifications
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  FirebaseMessaging? _firebaseMessaging;
  String? _fcmToken;
  bool _initialized = false;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize notification service and request permissions
  Future<void> initialize() async {
    // Skip initialization on web platform
    if (kIsWeb) {
      if (kDebugMode) {
        print(
          '⚠️ Notification Service: Skipping initialization on web platform',
        );
      }
      return;
    }

    // Skip if already initialized
    if (_initialized) {
      return;
    }

    try {
      if (kDebugMode) {
        print('🔔 Initializing Notification Service...');
      }

      // Initialize FirebaseMessaging instance
      _firebaseMessaging = FirebaseMessaging.instance;
      _setupNotificationHandlers();

      // Request notification permissions
      final settings = await requestPermission();
      if (kDebugMode) {
        print(
          '📱 Notification permission status: ${settings.authorizationStatus}',
        );
      }

      // Note: onBackgroundMessage must be registered in main() before runApp()
      // It's not called here to avoid duplicate registration

      // Get FCM token
      await _getFCMToken();

      // Listen for token refresh
      _firebaseMessaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (kDebugMode) {
          print('🔄 FCM token refreshed: $newToken');
        }
        // TODO: Send updated token to your backend
        _sendTokenToBackend(newToken);
      });

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing Notification Service: $e');
      }
      // Don't rethrow - allow app to continue even if notifications fail
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> requestPermission() async {
    if (_firebaseMessaging == null) {
      throw StateError(
        'FirebaseMessaging not initialized. Call initialize() first.',
      );
    }
    final settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings;
  }

  /// Get the FCM token for this device
  Future<String?> _getFCMToken() async {
    if (_firebaseMessaging == null) {
      return null;
    }
    try {
      _fcmToken = await _firebaseMessaging!.getToken();
      if (kDebugMode) {
        print('✅ FCM token obtained: $_fcmToken');
      }

      // Send token to backend
      if (_fcmToken != null) {
        await _sendTokenToBackend(_fcmToken!);
      }

      return _fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting FCM token: $e');
      }
      return null;
    }
  }

  /// Send FCM token to backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      // TODO: Implement API call to send FCM token to your backend
      // Example:
      // await ApiService.instance.updateFCMToken(token);
      if (kDebugMode) {
        print('📤 TODO: Send FCM token to backend: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending FCM token to backend: $e');
      }
    }
  }

  /// Set up notification handlers for foreground, background, and terminated states
  void _setupNotificationHandlers() {
    if (_firebaseMessaging == null) return;

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('📨 Received foreground message: ${message.messageId}');
        print('   Title: ${message.notification?.title}');
        print('   Body: ${message.notification?.body}');
        print('   Data: ${message.data}');
      }
      // Handle foreground notification
      _handleForegroundMessage(message);
    });

    // Handle notification taps when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 Notification tapped: ${message.messageId}');
        print('   Data: ${message.data}');
      }
      // Handle notification tap
      _handleNotificationTap(message);
    });

    // Check if app was opened from a terminated state via notification
    _firebaseMessaging!.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print('🚀 App opened from terminated state via notification');
          print('   Data: ${message.data}');
        }
        // Handle notification tap from terminated state
        // Note: You'll need to store the navigation intent and handle it after app initializes
        _handleNotificationTap(message);
      }
    });
  }

  /// Handle foreground notification (when app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    // For foreground messages, you might want to show a local notification
    // or update the UI directly. For now, we'll just log it.
    // You can use flutter_local_notifications package to show notifications
    // even when the app is in the foreground.
  }

  /// Callback for handling notification taps (set from app)
  Function(RemoteMessage)? onNotificationTap;

  /// Handle notification tap (navigate to relevant screen)
  /// This will be called by the app's navigation handler
  void _handleNotificationTap(RemoteMessage message) {
    if (onNotificationTap != null) {
      onNotificationTap!(message);
    } else {
      if (kDebugMode) {
        print('⚠️ No notification tap handler registered');
      }
    }
  }

  /// Delete FCM token (e.g., on logout)
  Future<void> deleteToken() async {
    if (_firebaseMessaging == null) return;
    try {
      await _firebaseMessaging!.deleteToken();
      _fcmToken = null;
      if (kDebugMode) {
        print('🗑️ FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting FCM token: $e');
      }
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    if (_firebaseMessaging == null) return;
    try {
      await _firebaseMessaging!.subscribeToTopic(topic);
      if (kDebugMode) {
        print('✅ Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error subscribing to topic: $e');
      }
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_firebaseMessaging == null) return;
    try {
      await _firebaseMessaging!.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('✅ Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unsubscribing from topic: $e');
      }
    }
  }
}
