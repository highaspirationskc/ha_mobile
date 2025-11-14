// lib/features/mentees/widgets/mentee_call_tile.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../business/user/entities/user.dart';
import '../../../core/theme/brand_colors.dart';

class MenteeCallTile extends StatelessWidget {
  final User mentee;
  final VoidCallback? onTap;

  const MenteeCallTile({super.key, required this.mentee, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(mentee),
            const SizedBox(width: 16),

            // Name
            Expanded(
              child: Text(
                mentee.displayName.isNotEmpty ? mentee.displayName : 'Mentee',
                style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),

            // Phone icon
            IconButton(
              icon: Icon(Icons.phone, color: cs.primary),
              onPressed: () => _makePhoneCall(context, mentee.phone),
              tooltip: 'Call ${mentee.displayName}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(User mentee) {
    if (mentee.image != null && mentee.image!.isNotEmpty) {
      // Check if it's a network image or asset
      if (mentee.image!.startsWith('http')) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(mentee.image!),
        );
      } else {
        return CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(mentee.image!),
        );
      }
    }

    // Fallback to colored avatar with initials
    final initials = _getInitials(mentee.displayName);
    final color = _getColorForIndex(mentee.colorIndex ?? 0);

    return CircleAvatar(
      radius: 24,
      backgroundColor: color.withOpacity(0.2),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 16,
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

    // Remove any non-digit characters except '+'
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot make phone calls on this device'),
              duration: const Duration(seconds: 2),
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
}
