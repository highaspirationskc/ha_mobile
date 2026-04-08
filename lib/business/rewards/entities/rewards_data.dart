import 'redemption.dart';
import 'reward.dart';

class RewardsData {
  final List<Reward> individualIncentives;
  final List<Reward> teamIncentives;
  final List<Redemption> redeemed;
  final int totalPoints;

  const RewardsData({
    required this.individualIncentives,
    required this.teamIncentives,
    required this.redeemed,
    required this.totalPoints,
  });

  List<Reward> get allIncentives => [...individualIncentives, ...teamIncentives];

  factory RewardsData.fromJson(Map<String, dynamic> json) {
    Reward _parseReward(dynamic item) =>
        Reward.fromJson(item as Map<String, dynamic>);

    Redemption _parseRedemption(dynamic item) =>
        Redemption.fromJson(item as Map<String, dynamic>);

    return RewardsData(
      totalPoints: json['totalPoints'] as int? ?? 0,
      individualIncentives:
          (json['individualIncentives'] as List<dynamic>? ?? [])
              .map(_parseReward)
              .toList(),
      teamIncentives: (json['teamIncentives'] as List<dynamic>? ?? [])
          .map(_parseReward)
          .toList(),
      redeemed: (json['redeemed'] as List<dynamic>? ?? [])
          .map(_parseRedemption)
          .toList(),
    );
  }
}
