// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/session.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_refs.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../presentation/widgets/avatar.dart';
import '../../presentation/screens/login_screen.dart';
import 'widgets/community_service_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  String? _imageOverride;
  int? _colorIndexOverride;
  int _totalCommunityServiceHours = 0;
  int _totalCommunityServiceEvents = 0;
  int _totalAttendance = 0;
  int _totalPoints = 0;
  UserRef? _mentor;
  List<UserRef> _guardians = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Listen to API service changes to update hours when new entries are added
    ApiService.instance.changes.addListener(_onApiChanges);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onApiChanges);
    super.dispose();
  }

  void _onApiChanges() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch current user data from API (includes mentor if user is a mentee)
      final currentUserData = await ApiService.instance.getCurrentUser();

      final hours = await ApiService.instance.getTotalCommunityServiceHours(
        userId: currentUserId,
      );
      final services = await ApiService.instance.getCommunityServices(
        userId: currentUserId,
      );
      final attendance = await ApiService.instance.getTotalAttendance(
        userId: currentUserId,
      );

      if (mounted) {
        setState(() {
          _currentUser = currentUserData.user;
          _mentor = currentUserData.mentor;
          _guardians = currentUserData.guardians;
          _totalCommunityServiceHours = hours;
          _totalCommunityServiceEvents = services.length;
          _totalAttendance = attendance;
          _totalPoints =
              attendance +
              services.length; // Points = attendance + community service events
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Fallback to mock user if no authenticated user (shouldn't happen but safe)
    final u = _currentUser ?? currentUser;

    return ValueListenableBuilder<CurrentUserKind>(
      valueListenable: currentUserKind,
      builder: (context, kind, _) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Large Avatar
              _buildAvatar(u, cs, t),
              const SizedBox(height: 16),

              // Name
              Text(
                u.displayName.isNotEmpty ? u.displayName : (u.email ?? ''),
                style: t.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Email
              if (u.email != null)
                Text(
                  u.email!,
                  style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                ),

              // Points (only for mentees)
              if (currentUserKind.value == CurrentUserKind.mentee) ...[
                const SizedBox(height: 8),
                Text(
                  '$_totalPoints pts',
                  style: t.titleLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Mentor Section (only show for mentees with assigned mentors)
              if (currentUserKind.value == CurrentUserKind.mentee &&
                  _mentor != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Mentor',
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                    _buildMentorTile(context, cs, t),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Family Section (only show for mentees with guardians)
              if (currentUserKind.value == CurrentUserKind.mentee &&
                  _guardians.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Family',
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                    ..._guardians.asMap().entries.map((entry) {
                      final index = entry.key;
                      final guardian = entry.value;
                      return Column(
                        children: [
                          _buildGuardianTile(context, cs, t, guardian),
                          if (index < _guardians.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 72,
                              color: cs.outlineVariant.withOpacity(0.3),
                            ),
                        ],
                      );
                    }),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Stats Section (only show for mentees)
              if (currentUserKind.value == CurrentUserKind.mentee)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Stats',
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                    _buildAttendanceTile(context, cs, t),
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 72,
                      color: cs.outlineVariant.withOpacity(0.3),
                    ),
                    CommunityServiceTile(
                      totalHours: _totalCommunityServiceHours,
                      totalEvents: _totalCommunityServiceEvents,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Log Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _handleLogOut(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),

              const SizedBox(height: 100), // Space for floating nav bar
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogOut(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogOut == true && context.mounted) {
      // Perform logout via AuthService
      await AuthService.instance.logout();
      clearAuthenticatedUser();

      // Navigate to login screen and clear navigation stack
      // Use Navigator.of(context, rootNavigator: true) to ensure we're using the root navigator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildAvatar(User u, ColorScheme cs, TextTheme t) {
    return Avatar(
      firstName: u.firstName,
      lastName: u.lastName,
      image: _imageOverride ?? u.image,
      colorIndex: _colorIndexOverride ?? u.colorIndex,
      editable: true,
      onImageChanged: (path) => _handleAvatarChange(path),
      onColorChanged: (i) => setState(() => _colorIndexOverride = i),
      size: 64,
    );
  }

  Future<void> _handleAvatarChange(String? path) async {
    if (path == null) {
      // Remove avatar - just clear local override for now
      setState(() => _imageOverride = null);
      return;
    }

    // Show loading indicator
    setState(() => _imageOverride = path);

    try {
      // Read file bytes (works on both web and native)
      final xFile = XFile(path);
      final bytes = await xFile.readAsBytes();
      final fileName = path.split('/').last;

      // Upload the new avatar
      final newAvatarUrl = await ApiService.instance.updateUserAvatar(
        userId: currentUserId,
        imageBytes: bytes,
        fileName: fileName.isNotEmpty ? fileName : 'avatar.jpg',
      );

      if (mounted) {
        setState(() {
          _imageOverride = newAvatarUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Revert to previous image on error
        setState(() => _imageOverride = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update avatar: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildMentorTile(BuildContext context, ColorScheme cs, TextTheme t) {
    final phoneNumber = _mentor!.phone ?? '';

    return InkWell(
      onTap: phoneNumber.isNotEmpty ? () => _callMentor(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Mentor Avatar
            Avatar(
              firstName: _mentor!.firstName,
              lastName: _mentor!.lastName,
              image: _mentor!.image,
              colorIndex: _mentor!.colorIndex,
              size: 48,
              editable: false,
            ),
            const SizedBox(width: 16),

            // Mentor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mentor',
                    style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _mentor!.displayName,
                    style: t.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Phone Number (tappable)
            if (phoneNumber.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phoneNumber,
                    style: t.bodyMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.phone, color: cs.primary, size: 20),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _callMentor(BuildContext context) async {
    final phoneNumber = _mentor?.phone ?? '';
    if (phoneNumber.isEmpty) return;

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

  Widget _buildGuardianTile(
    BuildContext context,
    ColorScheme cs,
    TextTheme t,
    UserRef guardian,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Guardian Avatar
          Avatar(
            firstName: guardian.firstName,
            lastName: guardian.lastName,
            image: guardian.image,
            colorIndex: guardian.colorIndex,
            size: 48,
            editable: false,
          ),
          const SizedBox(width: 16),

          // Guardian Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guardian',
                  style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  guardian.displayName,
                  style: t.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTile(
    BuildContext context,
    ColorScheme cs,
    TextTheme t,
  ) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to attendance screen when implemented
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance details coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Attendance Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.event_available, color: cs.primary, size: 24),
            ),
            const SizedBox(width: 16),
            // Attendance Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance',
                    style: t.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_totalAttendance events',
                    style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
          ],
        ),
      ),
    );
  }
}
