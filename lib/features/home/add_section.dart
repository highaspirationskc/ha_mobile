import 'package:flutter/material.dart';
import '../../presentation/widgets/bottom_sheet_community_service.dart';
import '../../presentation/widgets/bottom_sheet_pulse.dart';

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
        Row(
          children: [
            Expanded(
              child: _AddButton(
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AddButton(
                icon: Icons.fact_check,
                label: 'Check-In',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useRootNavigator: true,
                    builder: (context) => const BottomSheetPulse(),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddButton({
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outline, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Icon in top right
              Positioned(
                top: 0,
                right: 0,
                child: Icon(icon, size: 24, color: cs.onSurface),
              ),
              // Label at bottom left
              Positioned(
                bottom: 0,
                left: 0,
                right: 40,
                child: Text(
                  label,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
