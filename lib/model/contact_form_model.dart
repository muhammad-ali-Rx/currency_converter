class ContactForm {
  final String id;
  final String name;
  final String email;
  final String subject;
  final String message;
  final String status; // new, replied, closed
  final DateTime createdAt;
  final String? response;
  final DateTime? respondedAt;
  final String? respondedBy;

  ContactForm({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
    this.response,
    this.respondedAt,
    this.respondedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'response': response,
      'respondedAt': respondedAt?.millisecondsSinceEpoch,
      'respondedBy': respondedBy,
    };
  }

  factory ContactForm.fromMap(Map<String, dynamic> map, String id) {
    return ContactForm(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'new',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      response: map['response'],
      respondedAt: map['respondedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['respondedAt'])
          : null,
      respondedBy: map['respondedBy'],
    );
  }

  ContactForm copyWith({
    String? id,
    String? name,
    String? email,
    String? subject,
    String? message,
    String? status,
    DateTime? createdAt,
    String? response,
    DateTime? respondedAt,
    String? respondedBy,
  }) {
    return ContactForm(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      response: response ?? this.response,
      respondedAt: respondedAt ?? this.respondedAt,
      respondedBy: respondedBy ?? this.respondedBy,
    );
  }
}
