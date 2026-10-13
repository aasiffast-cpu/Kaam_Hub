import 'user_role.dart';

/// Represents a persistent user profile in the KaamHub marketplace.
/// Maps directly to the `users/{userId}` Firestore collection schema.
class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  /// Factory constructor to safely parse Firestore document snapshots or maps.
  factory UserModel.fromMap(Map<String, dynamic> map, {required String uid}) {
    DateTime parsedCreatedAt;
    final rawDate = map['createdAt'];
    if (rawDate is DateTime) {
      parsedCreatedAt = rawDate;
    } else if (rawDate is String) {
      parsedCreatedAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return UserModel(
      uid: uid,
      name: (map['name'] as String?)?.trim() ?? 'User',
      phoneNumber: (map['phoneNumber'] as String?)?.trim() ?? '',
      role: UserRole.fromString(map['role'] as String?),
      createdAt: parsedCreatedAt,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// Serializes the model into a standard JSON/Firestore compatible map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Creates a copy of the model with updated fields.
  /// Prevents accidental or arbitrary promotion to admin without explicit intent.
  UserModel copyWith({
    String? name,
    String? phoneNumber,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isCustomer => role == UserRole.customer;
  bool get isWorker => role == UserRole.worker;
  bool get isAdmin => role == UserRole.admin;

  @override
  String toString() =>
      'UserModel(uid: $uid, name: $name, phone: $phoneNumber, role: ${role.name}, active: $isActive)';
}
