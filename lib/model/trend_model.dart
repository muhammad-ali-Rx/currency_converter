class Trend {
  final String? id;
  final String title;
  final String currency;
  final String timeframe;
  final double percentage;
  final String direction; // 'up', 'down', 'neutral'
  final String description;
  final String analysis;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final String authorName;

  Trend({
    this.id,
    required this.title,
    required this.currency,
    required this.timeframe,
    required this.percentage,
    required this.direction,
    required this.description,
    required this.analysis,
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
      'timeframe': timeframe,
      'percentage': percentage,
      'direction': direction,
      'description': description,
      'analysis': analysis,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'authorId': authorId,
      'authorName': authorName,
    };
  }

  factory Trend.fromMap(Map<String, dynamic> map, String documentId) {
    return Trend(
      id: documentId,
      title: map['title'] ?? '',
      currency: map['currency'] ?? '',
      timeframe: map['timeframe'] ?? '',
      percentage: (map['percentage'] ?? 0.0).toDouble(),
      direction: map['direction'] ?? 'neutral',
      description: map['description'] ?? '',
      analysis: map['analysis'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
    );
  }

  Trend copyWith({
    String? id,
    String? title,
    String? currency,
    String? timeframe,
    double? percentage,
    String? direction,
    String? description,
    String? analysis,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorId,
    String? authorName,
  }) {
    return Trend(
      id: id ?? this.id,
      title: title ?? this.title,
      currency: currency ?? this.currency,
      timeframe: timeframe ?? this.timeframe,
      percentage: percentage ?? this.percentage,
      direction: direction ?? this.direction,
      description: description ?? this.description,
      analysis: analysis ?? this.analysis,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
    );
  }
}
