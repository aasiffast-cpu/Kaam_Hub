/// Base application exception to encapsulate error messages and codes cleanly.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication specific exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

/// Network/Database connection exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

/// Permission / Authorization exceptions
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(
    super.message, {
    super.code = 'PERMISSION_DENIED',
    super.details,
  });
}

/// Validation failure exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}
