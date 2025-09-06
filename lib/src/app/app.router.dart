// lib/src/app/router.dart (your file)

import 'package:flutter/material.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/login_screen.dart';

final router = RouterConfig<RouteSettings>(
  routerDelegate: _AppRouterDelegate(),
  routeInformationParser: _AppRouteParser(),
);

class _AppRouteParser extends RouteInformationParser<RouteSettings> {
  @override
  Future<RouteSettings> parseRouteInformation(RouteInformation routeInformation) async {
    final path = routeInformation.uri.path;
    return RouteSettings(name: path.isEmpty ? '/' : path);
  }
}

class _AppRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _path = '/';
  @override
  RouteSettings? get currentConfiguration => RouteSettings(name: _path);

  @override
  Widget build(BuildContext context) {
    final pages = <Page>[
      if (_path == '/') const MaterialPage(child: LoginScreen()),
      if (_path == '/dashboard') const MaterialPage(child: DashboardScreen()),
      // add more when ready:
      // if (_path == '/customers') const MaterialPage(child: CustomerListScreen()),
      // ...
    ];
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) return false;
        // naive back: go to root
        _path = '/';
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {
    _path = configuration.name ?? '/';
    notifyListeners();
  }

  void go(String path) {
    _path = path;
    notifyListeners();
  }
}
