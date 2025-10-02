class PrivateChat {
  final int chatId;
  final String user1Id;
  final String user2Id;
  final int? lastMessageId;
  final DateTime updatedAt;
  final String? otherUsername;
  final String? otherProfileImage;
  final String? otherUserId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final int unreadCount;

  PrivateChat({
    required this.chatId,
    required this.user1Id,
    required this.user2Id,
    this.lastMessageId,
    required this.updatedAt,
    this.otherUsername,
    this.otherProfileImage,
    this.otherUserId,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCount = 0,
  });

  factory PrivateChat.fromJson(Map<String, dynamic> json) {
    return PrivateChat(
      chatId: json['chat_id'],
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      lastMessageId: json['last_message_id'],
      updatedAt: DateTime.parse(json['updated_at']),
      otherUsername: json['other_username'],
      otherProfileImage: json['other_profile_image'],
      otherUserId: json['other_user_id'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : null,
      lastMessageSenderId: json['last_message_sender_id'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
