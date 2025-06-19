import 'package:flutter/material.dart';

class Currency {
  final String code;
  final String name;
  final double rate;
  final double amount;
  final double percentChange;
  final double ratePerUsd;
  final Color? color; // make it nullable

  Currency({
    required this.code,
    required this.name,
    required this.rate,
    required this.amount,
    required this.percentChange,
    required this.ratePerUsd,
    this.color, // optional
  });
}
extension CurrencyExtensions on Currency {
  double get usdValue => amount / ratePerUsd;
  String get formattedLocal => '${amount.toStringAsFixed(2)} $code';
  String get formattedUsd => '\$${usdValue.toStringAsFixed(2)}';
}
