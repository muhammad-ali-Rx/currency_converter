import 'dart:convert';
import 'package:currency_converter/model/rate-alert.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'web-compatible-notification-service.dart';

class SimpleAlertService {
  static final SimpleAlertService _instance = SimpleAlertService._internal();
  factory SimpleAlertService() => _instance;
  SimpleAlertService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final WebCompatibleNotificationService _notificationService = WebCompatibleNotificationService();
  bool _serviceInitialized = false;
  
  /// Initialize service with web-compatible notifications
  Future<bool> initNotifications() async {
    if (_serviceInitialized) {
      print('✅ Service already initialized');
      return true;
    }

    try {
      print('🔄 Initializing SimpleAlertService...');
      print('📱 Platform: ${_notificationService.getPlatformInfo()}');
      
      final success = await _notificationService.initialize();
      
      if (success) {
        _serviceInitialized = true;
        print('✅ SimpleAlertService initialized successfully');
        return true;
      } else {
        print('⚠️ Notification initialization failed, but service will continue');
        _serviceInitialized = true; // Allow service to work without notifications
        return false;
      }
    } catch (e) {
      print('❌ Error initializing SimpleAlertService: $e');
      return false;
    }
  }

  /// Add alert to Firebase
  Future<String?> addAlert(SimpleRateAlert alert) async {
    try {
      final alertData = {
        'fromCurrency': alert.fromCurrency,
        'toCurrency': alert.toCurrency,
        'targetRate': alert.targetRate,
        'condition': alert.condition,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': alert.isActive,
      };
      
      final docRef = await _firestore.collection('simple_alerts').add(alertData);
      print('✅ Alert added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding alert: $e');
      return null;
    }
  }

  /// Get alerts stream
  Stream<List<SimpleRateAlert>> getAlertsStream() {
    return _firestore
        .collection('simple_alerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final alerts = <SimpleRateAlert>[];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          
          final alert = SimpleRateAlert.fromMap(data);
          alerts.add(alert);
        } catch (e) {
          print('❌ Error parsing alert document ${doc.id}: $e');
          continue;
        }
      }
      
      return alerts;
    });
  }

  /// Get all alerts
  Future<List<SimpleRateAlert>> getAlerts() async {
    try {
      final snapshot = await _firestore
          .collection('simple_alerts')
          .orderBy('createdAt', descending: true)
          .get();
      
      final alerts = <SimpleRateAlert>[];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          
          final alert = SimpleRateAlert.fromMap(data);
          alerts.add(alert);
        } catch (e) {
          print('❌ Error parsing alert document ${doc.id}: $e');
          continue;
        }
      }
      
      print('✅ Successfully loaded ${alerts.length} alerts');
      return alerts;
    } catch (e) {
      print('❌ Error getting alerts: $e');
      return [];
    }
  }

  /// Delete alert
  Future<bool> deleteAlert(String alertId) async {
    try {
      await _firestore.collection('simple_alerts').doc(alertId).delete();
      print('✅ Alert deleted: $alertId');
      return true;
    } catch (e) {
      print('❌ Error deleting alert: $e');
      return false;
    }
  }

  /// Get current exchange rate
  Future<double?> getCurrentRate(String from, String to) async {
    try {
      final url = 'https://api.exchangerate-api.com/v4/latest/$from';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final rate = rates[to]?.toDouble();
        print('✅ Current rate $from/$to: $rate');
        return rate;
      } else {
        print('❌ API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting rate: $e');
    }
    return null;
  }

  /// Check all alerts and send notifications
  Future<void> checkAlerts() async {
    try {
      print('🔍 Starting alert check...');
      print('📱 Platform: ${_notificationService.getPlatformInfo()}');
      
      // Ensure notifications are initialized
      if (!_notificationService.isInitialized) {
        print('🔄 Reinitializing notifications...');
        await _notificationService.reinitialize();
      }
      
      final alerts = await getAlerts();
      final activeAlerts = alerts.where((a) => a.isActive).toList();
      
      print('📊 Found ${activeAlerts.length} active alerts to check');
      
      for (final alert in activeAlerts) {
        print('🔍 Checking ${alert.fromCurrency}/${alert.toCurrency}...');
        
        final currentRate = await getCurrentRate(alert.fromCurrency, alert.toCurrency);
        
        if (currentRate != null) {
          bool shouldTrigger = false;
          
          if (alert.condition == 'above' && currentRate >= alert.targetRate) {
            shouldTrigger = true;
            print('🚨 TRIGGER: $currentRate >= ${alert.targetRate} (above)');
          } else if (alert.condition == 'below' && currentRate <= alert.targetRate) {
            shouldTrigger = true;
            print('🚨 TRIGGER: $currentRate <= ${alert.targetRate} (below)');
          } else {
            print('✅ No trigger: $currentRate vs ${alert.targetRate} (${alert.condition})');
          }
          
          if (shouldTrigger) {
            await _triggerAlert(alert, currentRate);
          }
        } else {
          print('❌ Could not get rate for ${alert.fromCurrency}/${alert.toCurrency}');
        }
      }
      
      print('✅ Alert check completed');
    } catch (e) {
      print('❌ Error checking alerts: $e');
    }
  }

  /// Trigger alert and send notification
  Future<void> _triggerAlert(SimpleRateAlert alert, double currentRate) async {
    try {
      print('🚨 Triggering alert for ${alert.fromCurrency}/${alert.toCurrency}');
      
      // Send notification
      final notificationSent = await _notificationService.sendRateAlertNotification(
        fromCurrency: alert.fromCurrency,
        toCurrency: alert.toCurrency,
        currentRate: currentRate,
        targetRate: alert.targetRate,
        condition: alert.condition,
      );
      
      if (notificationSent) {
        print('✅ Notification sent successfully');
      } else {
        print('⚠️ Notification failed to send');
      }
      
      // Deactivate alert regardless of notification status
      await _deactivateAlert(alert.id);
      
      print('✅ Alert triggered and deactivated: ${alert.id}');
    } catch (e) {
      print('❌ Error triggering alert: $e');
    }
  }

  /// Deactivate alert after notification
  Future<void> _deactivateAlert(String alertId) async {
    try {
      await _firestore.collection('simple_alerts').doc(alertId).update({
        'isActive': false,
        'triggeredAt': FieldValue.serverTimestamp(),
      });
      print('✅ Alert deactivated: $alertId');
    } catch (e) {
      print('❌ Error deactivating alert: $e');
    }
  }

  /// Test notification
  Future<bool> testNotification() async {
    print('🧪 Testing notification...');
    print('📱 Platform: ${_notificationService.getPlatformInfo()}');
    
    if (!_notificationService.isInitialized) {
      print('🔄 Initializing notifications for test...');
      final initialized = await _notificationService.initialize();
      if (!initialized) {
        print('❌ Failed to initialize notifications for test');
        return false;
      }
    }
    
    return await _notificationService.sendTestNotification();
  }

  /// Check notification permissions
  Future<bool> hasNotificationPermissions() async {
    return await _notificationService.areNotificationsEnabled();
  }

  /// Open notification settings
  Future<void> openNotificationSettings() async {
    await _notificationService.openNotificationSettings();
  }

  /// Get service status
  bool get isInitialized => _serviceInitialized;
  
  /// Get platform info
  String get platformInfo => _notificationService.getPlatformInfo();
  
  /// Force reinitialize
  Future<bool> reinitialize() async {
    _serviceInitialized = false;
    return await initNotifications();
  }
}
