// lib/presentation/screens/root_shell.dart
import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/session.dart'; // currentUserKind, CurrentUserKind

import '../widgets/ha_app_bar.dart';
import '../widgets/ha_nav_bar.dart';
import '../widgets/avatar.dart';
import '../../data/services/api_service.dart';
import '../../business/user/entities/user.dart';

// Screens (body-only)
import '../../features/home/home_screen.dart';
import 'notifications_screen.dart';
import 'message_screen.dart';
import '../../features/profile/profile_screen.dart';
import 'event_detail_screen.dart';
import 'calendar_screen.dart';
import 'scoop_detail_screen.dart';
import 'past_scoops_screen.dart';
import 'check_in_scanner.dart';
import '../../features/mentees/mentees_list_screen.dart';
import '../../features/profile/community_service_screen.dart';
import '../../features/profile/account_settings_screen.dart';
import '../../features/contact_support/contact_support_screen.dart';
import '../widgets/grade_cards_screen.dart';
import 'pulses_screen.dart';
import 'team_screen.dart';

// Entities
import '../../business/events/entities/event.dart';
import '../../business/scoops/entities/scoop.dart';

// Mock data
// Mock messages import removed - now using API service

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  // We keep a stack index (which tab Navigator is visible). For mentee,
  // the nav has a non-tab action at index 1, so we map between navIndex<->stackIndex.
  int _stackIndex = 0;

  // Stable keys per potential tab
  final _homeKey = GlobalKey<NavigatorState>();
  final _menteesKey = GlobalKey<NavigatorState>(); // mentor-only tab
  final _teamsKey = GlobalKey<NavigatorState>();
  final _profileKey = GlobalKey<NavigatorState>();

  // Track top route names for titles
  String _homeRoute = AppRoutes.homeRoot;
  String _menteesRoute = AppRoutes.menteesRoot;
  String _teamsRoute = AppRoutes.teamRoot;
  String _profileRoute = AppRoutes.profileRoot;

  // Current user data
  User? _currentUser;

  // Unread messages count
  int _unreadCount = 0;

  // deferred setState to avoid setState-during-build
  bool _pending = false;
  void _deferRebuild() {
    if (_pending) return;
    _pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pending = false;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUnreadCount();
    ApiService.instance.changes.addListener(_onApiChange);
  }

  @override
  void dispose() {
    ApiService.instance.changes.removeListener(_onApiChange);
    super.dispose();
  }

  void _onApiChange() {
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    // Fetch inbox if not cached, then get unread count
    await ApiService.instance.getInbox();
    if (mounted) {
      setState(() {
        _unreadCount = ApiService.instance.getUnreadCount();
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final currentUserData = await ApiService.instance.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = currentUserData.user;
        });
      }
    } catch (e) {
      // Fall back to mock user if API fails
      if (mounted) {
        setState(() {});
      }
    }
  }

  late final _homeObs = _TabObserver((r, _) {
    _homeRoute = r?.settings.name ?? AppRoutes.homeRoot;
    _deferRebuild();
  });
  late final _menteesObs = _TabObserver((r, _) {
    _menteesRoute = r?.settings.name ?? AppRoutes.menteesRoot;
    _deferRebuild();
  });
  late final _teamsObs = _TabObserver((r, _) {
    _teamsRoute = r?.settings.name ?? AppRoutes.teamRoot;
    _deferRebuild();
  });
  late final _profileObs = _TabObserver((r, _) {
    _profileRoute = r?.settings.name ?? AppRoutes.profileRoot;
    _deferRebuild();
  });

  // Build a tab descriptor
  _Tab _homeTab() => _Tab(
    label: 'Home',
    icon: const Icon(Icons.home_outlined),
    selectedIcon: const Icon(Icons.home),
    key: _homeKey,
    observers: [_homeObs],
    rootName: AppRoutes.homeRoot,
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case AppRoutes.homeRoot:
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
            settings: const RouteSettings(name: AppRoutes.homeRoot),
          );
        case AppRoutes.eventDetail:
          final event = settings.arguments as Event;
          return MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
            settings: const RouteSettings(name: AppRoutes.eventDetail),
          );
        case AppRoutes.calendar:
          return MaterialPageRoute(
            builder: (_) => const CalendarScreen(),
            settings: const RouteSettings(name: AppRoutes.calendar),
          );
        case AppRoutes.scoopDetail:
          final scoop = settings.arguments as Scoop;
          return MaterialPageRoute(
            builder: (_) => ScoopDetailScreen(scoop: scoop),
            settings: const RouteSettings(name: AppRoutes.scoopDetail),
          );
        case AppRoutes.pastScoops:
          return MaterialPageRoute(
            builder: (_) => const PastScoopsScreen(),
            settings: const RouteSettings(name: AppRoutes.pastScoops),
          );
        case AppRoutes.checkInScanner:
          final eventId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => CheckInScannerScreen(mockEventId: eventId),
            settings: const RouteSettings(name: AppRoutes.checkInScanner),
          );
        case AppRoutes.notificationsRoot:
          return MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
            settings: const RouteSettings(name: AppRoutes.notificationsRoot),
          );
        case AppRoutes.notificationMessage:
          final id = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => MessageScreen(messageId: id),
            settings: const RouteSettings(name: AppRoutes.notificationMessage),
          );
        default:
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
            settings: const RouteSettings(name: AppRoutes.homeRoot),
          );
      }
    },
    titleForRoute: (name) => switch (name) {
      AppRoutes.eventDetail => 'Event',
      AppRoutes.calendar => 'Calendar',
      AppRoutes.scoopDetail => 'Saturday Scoop',
      AppRoutes.pastScoops => 'Past Scoops',
      AppRoutes.checkInScanner => '', // hide app bar; shell will handle
      AppRoutes.notificationsRoot => 'Notifications',
      AppRoutes.notificationMessage => 'Message',
      _ => 'Hello ${(_currentUser ?? currentUser).firstName ?? 'there'}',
    },
  );

  _Tab _menteesTab() => _Tab(
    label: 'Mentees',
    icon: const Icon(Icons.group_outlined),
    selectedIcon: const Icon(Icons.group),
    key: _menteesKey,
    observers: [_menteesObs],
    rootName: AppRoutes.menteesRoot,
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case AppRoutes.menteesRoot:
          return MaterialPageRoute(
            builder: (_) => const MenteesListScreen(),
            settings: const RouteSettings(name: AppRoutes.menteesRoot),
          );
        case AppRoutes.notificationsRoot:
          return MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
            settings: const RouteSettings(name: AppRoutes.notificationsRoot),
          );
        case AppRoutes.notificationMessage:
          final id = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => MessageScreen(messageId: id),
            settings: const RouteSettings(name: AppRoutes.notificationMessage),
          );
        default:
          return MaterialPageRoute(
            builder: (_) => const MenteesListScreen(),
            settings: const RouteSettings(name: AppRoutes.menteesRoot),
          );
      }
    },
    titleForRoute: (name) => switch (name) {
      AppRoutes.notificationsRoot => 'Notifications',
      AppRoutes.notificationMessage => 'Message',
      _ => 'Mentees',
    },
  );

  _Tab _teamsTab() => _Tab(
    label: 'Teams',
    icon: const Icon(Icons.emoji_events_outlined),
    selectedIcon: const Icon(Icons.emoji_events),
    key: _teamsKey,
    observers: [_teamsObs],
    rootName: AppRoutes.teamRoot,
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case AppRoutes.teamRoot:
          return MaterialPageRoute(
            builder: (_) => const TeamScreen(),
            settings: const RouteSettings(name: AppRoutes.teamRoot),
          );
        case AppRoutes.notificationsRoot:
          return MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
            settings: const RouteSettings(name: AppRoutes.notificationsRoot),
          );
        case AppRoutes.notificationMessage:
          final id = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => MessageScreen(messageId: id),
            settings: const RouteSettings(name: AppRoutes.notificationMessage),
          );
        default:
          return MaterialPageRoute(
            builder: (_) => const TeamScreen(),
            settings: const RouteSettings(name: AppRoutes.teamRoot),
          );
      }
    },
    titleForRoute: (name) => switch (name) {
      AppRoutes.notificationsRoot => 'Notifications',
      AppRoutes.notificationMessage => 'Message',
      _ => 'Leaderboard',
    },
  );

  _Tab _profileTab() {
    final user = _currentUser ?? currentUser;
    return _Tab(
      label: 'Profile',
      icon: Avatar(
        firstName: user.firstName,
        lastName: user.lastName,
        image: user.image,
        colorIndex: user.colorIndex,
        size: 28,
        editable: false,
      ),
      selectedIcon: Avatar(
        firstName: user.firstName,
        lastName: user.lastName,
        image: user.image,
        colorIndex: user.colorIndex,
        size: 28,
        editable: false,
      ),
      key: _profileKey,
      observers: [_profileObs],
      rootName: AppRoutes.profileRoot,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.profileRoot:
            return MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
              settings: const RouteSettings(name: AppRoutes.profileRoot),
            );
          case AppRoutes.communityService:
            return MaterialPageRoute(
              builder: (_) => const CommunityServiceScreen(),
              settings: const RouteSettings(name: AppRoutes.communityService),
            );
          case AppRoutes.gradeCards:
            return MaterialPageRoute(
              builder: (_) => GradeCardsScreen(
                menteeUserId: currentUserId,
                canEdit: true, // Mentees can edit their own grade cards
              ),
              settings: const RouteSettings(name: AppRoutes.gradeCards),
            );
          case AppRoutes.accountSettings:
            return MaterialPageRoute(
              builder: (_) => const AccountSettingsScreen(),
              settings: const RouteSettings(name: AppRoutes.accountSettings),
            );
          case AppRoutes.contactSupport:
            return MaterialPageRoute(
              builder: (_) => const ContactSupportScreen(),
              settings: const RouteSettings(name: AppRoutes.contactSupport),
            );
          case AppRoutes.pulses:
            return MaterialPageRoute(
              builder: (_) => const PulsesScreen(),
              settings: const RouteSettings(name: AppRoutes.pulses),
            );
          case AppRoutes.team:
            // Legacy route - redirect to team screen for backwards compatibility
            return MaterialPageRoute(
              builder: (_) => const TeamScreen(),
              settings: const RouteSettings(name: AppRoutes.team),
            );
          case AppRoutes.notificationsRoot:
            return MaterialPageRoute(
              builder: (_) => const NotificationsScreen(),
              settings: const RouteSettings(name: AppRoutes.notificationsRoot),
            );
          case AppRoutes.notificationMessage:
            final id = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => MessageScreen(messageId: id),
              settings: const RouteSettings(
                name: AppRoutes.notificationMessage,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
              settings: const RouteSettings(name: AppRoutes.profileRoot),
            );
        }
      },
      titleForRoute: (name) => switch (name) {
        AppRoutes.communityService => 'Community Service',
        AppRoutes.gradeCards => 'Grade Cards',
        AppRoutes.accountSettings => 'Account Settings',
        AppRoutes.contactSupport => 'Contact Support',
        AppRoutes.pulses => 'Pulses',
        AppRoutes.team => 'Team',
        AppRoutes.notificationsRoot => 'Notifications',
        AppRoutes.notificationMessage => 'Message',
        _ => 'Profile',
      },
    );
  }

  Future<bool> _onWillPop(List<_Tab> tabs) async {
    final key = [
      _homeKey,
      _menteesKey,
      _teamsKey,
      _profileKey,
    ].where((k) => tabs.any((t) => t.key == k)).elementAt(_stackIndex);
    final canPop = key.currentState?.canPop() ?? false;
    if (canPop) {
      key.currentState!.maybePop();
      return false;
    }
    if (_stackIndex != 0) {
      setState(() => _stackIndex = 0);
      return false;
    }
    return true;
  }

  String _titleFor(List<_Tab> tabs, int stackIndex) {
    // Ensure stackIndex is within bounds
    if (stackIndex >= tabs.length) {
      return 'High Aspirations';
    }

    final names = [
      _homeRoute,
      if (tabs.any((t) => t.key == _menteesKey)) _menteesRoute,
      _teamsRoute,
      _profileRoute,
    ];

    // Ensure the names list index is valid
    if (stackIndex >= names.length) {
      return 'High Aspirations';
    }

    final routeName = names[stackIndex];
    final tab = tabs[stackIndex];
    return tab.titleForRoute(routeName);
  }

  bool _shouldHideAppBar(String routeName) =>
      routeName == AppRoutes.checkInScanner;

  bool _shouldHideNavBar(String routeName) =>
      routeName != AppRoutes.homeRoot &&
      routeName != AppRoutes.menteesRoot &&
      routeName != AppRoutes.teamRoot &&
      routeName != AppRoutes.profileRoot;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CurrentUserKind>(
      valueListenable: currentUserKind,
      builder: (context, kind, _) {
        final showMenteesTab =
            kind == CurrentUserKind.mentor || kind == CurrentUserKind.parent;

        // Build stack tabs (notifications removed from tabs, now in app bar)
        final tabs = <_Tab>[
          _homeTab(),
          if (showMenteesTab) _menteesTab(), // mentor and parent
          _teamsTab(),
          _profileTab(),
        ];

        final navSelected = _stackIndex;

        // Title & app bar visibility
        final title = _titleFor(tabs, _stackIndex);
        final currentRoute = [
          _homeRoute,
          if (showMenteesTab) _menteesRoute,
          _teamsRoute,
          _profileRoute,
        ][_stackIndex];
        final hideAppBar = _shouldHideAppBar(currentRoute);
        final hideNavBar = _shouldHideNavBar(currentRoute);

        // Unread count from inbox
        final unreadCount = _unreadCount;

        // Get current user for avatar
        final user = _currentUser ?? currentUser;

        // Build NavigationBar destinations (notifications removed, add removed)
        final navItems = <(Widget, Widget, String)>[
          (const Icon(Icons.home_outlined), const Icon(Icons.home), 'Home'),
          if (showMenteesTab)
            (
              const Icon(Icons.group_outlined),
              const Icon(Icons.group),
              kind == CurrentUserKind.parent ? 'Children' : 'Mentees',
            ),
          (
            const Icon(Icons.emoji_events_outlined),
            const Icon(Icons.emoji_events),
            'Teams',
          ),
          (
            Avatar(
              firstName: user.firstName,
              lastName: user.lastName,
              image: user.image,
              colorIndex: user.colorIndex,
              size: 28,
              editable: false,
            ),
            Avatar(
              firstName: user.firstName,
              lastName: user.lastName,
              image: user.image,
              colorIndex: user.colorIndex,
              size: 28,
              editable: false,
            ),
            'Profile',
          ),
        ];

        return WillPopScope(
          onWillPop: () => _onWillPop(tabs),
          child: Scaffold(
            extendBody: true, // Allow body to extend under floating nav
            appBar: hideAppBar
                ? null
                : HAAppBar(
                    title: title,
                    titleWidget: currentRoute == AppRoutes.homeRoot
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Hello ${(_currentUser ?? currentUser).firstName ?? 'there'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                'Welcome back!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        : null,
                    showBack:
                        ([_homeKey, _menteesKey, _teamsKey, _profileKey]
                            .where((k) => tabs.any((t) => t.key == k))
                            .elementAt(_stackIndex)
                            .currentState
                            ?.canPop() ??
                        false),
                    onBack: () =>
                        ([_homeKey, _menteesKey, _teamsKey, _profileKey]
                                .where((k) => tabs.any((t) => t.key == k))
                                .elementAt(_stackIndex)
                                .currentState!)
                            .maybePop(),
                    actions: [
                      IconButton(
                        icon: _buildNotificationIcon(
                          Icons.notifications_outlined,
                          unreadCount,
                        ),
                        onPressed: () {
                          // Navigate to notifications via current tab navigator
                          final currentNavigator =
                              [_homeKey, _menteesKey, _teamsKey, _profileKey]
                                  .where((k) => tabs.any((t) => t.key == k))
                                  .elementAt(_stackIndex)
                                  .currentState;
                          currentNavigator?.pushNamed(
                            AppRoutes.notificationsRoot,
                          );
                        },
                        tooltip: 'Notifications',
                      ),
                    ],
                  ),
            body: IndexedStack(
              index: _stackIndex,
              children: [
                for (final t in tabs)
                  Navigator(
                    key: t.key,
                    onGenerateInitialRoutes: (_, __) => [
                      t.onGenerateRoute(RouteSettings(name: t.rootName)),
                    ],
                    onGenerateRoute: t.onGenerateRoute,
                    observers: t.observers,
                  ),
              ],
            ),
            bottomNavigationBar: hideNavBar
                ? null
                : HANavBar(
                    index: navSelected,
                    onChanged: (tapped) {
                      if (_stackIndex != tapped) {
                        setState(() => _stackIndex = tapped);
                      }
                    },
                    tabs: navItems,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationIcon(IconData icon, int unreadCount) {
    if (unreadCount == 0) {
      return Icon(icon);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _TabObserver extends NavigatorObserver {
  final void Function(Route<dynamic>?, Route<dynamic>?) onChanged;
  _TabObserver(this.onChanged);
  @override
  void didPush(Route route, Route? previousRoute) =>
      onChanged(route, previousRoute);
  @override
  void didPop(Route route, Route? previousRoute) =>
      onChanged(previousRoute, route);
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) =>
      onChanged(newRoute, oldRoute);
}

class _Tab {
  final String label;
  final Widget icon, selectedIcon;
  final GlobalKey<NavigatorState> key;
  final List<NavigatorObserver> observers;
  final Route<dynamic> Function(RouteSettings) onGenerateRoute;
  final String Function(String routeName) titleForRoute;
  final String rootName;

  _Tab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.key,
    required this.observers,
    required this.onGenerateRoute,
    required this.titleForRoute,
    required this.rootName,
  });
}
