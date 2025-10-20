// lib/presentation/widgets/button_round_small.dart
import 'package:flutter/material.dart';

class ButtonRoundSmall extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final bool tonal; // if true, uses secondaryContainer; else primary
  final EdgeInsetsGeometry? padding;
  final double minHeight;
  final bool isLoading; // NEW

  const ButtonRoundSmall({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.tonal = false,
    this.padding,
    this.minHeight = 32,
    this.isLoading = false, // NEW default
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = tonal ? cs.secondaryContainer : cs.primary;
    final fg = tonal ? cs.onSecondaryContainer : cs.onPrimary;

    final style = FilledButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      minimumSize: Size(minHeight, minHeight), // height clamp
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    Widget? leading() {
      if (isLoading) {
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(fg),
          ),
        );
      }
      if (leadingIcon != null) {
        return Icon(leadingIcon, size: 16, color: fg);
      }
      return null;
    }

    final lead = leading();

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lead != null) ...[
            lead,
            const SizedBox(width: 4), // exact 4px gap
          ],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
