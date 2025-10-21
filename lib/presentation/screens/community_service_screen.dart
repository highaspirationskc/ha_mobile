import 'package:flutter/material.dart';
import '../../business/community_service/entities/community_service.dart';
import '../../data/services/api_service.dart';
import '../../core/session.dart';
import '../widgets/list_tile_community_service.dart';

class CommunityServiceScreen extends StatefulWidget {
  const CommunityServiceScreen({super.key});

  @override
  State<CommunityServiceScreen> createState() => _CommunityServiceScreenState();
}

class _CommunityServiceScreenState extends State<CommunityServiceScreen> {
  List<CommunityService> _services = [];
  int _totalHours = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommunityServices();
    // Listen to API service changes to update when new entries are added
    ApiService.instance.changes.addListener(_onApiChanges);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onApiChanges);
    super.dispose();
  }

  void _onApiChanges() {
    _loadCommunityServices();
  }

  Future<void> _loadCommunityServices() async {
    try {
      final services = await ApiService.instance.getCommunityServices(
        userId: currentUserId,
      );
      final hours = await ApiService.instance.getTotalCommunityServiceHours(
        userId: currentUserId,
      );
      if (mounted) {
        setState(() {
          _services = services;
          _totalHours = hours;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(
                            Icons.home_work_outlined,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          'Community Service',
                          style: t.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Events Count
                            Column(
                              children: [
                                Text(
                                  '${_services.length}',
                                  style: t.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.primary,
                                  ),
                                ),
                                Text(
                                  'Events',
                                  style: t.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),

                            // Divider
                            Container(
                              width: 1,
                              height: 40,
                              color: cs.outlineVariant,
                            ),

                            // Total Hours
                            Column(
                              children: [
                                Text(
                                  '$_totalHours',
                                  style: t.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.primary,
                                  ),
                                ),
                                Text(
                                  'Hours',
                                  style: t.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Events List
                  if (_services.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.home_work_outlined,
                            size: 48,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Community Service Yet',
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start volunteering to track your community service hours!',
                            style: t.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Events',
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._services.map(
                          (service) => ListTileCommunityService(
                            service: service,
                            onTap: () {
                              // TODO: Navigate to service detail if needed
                            },
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
