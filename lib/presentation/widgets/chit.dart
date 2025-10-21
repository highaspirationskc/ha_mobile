import 'package:flutter/material.dart';

/// A reusable chip component that can be used throughout the app
/// for displaying labels, tags, roles, or other short text indicators
class Chit extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final TextStyle? textStyle;

  const Chit({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.primary,
        borderRadius: BorderRadius.circular(borderRadius ?? 999),
      ),
      child: Text(
        label,
        style:
            textStyle ??
            t.labelSmall?.copyWith(
              color: textColor ?? cs.onPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
