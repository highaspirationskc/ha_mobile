import 'package:flutter/material.dart';
import '../../core/theme/brand_colors.dart';

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
    final cs = Theme.of(context).colorScheme;
    final isTeamRoute = title == 'Leaderboard' || title == 'Team';

    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: isTeamRoute ? kFontDark : null,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, // shell controls the back button
      leading: showBack
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isTeamRoute ? kFontDark : null,
              ),
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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isTeamRoute ? kFontDark : null,
            ),
          ),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
