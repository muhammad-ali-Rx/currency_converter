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
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Create from Map (Firebase data)
  factory SimpleRateAlert.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    
    final createdAtField = map['createdAt'];
    
    if (createdAtField is Timestamp) {
      parsedDate = createdAtField.toDate();
    } else if (createdAtField is String) {
      parsedDate = DateTime.parse(createdAtField);
    } else {
      parsedDate = DateTime.now();
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

  @override
  String toString() {
    return 'SimpleRateAlert(${fromCurrency}/${toCurrency} $condition $targetRate)';
  }
}
