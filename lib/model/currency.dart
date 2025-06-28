import 'package:flutter/material.dart';

class Currency {
  final String code;
  final String name;
  final double rate;
  final double amount;
  final double percentChange;
  final double ratePerUsd;
  final Color color;

  Currency({
    required this.code,
    required this.name,
    required this.rate,
    required this.amount,
    required this.percentChange,
    required this.ratePerUsd,
    required this.color,
  });

  // ✅ FIREBASE COMPATIBLE: Factory constructor for Firestore data
  factory Currency.fromFirestore(Map<String, dynamic> data) {
    return Currency(
      code: data['code']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      rate: _parseNumber(data['rate']),
      amount: _parseNumber(data['amount']),
      percentChange: _parseNumber(data['percentChange']),
      ratePerUsd: _parseNumber(data['ratePerUsd']),
      color: _parseColor(data['color']),
    );
  }

  // ✅ Helper method to safely parse Firestore Number to double
  static double _parseNumber(dynamic value) {
    if (value == null) return 0.0;
    
    // Firestore returns num (can be int or double)
    if (value is num) {
      return value.toDouble();
    }
    
    // Fallback for string parsing
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    
    return 0.0;
  }

  // ✅ Helper method to safely parse Color values
  static Color _parseColor(dynamic value) {
    if (value == null) return Colors.blue;
    
    try {
      // Firestore mein color integer ke roop mein store hota hai
      if (value is num) {
        return Color(value.toInt());
      }
      
      if (value is String) {
        final intValue = int.tryParse(value);
        if (intValue != null) {
          return Color(intValue);
        }
      }
      
      return Colors.blue; // Default fallback
    } catch (e) {
      print('Error parsing color: $e, value: $value, type: ${value.runtimeType}');
      return Colors.blue;
    }
  }

  // ✅ Method to convert Currency to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'rate': rate, // Firestore will store as Number
      'amount': amount,
      'percentChange': percentChange,
      'ratePerUsd': ratePerUsd,
      'color': color.value, // Store as integer
    };
  }

  // Legacy JSON support (if needed)
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency.fromFirestore(json);
  }

  Map<String, dynamic> toJson() {
    return toFirestore();
  }

  // Copy with method for creating modified copies
  Currency copyWith({
    String? code,
    String? name,
    double? rate,
    double? amount,
    double? percentChange,
    double? ratePerUsd,
    Color? color,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      percentChange: percentChange ?? this.percentChange,
      ratePerUsd: ratePerUsd ?? this.ratePerUsd,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Currency(code: $code, name: $name, rate: $rate, amount: $amount, percentChange: $percentChange, ratePerUsd: $ratePerUsd)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency &&
        other.code == code &&
        other.name == name &&
        other.rate == rate &&
        other.amount == amount &&
        other.percentChange == percentChange &&
        other.ratePerUsd == ratePerUsd &&
        other.color == color;
  }

  @override
  int get hashCode {
    return code.hashCode ^
        name.hashCode ^
        rate.hashCode ^
        amount.hashCode ^
        percentChange.hashCode ^
        ratePerUsd.hashCode ^
        color.hashCode;
  }
}
