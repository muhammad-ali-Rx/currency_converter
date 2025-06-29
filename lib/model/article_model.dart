class Article {
  final String? id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String source;
  final String impact;
  final String imageUrl; // This will store base64 string
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final String authorName;
  final bool isPublished;

  Article({
    this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.source,
    required this.impact,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    required this.authorName,
    this.isPublished = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'category': category,
      'source': source,
      'impact': impact,
      'imageUrl': imageUrl, // Base64 string
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'authorId': authorId,
      'authorName': authorName,
      'isPublished': isPublished,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map, String id) {
    return Article(
      id: id,
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      source: map['source'] ?? '',
      impact: map['impact'] ?? '',
      imageUrl: map['imageUrl'] ?? '', // Base64 string
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      isPublished: map['isPublished'] ?? true,
    );
  }

  Article copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? category,
    String? source,
    String? impact,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorId,
    String? authorName,
    bool? isPublished,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      category: category ?? this.category,
      source: source ?? this.source,
      impact: impact ?? this.impact,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
