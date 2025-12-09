import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../business/community_service/entities/community_service.dart';
import '../../core/theme/brand_colors.dart';
import '../../data/services/api_service.dart';
import '../../core/session.dart';
import '../../presentation/widgets/button_long.dart';
import '../../presentation/widgets/bottom_sheet_community_service.dart';
import 'widgets/community_service_tile.dart';

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
      backgroundColor: cs.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Giving Back',
                    style: t.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hero Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/community_service_gardening.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Cards Row
                  Row(
                    children: [
                      // Events Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Icon in top right
                              Positioned(
                                top: 0,
                                right: 0,
                                child: SvgPicture.asset(
                                  'assets/icons/material-symbols_event.svg',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              // Text in bottom left
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 32),
                                  Text(
                                    'You gave back',
                                    style: t.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '${_services.length} ${_services.length == 1 ? 'time' : 'times'}',
                                    style: t.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Hours Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Icon in top right
                              Positioned(
                                top: 0,
                                right: 0,
                                child: SvgPicture.asset(
                                  'assets/icons/solar_hourglass-bold.svg',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              // Text in bottom left
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 32),
                                  Text(
                                    'You helped for',
                                    style: t.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '$_totalHours ${_totalHours == 1 ? 'hour' : 'hours'}',
                                    style: t.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Add Community Service Button
                  ButtonLong(
                    label: 'Add Community Service',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        useRootNavigator: true,
                        builder: (context) =>
                            const BottomSheetCommunityService(),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: kHAPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(height: 1, thickness: 1, color: cs.outlineVariant),
                  const SizedBox(height: 24),

                  // My Service Header
                  Text(
                    'My Service',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Service List
                  if (_services.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No community service logged yet',
                          style: t.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._services.map(
                      (service) => CommunityServiceTile(service: service),
                    ),
                ],
              ),
            ),
    );
  }
}
