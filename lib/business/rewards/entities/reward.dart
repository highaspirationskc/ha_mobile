enum RewardType { team, individual }

class Reward {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;
  final int cost;
  final RewardType type;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reward({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    required this.cost,
    required this.type,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    final rawType = (json['incentiveType'] as String? ?? 'individual').toLowerCase();
    return Reward(
      id: json['id'].toString(),
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      cost: json['pointCost'] as int,
      type: rawType == 'team' ? RewardType.team : RewardType.individual,
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
