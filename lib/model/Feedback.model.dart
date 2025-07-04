import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String type;
  final String name;
  final String email;
  final String message;
  final DateTime timestamp;
  final String status;
  final String priority;
  final String category;
  final String? steps;
  final int? rating;

  FeedbackModel({
    required this.id,
    required this.type,
    required this.name,
    required this.email,
    required this.message,
    required this.timestamp,
    required this.status,
    required this.priority,
    required this.category,
    this.steps,
    this.rating,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] is Timestamp 
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'New',
      priority: json['priority'] ?? 'Medium',
      category: json['category'] ?? 'feedback',
      steps: json['steps'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'email': email,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'priority': priority,
      'category': category,
      'steps': steps,
      'rating': rating,
    };
  }

  FeedbackModel copyWith({
    String? id,
    String? type,
    String? name,
    String? email,
    String? message,
    DateTime? timestamp,
    String? status,
    String? priority,
    String? category,
    String? steps,
    int? rating,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      steps: steps ?? this.steps,
      rating: rating ?? this.rating,
    );
  }
}