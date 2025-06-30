import 'dart:convert';
import 'package:currency_converter/model/rate-alert.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SimpleAlertService {
  static final SimpleAlertService _instance = SimpleAlertService._internal();
  factory SimpleAlertService() => _instance;
  SimpleAlertService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Initialize notifications
  Future<void> initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(settings);
  }

  // Add alert to Firebase - FIXED VERSION
  Future<String?> addAlert(SimpleRateAlert alert) async {
    try {
      // Create map without the id field for new documents
      final alertData = {
        'fromCurrency': alert.fromCurrency,
        'toCurrency': alert.toCurrency,
        'targetRate': alert.targetRate,
        'condition': alert.condition,
        'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
        'isActive': alert.isActive,
      };
      
      final docRef = await _firestore.collection('simple_alerts').add(alertData);
      print('Alert added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding alert: $e');
      return null;
    }
  }

  // Get all alerts from Firebase - FIXED VERSION
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
          data['id'] = doc.id; // Add document ID to data
          
          final alert = SimpleRateAlert.fromMap(data);
          alerts.add(alert);
        } catch (e) {
          print('Error parsing alert document ${doc.id}: $e');
          // Skip this document and continue with others
          continue;
        }
      }
      
      print('Successfully loaded ${alerts.length} alerts');
      return alerts;
    } catch (e) {
      print('Error getting alerts: $e');
      return [];
    }
  }

  // Get alerts as stream - NEW METHOD
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
          print('Error parsing alert document ${doc.id}: $e');
          continue;
        }
      }
      
      return alerts;
    });
  }

  // Delete alert
  Future<bool> deleteAlert(String alertId) async {
    try {
      await _firestore.collection('simple_alerts').doc(alertId).delete();
      print('Alert deleted: $alertId');
      return true;
    } catch (e) {
      print('Error deleting alert: $e');
      return false;
    }
  }

  // Get current exchange rate
  Future<double?> getCurrentRate(String from, String to) async {
    try {
      final url = 'https://api.exchangerate-api.com/v4/latest/$from';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        return rates[to]?.toDouble();
      }
    } catch (e) {
      print('Error getting rate: $e');
    }
    return null;
  }

  // Check all alerts and send notifications
  Future<void> checkAlerts() async {
    try {
      final alerts = await getAlerts();
      final activeAlerts = alerts.where((a) => a.isActive).toList();
      
      print('Checking ${activeAlerts.length} active alerts...');
      
      for (final alert in activeAlerts) {
        final currentRate = await getCurrentRate(alert.fromCurrency, alert.toCurrency);
        
        if (currentRate != null) {
          bool shouldNotify = false;
          
          if (alert.condition == 'above' && currentRate >= alert.targetRate) {
            shouldNotify = true;
          } else if (alert.condition == 'below' && currentRate <= alert.targetRate) {
            shouldNotify = true;
          }
          
          if (shouldNotify) {
            await _sendNotification(alert, currentRate);
            await _deactivateAlert(alert.id); // Deactivate after notification
          }
        }
      }
    } catch (e) {
      print('Error checking alerts: $e');
    }
  }

  // Send notification
  Future<void> _sendNotification(SimpleRateAlert alert, double currentRate) async {
    const androidDetails = AndroidNotificationDetails(
      'rate_alerts',
      'Rate Alerts',
      channelDescription: 'Currency rate alert notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    final title = '🚨 Rate Alert!';
    final body = '${alert.fromCurrency}/${alert.toCurrency} is now ${currentRate.toStringAsFixed(4)} (${alert.condition} ${alert.targetRate.toStringAsFixed(4)})';
    
    await _notifications.show(
      alert.id.hashCode,
      title,
      body,
      details,
    );
    
    print('Notification sent for ${alert.fromCurrency}/${alert.toCurrency}');
  }

  // Deactivate alert after notification
  Future<void> _deactivateAlert(String alertId) async {
    try {
      await _firestore.collection('simple_alerts').doc(alertId).update({'isActive': false});
      print('Alert deactivated: $alertId');
    } catch (e) {
      print('Error deactivating alert: $e');
    }
  }
}
