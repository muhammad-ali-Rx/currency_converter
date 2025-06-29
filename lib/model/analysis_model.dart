class Analysis {
  final String? id;
  final String title;
  final String currency;
  final String analysisType; // 'Technical', 'Fundamental', 'Market Sentiment'
  final String content;
  final String summary;
  final String recommendation; // 'Buy', 'Sell', 'Hold'
  final String riskLevel; // 'Low', 'Medium', 'High'
  final double confidenceScore; // 0.0 to 100.0
  final List<String> keyPoints;
  final String timeHorizon; // 'Short-term', 'Medium-term', 'Long-term'
  final bool isPublished;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final String authorName;

  Analysis({
    this.id,
    required this.title,
    required this.currency,
    required this.analysisType,
    required this.content,
    required this.summary,
    required this.recommendation,
    required this.riskLevel,
    required this.confidenceScore,
    required this.keyPoints,
    required this.timeHorizon,
    this.isPublished = true,
    this.views = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.authorName,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'currency': currency,
      'analysisType': analysisType,
      'content': content,
      'summary': summary,
      'recommendation': recommendation,
      'riskLevel': riskLevel,
      'confidenceScore': confidenceScore,
      'keyPoints': keyPoints,
      'timeHorizon': timeHorizon,
      'isPublished': isPublished,
      'views': views,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'authorId': authorId,
      'authorName': authorName,
    };
  }

  factory Analysis.fromMap(Map<String, dynamic> map, String documentId) {
    return Analysis(
      id: documentId,
      title: map['title'] ?? '',
      currency: map['currency'] ?? '',
      analysisType: map['analysisType'] ?? '',
      content: map['content'] ?? '',
      summary: map['summary'] ?? '',
      recommendation: map['recommendation'] ?? '',
      riskLevel: map['riskLevel'] ?? '',
      confidenceScore: (map['confidenceScore'] ?? 0.0).toDouble(),
      keyPoints: List<String>.from(map['keyPoints'] ?? []),
      timeHorizon: map['timeHorizon'] ?? '',
      isPublished: map['isPublished'] ?? true,
      views: map['views'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
    );
  }

  Analysis copyWith({
    String? id,
    String? title,
    String? currency,
    String? analysisType,
    String? content,
    String? summary,
    String? recommendation,
    String? riskLevel,
    double? confidenceScore,
    List<String>? keyPoints,
    String? timeHorizon,
    bool? isPublished,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorId,
    String? authorName,
  }) {
    return Analysis(
      id: id ?? this.id,
      title: title ?? this.title,
      currency: currency ?? this.currency,
      analysisType: analysisType ?? this.analysisType,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      recommendation: recommendation ?? this.recommendation,
      riskLevel: riskLevel ?? this.riskLevel,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      keyPoints: keyPoints ?? this.keyPoints,
      timeHorizon: timeHorizon ?? this.timeHorizon,
      isPublished: isPublished ?? this.isPublished,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
    );
  }
}
