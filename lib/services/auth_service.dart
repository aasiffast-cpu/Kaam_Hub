import '../models/user_model.dart';
import '../models/user_role.dart';

/// Abstract contract for Authentication operations in KaamHub.
/// Allows swapping between Firebase Authentication and test/mock implementations seamlessly.
abstract class AuthService {
  /// Stream providing real-time updates when auth state or active user changes.
  Stream<UserModel?> get authStateChanges;

  /// Returns the currently authenticated user profile, or null if logged out.
  UserModel? get currentUser;

  /// Requests a 6-digit OTP code to be sent to [phoneNumber].
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  });

  /// Verifies the entered SMS code and signs the user in.
  /// If the user is new, [defaultName] and [initialRole] are used to register them.
  /// Security Guard: [initialRole] cannot be [UserRole.admin].
  Future<UserModel> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
    String? defaultName,
    UserRole initialRole = UserRole.customer,
  });

  /// Signs the currently authenticated user out.
  Future<void> signOut();

  /// Loads the full Firestore profile for a given user ID.
  Future<UserModel?> getUserProfile(String uid);
}
