class RateAlert {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final double targetRate;
  final String condition; // 'above' or 'below'
  final bool isActive;
  final DateTime createdAt;
  final DateTime? triggeredAt;

  RateAlert({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.targetRate,
    required this.condition,
    this.isActive = true,
    required this.createdAt,
    this.triggeredAt,
  });

  factory RateAlert.fromMap(Map<String, dynamic> map) {
    return RateAlert(
      id: map['id'] ?? '',
      fromCurrency: map['fromCurrency'] ?? '',
      toCurrency: map['toCurrency'] ?? '',
      targetRate: (map['targetRate'] ?? 0.0).toDouble(),
      condition: map['condition'] ?? 'above',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      triggeredAt: map['triggeredAt'] != null ? DateTime.parse(map['triggeredAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'targetRate': targetRate,
      'condition': condition,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'triggeredAt': triggeredAt?.toIso8601String(),
    };
  }

  RateAlert copyWith({
    String? id,
    String? fromCurrency,
    String? toCurrency,
    double? targetRate,
    String? condition,
    bool? isActive,
    DateTime? createdAt,
    DateTime? triggeredAt,
  }) {
    return RateAlert(
      id: id ?? this.id,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      targetRate: targetRate ?? this.targetRate,
      condition: condition ?? this.condition,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }
}