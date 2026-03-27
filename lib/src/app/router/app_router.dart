import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/player_import/presentation/import_screen.dart';

abstract final class AppRoutes {
  static const importPlayer = '/';
  static const dashboard = '/dashboard';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.importPlayer:
        return MaterialPageRoute<void>(
          builder: (_) => const ImportScreen(),
          settings: settings,
        );
      case AppRoutes.dashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const ImportScreen(),
          settings: settings,
        );
    }
  }
}
