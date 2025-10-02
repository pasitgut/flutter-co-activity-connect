class Message {
  final int messageId;
  final String senderId;
  final String? receiverId;
  final int? activityId;
  final String message;
  final bool isRead;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MessageSender? sender;

  Message({
    required this.messageId,
    required this.senderId,
    this.receiverId,
    this.activityId,
    required this.message,
    this.isRead = false,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      activityId: json['activity_id'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      isEdited: json['is_edited'] ?? false,
      createdAt: DateTime.parse(json['create_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sender: json['sender'] != null
          ? MessageSender.fromJson(json['sender'])
          : null,
    );
  }

  Message copyWith({
    int? messageId,
    String? senderId,
    String? receiverId,
    int? activityId,
    String? message,
    bool? isRead,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
    MessageSender? sender,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      activityId: activityId ?? this.activityId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
    );
  }
}

class MessageSender {
  final String userId;
  final String username;
  final String? profileImage;

  MessageSender({
    required this.userId,
    required this.username,
    this.profileImage,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      userId: json['user_id'],
      username: json['username'],
      profileImage: json['profile_image'],
    );
  }
}
