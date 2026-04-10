class ChatSession {
  const ChatSession({
    this.id = '',
    required this.userId,
    required this.title,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'title': title,
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String? ?? 'New Chat',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
}

class ChatMessage {
  const ChatMessage({
    this.id = '',
    this.sessionId = '',
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String id;
  final String sessionId;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'text': text,
        'is_user': isUser,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        sessionId: json['session_id'] as String,
        text: json['text'] as String,
        isUser: json['is_user'] as bool,
        timestamp: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );
}
