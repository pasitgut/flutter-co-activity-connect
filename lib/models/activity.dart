class Activity {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String type;
  final List<String> tags;
  final String joinCondition;
  final int maxMembers;
  int currentMembers;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.tags,
    required this.joinCondition,
    required this.maxMembers,
    this.currentMembers = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
