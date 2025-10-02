class ActivityMember {
  final int participantId;
  final String userId;
  final String username;
  final String email;
  final String avatarUrl;
  final String role;
  final String status;

  ActivityMember({
    required this.participantId,
    required this.userId,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.role,
    required this.status,
  });

  factory ActivityMember.fromJson(Map<String, dynamic> json) {
    return ActivityMember(
      participantId: json['participant_id'],
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      role: json['role'],
      status: json['status'],
    );
  }
}
