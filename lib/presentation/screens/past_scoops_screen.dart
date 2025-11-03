import 'package:flutter/material.dart';
import '../../data/mock/mock_data.dart';
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

  int get _totalItems => mockScoops.length;
  int get _displayedItems => _currentPage * _itemsPerPage;
  bool get _hasMore => _displayedItems < _totalItems;

  void _loadMore() {
    setState(() {
      _currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            final scoop = mockScoops[i];
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
