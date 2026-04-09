import 'package:flutter/material.dart';

import '../../business/rewards/entities/redemption.dart';
import '../../core/routes.dart';
import '../../data/services/rewards_service.dart';

class RedeemedRewardsScreen extends StatefulWidget {
  const RedeemedRewardsScreen({super.key});

  @override
  State<RedeemedRewardsScreen> createState() => _RedeemedRewardsScreenState();
}

class _RedeemedRewardsScreenState extends State<RedeemedRewardsScreen> {
  @override
  void initState() {
    super.initState();
    RewardsService.instance.fetchRewards();
  }

  Future<void> _refresh() => RewardsService.instance.refresh();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RewardsService.instance,
      builder: (context, _) {
        final isLoading = RewardsService.instance.isLoading;
        final redeemed = RewardsService.instance.redeemed;

        if (isLoading && redeemed.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (redeemed.isEmpty) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_giftcard_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No redeemed rewards yet',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: redeemed.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                thickness: 1,
                indent: 72,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withOpacity(0.3),
              ),
              itemBuilder: (context, index) {
                final item = redeemed[index];
                return _RedeemedTile(
                  redemption: item,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.rewardDetail,
                    arguments: item.incentive,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _RedeemedTile extends StatelessWidget {
  final Redemption redemption;
  final VoidCallback onTap;

  const _RedeemedTile({required this.redemption, required this.onTap});

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _statusColor(String status, ColorScheme cs) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final reward = redemption.incentive;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Reward image / placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: reward.imageUrl != null
                  ? Image.network(
                      reward.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(cs),
                    )
                  : _placeholder(cs),
            ),
            const SizedBox(width: 16),

            // Name + points | date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: t.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${redemption.pointsSpent}pts | ${_formatDate(redemption.createdAt)}',
                    style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Status badge
            Text(
              _formatStatus(redemption.status),
              style: t.bodySmall?.copyWith(
                color: _statusColor(redemption.status, cs),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme cs) => Container(
    width: 48,
    height: 48,
    color: cs.surfaceContainerHighest,
    child: Icon(
      Icons.card_giftcard_outlined,
      size: 24,
      color: cs.onSurfaceVariant,
    ),
  );
}
