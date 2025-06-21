import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:currency_converter/model/Rate_Alerts.dart';
class RateAlertService {
  static final RateAlertService _instance = RateAlertService._internal();
  factory RateAlertService() => _instance;
  RateAlertService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  Timer? _alertTimer;
  List<RateAlert> _alerts = [];

  Future<void> initialize() async {
    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(initSettings);
    
    // Start monitoring alerts
    startMonitoring();
  }

  void startMonitoring() {
    _alertTimer?.cancel();
    _alertTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkAlerts();
    });
  }

  void stopMonitoring() {
    _alertTimer?.cancel();
  }

  Future<void> _checkAlerts() async {
    for (var alert in _alerts.where((a) => a.isActive)) {
      try {
        final currentRate = await _getCurrentRate(alert.fromCurrency, alert.toCurrency);
        
        bool shouldTrigger = false;
        if (alert.condition == 'above' && currentRate >= alert.targetRate) {
          shouldTrigger = true;
        } else if (alert.condition == 'below' && currentRate <= alert.targetRate) {
          shouldTrigger = true;
        }

        if (shouldTrigger) {
          await _triggerAlert(alert, currentRate);
        }
      } catch (e) {
        print('Error checking alert ${alert.id}: $e');
      }
    }
  }

  Future<double> _getCurrentRate(String from, String to) async {
    // Replace with your actual currency API
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/$from'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['rates'][to] ?? 0.0).toDouble();
    }
    
    throw Exception('Failed to fetch exchange rate');
  }

  Future<void> _triggerAlert(RateAlert alert, double currentRate) async {
    // Show notification
    await _showNotification(alert, currentRate);
    
    // Mark alert as triggered and deactivate
    final updatedAlert = alert.copyWith(
      isActive: false,
      triggeredAt: DateTime.now(),
    );
    
    // Update in storage (implement your storage logic here)
    await updateAlert(updatedAlert);
  }

  Future<void> _showNotification(RateAlert alert, double currentRate) async {
    const androidDetails = AndroidNotificationDetails(
      'rate_alerts',
      'Rate Alerts',
      channelDescription: 'Currency exchange rate alerts',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final title = 'Rate Alert Triggered!';
    final body = '${alert.fromCurrency}/${alert.toCurrency} is now ${currentRate.toStringAsFixed(4)} '
                 '(target: ${alert.targetRate.toStringAsFixed(4)} ${alert.condition})';

    await _notificationsPlugin.show(
      alert.id.hashCode,
      title,
      body,
      details,
    );
  }

  // Alert management methods
  Future<void> addAlert(RateAlert alert) async {
    _alerts.add(alert);
    // Implement your storage logic here (SharedPreferences, SQLite, etc.)
  }

  Future<void> updateAlert(RateAlert alert) async {
    final index = _alerts.indexWhere((a) => a.id == alert.id);
    if (index != -1) {
      _alerts[index] = alert;
      // Implement your storage logic here
    }
  }

  Future<void> deleteAlert(String alertId) async {
    _alerts.removeWhere((a) => a.id == alertId);
    // Implement your storage logic here
  }

  List<RateAlert> getAlerts() => List.from(_alerts);

  Future<void> loadAlerts() async {
    // Implement loading from storage
    // _alerts = await loadFromStorage();
  }
}