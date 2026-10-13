/// Represents the primary user roles in the KaamHub ecosystem.
enum UserRole {
  customer,
  worker,
  admin;

  /// Human-readable label for UI display.
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.worker:
        return 'Service Worker';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  /// Parses a role string safely. Defaults to [customer] if unrecognized or null.
  /// Enforces that 'admin' cannot be casually assumed without explicit exact match.
  static UserRole fromString(String? roleStr) {
    if (roleStr == null) return UserRole.customer;
    switch (roleStr.toLowerCase().trim()) {
      case 'worker':
        return UserRole.worker;
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  /// Converts the enum to a consistent lowercase string for Firestore persistence.
  String toJson() => name.toLowerCase();
}
