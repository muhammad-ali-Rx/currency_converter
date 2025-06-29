class ChartData {
  final String? id;
  final String title;
  final String currency;
  final String chartType; // 'Line', 'Candlestick', 'Bar', 'Area'
  final String timeframe; // '1H', '4H', '1D', '1W', '1M'
  final List<ChartPoint> dataPoints;
  final String description;
  final List<String> technicalIndicators;
  final Map<String, dynamic> chartSettings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final String authorName;

  ChartData({
    this.id,
    required this.title,
    required this.currency,
    required this.chartType,
    required this.timeframe,
    required this.dataPoints,
    required this.description,
    required this.technicalIndicators,
    required this.chartSettings,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.authorName,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'currency': currency,
      'chartType': chartType,
      'timeframe': timeframe,
      'dataPoints': dataPoints.map((point) => point.toMap()).toList(),
      'description': description,
      'technicalIndicators': technicalIndicators,
      'chartSettings': chartSettings,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'authorId': authorId,
      'authorName': authorName,
    };
  }

  factory ChartData.fromMap(Map<String, dynamic> map, String documentId) {
    return ChartData(
      id: documentId,
      title: map['title'] ?? '',
      currency: map['currency'] ?? '',
      chartType: map['chartType'] ?? '',
      timeframe: map['timeframe'] ?? '',
      dataPoints: (map['dataPoints'] as List<dynamic>?)
          ?.map((point) => ChartPoint.fromMap(point))
          .toList() ?? [],
      description: map['description'] ?? '',
      technicalIndicators: List<String>.from(map['technicalIndicators'] ?? []),
      chartSettings: Map<String, dynamic>.from(map['chartSettings'] ?? {}),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
    );
  }
}

class ChartPoint {
  final DateTime timestamp;
  final double value;
  final double? high;
  final double? low;
  final double? open;
  final double? close;
  final double? volume;

  ChartPoint({
    required this.timestamp,
    required this.value,
    this.high,
    this.low,
    this.open,
    this.close,
    this.volume,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'value': value,
      'high': high,
      'low': low,
      'open': open,
      'close': close,
      'volume': volume,
    };
  }

  factory ChartPoint.fromMap(Map<String, dynamic> map) {
    return ChartPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      value: (map['value'] ?? 0.0).toDouble(),
      high: map['high']?.toDouble(),
      low: map['low']?.toDouble(),
      open: map['open']?.toDouble(),
      close: map['close']?.toDouble(),
      volume: map['volume']?.toDouble(),
    );
  }
}
