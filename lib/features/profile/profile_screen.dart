// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/session.dart';
import '../../core/routes.dart';
import '../../core/theme/brand_colors.dart';
import '../../core/utils/phone_formatter.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_refs.dart';
import '../../data/services/api_service.dart';
import '../../data/services/rewards_service.dart';
import '../../presentation/widgets/avatar.dart';
import '../../presentation/widgets/message_bottom_sheet.dart';
import 'widgets/community_service_button.dart';
import 'widgets/grade_cards_tile.dart';
import 'widgets/redeemed_rewards_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  double _totalCommunityServiceHours = 0;
  int _totalCommunityServiceEvents = 0;
  // TODO: Re-enable when attendance is ready
  // int _totalAttendance = 0;
  int _totalGradeCards = 0;
  UserRef? _mentor;
  List<UserRef> _guardians = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    RewardsService.instance.fetchRewards();
    RewardsService.instance.addListener(_onRewardsChange);
    // Listen to API service changes to update hours when new entries are added
    ApiService.instance.changes.addListener(_onApiChanges);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onApiChanges);
    RewardsService.instance.removeListener(_onRewardsChange);
    super.dispose();
  }

  void _onApiChanges() => _loadUserData();

  void _onRewardsChange() => setState(() {});

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
      await ApiService.instance.getTotalAttendance(userId: currentUserId);
      final gradeCardCount = await ApiService.instance.getGradeCardCount(
        userId: currentUserId,
      );

      if (mounted) {
        setState(() {
          _currentUser = currentUserData.user;
          _mentor = currentUserData.mentor;
          _guardians = currentUserData.guardians;
          _totalCommunityServiceHours = hours;
          _totalCommunityServiceEvents = services.length;
          // TODO: Re-enable when attendance is ready
          // _totalAttendance = attendance;
          _totalGradeCards = gradeCardCount;
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
              // Settings icon in top right
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: IconButton(
                    icon: Icon(Icons.settings_outlined, color: cs.onSurface),
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.accountSettings);
                    },
                    tooltip: 'Account Settings',
                  ),
                ),
              ),

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

              // Phone
              if (u.phone != null && u.phone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    PhoneFormatter.format(u.phone),
                    style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),

              // Points (only for mentees)
              if (currentUserKind.value == CurrentUserKind.mentee) ...[
                const SizedBox(height: 8),
                Text(
                  '${RewardsService.instance.totalPoints} pts',
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
                    // TODO: Re-enable attendance tile when ready
                    // _buildAttendanceTile(context, cs, t),
                    // Divider(
                    //   height: 1,
                    //   thickness: 1,
                    //   indent: 72,
                    //   color: cs.outlineVariant.withOpacity(0.3),
                    // ),
                    CommunityServiceTile(
                      totalHours: _totalCommunityServiceHours,
                      totalEvents: _totalCommunityServiceEvents,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 72,
                      color: cs.outlineVariant.withOpacity(0.3),
                    ),
                    GradeCardsTile(totalCards: _totalGradeCards),
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 72,
                      color: cs.outlineVariant.withOpacity(0.3),
                    ),
                    RedeemedRewardsTile(
                      count: RewardsService.instance.redeemed.length,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                  ],
                ),

              const SizedBox(height: 100), // Space for floating nav bar
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(User u, ColorScheme cs, TextTheme t) {
    return Avatar(
      firstName: u.firstName,
      lastName: u.lastName,
      image: u.image,
      colorIndex: u.colorIndex,
      editable: false,
      size: 64,
    );
  }

  Widget _buildMentorTile(BuildContext context, ColorScheme cs, TextTheme t) {
    final phoneNumber = _mentor!.phone ?? '';

    return Padding(
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

          // Action icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message icon
              IconButton(
                icon: Icon(Icons.mail_outline, color: kHAPrimary, size: 22),
                onPressed: () => _messageMentor(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              // Phone icon (only if phone available)
              if (phoneNumber.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.phone, color: kHAPrimary, size: 22),
                  onPressed: () => _callMentor(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _messageMentor(BuildContext context) {
    showMessageBottomSheet(
      context,
      recipientName: _mentor!.displayName,
      recipientId: _mentor!.id,
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
    final phoneNumber = guardian.phone ?? '';

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

          // Action icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message icon
              IconButton(
                icon: Icon(Icons.mail_outline, color: kHAPrimary, size: 22),
                onPressed: () => _messageGuardian(context, guardian),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              // Phone icon (only if phone available)
              if (phoneNumber.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.phone, color: kHAPrimary, size: 22),
                  onPressed: () => _callGuardian(context, guardian),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _messageGuardian(BuildContext context, UserRef guardian) {
    showMessageBottomSheet(
      context,
      recipientName: guardian.displayName,
      recipientId: guardian.id,
    );
  }

  Future<void> _callGuardian(BuildContext context, UserRef guardian) async {
    final phoneNumber = guardian.phone ?? '';
    if (phoneNumber.isEmpty) return;

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
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

  // TODO: Re-enable attendance tile when ready
  // Widget _buildAttendanceTile(
  //   BuildContext context,
  //   ColorScheme cs,
  //   TextTheme t,
  // ) {
  //   return InkWell(
  //     onTap: () {
  //       // TODO: Navigate to attendance screen when implemented
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Attendance details coming soon!'),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //     },
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       child: Row(
  //         children: [
  //           // Attendance Icon
  //           Container(
  //             width: 48,
  //             height: 48,
  //             decoration: BoxDecoration(
  //               color: cs.primary.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(24),
  //             ),
  //             child: Icon(Icons.event_available, color: cs.primary, size: 24),
  //           ),
  //           const SizedBox(width: 16),
  //           // Attendance Info
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Attendance',
  //                   style: t.bodyLarge?.copyWith(
  //                     fontWeight: FontWeight.w600,
  //                     color: cs.onSurface,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 2),
  //                 Text(
  //                   '$_totalAttendance events',
  //                   style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           // Arrow Icon
  //           Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 24),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
