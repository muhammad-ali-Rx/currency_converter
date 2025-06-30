import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FixedNotificationService {
  static final FixedNotificationService _instance = FixedNotificationService._internal();
  factory FixedNotificationService() => _instance;
  FixedNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notifications with comprehensive setup
  Future<bool> initialize() async {
    try {
      print('🔄 Starting notification initialization...');
      
      // Step 1: Request permissions first
      final hasPermission = await _requestPermissions();
      print('📱 Permission status: $hasPermission');
      
      // Step 2: Initialize plugin (even if no permission for now)
      final initialized = await _initializePlugin();
      print('🔧 Plugin initialized: $initialized');
      
      if (initialized) {
        // Step 3: Create notification channel
        await _createNotificationChannel();
        print('📢 Notification channel created');
        
        _isInitialized = true;
        print('✅ Notification service fully initialized');
        return true;
      }
      
      print('❌ Plugin initialization failed');
      return false;
      
    } catch (e, stackTrace) {
      print('❌ Error initializing notifications: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // For Android 13+
        final status = await Permission.notification.request();
        print('📱 Android notification permission: $status');
        
        // Also request other permissions
        await Permission.ignoreBatteryOptimizations.request();
        
        return status.isGranted;
      } else if (Platform.isIOS) {
        // iOS permissions handled in plugin initialization
        return true;
      }
      return true;
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Initialize the notification plugin
  Future<bool> _initializePlugin() async {
    try {
      // Android settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      print('🔧 Plugin initialization result: $result');
      return result ?? false;
      
    } catch (e) {
      print('❌ Error initializing plugin: $e');
      return false;
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      try {
        const androidChannel = AndroidNotificationChannel(
          'rate_alerts_channel',
          'Rate Alerts',
          description: 'Notifications for currency rate alerts',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(androidChannel);
          print('✅ Android notification channel created successfully');
        } else {
          print('⚠️ Android plugin not available');
        }
      } catch (e) {
        print('❌ Error creating notification channel: $e');
      }
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
  }

  /// Send rate alert notification
  Future<bool> sendRateAlertNotification({
    required String fromCurrency,
    required String toCurrency,
    required double currentRate,
    required double targetRate,
    required String condition,
  }) async {
    if (!_isInitialized) {
      print('❌ Notifications not initialized, attempting to initialize...');
      final initialized = await initialize();
      if (!initialized) {
        print('❌ Failed to initialize notifications');
        return false;
      }
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'rate_alerts_channel',
        'Rate Alerts',
        channelDescription: 'Currency rate alert notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        color: Color.fromARGB(255, 10, 108, 236),
        ledColor: Color.fromARGB(255, 10, 108, 236),
        ledOnMs: 1000,
        ledOffMs: 500,
        showWhen: true,
        when: null,
        usesChronometer: false,
        fullScreenIntent: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final title = '🚨 Currency Alert Triggered!';
      final body = '$fromCurrency/$toCurrency is now ${currentRate.toStringAsFixed(4)}\n'
                  'Target: $condition ${targetRate.toStringAsFixed(4)}';

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _notifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: '$fromCurrency/$toCurrency:$currentRate',
      );

      print('✅ Notification sent successfully: $fromCurrency/$toCurrency');
      return true;
      
    } catch (e) {
      print('❌ Error sending notification: $e');
      return false;
    }
  }

  /// Send test notification
  Future<bool> sendTestNotification() async {
    print('🧪 Sending test notification...');
    
    return await sendRateAlertNotification(
      fromCurrency: 'USD',
      toCurrency: 'EUR',
      currentRate: 0.8520,
      targetRate: 0.8500,
      condition: 'above',
    );
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        print('📱 Current notification permission: $status');
        return status.isGranted;
      }
      return true; // iOS handles this differently
    } catch (e) {
      print('❌ Error checking notification permissions: $e');
      return false;
    }
  }

  /// Open notification settings
  Future<void> openNotificationSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('❌ Error opening settings: $e');
    }
  }

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Force re-initialization
  Future<bool> reinitialize() async {
    _isInitialized = false;
    return await initialize();
  }
}
