class Activity {
  int id;
  String creatorId;
  String title;
  String description;
  int currentMembers;
  int maxMembers;
  bool isPublic;
  String type;
  List<String> tags;

  Activity({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.currentMembers,
    required this.maxMembers,
    required this.isPublic,
    required this.type,
    required this.tags,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['activity_id'],
      creatorId: json['creator_id'],
      title: json['title'],
      description: json['description'],
      currentMembers: json['current_member'],
      maxMembers: json['max_member'],
      isPublic: json['is_public'],
      type: json['type'],
      tags: List<String>.from(json['tags']),
    );
  }
}
