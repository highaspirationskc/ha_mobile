class EventType {
  final String id;
  final String name;
  final String category;
  final int pointValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventType({
    required this.id,
    required this.name,
    required this.category,
    required this.pointValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      pointValue: json['pointValue'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'pointValue': pointValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
