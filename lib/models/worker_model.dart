/// Verification statuses for a service worker profile.
enum WorkerVerificationStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case WorkerVerificationStatus.pending:
        return 'Pending Verification';
      case WorkerVerificationStatus.approved:
        return 'Verified & Police Cleared';
      case WorkerVerificationStatus.rejected:
        return 'Rejected';
    }
  }

  static WorkerVerificationStatus fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'approved':
        return WorkerVerificationStatus.approved;
      case 'rejected':
        return WorkerVerificationStatus.rejected;
      case 'pending':
      default:
        return WorkerVerificationStatus.pending;
    }
  }

  String toJson() => name;
}

/// Detailed Worker Profile model mapping to Firestore `workers/{workerId}` collection.
class WorkerModel {
  final String id;
  final String userId;
  final String displayName;
  final String phoneNumber;
  final String profileImageUrl;
  final String serviceCategory;
  final List<String> subCategories;
  final String city;
  final List<String> serviceAreas;
  final int experienceYears;
  final double startingRate;
  final bool isAvailable;
  final WorkerVerificationStatus verificationStatus;
  final String? rejectionReason;

  // Sensitive Verification Documents (Restricted to Worker & Admin only)
  final String? cnicFrontUrl;
  final String? cnicBackUrl;
  final String? policeClearanceUrl;
  final List<String> workPhotoUrls;

  // Performance Metrics
  final double averageRating;
  final int reviewCount;
  final int completedJobsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkerModel({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.serviceCategory,
    this.subCategories = const [],
    required this.city,
    this.serviceAreas = const [],
    required this.experienceYears,
    required this.startingRate,
    this.isAvailable = true,
    this.verificationStatus = WorkerVerificationStatus.pending,
    this.rejectionReason,
    this.cnicFrontUrl,
    this.cnicBackUrl,
    this.policeClearanceUrl,
    this.workPhotoUrls = const [],
    this.averageRating = 5.0,
    this.reviewCount = 0,
    this.completedJobsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isVerified =>
      verificationStatus == WorkerVerificationStatus.approved;
  bool get isPending => verificationStatus == WorkerVerificationStatus.pending;
  bool get hasCompleteDocuments =>
      profileImageUrl.isNotEmpty &&
      cnicFrontUrl != null &&
      cnicBackUrl != null &&
      policeClearanceUrl != null;

  factory WorkerModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return WorkerModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Service Worker',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String? ?? '',
      serviceCategory: map['serviceCategory'] as String? ?? 'General Services',
      subCategories: List<String>.from(map['subCategories'] as List? ?? []),
      city: map['city'] as String? ?? 'Sahiwal',
      serviceAreas: List<String>.from(map['serviceAreas'] as List? ?? []),
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 1,
      startingRate: (map['startingRate'] as num?)?.toDouble() ?? 500.0,
      isAvailable: map['isAvailable'] as bool? ?? true,
      verificationStatus: WorkerVerificationStatus.fromString(
        map['verificationStatus'] as String?,
      ),
      rejectionReason: map['rejectionReason'] as String?,
      cnicFrontUrl: map['cnicFrontUrl'] as String?,
      cnicBackUrl: map['cnicBackUrl'] as String?,
      policeClearanceUrl: map['policeClearanceUrl'] as String?,
      workPhotoUrls: List<String>.from(map['workPhotoUrls'] as List? ?? []),
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      completedJobsCount: (map['completedJobsCount'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'serviceCategory': serviceCategory,
      'subCategories': subCategories,
      'city': city,
      'serviceAreas': serviceAreas,
      'experienceYears': experienceYears,
      'startingRate': startingRate,
      'isAvailable': isAvailable,
      'verificationStatus': verificationStatus.toJson(),
      'rejectionReason': rejectionReason,
      'cnicFrontUrl': cnicFrontUrl,
      'cnicBackUrl': cnicBackUrl,
      'policeClearanceUrl': policeClearanceUrl,
      'workPhotoUrls': workPhotoUrls,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'completedJobsCount': completedJobsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WorkerModel copyWith({
    String? displayName,
    String? phoneNumber,
    String? profileImageUrl,
    String? serviceCategory,
    List<String>? subCategories,
    String? city,
    List<String>? serviceAreas,
    int? experienceYears,
    double? startingRate,
    bool? isAvailable,
    WorkerVerificationStatus? verificationStatus,
    String? rejectionReason,
    String? cnicFrontUrl,
    String? cnicBackUrl,
    String? policeClearanceUrl,
    List<String>? workPhotoUrls,
    double? averageRating,
    int? reviewCount,
    int? completedJobsCount,
    DateTime? updatedAt,
  }) {
    return WorkerModel(
      id: id,
      userId: userId,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      subCategories: subCategories ?? this.subCategories,
      city: city ?? this.city,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      experienceYears: experienceYears ?? this.experienceYears,
      startingRate: startingRate ?? this.startingRate,
      isAvailable: isAvailable ?? this.isAvailable,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      cnicFrontUrl: cnicFrontUrl ?? this.cnicFrontUrl,
      cnicBackUrl: cnicBackUrl ?? this.cnicBackUrl,
      policeClearanceUrl: policeClearanceUrl ?? this.policeClearanceUrl,
      workPhotoUrls: workPhotoUrls ?? this.workPhotoUrls,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      completedJobsCount: completedJobsCount ?? this.completedJobsCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
