// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/session.dart';
import '../../core/routes.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_refs.dart';
import '../../data/services/api_service.dart';
import '../widgets/avatar.dart';
import '../widgets/community_service_tile.dart';
import '../../business/user/entities/role_mentee.dart';

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
  int _totalAttendance = 0;
  int _totalPulses = 0;
  int _totalPoints = 0;
  UserRef? _mentor;
  TeamSummary? _teamSummary;

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
      final attendance = await ApiService.instance.getTotalAttendance(
        userId: currentUserId,
      );
      final pulses = await ApiService.instance.getPulses(userId: currentUserId);
      final menteeData = await ApiService.instance.getMenteeData(
        userId: currentUserId,
      );
      if (mounted) {
        setState(() {
          _totalCommunityServiceHours = hours;
          _totalCommunityServiceEvents = services.length;
          _totalAttendance = attendance;
          _totalPulses = pulses.length;
          _totalPoints =
              attendance +
              services.length; // Points = attendance + community service events
          _mentor = menteeData?.mentor;
          _teamSummary = menteeData?.teamSummary;
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
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 100, // Space for floating nav bar
          ),
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

                  // Points chip
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
                      '$_totalPoints points',
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

            // Mentor Tile (only show for mentees with assigned mentors)
            if (currentUserKind.value == CurrentUserKind.mentee &&
                _mentor != null)
              _buildMentorTile(context, cs, t),

            // Attendance Tile
            _buildAttendanceTile(context, cs, t),

            // Pulse Tile
            _buildPulseTile(context, cs, t),

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

  Widget _buildMentorTile(BuildContext context, ColorScheme cs, TextTheme t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _callMentor(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Mentor Avatar
              SizedBox(
                width: 48,
                height: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_mentor!.image != null && _mentor!.image!.isNotEmpty)
                        Image(
                          image: _mentor!.image!.startsWith('http')
                              ? NetworkImage(_mentor!.image!) as ImageProvider
                              : AssetImage(_mentor!.image!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildMentorFallbackAvatar(context, cs),
                        )
                      else
                        _buildMentorFallbackAvatar(context, cs),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Mentor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mentor',
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _mentor!.displayName,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // Phone Number (placeholder for now)
              Text(
                '(620) 555-1234',
                style: t.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callMentor(BuildContext context) async {
    const phoneNumber =
        '(620) 555-1234'; // TODO: Make this dynamic from mentor data
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        // Fallback: copy phone number to clipboard
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phone number copied to clipboard: $phoneNumber'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Fallback: copy phone number to clipboard
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number copied to clipboard: $phoneNumber'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildAttendanceTile(
    BuildContext context,
    ColorScheme cs,
    TextTheme t,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to attendance screen when implemented
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance details coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Attendance Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.event_available,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Attendance Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_totalAttendance',
                      style: t.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Attendance',
                      style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // View Button
              Text(
                'View',
                style: t.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseTile(BuildContext context, ColorScheme cs, TextTheme t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.pulses);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Pulse Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.favorite, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              // Pulse Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_totalPulses',
                      style: t.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pulses',
                      style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // View Button
              Text(
                'View',
                style: t.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMentorFallbackAvatar(BuildContext context, ColorScheme cs) {
    final f = (_mentor!.firstName ?? '').trim();
    final l = (_mentor!.lastName ?? '').trim();
    final initials =
        (f.isNotEmpty ? f.characters.first : '') +
        (l.isNotEmpty ? l.characters.first : '');

    return Container(
      color: cs.surfaceVariant,
      alignment: Alignment.center,
      child: Text(
        (initials.isEmpty ? 'M' : initials).toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
