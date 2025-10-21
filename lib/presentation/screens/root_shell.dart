// lib/presentation/screens/root_shell.dart
import 'package:flutter/material.dart';
import 'package:ha_mobile/presentation/screens/check_in_scanner.dart';

import '../../core/routes.dart';
import '../widgets/ha_app_bar.dart';
import '../widgets/ha_nav_bar.dart';
// import '../widgets/bottom_cta.dart'; // keep if you use route-specific CTAs

// Screens (body-only)
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';
import 'event_detail_screen.dart';
import 'calendar_screen.dart';
import 'scoop_detail_screen.dart';

// Entities
import '../../business/events/entities/event.dart';
import '../../business/scoops/entities/scoop.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  // One stable GlobalKey per tab Navigator
  final _homeKey = GlobalKey<NavigatorState>();
  final _notiKey = GlobalKey<NavigatorState>();
  final _profileKey = GlobalKey<NavigatorState>();

  // Track top route per tab
  String _homeRoute = AppRoutes.homeRoot;
  String _notiRoute = AppRoutes.notificationsRoot;
  String _profileRoute = AppRoutes.profileRoot;

  // ---- Post-frame rebuild (always deferred) ----
  bool _pendingRebuild = false;
  void _requestRebuild() {
    if (!mounted || _pendingRebuild) return;
    _pendingRebuild = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pendingRebuild = false;
      setState(() {});
    });
  }

  late final _homeObserver = _TabObserver((r, _) {
    _homeRoute = r?.settings.name ?? AppRoutes.homeRoot;
    _requestRebuild();
  });
  late final _notiObserver = _TabObserver((r, _) {
    _notiRoute = r?.settings.name ?? AppRoutes.notificationsRoot;
    _requestRebuild();
  });
  late final _profileObserver = _TabObserver((r, _) {
    _profileRoute = r?.settings.name ?? AppRoutes.profileRoot;
    _requestRebuild();
  });

  // Build tab descriptors once (stable)
  late final List<_Tab> _tabs = <_Tab>[
    _Tab(
      label: 'Home',
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home),
      key: _homeKey,
      observers: [_homeObserver],
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
            final eventId = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => CheckInScannerScreen(mockEventId: eventId),
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
        _ => 'High Aspirations',
      },
    ),
    _Tab(
      label: 'Notifications',
      icon: const Icon(Icons.notifications_none),
      selectedIcon: const Icon(Icons.notifications),
      key: _notiKey,
      observers: [_notiObserver],
      rootName: AppRoutes.notificationsRoot,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.notificationMessage:
            final id = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => MessageScreen(messageId: id),
              settings: const RouteSettings(
                name: AppRoutes.notificationMessage,
              ),
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
    ),
    _Tab(
      label: 'Profile',
      icon: const Icon(Icons.person_outline),
      selectedIcon: const Icon(Icons.person),
      key: _profileKey,
      observers: [_profileObserver],
      rootName: AppRoutes.profileRoot,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: const RouteSettings(name: AppRoutes.profileRoot),
        );
      },
      titleForRoute: (_) => 'Profile',
    ),
  ];

  _Tab get _currentTab => _tabs[_index];
  GlobalKey<NavigatorState> get _currentKey => _currentTab.key;
  String get _currentRouteName =>
      [_homeRoute, _notiRoute, _profileRoute][_index];
  bool get _canGoBack => _currentKey.currentState?.canPop() ?? false;
  String get _title => _currentTab.titleForRoute(_currentRouteName);

  bool get _isScannerRoute => _currentRouteName == AppRoutes.checkInScanner;

  Future<bool> _onWillPop() async {
    if (_canGoBack) {
      _currentKey.currentState!.maybePop();
      return false;
    }
    if (_index != 0) {
      _index = 0;
      _requestRebuild();
      return false;
    }
    return true;
  }

  Widget? _buildBottomArea() {
    // Hide any bottom UI on the scanner route
    if (_isScannerRoute) return null;

    // Show HANavBar only at tab roots
    if (!_canGoBack) {
      return HANavBar(
        index: _index,
        onChanged: (i) {
          if (_index == i) return;
          _index = i;
          _requestRebuild();
        },
        tabs: _tabs.map((t) => (t.icon, t.selectedIcon, t.label)).toList(),
      );
    }

    // Example: route-specific bottom CTAs (keep commented unless used)
    // switch (_currentRouteName) {
    //   case AppRoutes.eventDetail:
    //     return BottomCTA(label: 'Register', onPressed: () {});
    //   default:
    //     return null;
    // }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appBar = _isScannerRoute
        ? null // HIDE HEADER on scanner
        : HAAppBar(
            title: _title,
            showBack: _canGoBack,
            onBack: () => _currentKey.currentState!.maybePop(),
          );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: appBar,
        body: IndexedStack(
          index: _index,
          children: [
            for (final t in _tabs)
              Navigator(
                key: t.key,
                // Provide a single initial route explicitly to avoid duplicates
                onGenerateInitialRoutes: (_, __) => [
                  t.onGenerateRoute(RouteSettings(name: t.rootName)),
                ],
                onGenerateRoute: t.onGenerateRoute,
                observers: t.observers,
              ),
          ],
        ),
        bottomNavigationBar: _buildBottomArea(),
      ),
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
