// lib/business/pulse/entities/pulse.dart

enum SupportTopic { school, work, home, relationships, health, other }

class Pulse {
  final String id;
  final String userId;
  final DateTime createdAt;
  final int rating; // 1-5 star rating
  final String highlight;
  final String challenge;
  final String thoughts;
  final List<SupportTopic> supportTopics;

  const Pulse({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.rating,
    required this.highlight,
    required this.challenge,
    required this.thoughts,
    required this.supportTopics,
  });

  Pulse copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    int? rating,
    String? highlight,
    String? challenge,
    String? thoughts,
    List<SupportTopic>? supportTopics,
  }) {
    return Pulse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      highlight: highlight ?? this.highlight,
      challenge: challenge ?? this.challenge,
      thoughts: thoughts ?? this.thoughts,
      supportTopics: supportTopics ?? this.supportTopics,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pulse &&
        other.id == id &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.rating == rating &&
        other.highlight == highlight &&
        other.challenge == challenge &&
        other.thoughts == thoughts &&
        other.supportTopics == supportTopics;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      createdAt,
      rating,
      highlight,
      challenge,
      thoughts,
      supportTopics,
    );
  }

  @override
  String toString() {
    return 'Pulse(id: $id, userId: $userId, createdAt: $createdAt, rating: $rating, highlight: $highlight, challenge: $challenge, thoughts: $thoughts, supportTopics: $supportTopics)';
  }
}
