// lib/presentation/widgets/button_round_small.dart
import 'package:flutter/material.dart';

class ButtonRoundSmall extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final bool tonal; // if true, uses secondaryContainer; else primary
  final EdgeInsetsGeometry? padding;
  final double minHeight;

  const ButtonRoundSmall({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.tonal = false,
    this.padding,
    this.minHeight = 32,
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

    if (leadingIcon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        label: Text(label),
        icon: Icon(leadingIcon, size: 16),
        style: style,
      );
    }
    return FilledButton(onPressed: onPressed, style: style, child: Text(label));
  }
}
