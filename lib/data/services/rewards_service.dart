import 'package:flutter/foundation.dart';

import '../../business/rewards/entities/reward.dart';
import '../../business/rewards/entities/redemption.dart';
import '../../business/rewards/entities/rewards_data.dart';
import '../mock/mock_rewards.dart';
import 'api_service.dart';

/// Service that manages rewards data with caching and fallback to mock data.
class RewardsService extends ChangeNotifier {
  static final RewardsService instance = RewardsService._();
  RewardsService._();

  RewardsData? _data;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;

  static const _cacheDuration = Duration(minutes: 5);

  List<Reward> get individualRewards => _data?.individualIncentives ?? [];
  List<Reward> get teamRewards => _data?.teamIncentives ?? [];
  List<Reward> get allRewards => _data?.allIncentives ?? mockRewards;
  List<Redemption> get redeemed => _data?.redeemed ?? [];
  int get totalPoints => _data?.totalPoints ?? 0;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _data != null;

  bool get _isCacheValid {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < _cacheDuration;
  }

  Future<void> fetchRewards({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid && _data != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) print('🎁 RewardsService: Fetching rewards...');

      final data = await ApiService.instance.getRewards(
        forceRefresh: forceRefresh,
      );
      _data = data;
      _lastFetch = DateTime.now();
      _error = null;

      if (kDebugMode) {
        print(
          '✅ RewardsService: ${data.individualIncentives.length} individual, '
          '${data.teamIncentives.length} team, ${data.totalPoints} pts',
        );
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ RewardsService: Error fetching rewards, using mock data: $e');
      }
      // Fall back to mock data so the UI always has something to show
      if (_data == null) {
        _data = RewardsData(
          individualIncentives:
              mockRewards.where((r) => r.type == RewardType.individual).toList(),
          teamIncentives:
              mockRewards.where((r) => r.type == RewardType.team).toList(),
          redeemed: const [],
          totalPoints: 0,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Redeems an incentive and refreshes rewards data afterwards.
  Future<void> redeemIncentive(String incentiveId) async {
    await ApiService.instance.createRedemption(incentiveId: incentiveId);
    await fetchRewards(forceRefresh: true);
  }

  Future<void> refresh() => fetchRewards(forceRefresh: true);

  void clearCache() {
    _data = null;
    _lastFetch = null;
    _error = null;
    notifyListeners();
  }
}
