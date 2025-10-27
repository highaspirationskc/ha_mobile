import 'package:flutter/material.dart';

class HAAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const HAAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.showBack = false,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false, // shell controls the back button
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
              tooltip: 'Back',
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                '/logos/HA_logo_darkblue.png',
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
      title:
          titleWidget ??
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
