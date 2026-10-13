import 'package:flutter/material.dart';

import '../features/admin/admin_dashboard_placeholder.dart';
import '../features/auth/role_selection_screen.dart';
import '../features/customer/customer_home_placeholder.dart';
import '../features/worker/worker_dashboard_placeholder.dart';

/// Centralized named route identifiers and route generator for KaamHub.
class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String roleSelection = '/role_selection';
  static const String customerHome = '/customer/home';
  static const String workerDashboard = '/worker/dashboard';
  static const String adminDashboard = '/admin/dashboard';

  /// Generates the requested route dynamically.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
          settings: settings,
        );

      case customerHome:
        return MaterialPageRoute(
          builder: (_) => const CustomerHomeScreen(),
          settings: settings,
        );

      case workerDashboard:
        return MaterialPageRoute(
          builder: (_) => const WorkerDashboardScreen(),
          settings: settings,
        );

      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Route Not Found')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
