import '../../user/entities/user.dart';

/// A message entity containing subject, content, and author information
class Message {
  final String id;
  final String subject;
  final String message;
  final User? author;
  final List<User> recipients;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isReply;
  final String? replyMode;
  final bool support;
  final String? parentId;
  final String? threadRootId;
  final List<Message> replies;
  final bool
  isRead; // From API - whether the current user has read this message

  const Message({
    required this.id,
    required this.subject,
    required this.message,
    this.author,
    this.recipients = const [],
    required this.createdAt,
    this.updatedAt,
    this.isReply = false,
    this.replyMode,
    this.support = false,
    this.parentId,
    this.threadRootId,
    this.replies = const [],
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      author: json['author'] != null
          ? User.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      recipients:
          (json['recipients'] as List<dynamic>?)
              ?.map((r) => User.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isReply: json['isReply'] as bool? ?? false,
      replyMode: json['replyMode'] as String?,
      support: json['support'] as bool? ?? false,
      parentId: json['parent']?['id']?.toString(),
      threadRootId: json['threadRoot']?['id']?.toString(),
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((r) => Message.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'message': message,
      'author': author?.toJson(),
      'recipients': recipients.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isReply': isReply,
      'replyMode': replyMode,
      'support': support,
      'parent': parentId != null ? {'id': parentId} : null,
      'threadRoot': threadRootId != null ? {'id': threadRootId} : null,
      'replies': replies.map((r) => r.toJson()).toList(),
      'isRead': isRead,
    };
  }

  Message copyWith({
    String? id,
    String? subject,
    String? message,
    User? Function()? author,
    List<User>? recipients,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isReply,
    String? replyMode,
    bool? support,
    String? parentId,
    String? threadRootId,
    List<Message>? replies,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      author: author != null ? author() : this.author,
      recipients: recipients ?? this.recipients,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isReply: isReply ?? this.isReply,
      replyMode: replyMode ?? this.replyMode,
      support: support ?? this.support,
      parentId: parentId ?? this.parentId,
      threadRootId: threadRootId ?? this.threadRootId,
      replies: replies ?? this.replies,
      isRead: isRead ?? this.isRead,
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
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, subject, message, author, createdAt);
  }

  @override
  String toString() {
    return 'Message(id: $id, subject: $subject, isReply: $isReply, author: ${author?.firstName})';
  }
}
