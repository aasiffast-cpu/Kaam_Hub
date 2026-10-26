import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/user_role.dart';
import 'auth_service.dart';
import 'mock_auth_service.dart';

/// Central reactive state notifier for authentication and role-based access.
class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthNotifier({AuthService? authService})
    : _authService = authService ?? MockAuthService() {
    _currentUser = _authService.currentUser;
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserRole? get currentRole => _currentUser?.role;
  bool get isCustomer => _currentUser?.role == UserRole.customer;
  bool get isWorker => _currentUser?.role == UserRole.worker;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  /// Sends phone OTP code.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (id) {
          _isLoading = false;
          notifyListeners();
          onCodeSent(id);
        },
        onError: (err) {
          _isLoading = false;
          _errorMessage = err;
          notifyListeners();
          onError(err);
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      onError(e.toString());
    }
  }

  /// Verifies OTP and completes sign-in.
  Future<UserModel?> verifyOtp({
    required String verificationId,
    required String smsCode,
    String? defaultName,
    UserRole initialRole = UserRole.customer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.verifyOtpAndSignIn(
        verificationId: verificationId,
        smsCode: smsCode,
        defaultName: defaultName,
        initialRole: initialRole,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Quick sign-in with pre-configured developer demo account.
  Future<void> signInWithDemo(UserRole role) async {
    final auth = _authService;
    if (auth is MockAuthService) {
      await auth.signInWithDemoAccount(role);
      _currentUser = _authService.currentUser;
      notifyListeners();
    }
  }

  /// Updates user profile details (name and profile image) and notifies listeners.
  Future<UserModel> updateProfile({String? name, String? photoUrl}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _authService.updateUserProfile(
        name: name,
        photoUrl: photoUrl,
      );
      _currentUser = updated;
      _isLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Logs out the user.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
