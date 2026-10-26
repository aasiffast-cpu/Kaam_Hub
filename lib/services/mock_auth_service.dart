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

  final Map<String, UserModel> _usersDb = {};

  MockAuthService._internal();

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

    // OTP for testing is 123456
    if (smsCode != '123456' && smsCode != '000000') {
      throw const AuthException('Invalid OTP code. Use 123456 for testing.');
    }

    // Security Guard: Prevent role escalation to admin during normal sign-in/registration
    if (initialRole == UserRole.admin) {
      throw const PermissionDeniedException(
        'Admin accounts cannot be self-registered. Contact platform safety.',
      );
    }

    // Create a user record for the verified phone
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
    // Demo accounts removed — use real OTP sign-in flow.
    throw UnsupportedError('Demo accounts have been removed. Use real sign-in.');
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<UserModel> updateUserProfile({String? name, String? photoUrl}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final current = _currentUser;
    if (current == null) throw const AuthException('No user is signed in.');
    final updated = current.copyWith(
      name: name?.trim().isNotEmpty == true ? name!.trim() : current.name,
      photoUrl: photoUrl ?? current.photoUrl,
    );
    _currentUser = updated;
    _usersDb[updated.phoneNumber] = updated;
    _authStateController.add(updated);
    return updated;
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      return _usersDb.values.firstWhere((u) => u.uid == uid);
    } catch (_) {
      return _currentUser;
    }
  }
}
