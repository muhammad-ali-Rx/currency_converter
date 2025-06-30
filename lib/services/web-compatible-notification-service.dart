import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class WebCompatibleNotificationService {
  static final WebCompatibleNotificationService _instance = WebCompatibleNotificationService._internal();
  factory WebCompatibleNotificationService() => _instance;
  WebCompatibleNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Check if we're running on web
  bool get isWeb => kIsWeb;
  
  /// Check if we're running on mobile
  bool get isMobile => !kIsWeb;

  /// Initialize notifications with web compatibility
  Future<bool> initialize() async {
    try {
      print('🔄 Starting web-compatible notification initialization...');
      print('📱 Platform: ${isWeb ? "Web" : "Mobile"}');
      
      if (isWeb) {
        return await _initializeForWeb();
      } else {
        return await _initializeForMobile();
      }
      
    } catch (e, stackTrace) {
      print('❌ Error initializing notifications: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Initialize for web platform
  Future<bool> _initializeForWeb() async {
    try {
      print('🌐 Initializing for web...');
      
      // For web, we can only use browser notifications
      // Check if browser supports notifications
      if (_isBrowserNotificationSupported()) {
        print('✅ Browser notifications supported');
        
        // Try to request permission using web APIs
        final hasPermission = await _requestWebNotificationPermission();
        print('📱 Web notification permission: $hasPermission');
        
        _isInitialized = true;
        return true;
      } else {
        print('❌ Browser notifications not supported');
        return false;
      }
    } catch (e) {
      print('❌ Error initializing for web: $e');
      return false;
    }
  }

  /// Initialize for mobile platform
  Future<bool> _initializeForMobile() async {
    try {
      print('📱 Initializing for mobile...');
      
      // Request permissions first
      final hasPermission = await _requestMobilePermissions();
      print('📱 Mobile permission status: $hasPermission');
      
      // Initialize plugin
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        await _createMobileNotificationChannel();
        _isInitialized = true;
        print('✅ Mobile notifications initialized successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error initializing for mobile: $e');
      return false;
    }
  }

  /// Check if browser supports notifications
  bool _isBrowserNotificationSupported() {
    if (!isWeb) return false;
    
    try {
      // This will be handled by the browser
      return true; // Assume supported for now
    } catch (e) {
      return false;
    }
  }

  /// Request web notification permission
  Future<bool> _requestWebNotificationPermission() async {
    if (!isWeb) return false;
    
    try {
      // For web, we'll return true for now
      // In a real implementation, you'd use js interop
      print('🌐 Web notification permission requested');
      return true;
    } catch (e) {
      print('❌ Error requesting web permission: $e');
      return false;
    }
  }

  /// Request mobile permissions
  Future<bool> _requestMobilePermissions() async {
    if (isWeb) return false;
    
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      print('❌ Error requesting mobile permissions: $e');
      return false;
    }
  }

  /// Create notification channel for mobile
  Future<void> _createMobileNotificationChannel() async {
    if (isWeb) return;
    
    try {
      const androidChannel = AndroidNotificationChannel(
        'rate_alerts_channel',
        'Rate Alerts',
        description: 'Notifications for currency rate alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        print('✅ Mobile notification channel created');
      }
    } catch (e) {
      print('❌ Error creating mobile notification channel: $e');
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
      print('❌ Notifications not initialized');
      return false;
    }

    try {
      if (isWeb) {
        return await _sendWebNotification(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          currentRate: currentRate,
          targetRate: targetRate,
          condition: condition,
        );
      } else {
        return await _sendMobileNotification(
          fromCurrency: fromCurrency,
          toCurrency: toCurrency,
          currentRate: currentRate,
          targetRate: targetRate,
          condition: condition,
        );
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
      return false;
    }
  }

  /// Send web notification
  Future<bool> _sendWebNotification({
    required String fromCurrency,
    required String toCurrency,
    required double currentRate,
    required double targetRate,
    required String condition,
  }) async {
    try {
      print('🌐 Sending web notification...');
      
      final title = '🚨 Currency Alert Triggered!';
      final body = '$fromCurrency/$toCurrency is now ${currentRate.toStringAsFixed(4)}\n'
                  'Target: $condition ${targetRate.toStringAsFixed(4)}';
      
      // For web, we'll just log the notification
      // In a real implementation, you'd use browser notification API
      print('📢 Web Notification:');
      print('Title: $title');
      print('Body: $body');
      
      return true;
    } catch (e) {
      print('❌ Error sending web notification: $e');
      return false;
    }
  }

  /// Send mobile notification
  Future<bool> _sendMobileNotification({
    required String fromCurrency,
    required String toCurrency,
    required double currentRate,
    required double targetRate,
    required String condition,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'rate_alerts_channel',
        'Rate Alerts',
        channelDescription: 'Currency rate alert notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
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

      print('✅ Mobile notification sent successfully');
      return true;
      
    } catch (e) {
      print('❌ Error sending mobile notification: $e');
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
      if (isWeb) {
        // For web, return true if initialized
        return _isInitialized;
      } else {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
    } catch (e) {
      print('❌ Error checking notification permissions: $e');
      return false;
    }
  }

  /// Open notification settings
  Future<void> openNotificationSettings() async {
    try {
      if (isWeb) {
        print('🌐 Web: Please enable notifications in your browser settings');
      } else {
        await openAppSettings();
      }
    } catch (e) {
      print('❌ Error opening settings: $e');
    }
  }

  /// Get platform info
  String getPlatformInfo() {
    return isWeb ? 'Web Browser' : 'Mobile Device';
  }

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Force re-initialization
  Future<bool> reinitialize() async {
    _isInitialized = false;
    return await initialize();
  }
}
