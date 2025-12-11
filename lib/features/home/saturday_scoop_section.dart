import 'package:flutter/material.dart';
import '../../business/scoops/entities/scoop.dart';
import '../../data/services/api_service.dart';
import '../../core/routes.dart';
import '../../presentation/widgets/list_tile_scoop.dart';

class SaturdayScoopSection extends StatefulWidget {
  const SaturdayScoopSection({super.key});

  @override
  State<SaturdayScoopSection> createState() => _SaturdayScoopSectionState();
}

class _SaturdayScoopSectionState extends State<SaturdayScoopSection> {
  Scoop? _scoop;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScoop();
  }

  Future<void> _loadScoop() async {
    final scoop = await ApiService.instance.getThisWeeksScoop();
    if (mounted) {
      setState(() {
        _scoop = scoop;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Still loading
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    // If no Saturday scoop for this week, return empty widget
    if (_scoop == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saturday Scoop',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ListTileScoop(
          scoop: _scoop!,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.scoopDetail, arguments: _scoop);
          },
        ),
      ],
    );
  }
}
