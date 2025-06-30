import 'package:cloud_firestore/cloud_firestore.dart';

class SimpleRateAlert {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double targetRate;
  final String condition; // 'above' or 'below'
  final DateTime createdAt;
  final bool isActive;

  SimpleRateAlert({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.targetRate,
    required this.condition,
    required this.createdAt,
    this.isActive = true,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'targetRate': targetRate,
      'condition': condition,
      'createdAt': createdAt.toIso8601String(), // Always save as string
      'isActive': isActive,
    };
  }

  // Create from Map (Firebase data) - FIXED VERSION
  factory SimpleRateAlert.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    
    // Handle different types of createdAt field
    final createdAtField = map['createdAt'];
    
    if (createdAtField is Timestamp) {
      // Firebase Timestamp object
      parsedDate = createdAtField.toDate();
    } else if (createdAtField is String) {
      // ISO string
      parsedDate = DateTime.parse(createdAtField);
    } else {
      // Fallback to current time
      parsedDate = DateTime.now();
      print('Warning: createdAt field type not recognized, using current time');
    }
    
    return SimpleRateAlert(
      id: map['id'] ?? '',
      fromCurrency: map['fromCurrency'] ?? '',
      toCurrency: map['toCurrency'] ?? '',
      targetRate: (map['targetRate'] ?? 0.0).toDouble(),
      condition: map['condition'] ?? 'above',
      createdAt: parsedDate,
      isActive: map['isActive'] ?? true,
    );
  }
}
