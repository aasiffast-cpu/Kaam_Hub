import 'dart:async';

import '../core/errors/app_exception.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import 'auth_service.dart';

/// In-memory implementation of [AuthService] for development, testing,
/// and live browser execution prior to linking production Firebase credentials.
class MockAuthService implements AuthService {
  // Singleton pattern for persistent session across screens
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;

  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;

  // Pre-seeded demo accounts
  static final UserModel demoCustomer = UserModel(
    uid: 'cust_001',
    name: 'Ahmed Khan',
    phoneNumber: '+92 300 1234567',
    role: UserRole.customer,
    createdAt: DateTime(2026, 1, 10),
  );

  static final UserModel demoWorker = UserModel(
    uid: 'work_001',
    name: 'Rashid Ali',
    phoneNumber: '+92 300 7654321',
    role: UserRole.worker,
    createdAt: DateTime(2026, 1, 15),
  );

  static final UserModel demoAdmin = UserModel(
    uid: 'adm_001',
    name: 'Safety Supervisor',
    phoneNumber: '+92 300 9999999',
    role: UserRole.admin,
    createdAt: DateTime(2025, 12, 1),
  );

  final Map<String, UserModel> _usersDb = {};

  MockAuthService._internal() {
    // Seed initial users database
    _usersDb[demoCustomer.phoneNumber] = demoCustomer;
    _usersDb[demoWorker.phoneNumber] = demoWorker;
    _usersDb[demoAdmin.phoneNumber] = demoAdmin;
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Basic format check
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.length < 10) {
      onError('Please enter a valid Pakistani mobile number.');
      return;
    }

    // Generate mock verification ID
    final verificationId =
        'mock_verif_${DateTime.now().millisecondsSinceEpoch}';
    onCodeSent(verificationId);
  }

  @override
  Future<UserModel> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
    String? defaultName,
    UserRole initialRole = UserRole.customer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Standard demo OTP is 123456
    if (smsCode != '123456' && smsCode != '000000') {
      throw const AuthException('Invalid OTP code. For demo, use 123456.');
    }

    // Security Guard: Prevent role escalation to admin during normal sign-in/registration
    if (initialRole == UserRole.admin) {
      throw const PermissionDeniedException(
        'Admin accounts cannot be self-registered. Contact platform safety.',
      );
    }

    // Check if phone matches one of our demo accounts
    final user = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: defaultName?.trim().isNotEmpty == true
          ? defaultName!.trim()
          : 'Verified User',
      phoneNumber: '+92 300 5554433',
      role: initialRole,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    _authStateController.add(_currentUser);
    return user;
  }

  /// Quick sign-in helper for development and UI inspection.
  Future<void> signInWithDemoAccount(UserRole role) async {
    switch (role) {
      case UserRole.customer:
        _currentUser = demoCustomer;
        break;
      case UserRole.worker:
        _currentUser = demoWorker;
        break;
      case UserRole.admin:
        _currentUser = demoAdmin;
        break;
    }
    _authStateController.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    return _usersDb.values.firstWhere(
      (u) => u.uid == uid,
      orElse: () => _currentUser ?? demoCustomer,
    );
  }
}
