// lib/presentation/screens/root_shell.dart
import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/session.dart'; // currentUserKind, CurrentUserKind

import '../widgets/ha_app_bar.dart';
import '../widgets/ha_nav_bar.dart';
import '../widgets/bottom_sheet_community_service.dart';
import '../widgets/bottom_sheet_pulse.dart';

// Screens (body-only)
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';
import 'event_detail_screen.dart';
import 'calendar_screen.dart';
import 'scoop_detail_screen.dart';
import 'check_in_scanner.dart';
import 'mentees_list_screen.dart';
import 'community_service_screen.dart';
import 'pulses_screen.dart';

// Entities
import '../../business/events/entities/event.dart';
import '../../business/scoops/entities/scoop.dart';

// Mock data
import '../../data/mock/mock_messages.dart';

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
  final _notiKey = GlobalKey<NavigatorState>();
  final _menteesKey = GlobalKey<NavigatorState>(); // mentor-only tab
  final _profileKey = GlobalKey<NavigatorState>();

  // Track top route names for titles
  String _homeRoute = AppRoutes.homeRoot;
  String _notiRoute = AppRoutes.notificationsRoot;
  String _menteesRoute = AppRoutes.menteesRoot;
  String _profileRoute = AppRoutes.profileRoot;

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

  late final _homeObs = _TabObserver((r, _) {
    _homeRoute = r?.settings.name ?? AppRoutes.homeRoot;
    _deferRebuild();
  });
  late final _notiObs = _TabObserver((r, _) {
    _notiRoute = r?.settings.name ?? AppRoutes.notificationsRoot;
    _deferRebuild();
  });
  late final _menteesObs = _TabObserver((r, _) {
    _menteesRoute = r?.settings.name ?? AppRoutes.menteesRoot;
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
        case AppRoutes.checkInScanner:
          return MaterialPageRoute(
            builder: (_) => const CheckInScannerScreen(),
            settings: const RouteSettings(name: AppRoutes.checkInScanner),
          );
        case AppRoutes.homeRoot:
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
      AppRoutes.checkInScanner => '', // hide app bar; shell will handle
      AppRoutes.homeRoot => 'Hello ${currentUser.firstName ?? 'there'}',
      _ => 'High Aspirations',
    },
  );

  _Tab _notiTab() => _Tab(
    label: 'Notifications',
    icon: const Icon(Icons.notifications),
    selectedIcon: const Icon(Icons.notifications),
    key: _notiKey,
    observers: [_notiObs],
    rootName: AppRoutes.notificationsRoot,
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case AppRoutes.notificationMessage:
          final id = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (_) => MessageScreen(messageId: id),
            settings: const RouteSettings(name: AppRoutes.notificationMessage),
          );
        case AppRoutes.notificationsRoot:
        default:
          return MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
            settings: const RouteSettings(name: AppRoutes.notificationsRoot),
          );
      }
    },
    titleForRoute: (name) => switch (name) {
      AppRoutes.notificationMessage => 'Message',
      _ => 'Notifications',
    },
  );

  _Tab _menteesTab() => _Tab(
    label: 'Mentees',
    icon: const Icon(Icons.group_outlined),
    selectedIcon: const Icon(Icons.group),
    key: _menteesKey,
    observers: [_menteesObs],
    rootName: AppRoutes.menteesRoot,
    onGenerateRoute: (_) => MaterialPageRoute(
      builder: (_) => const MenteesListScreen(),
      settings: const RouteSettings(name: AppRoutes.menteesRoot),
    ),
    titleForRoute: (_) => 'Mentees',
  );

  _Tab _profileTab() => _Tab(
    label: 'Profile',
    icon: const Icon(Icons.person_outline),
    selectedIcon: const Icon(Icons.person),
    key: _profileKey,
    observers: [_profileObs],
    rootName: AppRoutes.profileRoot,
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case AppRoutes.communityService:
          return MaterialPageRoute(
            builder: (_) => const CommunityServiceScreen(),
            settings: const RouteSettings(name: AppRoutes.communityService),
          );
        case AppRoutes.pulses:
          return MaterialPageRoute(
            builder: (_) => const PulsesScreen(),
            settings: const RouteSettings(name: AppRoutes.pulses),
          );
        case AppRoutes.profileRoot:
        default:
          return MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
            settings: const RouteSettings(name: AppRoutes.profileRoot),
          );
      }
    },
    titleForRoute: (name) => switch (name) {
      AppRoutes.communityService => 'Community Service',
      AppRoutes.pulses => 'Pulses',
      _ => 'Profile',
    },
  );

  Future<bool> _onWillPop(List<_Tab> tabs) async {
    final key = [
      _homeKey,
      _notiKey,
      _menteesKey,
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
    final names = [
      _homeRoute,
      if (tabs.any((t) => t.key == _notiKey)) _notiRoute,
      if (tabs.any((t) => t.key == _menteesKey)) _menteesRoute,
      _profileRoute,
    ];
    final routeName = names[stackIndex];
    final tab = tabs[stackIndex];
    return tab.titleForRoute(routeName);
  }

  bool _shouldHideAppBar(String routeName) =>
      routeName == AppRoutes.checkInScanner;

  bool _shouldHideNavBar(String routeName) =>
      routeName != AppRoutes.homeRoot &&
      routeName != AppRoutes.notificationsRoot &&
      routeName != AppRoutes.menteesRoot &&
      routeName != AppRoutes.profileRoot;

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add',
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.volunteer_activism_outlined),
                  title: const Text('Community Service'),
                  onTap: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const BottomSheetCommunityService(),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('What\'s the Pulse?'),
                  onTap: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const BottomSheetPulse(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CurrentUserKind>(
      valueListenable: currentUserKind,
      builder: (context, kind, _) {
        final isMentee = kind == CurrentUserKind.mentee;

        // Build stack tabs
        final tabs = <_Tab>[
          _homeTab(),
          _notiTab(),
          if (!isMentee) _menteesTab(), // mentor only
          _profileTab(),
        ];

        // Map stackIndex <-> navIndex
        int navIndexFromStack(int s) => isMentee ? (s >= 2 ? s + 1 : s) : s;
        int stackIndexFromNav(int n) => isMentee ? (n > 2 ? n - 1 : n) : n;

        final navSelected = navIndexFromStack(_stackIndex);

        // Title & app bar visibility
        final title = _titleFor(tabs, _stackIndex);
        final currentRoute = [
          _homeRoute,
          _notiRoute,
          if (!isMentee) _menteesRoute,
          _profileRoute,
        ][_stackIndex];
        final hideAppBar = _shouldHideAppBar(currentRoute);
        final hideNavBar = _shouldHideNavBar(currentRoute);

        // Count unread messages for notification badge
        final unreadCount = mockMessages.where((msg) => !msg.read).length;

        // Build NavigationBar destinations
        final navItems = <(Widget, Widget, String)>[
          (const Icon(Icons.home_outlined), const Icon(Icons.home), 'Home'),
          (
            _buildNotificationIcon(Icons.notifications_outlined, unreadCount),
            _buildNotificationIcon(Icons.notifications, unreadCount),
            'Notifications',
          ),
          if (isMentee)
            (const Icon(Icons.add), const Icon(Icons.add), '')
          else
            (
              const Icon(Icons.group_outlined),
              const Icon(Icons.group),
              'Mentees',
            ),
          (
            const Icon(Icons.person_outline),
            const Icon(Icons.person),
            'Profile',
          ),
        ];

        return WillPopScope(
          onWillPop: () => _onWillPop(tabs),
          child: Scaffold(
            appBar: hideAppBar
                ? null
                : HAAppBar(
                    title: title,
                    titleWidget: currentRoute == AppRoutes.homeRoot
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Hello ${currentUser.firstName ?? 'there'}',
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
                        ([_homeKey, _notiKey, _menteesKey, _profileKey]
                            .where((k) => tabs.any((t) => t.key == k))
                            .elementAt(_stackIndex)
                            .currentState
                            ?.canPop() ??
                        false),
                    onBack: () =>
                        ([_homeKey, _notiKey, _menteesKey, _profileKey]
                                .where((k) => tabs.any((t) => t.key == k))
                                .elementAt(_stackIndex)
                                .currentState!)
                            .maybePop(),
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
                      if (isMentee && tapped == 2) {
                        // Middle action: show sheet, don't change tab
                        _showAddSheet();
                        return;
                      }
                      final nextStack = stackIndexFromNav(tapped);
                      if (_stackIndex != nextStack) {
                        setState(() => _stackIndex = nextStack);
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
