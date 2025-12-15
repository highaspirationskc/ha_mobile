/// A grade card entity representing academic achievements by mentees
class GradeCard {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GradeCard({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GradeCard.fromJson(Map<String, dynamic> json) {
    return GradeCard(
      id: json['id'].toString(),
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GradeCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GradeCard(id: $id, imageUrl: $imageUrl, description: $description)';
  }
}
