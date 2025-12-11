import 'package:flutter/material.dart';
import '../../business/scoops/entities/scoop.dart';
import '../../data/services/api_service.dart';
import '../../core/routes.dart';
import '../widgets/list_tile_scoop.dart';

class PastScoopsScreen extends StatefulWidget {
  const PastScoopsScreen({super.key});

  @override
  State<PastScoopsScreen> createState() => _PastScoopsScreenState();
}

class _PastScoopsScreenState extends State<PastScoopsScreen> {
  static const int _itemsPerPage = 10;
  int _currentPage = 1;
  List<Scoop> _scoops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScoops();
  }

  Future<void> _loadScoops() async {
    final scoops = await ApiService.instance.getSaturdayScoops();
    if (mounted) {
      setState(() {
        _scoops = scoops;
        _isLoading = false;
      });
    }
  }

  int get _totalItems => _scoops.length;
  int get _displayedItems => _currentPage * _itemsPerPage;
  bool get _hasMore => _displayedItems < _totalItems;

  void _loadMore() {
    setState(() {
      _currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_scoops.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No scoops yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final itemsToShow = _displayedItems > _totalItems
        ? _totalItems
        : _displayedItems;

    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemsToShow + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          // Show scoop tile
          if (i < itemsToShow) {
            final scoop = _scoops[i];
            return ListTileScoop(
              scoop: scoop,
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamed(AppRoutes.scoopDetail, arguments: scoop);
              },
            );
          }

          // Show "Load More" button
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: OutlinedButton(
                onPressed: _loadMore,
                child: const Text('Load More'),
              ),
            ),
          );
        },
      ),
    );
  }
}
