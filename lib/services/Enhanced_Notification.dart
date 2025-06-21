import 'dart:async';
import 'package:currency_converter/model/app_notification.dart';
import 'package:currency_converter/model/notifications.dart';

class EnhancedNotificationService {
  static final EnhancedNotificationService _instance = EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal() {
    // Initialize with some sample notifications for testing
    _initializeSampleNotifications();
  }

  final StreamController<List<AppNotification>> _notificationController = 
      StreamController<List<AppNotification>>.broadcast();
  
  Stream<List<AppNotification>> get notificationStream => _notificationController.stream;
  
  List<AppNotification> _notifications = [];
  NotificationSettings _settings = NotificationSettings();

  void _initializeSampleNotifications() {
    _notifications = [
      AppNotification(
        id: '1',
        title: 'Rate Alert Triggered',
        body: 'USD/EUR rate has reached your target of 0.85',
        type: NotificationType.rateAlert,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'App Update Available',
        body: 'Version 2.1.0 is now available with new features',
        type: NotificationType.appUpdate,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      AppNotification(
        id: '3',
        title: 'Market News',
        body: 'EUR strengthens against USD amid economic data',
        type: NotificationType.marketNews,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
      ),
    ];
    _notificationController.add(_notifications);
  }

  // Get all notifications
  List<AppNotification> getNotifications() {
    return List.from(_notifications);
  }

  // Get unread count
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  // Get settings
  NotificationSettings getSettings() {
    return _settings;
  }

  // Update settings
  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    // Save to local storage if needed
  }

  // Add notification
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    _notificationController.add(_notifications);
  }

  // Mark as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationController.add(_notifications);
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _notificationController.add(_notifications);
  }

  // Delete notification
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    _notificationController.add(_notifications);
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    _notificationController.add(_notifications);
  }

  // Show app update notification
  Future<void> showAppUpdateNotification(String version, String message) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'App Update Available',
      body: 'Version $version: $message',
      type: NotificationType.appUpdate,
      timestamp: DateTime.now(),
    );
    await addNotification(notification);
  }

  // Show rate alert notification
  Future<void> showRateAlertNotification(String currencyPair, double rate, String condition) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Rate Alert Triggered',
      body: '$currencyPair rate $condition $rate',
      type: NotificationType.rateAlert,
      timestamp: DateTime.now(),
    );
    await addNotification(notification);
  }

  // Check notification permissions
  Future<bool> areNotificationsEnabled() async {
    // Implement platform-specific permission check
    return true; // Placeholder
  }

  // Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    // Implement platform-specific permission request
    return true; // Placeholder
  }

  // Dispose
  void dispose() {
    _notificationController.close();
  }
}