// lib/presentation/screens/root_shell.dart
import 'package:flutter/material.dart';
import 'package:ha_mobile/business/events/entities/event.dart';
import '../../core/routes.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'message_screen.dart';
import 'profile_screen.dart';
import '../widgets/ha_app_bar.dart';
import '../widgets/ha_nav_bar.dart';
import 'event_detail_screen.dart';
import 'calendar_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

/// Observes a tab's Navigator and reports the active route.
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

class _RootShellState extends State<RootShell> {
  int _index = 0;

  // One Navigator per tab
  final _homeKey = GlobalKey<NavigatorState>();
  final _notiKey = GlobalKey<NavigatorState>();
  final _profileKey = GlobalKey<NavigatorState>();

  // Track current route per tab for dynamic titles / back button
  String _homeRoute = AppRoutes.homeRoot;
  String _notiRoute = AppRoutes.notificationsRoot;
  String _profileRoute = AppRoutes.profileRoot;

  // Observers update the route trackers above (deferred to avoid setState during build)
  late final _homeObserver = _TabObserver((newR, _) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        setState(() => _homeRoute = newR?.settings.name ?? AppRoutes.homeRoot);
    });
  });
  late final _notiObserver = _TabObserver((newR, _) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        setState(
          () => _notiRoute = newR?.settings.name ?? AppRoutes.notificationsRoot,
        );
    });
  });
  late final _profileObserver = _TabObserver((newR, _) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        setState(
          () => _profileRoute = newR?.settings.name ?? AppRoutes.profileRoot,
        );
    });
  });

  // Tab configs
  late final _tabs = <_Tab>[
    _Tab(
      label: 'Home',
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home),
      key: _homeKey,
      observers: [_homeObserver],
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
          case AppRoutes.homeRoot:
          default:
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
              settings: const RouteSettings(name: AppRoutes.homeRoot),
            );
        }
      },
      titleForRoute: (routeName) => switch (routeName) {
        AppRoutes.eventDetail => 'Event',
        AppRoutes.calendar => 'Calendar',
        _ => 'High Aspirations',
      },
    ),

    _Tab(
      label: 'Notifications',
      icon: const Icon(Icons.notifications_none),
      selectedIcon: const Icon(Icons.notifications),
      key: _notiKey,
      observers: [_notiObserver],
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.notificationMessage:
            final id = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => MessageScreen(messageId: id), // body-only
              settings: const RouteSettings(
                name: AppRoutes.notificationMessage,
              ),
            );
          case AppRoutes.notificationsRoot:
          default:
            return MaterialPageRoute(
              builder: (_) => const NotificationsScreen(), // body-only
              settings: const RouteSettings(name: AppRoutes.notificationsRoot),
            );
        }
      },
      titleForRoute: (routeName) => switch (routeName) {
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
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const ProfileScreen(), // body-only
        settings: const RouteSettings(name: AppRoutes.profileRoot),
      ),
      titleForRoute: (_) => 'Profile',
    ),
  ];

  // Convenience getters for current tab
  GlobalKey<NavigatorState> get _currentKey =>
      [_homeKey, _notiKey, _profileKey][_index];
  String get _currentRouteName =>
      [_homeRoute, _notiRoute, _profileRoute][_index];
  bool get _canGoBack => _currentKey.currentState?.canPop() ?? false;
  String get _title => _tabs[_index].titleForRoute(_currentRouteName);

  // Android back button handling
  Future<bool> _onWillPop() async {
    if (_canGoBack) {
      _currentKey.currentState!.pop();
      return false;
    }
    if (_index != 0) {
      setState(() => _index = 0);
      return false;
    }
    return true; // exit app
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: HAAppBar(
          title: _title,
          showBack: _canGoBack,
          onBack: () => _currentKey.currentState!.maybePop(),
        ),
        body: IndexedStack(
          index: _index,
          children: [
            // Home tab Navigator
            Navigator(
              key: _homeKey,
              initialRoute: '/',
              onGenerateRoute: (s) => (s.name == null || s.name == '/')
                  ? _tabs[0].onGenerateRoute(const RouteSettings(name: '/'))
                  : _tabs[0].onGenerateRoute(s),
              observers: [_homeObserver],
            ),
            // Notifications tab Navigator
            Navigator(
              key: _notiKey,
              initialRoute: '/',
              onGenerateRoute: (s) => (s.name == null || s.name == '/')
                  ? _tabs[1].onGenerateRoute(const RouteSettings(name: '/'))
                  : _tabs[1].onGenerateRoute(s),
              observers: [_notiObserver],
            ),
            // Profile tab Navigator
            Navigator(
              key: _profileKey,
              initialRoute: '/',
              onGenerateRoute: (s) => (s.name == null || s.name == '/')
                  ? _tabs[2].onGenerateRoute(const RouteSettings(name: '/'))
                  : _tabs[2].onGenerateRoute(s),
              observers: [_profileObserver],
            ),
          ],
        ),
        bottomNavigationBar: HANavBar(
          index: _index,
          onChanged: (i) => setState(() => _index = i),
          tabs: _tabs.map((t) => (t.icon, t.selectedIcon, t.label)).toList(),
        ),
      ),
    );
  }
}

class _Tab {
  final String label;
  final Widget icon, selectedIcon;
  final GlobalKey<NavigatorState> key;
  final List<NavigatorObserver> observers;
  final Route<dynamic> Function(RouteSettings) onGenerateRoute;
  final String Function(String routeName) titleForRoute;

  _Tab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.key,
    required this.observers,
    required this.onGenerateRoute,
    required this.titleForRoute,
  });
}
