// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../business/user/entities/user.dart';
import '../widgets/avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Local overrides so you can test editing without touching global mock data.
  String? _imageOverride;
  int? _colorIndexOverride;

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
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + role chip
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${u.firstName} ${u.lastName}',
                              style: t.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: cs.primary.withOpacity(0.20),
                              ),
                            ),
                            child: Text(
                              currentUserRoleLabel, // from session.dart
                              style: t.labelSmall?.copyWith(
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        u.email,
                        style: t.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Divider(height: 1, color: cs.outlineVariant),
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
