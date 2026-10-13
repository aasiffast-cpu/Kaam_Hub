import 'package:flutter/material.dart';

import '../features/admin/admin_dashboard_placeholder.dart';
import '../features/auth/admin_access_guard.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_verification_screen.dart';
import '../features/auth/phone_sign_in_screen.dart';
import '../features/auth/profile_screen.dart';
import '../features/auth/role_selection_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/customer/customer_dashboard_screen.dart';
import '../features/customer/select_location_screen.dart';
import '../features/customer/worker_profile_screen.dart';
import '../features/worker/service_provider_dashboard_screen.dart';
import '../features/worker/worker_document_upload_screen.dart';
import '../models/user_role.dart';
import '../models/worker_model.dart';
import '../services/auth_notifier.dart';

/// Centralized named route identifiers and route generator for KaamHub.
class AppRoutes {
  AppRoutes._();

  static const String initial = '/';
  static const String roleSelection = '/role_selection';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String phoneSignIn = '/sign_in';
  static const String otpVerification = '/verify_otp';
  static const String customerHome = '/customer/home';
  static const String customerDashboard = '/customer/dashboard';
  static const String workerDashboard = '/worker/dashboard';
  static const String serviceProviderDashboard =
      '/worker/service_provider_dashboard';
  static const String workerDocumentUpload = '/worker/upload_documents';
  static const String workerProfile = '/worker_profile';
  static const String adminDashboard = '/admin/dashboard';
  static const String profile = '/profile';
  static const String mapLocation = '/map_location';

  /// Generates the requested route dynamically, applying security guards.
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    AuthNotifier authNotifier,
  ) {
    switch (settings.name) {
      case initial:
      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(authNotifier: authNotifier),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(authNotifier: authNotifier),
          settings: settings,
        );

      case signUp:
        return MaterialPageRoute(
          builder: (_) => SignUpScreen(authNotifier: authNotifier),
          settings: settings,
        );

      case phoneSignIn:
        return MaterialPageRoute(
          builder: (_) => PhoneSignInScreen(authNotifier: authNotifier),
          settings: settings,
        );

      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            authNotifier: authNotifier,
            verificationId: args['verificationId'] as String? ?? 'demo_id',
            phoneNumber: args['phoneNumber'] as String? ?? '+92 300 1234567',
            name: args['name'] as String?,
            initialRole: args['role'] as UserRole? ?? UserRole.customer,
          ),
          settings: settings,
        );

      case customerHome:
      case customerDashboard:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final tabIndex = args['tabIndex'] as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => CustomerDashboardScreen(
            authNotifier: authNotifier,
            initialTabIndex: tabIndex,
          ),
          settings: settings,
        );

      case workerDashboard:
      case serviceProviderDashboard:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final tabIndex = args['tabIndex'] as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => ServiceProviderDashboardScreen(
            authNotifier: authNotifier,
            initialTabIndex: tabIndex,
          ),
          settings: settings,
        );

      case workerDocumentUpload:
        return MaterialPageRoute(
          builder: (_) => WorkerDocumentUploadScreen(
            authNotifier: authNotifier,
            existingWorker: settings.arguments is WorkerModel
                ? settings.arguments as WorkerModel
                : null,
          ),
          settings: settings,
        );

      case workerProfile:
        WorkerModel? worker;
        String? workerId;
        if (settings.arguments is WorkerModel) {
          worker = settings.arguments as WorkerModel;
        } else if (settings.arguments is String) {
          workerId = settings.arguments as String;
        }
        return MaterialPageRoute(
          builder: (_) =>
              WorkerProfileScreen(initialWorker: worker, workerId: workerId),
          settings: settings,
        );

      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => AdminAccessGuard(
            authNotifier: authNotifier,
            child: AdminDashboardScreen(authNotifier: authNotifier),
          ),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(authNotifier: authNotifier),
          settings: settings,
        );

      case mapLocation:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) =>
              SelectLocationScreen(initialCityId: args['cityId'] as String?),
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
