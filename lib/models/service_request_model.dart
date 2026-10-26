/// Service request status lifecycle for KaamHub.
/// Status transitions are enforced server-side; client changes go through service layer.
enum ServiceRequestStatus {
  draft,
  requested,
  quoted,
  accepted,
  inProgress,
  completed,
  cancelled,
  disputed;

  String get displayName {
    switch (this) {
      case ServiceRequestStatus.draft:
        return 'Draft';
      case ServiceRequestStatus.requested:
        return 'Requested';
      case ServiceRequestStatus.quoted:
        return 'Quote Received';
      case ServiceRequestStatus.accepted:
        return 'Accepted / Scheduled';
      case ServiceRequestStatus.inProgress:
        return 'In Progress';
      case ServiceRequestStatus.completed:
        return 'Completed';
      case ServiceRequestStatus.cancelled:
        return 'Cancelled';
      case ServiceRequestStatus.disputed:
        return 'Disputed';
    }
  }

  static ServiceRequestStatus fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'requested':
        return ServiceRequestStatus.requested;
      case 'quoted':
        return ServiceRequestStatus.quoted;
      case 'accepted':
        return ServiceRequestStatus.accepted;
      case 'inprogress':
      case 'in_progress':
        return ServiceRequestStatus.inProgress;
      case 'completed':
        return ServiceRequestStatus.completed;
      case 'cancelled':
        return ServiceRequestStatus.cancelled;
      case 'disputed':
        return ServiceRequestStatus.disputed;
      case 'draft':
      default:
        return ServiceRequestStatus.draft;
    }
  }

  String toJson() => name;

  bool get isActive =>
      this == ServiceRequestStatus.requested ||
      this == ServiceRequestStatus.quoted ||
      this == ServiceRequestStatus.accepted ||
      this == ServiceRequestStatus.inProgress;

  bool get isTerminal =>
      this == ServiceRequestStatus.completed ||
      this == ServiceRequestStatus.cancelled;
}

/// A status change event recorded for audit trail.
class StatusHistoryEntry {
  final ServiceRequestStatus status;
  final String changedByUserId;
  final String? note;
  final DateTime timestamp;

  const StatusHistoryEntry({
    required this.status,
    required this.changedByUserId,
    this.note,
    required this.timestamp,
  });

  factory StatusHistoryEntry.fromMap(Map<String, dynamic> map) {
    return StatusHistoryEntry(
      status: ServiceRequestStatus.fromString(map['status'] as String?),
      changedByUserId: map['changedByUserId'] as String? ?? '',
      note: map['note'] as String?,
      timestamp:
          DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status.toJson(),
        'changedByUserId': changedByUserId,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Core service request model representing a customer booking request.
class ServiceRequestModel {
  final String id;
  final String customerId;
  final String customerName;
  final String? workerId;
  final String? workerName;

  // Request details
  final String serviceCategory;
  final String description;
  final String serviceAddress;
  final double? serviceLat;
  final double? serviceLng;
  final String cityId;

  // Scheduling
  final DateTime? preferredDate;
  final String? preferredTimeSlot;

  // Financials
  final double? budgetMin;
  final double? budgetMax;
  final double? quotedAmount;
  final bool isQuoteBased;

  // Status
  final ServiceRequestStatus status;
  final List<StatusHistoryEntry> statusHistory;

  // Optional extras
  final List<String> photoUrls;
  final String? cancellationReason;
  final String? cancellationActorId;
  final String? disputeReason;

  // Dates
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceRequestModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.workerId,
    this.workerName,
    required this.serviceCategory,
    required this.description,
    required this.serviceAddress,
    this.serviceLat,
    this.serviceLng,
    required this.cityId,
    this.preferredDate,
    this.preferredTimeSlot,
    this.budgetMin,
    this.budgetMax,
    this.quotedAmount,
    this.isQuoteBased = true,
    this.status = ServiceRequestStatus.draft,
    this.statusHistory = const [],
    this.photoUrls = const [],
    this.cancellationReason,
    this.cancellationActorId,
    this.disputeReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceRequestModel.fromMap(
      Map<String, dynamic> map, String id) {
    return ServiceRequestModel(
      id: id,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? 'Customer',
      workerId: map['workerId'] as String?,
      workerName: map['workerName'] as String?,
      serviceCategory: map['serviceCategory'] as String? ?? '',
      description: map['description'] as String? ?? '',
      serviceAddress: map['serviceAddress'] as String? ?? '',
      serviceLat: (map['serviceLat'] as num?)?.toDouble(),
      serviceLng: (map['serviceLng'] as num?)?.toDouble(),
      cityId: map['cityId'] as String? ?? '',
      preferredDate:
          DateTime.tryParse(map['preferredDate'] as String? ?? ''),
      preferredTimeSlot: map['preferredTimeSlot'] as String?,
      budgetMin: (map['budgetMin'] as num?)?.toDouble(),
      budgetMax: (map['budgetMax'] as num?)?.toDouble(),
      quotedAmount: (map['quotedAmount'] as num?)?.toDouble(),
      isQuoteBased: map['isQuoteBased'] as bool? ?? true,
      status: ServiceRequestStatus.fromString(map['status'] as String?),
      statusHistory: (map['statusHistory'] as List? ?? [])
          .map((e) =>
              StatusHistoryEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      photoUrls: List<String>.from(map['photoUrls'] as List? ?? []),
      cancellationReason: map['cancellationReason'] as String?,
      cancellationActorId: map['cancellationActorId'] as String?,
      disputeReason: map['disputeReason'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'customerName': customerName,
        'workerId': workerId,
        'workerName': workerName,
        'serviceCategory': serviceCategory,
        'description': description,
        'serviceAddress': serviceAddress,
        'serviceLat': serviceLat,
        'serviceLng': serviceLng,
        'cityId': cityId,
        'preferredDate': preferredDate?.toIso8601String(),
        'preferredTimeSlot': preferredTimeSlot,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'quotedAmount': quotedAmount,
        'isQuoteBased': isQuoteBased,
        'status': status.toJson(),
        'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
        'photoUrls': photoUrls,
        'cancellationReason': cancellationReason,
        'cancellationActorId': cancellationActorId,
        'disputeReason': disputeReason,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  ServiceRequestModel copyWith({
    String? workerId,
    String? workerName,
    double? quotedAmount,
    ServiceRequestStatus? status,
    List<StatusHistoryEntry>? statusHistory,
    String? cancellationReason,
    String? cancellationActorId,
    String? disputeReason,
    DateTime? preferredDate,
    String? preferredTimeSlot,
  }) {
    return ServiceRequestModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      serviceCategory: serviceCategory,
      description: description,
      serviceAddress: serviceAddress,
      serviceLat: serviceLat,
      serviceLng: serviceLng,
      cityId: cityId,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTimeSlot: preferredTimeSlot ?? this.preferredTimeSlot,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      quotedAmount: quotedAmount ?? this.quotedAmount,
      isQuoteBased: isQuoteBased,
      status: status ?? this.status,
      statusHistory: statusHistory ?? this.statusHistory,
      photoUrls: photoUrls,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationActorId: cancellationActorId ?? this.cancellationActorId,
      disputeReason: disputeReason ?? this.disputeReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
