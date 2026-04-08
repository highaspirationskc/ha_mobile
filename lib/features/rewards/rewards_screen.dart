import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../business/rewards/entities/reward.dart';
import '../../core/routes.dart';
import '../../data/services/rewards_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    RewardsService.instance.fetchRewards();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RewardsService.instance,
      builder: (context, _) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TabHeader(
                  userPoints: RewardsService.instance.totalPoints,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _RewardsGrid(
                        rewards: RewardsService.instance.individualRewards,
                        isLoading: RewardsService.instance.isLoading,
                      ),
                      _RewardsGrid(
                        rewards: RewardsService.instance.teamRewards,
                        isLoading: RewardsService.instance.isLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabHeader extends StatelessWidget {
  final int userPoints;

  const _TabHeader({required this.userPoints});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              labelColor: cs.onSurface,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 2),
                borderRadius: BorderRadius.zero,
              ),
              indicatorColor: cs.onSurface,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              padding: EdgeInsets.zero,
              tabs: const [
                Tab(text: 'Individual'),
                Tab(text: 'Team'),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/points_icon.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  '${userPoints}pts',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardsGrid extends StatelessWidget {
  final List<Reward> rewards;
  final bool isLoading;

  const _RewardsGrid({required this.rewards, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading && rewards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rewards.isEmpty) {
      return Center(
        child: Text(
          'No rewards available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, i) => _RewardGridTile(reward: rewards[i]),
    );
  }
}

class _RewardGridTile extends StatelessWidget {
  final Reward reward;

  const _RewardGridTile({required this.reward});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.rewardDetail,
        arguments: reward,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: reward.imageUrl != null
                    ? Image.network(
                        reward.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.card_giftcard,
                            size: 48,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.card_giftcard,
                          size: 48,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reward.name,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${reward.cost} pts',
            style: textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
