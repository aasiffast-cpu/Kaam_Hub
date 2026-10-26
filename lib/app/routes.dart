import 'package:flutter/material.dart';

import '../features/admin/admin_categories_screen.dart';
import '../features/admin/admin_cities_screen.dart';
import '../features/admin/admin_dashboard_placeholder.dart';
import '../features/admin/admin_requests_screen.dart';
import '../features/admin/admin_users_screen.dart';
import '../features/auth/admin_access_guard.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/otp_verification_screen.dart';
import '../features/auth/phone_sign_in_screen.dart';
import '../features/auth/profile_screen.dart';
import '../features/auth/role_selection_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/customer/chat_list_screen.dart';
import '../features/customer/chat_screen.dart';
import '../features/customer/create_request_screen.dart';
import '../features/customer/customer_dashboard_screen.dart';
import '../features/customer/request_detail_screen.dart';
import '../features/customer/review_screen.dart';
import '../features/customer/select_location_screen.dart';
import '../features/customer/worker_profile_screen.dart';
import '../features/shared/help_center_screen.dart';
import '../features/shared/notifications_screen.dart';
import '../features/shared/report_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/worker/service_provider_dashboard_screen.dart';
import '../features/worker/worker_application_status_screen.dart';
import '../features/worker/worker_document_upload_screen.dart';
import '../models/user_role.dart';
import '../models/worker_model.dart';
import '../services/auth_notifier.dart';

/// Centralized named route identifiers and route generator for KaamHub.
class AppRoutes {
  AppRoutes._();

  // ── Core ─────────────────────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String initial = '/';
  static const String roleSelection = '/role_selection';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String phoneSignIn = '/sign_in';
  static const String otpVerification = '/verify_otp';
  static const String profile = '/profile';

  // ── Customer ──────────────────────────────────────────────────────────────
  static const String customerHome = '/customer/home';
  static const String customerDashboard = '/customer/dashboard';
  static const String createRequest = '/customer/create_request';
  static const String requestDetail = '/customer/request_detail';
  static const String chatList = '/customer/chats';
  static const String chatConversation = '/customer/chat';
  static const String reviewScreen = '/customer/review';
  static const String mapLocation = '/map_location';
  static const String workerProfile = '/worker_profile';

  // ── Worker ────────────────────────────────────────────────────────────────
  static const String workerDashboard = '/worker/dashboard';
  static const String serviceProviderDashboard = '/worker/service_provider_dashboard';
  static const String workerDocumentUpload = '/worker/upload_documents';
  static const String workerApplicationStatus = '/worker/application_status';

  // ── Shared ────────────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String helpCenter = '/help_center';
  static const String reportUser = '/report_user';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const String adminDashboard = '/admin/dashboard';
  static const String adminCategories = '/admin/categories';
  static const String adminCities = '/admin/cities';
  static const String adminRequests = '/admin/requests';
  static const String adminUsers = '/admin/users';

  /// Generates the requested route dynamically, applying security guards.
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
    AuthNotifier authNotifier,
  ) {
    switch (settings.name) {
      // Splash
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      // Initial → show splash first, then role selection
      case initial:
      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(authNotifier: authNotifier),
          settings: settings,
        );

      // Auth
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
            phoneNumber:
                args['phoneNumber'] as String? ?? '+92 300 1234567',
            name: args['name'] as String?,
            initialRole: args['role'] as UserRole? ?? UserRole.customer,
          ),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(authNotifier: authNotifier),
          settings: settings,
        );

      // Customer
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

      case createRequest:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => CreateRequestScreen(
            authNotifier: authNotifier,
            preselectedCategory: args['category'] as String?,
          ),
          settings: settings,
        );

      case requestDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => RequestDetailScreen(
            requestId: args['requestId'] as String? ?? '',
            authNotifier: authNotifier,
            isWorkerView: args['isWorkerView'] as bool? ?? false,
          ),
          settings: settings,
        );

      case chatList:
        return MaterialPageRoute(
          builder: (_) => ChatListScreen(authNotifier: authNotifier),
          settings: settings,
        );

      case chatConversation:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: args['conversationId'] as String? ?? '',
            otherPartyName: args['otherPartyName'] as String? ?? 'Chat',
            authNotifier: authNotifier,
          ),
          settings: settings,
        );

      case reviewScreen:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ReviewScreen(
            requestId: args['requestId'] as String? ?? '',
            workerId: args['workerId'] as String? ?? '',
            workerName: args['workerName'] as String? ?? 'Provider',
            authNotifier: authNotifier,
          ),
          settings: settings,
        );

      case mapLocation:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) =>
              SelectLocationScreen(initialCityId: args['cityId'] as String?),
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

      // Worker
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

      case workerApplicationStatus:
        return MaterialPageRoute(
          builder: (_) => WorkerApplicationStatusScreen(
            worker: settings.arguments is WorkerModel
                ? settings.arguments as WorkerModel
                : null,
            authNotifier: authNotifier,
          ),
          settings: settings,
        );

      // Shared
      case notifications:
        return MaterialPageRoute(
          builder: (_) => NotificationsScreen(authNotifier: authNotifier),
          settings: settings,
        );

      case helpCenter:
        return MaterialPageRoute(
          builder: (_) => const HelpCenterScreen(),
          settings: settings,
        );

      case reportUser:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => ReportScreen(
            reportedUserId: args['reportedUserId'] as String? ?? '',
            reportedUserName: args['reportedUserName'] as String? ?? 'User',
            conversationId: args['conversationId'] as String?,
            requestId: args['requestId'] as String?,
            authNotifier: authNotifier,
          ),
          settings: settings,
        );

      // Admin (all guarded)
      case adminDashboard:
        return MaterialPageRoute(
          builder: (_) => AdminAccessGuard(
            authNotifier: authNotifier,
            child: AdminDashboardScreen(authNotifier: authNotifier),
          ),
          settings: settings,
        );

      case adminCategories:
        return MaterialPageRoute(
          builder: (_) => AdminAccessGuard(
            authNotifier: authNotifier,
            child: const AdminCategoriesScreen(),
          ),
          settings: settings,
        );

      case adminCities:
        return MaterialPageRoute(
          builder: (_) => AdminAccessGuard(
            authNotifier: authNotifier,
            child: const AdminCitiesScreen(),
          ),
          settings: settings,
        );

      case adminRequests:
        return MaterialPageRoute(
          builder: (_) => AdminAccessGuard(
            authNotifier: authNotifier,
            child: const AdminRequestsScreen(),
          ),
          settings: settings,
        );

      case adminUsers:
        return MaterialPageRoute(
          builder: (_) => AdminAccessGuard(
            authNotifier: authNotifier,
            child: const AdminUsersScreen(),
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Route Not Found')),
            body: Center(
                child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
