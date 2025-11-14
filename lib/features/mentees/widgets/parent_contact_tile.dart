// lib/features/mentees/widgets/parent_contact_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../business/user/entities/user_refs.dart';
import '../../../core/theme/brand_colors.dart';

class ParentContactTile extends StatelessWidget {
  final UserRef parent;
  final String? phoneNumber;
  final String? email;

  const ParentContactTile({
    super.key,
    required this.parent,
    this.phoneNumber,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // Build the list of action panes based on available contact info
    final actions = <Widget>[];

    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      actions.add(
        SlidableAction(
          onPressed: (context) => _makePhoneCall(context, phoneNumber),
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          icon: Icons.phone,
          label: 'Call',
        ),
      );
    }

    if (email != null && email!.isNotEmpty) {
      actions.add(
        SlidableAction(
          onPressed: (context) => _sendEmail(context, email),
          backgroundColor: cs.secondary,
          foregroundColor: Colors.white,
          icon: Icons.email,
          label: 'Email',
        ),
      );
    }

    return Slidable(
      key: ValueKey(parent.id),
      endActionPane: actions.isNotEmpty
          ? ActionPane(motion: const DrawerMotion(), children: actions)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(parent),
            const SizedBox(width: 16),

            // Name
            Expanded(
              child: Text(
                parent.displayName.isNotEmpty ? parent.displayName : 'Parent',
                style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserRef parent) {
    if (parent.image != null && parent.image!.isNotEmpty) {
      // Check if it's a network image or asset
      if (parent.image!.startsWith('http')) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(parent.image!),
        );
      } else {
        return CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(parent.image!),
        );
      }
    }

    // Fallback to colored avatar with initials
    final initials = _getInitials(parent.displayName);
    final color = _getColorForIndex(parent.colorIndex ?? 0);

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
            content: Text('No phone number available'),
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

  Future<void> _sendEmail(BuildContext context, String? emailAddress) async {
    if (emailAddress == null || emailAddress.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email address available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final uri = Uri(scheme: 'mailto', path: emailAddress);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot send emails on this device'),
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
}
