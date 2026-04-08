import 'reward.dart';

class Redemption {
  final String id;
  final Reward incentive;
  final int pointsSpent;
  final String status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? notes;

  const Redemption({
    required this.id,
    required this.incentive,
    required this.pointsSpent,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.notes,
  });

  factory Redemption.fromJson(Map<String, dynamic> json) {
    return Redemption(
      id: json['id'].toString(),
      incentive: Reward.fromJson(json['incentive'] as Map<String, dynamic>),
      pointsSpent: json['pointsSpent'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}
