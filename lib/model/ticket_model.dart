class SupportTicket {
  final String id;
  final String title;
  final String description;
  final String userEmail;
  final String userName;
  final String status; // open, in_progress, closed
  final String priority; // low, medium, high
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedTo;
  final List<String>? tags;

  SupportTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.userEmail,
    required this.userName,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'userEmail': userEmail,
      'userName': userName,
      'status': status,
      'priority': priority,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'assignedTo': assignedTo,
      'tags': tags ?? [],
    };
  }

  factory SupportTicket.fromMap(Map<String, dynamic> map, String id) {
    return SupportTicket(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      status: map['status'] ?? 'open',
      priority: map['priority'] ?? 'medium',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      assignedTo: map['assignedTo'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  SupportTicket copyWith({
    String? id,
    String? title,
    String? description,
    String? userEmail,
    String? userName,
    String? status,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedTo,
    List<String>? tags,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
    );
  }
}
