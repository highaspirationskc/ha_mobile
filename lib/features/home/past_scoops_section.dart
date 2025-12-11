import 'package:flutter/material.dart';
import '../../business/scoops/entities/scoop.dart';
import '../../data/services/api_service.dart';
import '../../core/routes.dart';
import '../../presentation/widgets/saturday_scoop_small.dart';

class PastScoopsSection extends StatefulWidget {
  const PastScoopsSection({super.key});

  @override
  State<PastScoopsSection> createState() => _PastScoopsSectionState();
}

class _PastScoopsSectionState extends State<PastScoopsSection> {
  List<Scoop> _scoops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScoops();
  }

  Future<void> _loadScoops() async {
    final scoops = await ApiService.instance.getPastScoops();
    if (mounted) {
      setState(() {
        _scoops = scoops;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Don't show section if loading or no scoops
    if (_isLoading || _scoops.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with View All button
        Row(
          children: [
            Text(
              'Past Scoops',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.pastScoops);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal scrolling scoop cards
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: (_scoops.length > 10 ? 10 : _scoops.length) + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              // Show up to 10 scoop cards
              if (i < 10 && i < _scoops.length) {
                final scoop = _scoops[i];
                return SizedBox(
                  width: 105,
                  child: SaturdayScoopSmall(
                    scoop: scoop,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.scoopDetail, arguments: scoop);
                    },
                  ),
                );
              }

              // Show "View More" card at the end
              return _ViewMoreCard(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.pastScoops);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ViewMoreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewMoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View More',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
