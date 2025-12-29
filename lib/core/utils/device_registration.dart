// lib/core/utils/device_registration.dart
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import '../../data/services/api_service.dart';
import '../../data/services/auth_storage.dart';
import '../../data/services/notification_service.dart';
import 'platform_utils.dart';

/// Register device for push notifications if not already registered
/// Checks local storage and only registers if the FCM token has changed
Future<void> registerDeviceIfNeeded() async {
  if (kIsWeb) {
    // Skip device registration on web
    return;
  }

  try {
    // Get current FCM token from NotificationService
    final fcmToken = NotificationService.instance.fcmToken;
    if (fcmToken == null) {
      if (kDebugMode) {
        print('ℹ️ No FCM token available, skipping device registration');
      }
      return;
    }

    // Check if we've already registered this token
    final registeredToken = await AuthStorage.getRegisteredFCMToken();
    if (registeredToken == fcmToken) {
      if (kDebugMode) {
        print('ℹ️ Device already registered with this FCM token');
      }
      return;
    }

    if (kDebugMode) {
      print('📱 Registering device with FCM token...');
    }

    // Register the device
    final platform = getPlatformString();
    await ApiService.instance.registerDevice(
      fcmToken: fcmToken,
      platform: platform,
      // deviceName is optional, can be added later if needed
    );

    // Save the registered token to local storage
    await AuthStorage.saveRegisteredFCMToken(fcmToken);

    if (kDebugMode) {
      print('✅ Device registered and token saved to local storage');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Failed to register device (non-critical): $e');
    }
    // Don't throw - device registration shouldn't block app functionality
  }
}
