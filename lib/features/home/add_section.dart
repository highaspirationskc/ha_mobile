import 'package:flutter/material.dart';
import '../../presentation/widgets/bottom_sheet_community_service.dart';
// import '../../presentation/widgets/bottom_sheet_pulse.dart'; // Commented out with Check-In button

class AddSection extends StatelessWidget {
  const AddSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        // Community Service - full width outlined button
        _AddButtonLong(
          icon: Icons.groups,
          label: 'Community Service',
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              useRootNavigator: true,
              builder: (context) => const BottomSheetCommunityService(),
            );
          },
        ),
        // Check-In button - commented out for now
        // const SizedBox(height: 12),
        // _AddButtonLong(
        //   icon: Icons.fact_check,
        //   label: 'Check-In',
        //   onTap: () {
        //     showModalBottomSheet(
        //       context: context,
        //       isScrollControlled: true,
        //       backgroundColor: Colors.transparent,
        //       useRootNavigator: true,
        //       builder: (context) => const BottomSheetPulse(),
        //     );
        //   },
        // ),
      ],
    );
  }
}

/// Long outlined button for Add section
class _AddButtonLong extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddButtonLong({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outline, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: cs.onSurface),
              const SizedBox(width: 12),
              Text(
                label,
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
