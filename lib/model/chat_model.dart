class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String senderName;
  final String? messageId;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.senderName,
    this.messageId,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'senderName': senderName,
      'messageId': messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      senderName: map['senderName'] ?? '',
      messageId: map['messageId'],
    );
  }
}

class LiveChat {
  final String id;
  final String userEmail;
  final String userName;
  final String status; // 'active', 'waiting', 'closed'
  final List<ChatMessage> messages;
  final DateTime startTime;
  final DateTime? endTime;
  final String? assignedAgent;

  LiveChat({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.status,
    required this.messages,
    required this.startTime,
    this.endTime,
    this.assignedAgent,
  });

  factory LiveChat.fromMap(Map<String, dynamic> map, String id) {
    List<ChatMessage> messagesList = [];
    if (map['messages'] != null) {
      messagesList = (map['messages'] as List<dynamic>)
          .map((msg) => ChatMessage.fromMap(msg))
          .toList();
    }

    return LiveChat(
      id: id,
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      status: map['status'] ?? 'active',
      messages: messagesList,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] ?? 0),
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime'])
          : null,
      assignedAgent: map['assignedAgent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userEmail': userEmail,
      'userName': userName,
      'status': status,
      'messages': messages.map((msg) => msg.toMap()).toList(),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'assignedAgent': assignedAgent,
    };
  }

  LiveChat copyWith({
    String? id,
    String? userEmail,
    String? userName,
    String? status,
    List<ChatMessage>? messages,
    DateTime? startTime,
    DateTime? endTime,
    String? assignedAgent,
  }) {
    return LiveChat(
      id: id ?? this.id,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      assignedAgent: assignedAgent ?? this.assignedAgent,
    );
  }
}
