class Conversation {
  final String id;
  final String name;
  final String type;
  final String role;
  final String avatar;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? profileImage;

  Conversation({
    required this.id,
    required this.name,
    required this.type,
    required this.role,
    required this.avatar,
    required this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
    this.profileImage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'role': role,
      'avatar': avatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'profileImage': profileImage,
    };
  }
}

class Message {
  final String id;
  final String text;
  final String sender;
  final bool isCurrentUser;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    required this.isCurrentUser,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      text: json['text'] ?? '',
      sender: json['sender'] ?? '',
      isCurrentUser: json['isCurrentUser'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp']) ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'isCurrentUser': isCurrentUser,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
