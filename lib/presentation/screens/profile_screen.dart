// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../core/routes.dart';
import '../../business/user/entities/user.dart';
import '../../data/services/api_service.dart';
import '../widgets/avatar.dart';
import '../widgets/community_service_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Local overrides so you can test editing without touching global mock data.
  String? _imageOverride;
  int? _colorIndexOverride;
  int _totalCommunityServiceHours = 0;
  int _totalCommunityServiceEvents = 0;

  @override
  void initState() {
    super.initState();
    _loadCommunityServiceHours();
    // Listen to API service changes to update hours when new entries are added
    ApiService.instance.changes.addListener(_onApiChanges);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onApiChanges);
    super.dispose();
  }

  void _onApiChanges() {
    _loadCommunityServiceHours();
  }

  Future<void> _loadCommunityServiceHours() async {
    try {
      final hours = await ApiService.instance.getTotalCommunityServiceHours(
        userId: currentUserId,
      );
      final services = await ApiService.instance.getCommunityServices(
        userId: currentUserId,
      );
      if (mounted) {
        setState(() {
          _totalCommunityServiceHours = hours;
          _totalCommunityServiceEvents = services.length;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return ValueListenableBuilder<CurrentUserKind>(
      valueListenable: currentUserKind,
      builder: (context, kind, _) {
        final User u = currentUser; // resolved from session.dart
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Role switcher
            Row(
              children: [
                Text(
                  'Profile',
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                SegmentedButton<CurrentUserKind>(
                  segments: const [
                    ButtonSegment(
                      value: CurrentUserKind.mentee,
                      label: Text('Mentee'),
                      icon: Icon(Icons.school_outlined),
                    ),
                    ButtonSegment(
                      value: CurrentUserKind.mentor,
                      label: Text('Mentor'),
                      icon: Icon(Icons.emoji_people_outlined),
                    ),
                  ],
                  selected: {kind},
                  onSelectionChanged: (s) {
                    switchCurrentUser(s.first);
                    // clear local overrides when switching mock users
                    setState(() {
                      _imageOverride = null;
                      _colorIndexOverride = null;
                    });
                    _loadCommunityServiceHours(); // Reload hours for new user
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Centered Avatar Section
            Center(
              child: Column(
                children: [
                  Avatar(
                    firstName: u.firstName,
                    lastName: u.lastName,
                    image: _imageOverride ?? u.image,
                    colorIndex: _colorIndexOverride ?? u.colorIndex,
                    editable: true,
                    onImageChanged: (path) =>
                        setState(() => _imageOverride = path),
                    onColorChanged: (i) =>
                        setState(() => _colorIndexOverride = i),
                    size: 96,
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    u.displayName.isNotEmpty ? u.displayName : u.email,
                    style: t.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    u.email,
                    style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Role chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: cs.primary.withOpacity(0.20)),
                    ),
                    child: Text(
                      currentUserRoleLabel, // from session.dart
                      style: t.labelMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Community Service Tile
            CommunityServiceTile(
              totalHours: _totalCommunityServiceHours,
              totalEvents: _totalCommunityServiceEvents,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.communityService);
              },
            ),

            const SizedBox(height: 16),

            // Future sections / role-specific cards can go here
            Text(
              'Other profile settings coming soon…',
              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        );
      },
    );
  }
}
