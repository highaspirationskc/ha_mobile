// lib/features/mentees/mentee_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../business/user/entities/user.dart';
import '../../business/user/entities/role_mentee.dart';
import '../../data/services/api_service.dart';
import '../../core/theme/brand_colors.dart';
import '../../presentation/widgets/message_bottom_sheet.dart';
import 'widgets/parent_contact_tile.dart';

class MenteeScreen extends StatefulWidget {
  final User mentee;

  const MenteeScreen({super.key, required this.mentee});

  @override
  State<MenteeScreen> createState() => _MenteeScreenState();
}

class _MenteeScreenState extends State<MenteeScreen> {
  MenteeData? _menteeData;
  bool _isLoading = true;

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

      setState(() {
        _menteeData = data;
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

            // Parents Section
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )
            else if (_menteeData?.parents != null &&
                _menteeData!.parents!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Parents',
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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _menteeData!.parents!.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 1,
                      indent: 72,
                      color: cs.outlineVariant.withOpacity(0.3),
                    ),
                    itemBuilder: (_, i) {
                      final parent = _menteeData!.parents![i];
                      return ParentContactTile(
                        parent: parent,
                        phoneNumber: parent.phone,
                        email: parent.email,
                      );
                    },
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.family_restroom, size: 48, color: cs.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No parent information available',
                      style: t.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

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
}
