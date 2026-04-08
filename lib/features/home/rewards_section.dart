import 'package:flutter/material.dart';
import '../../business/rewards/entities/reward.dart';
import '../../core/routes.dart';
import '../../data/services/rewards_service.dart';

class RewardsSection extends StatefulWidget {
  const RewardsSection({super.key});

  @override
  State<RewardsSection> createState() => _RewardsSectionState();
}

class _RewardsSectionState extends State<RewardsSection> {
  @override
  void initState() {
    super.initState();
    RewardsService.instance.fetchRewards();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: RewardsService.instance,
      builder: (context, _) {
        final rewards = RewardsService.instance.allRewards;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Rewards',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.rewards);
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (RewardsService.instance.isLoading && rewards.isEmpty)
              const SizedBox(
                height: 158,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SizedBox(
                height: 158,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  itemCount: rewards.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) =>
                      _RewardTile(reward: rewards[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RewardTile extends StatelessWidget {
  final Reward reward;

  const _RewardTile({required this.reward});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.rewardDetail,
        arguments: reward,
      ),
      child: SizedBox(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
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
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.card_giftcard,
                            size: 40,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.card_giftcard,
                          size: 40,
                          color: cs.onSurfaceVariant,
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
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${reward.cost} pts',
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
