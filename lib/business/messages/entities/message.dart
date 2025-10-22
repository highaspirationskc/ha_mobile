import '../../user/entities/user.dart';

/// A message entity containing subject, content, and author information
class Message {
  final String id;
  final String subject;
  final String message;
  final User author;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool read;

  const Message({
    required this.id,
    required this.subject,
    required this.message,
    required this.author,
    required this.createdAt,
    this.updatedAt,
    this.read = false,
  });

  Message copyWith({
    String? id,
    String? subject,
    String? message,
    User? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? read,
  }) {
    return Message(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      read: read ?? this.read,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.id == id &&
        other.subject == subject &&
        other.message == message &&
        other.author == author &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.read == read;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      subject,
      message,
      author,
      createdAt,
      updatedAt,
      read,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, subject: $subject, message: $message, author: $author, createdAt: $createdAt, updatedAt: $updatedAt, read: $read)';
  }
}
