// lib/features/mentees/mentee_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/user_refs.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/brand_colors.dart';
import '../../presentation/widgets/avatar.dart';
import '../../presentation/widgets/message_bottom_sheet.dart';
import '../../presentation/widgets/grade_cards_screen.dart';
import '../../core/session.dart';

class MenteeScreen extends StatefulWidget {
  final User mentee;

  const MenteeScreen({super.key, required this.mentee});

  @override
  State<MenteeScreen> createState() => _MenteeScreenState();
}

class _MenteeScreenState extends State<MenteeScreen> {
  MenteeData? _menteeData;
  bool _isLoading = true;
  int _gradeCardCount = 0;

  @override
  void initState() {
    super.initState();
    _loadMenteeData();
  }

  Future<void> _loadMenteeData() async {
    setState(() => _isLoading = true);

    try {
      final data = await ApiService.instance.getMenteeData(
        userId: widget.mentee.id,
      );
      final gradeCardCount = await ApiService.instance.getGradeCardCount(
        userId: widget.mentee.id,
      );

      setState(() {
        _menteeData = data;
        _gradeCardCount = gradeCardCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Large Avatar
            _buildAvatar(widget.mentee, cs),
            const SizedBox(height: 16),

            // Mentee Name
            Text(
              widget.mentee.displayName.isNotEmpty
                  ? widget.mentee.displayName
                  : 'Mentee',
              style: t.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Email
            if (widget.mentee.email != null)
              Text(
                widget.mentee.email!,
                style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
            const SizedBox(height: 24),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Phone Button
                OutlinedButton(
                  onPressed: () => _makePhoneCall(context, widget.mentee.phone),
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: Icon(Icons.phone, color: cs.primary, size: 28),
                ),
                const SizedBox(width: 24),

                // Message Button
                OutlinedButton(
                  onPressed: () => _openMessaging(context),
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: Icon(Icons.message, color: cs.primary, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Loading indicator
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )
            else ...[
              // Mentor Section
              if (_menteeData?.mentor != null)
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
                    _buildContactTile(
                      context,
                      userRef: _menteeData!.mentor!,
                      label: 'Mentor',
                      cs: cs,
                      t: t,
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Guardians/Parents Section
              if (_menteeData?.parents != null &&
                  _menteeData!.parents!.isNotEmpty)
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
                    ..._menteeData!.parents!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final parent = entry.value;
                      return Column(
                        children: [
                          _buildContactTile(
                            context,
                            userRef: parent,
                            label: 'Guardian',
                            cs: cs,
                            t: t,
                          ),
                          if (index < _menteeData!.parents!.length - 1)
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

              // No info message if neither mentor nor parents
              if (_menteeData?.mentor == null &&
                  (_menteeData?.parents == null ||
                      _menteeData!.parents!.isEmpty))
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: cs.outline),
                      const SizedBox(height: 16),
                      Text(
                        'No contact information available',
                        style: t.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

              // Stats Section (Grade Cards)
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
                  _buildGradeCardsTile(cs, t),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: cs.outlineVariant.withOpacity(0.5),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(User mentee, ColorScheme cs) {
    if (mentee.image != null && mentee.image!.isNotEmpty) {
      // Check if it's a network image or asset
      if (mentee.image!.startsWith('http')) {
        return CircleAvatar(
          radius: 64,
          backgroundImage: NetworkImage(mentee.image!),
        );
      } else {
        return CircleAvatar(
          radius: 64,
          backgroundImage: AssetImage(mentee.image!),
        );
      }
    }

    // Fallback to colored avatar with initials
    final initials = _getInitials(mentee.displayName);
    final color = _getColorForIndex(mentee.colorIndex ?? 0);

    return CircleAvatar(
      radius: 64,
      backgroundColor: color.withOpacity(0.2),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 48,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getColorForIndex(int index) {
    final colors = [
      kTeamRed,
      kTeamYellow,
      Colors.orange,
      kTeamGreen,
      Colors.teal,
      kTeamBlue,
      kHAPrimary,
      Colors.indigo,
      kBrandSeed,
      Colors.pink,
      Colors.brown,
      Colors.blueGrey,
    ];
    return colors[index % colors.length];
  }

  Future<void> _makePhoneCall(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No phone number available for this mentee'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot make phone calls on this device'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openMessaging(BuildContext context) {
    showMessageBottomSheet(
      context,
      recipientName: widget.mentee.displayName,
      recipientId: widget.mentee.id,
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required UserRef userRef,
    required String label,
    required ColorScheme cs,
    required TextTheme t,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Avatar(
        firstName: userRef.firstName,
        lastName: userRef.lastName,
        image: userRef.image,
        size: 48,
      ),
      title: Text(
        label,
        style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      subtitle: Text(
        userRef.displayName,
        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: userRef.phone != null && userRef.phone!.isNotEmpty
          ? IconButton(
              icon: Icon(Icons.phone, color: cs.primary),
              onPressed: () => _makePhoneCall(context, userRef.phone),
            )
          : null,
    );
  }

  Widget _buildGradeCardsTile(ColorScheme cs, TextTheme t) {
    // Check if current user is a guardian (parent) - they can edit
    final isGuardian = currentUserKind.value == CurrentUserKind.parent;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GradeCardsScreen(
              menteeUserId: widget.mentee.id,
              menteeId: _menteeData?.menteeId,
              menteeName: widget.mentee.firstName ?? 'Mentee',
              canEdit: isGuardian, // Only guardians can add/delete
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Grade Cards Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.school_outlined, color: cs.primary, size: 24),
            ),
            const SizedBox(width: 16),
            // Grade Cards Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grade Cards',
                    style: t.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_gradeCardCount ${_gradeCardCount == 1 ? 'card' : 'cards'}',
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
