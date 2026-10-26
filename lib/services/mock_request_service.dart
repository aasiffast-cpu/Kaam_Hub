import '../models/service_request_model.dart';

/// Mock service managing service request lifecycle for KaamHub MVP.
/// Replace with backend API for production. All status transitions are
/// validated here — client cannot skip statuses.
class MockRequestService {
  static final MockRequestService _instance = MockRequestService._internal();
  factory MockRequestService() => _instance;
  MockRequestService._internal() {
    _seedRequests();
  }

  final List<ServiceRequestModel> _requests = [];

  void _seedRequests() {
    final now = DateTime.now();
    _requests.addAll([
      ServiceRequestModel(
        id: 'req_001',
        customerId: 'customer_demo_001',
        customerName: 'Ali Hassan',
        workerId: 'worker_001',
        workerName: 'Muhammad Usman',
        serviceCategory: 'Electrician',
        description: 'UPS wiring not working, need urgent repair before evening.',
        serviceAddress: 'House #12, Block B, Sahiwal',
        cityId: 'city_sahiwal',
        preferredDate: now.add(const Duration(days: 1)),
        preferredTimeSlot: '10:00 AM - 12:00 PM',
        budgetMin: 500,
        budgetMax: 1500,
        quotedAmount: 1200,
        isQuoteBased: false,
        status: ServiceRequestStatus.accepted,
        statusHistory: [
          StatusHistoryEntry(
            status: ServiceRequestStatus.requested,
            changedByUserId: 'customer_demo_001',
            timestamp: now.subtract(const Duration(hours: 3)),
          ),
          StatusHistoryEntry(
            status: ServiceRequestStatus.quoted,
            changedByUserId: 'worker_001',
            note: 'Rs. 1200 for full wiring check and repair',
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
          StatusHistoryEntry(
            status: ServiceRequestStatus.accepted,
            changedByUserId: 'customer_demo_001',
            timestamp: now.subtract(const Duration(hours: 1)),
          ),
        ],
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      ServiceRequestModel(
        id: 'req_002',
        customerId: 'customer_demo_001',
        customerName: 'Ali Hassan',
        workerId: 'worker_002',
        workerName: 'Tariq Mehmood',
        serviceCategory: 'Plumber',
        description: 'Kitchen sink pipe leaking, need same day fix.',
        serviceAddress: 'House #12, Block B, Sahiwal',
        cityId: 'city_sahiwal',
        preferredDate: now.subtract(const Duration(days: 2)),
        quotedAmount: 800,
        isQuoteBased: false,
        status: ServiceRequestStatus.completed,
        statusHistory: [
          StatusHistoryEntry(
            status: ServiceRequestStatus.requested,
            changedByUserId: 'customer_demo_001',
            timestamp: now.subtract(const Duration(days: 3)),
          ),
          StatusHistoryEntry(
            status: ServiceRequestStatus.accepted,
            changedByUserId: 'worker_002',
            timestamp: now.subtract(const Duration(days: 3)),
          ),
          StatusHistoryEntry(
            status: ServiceRequestStatus.inProgress,
            changedByUserId: 'worker_002',
            timestamp: now.subtract(const Duration(days: 2)),
          ),
          StatusHistoryEntry(
            status: ServiceRequestStatus.completed,
            changedByUserId: 'customer_demo_001',
            timestamp: now.subtract(const Duration(days: 2)),
          ),
        ],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ServiceRequestModel(
        id: 'req_003',
        customerId: 'customer_demo_002',
        customerName: 'Sara Fatima',
        workerId: 'worker_001',
        workerName: 'Muhammad Usman',
        serviceCategory: 'Electrician',
        description: 'Fan installation needed in 2 rooms.',
        serviceAddress: 'House #45, Farid Town, Sahiwal',
        cityId: 'city_sahiwal',
        preferredDate: now.add(const Duration(days: 2)),
        preferredTimeSlot: '2:00 PM - 4:00 PM',
        isQuoteBased: true,
        status: ServiceRequestStatus.requested,
        statusHistory: [
          StatusHistoryEntry(
            status: ServiceRequestStatus.requested,
            changedByUserId: 'customer_demo_002',
            timestamp: now.subtract(const Duration(minutes: 30)),
          ),
        ],
        createdAt: now.subtract(const Duration(minutes: 30)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
    ]);
  }

  // ── Queries ──────────────────────────────────────────────────────────────

  Future<List<ServiceRequestModel>> getRequestsForCustomer(
      String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requests
        .where((r) => r.customerId == customerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<ServiceRequestModel>> getRequestsForWorker(
      String workerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requests
        .where((r) => r.workerId == workerId || r.status == ServiceRequestStatus.requested)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<ServiceRequestModel?> getRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ServiceRequestModel>> getPendingRequestsForAdmin() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _requests
        .where((r) => r.status == ServiceRequestStatus.disputed)
        .toList();
  }

  Future<List<ServiceRequestModel>> getAllRequestsForAdmin() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ── Mutations ────────────────────────────────────────────────────────────

  /// Customer creates a new service request.
  Future<ServiceRequestModel> createRequest({
    required String customerId,
    required String customerName,
    required String serviceCategory,
    required String description,
    required String serviceAddress,
    required String cityId,
    DateTime? preferredDate,
    String? preferredTimeSlot,
    double? budgetMin,
    double? budgetMax,
    bool isQuoteBased = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = 'req_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final request = ServiceRequestModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      serviceCategory: serviceCategory,
      description: description,
      serviceAddress: serviceAddress,
      cityId: cityId,
      preferredDate: preferredDate,
      preferredTimeSlot: preferredTimeSlot,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      isQuoteBased: isQuoteBased,
      status: ServiceRequestStatus.requested,
      statusHistory: [
        StatusHistoryEntry(
          status: ServiceRequestStatus.requested,
          changedByUserId: customerId,
          timestamp: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
    _requests.insert(0, request);
    return request;
  }

  /// Worker sends a quote (moves status: requested → quoted).
  Future<ServiceRequestModel> sendQuote({
    required String requestId,
    required String workerId,
    required String workerName,
    required double quotedAmount,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Request not found');
    final req = _requests[index];
    if (req.status != ServiceRequestStatus.requested) {
      throw Exception('Cannot quote: request is ${req.status.displayName}');
    }
    final updated = req.copyWith(
      workerId: workerId,
      workerName: workerName,
      quotedAmount: quotedAmount,
      status: ServiceRequestStatus.quoted,
      statusHistory: [
        ...req.statusHistory,
        StatusHistoryEntry(
          status: ServiceRequestStatus.quoted,
          changedByUserId: workerId,
          note: note ?? 'Rs. ${quotedAmount.toInt()} quoted',
          timestamp: DateTime.now(),
        ),
      ],
    );
    _requests[index] = updated;
    return updated;
  }

  /// Customer accepts the quote (moves status: quoted → accepted).
  Future<ServiceRequestModel> acceptQuote({
    required String requestId,
    required String customerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Request not found');
    final req = _requests[index];
    if (req.status != ServiceRequestStatus.quoted) {
      throw Exception('Cannot accept: no quote available yet');
    }
    final updated = req.copyWith(
      status: ServiceRequestStatus.accepted,
      statusHistory: [
        ...req.statusHistory,
        StatusHistoryEntry(
          status: ServiceRequestStatus.accepted,
          changedByUserId: customerId,
          timestamp: DateTime.now(),
        ),
      ],
    );
    _requests[index] = updated;
    return updated;
  }

  /// Worker marks job as In Progress (accepted → inProgress).
  Future<ServiceRequestModel> startJob({
    required String requestId,
    required String workerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Request not found');
    final req = _requests[index];
    if (req.status != ServiceRequestStatus.accepted) {
      throw Exception('Cannot start: not in accepted state');
    }
    final updated = req.copyWith(
      status: ServiceRequestStatus.inProgress,
      statusHistory: [
        ...req.statusHistory,
        StatusHistoryEntry(
          status: ServiceRequestStatus.inProgress,
          changedByUserId: workerId,
          timestamp: DateTime.now(),
        ),
      ],
    );
    _requests[index] = updated;
    return updated;
  }

  /// Worker marks job done, customer confirms (inProgress → completed).
  Future<ServiceRequestModel> completeJob({
    required String requestId,
    required String actorId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Request not found');
    final req = _requests[index];
    if (req.status != ServiceRequestStatus.inProgress &&
        req.status != ServiceRequestStatus.accepted) {
      throw Exception('Cannot complete from ${req.status.displayName}');
    }
    final updated = req.copyWith(
      status: ServiceRequestStatus.completed,
      statusHistory: [
        ...req.statusHistory,
        StatusHistoryEntry(
          status: ServiceRequestStatus.completed,
          changedByUserId: actorId,
          timestamp: DateTime.now(),
        ),
      ],
    );
    _requests[index] = updated;
    return updated;
  }

  /// Cancel a request with reason.
  Future<ServiceRequestModel> cancelRequest({
    required String requestId,
    required String actorId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Request not found');
    final req = _requests[index];
    if (req.status.isTerminal) {
      throw Exception('Cannot cancel a ${req.status.displayName} request');
    }
    final updated = req.copyWith(
      status: ServiceRequestStatus.cancelled,
      cancellationReason: reason,
      cancellationActorId: actorId,
      statusHistory: [
        ...req.statusHistory,
        StatusHistoryEntry(
          status: ServiceRequestStatus.cancelled,
          changedByUserId: actorId,
          note: reason,
          timestamp: DateTime.now(),
        ),
      ],
    );
    _requests[index] = updated;
    return updated;
  }

  /// Flag request as disputed.
  Future<ServiceRequestModel> disputeRequest({
    required String requestId,
    required String actorId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) throw Exception('Request not found');
    final req = _requests[index];
    final updated = req.copyWith(
      status: ServiceRequestStatus.disputed,
      disputeReason: reason,
      statusHistory: [
        ...req.statusHistory,
        StatusHistoryEntry(
          status: ServiceRequestStatus.disputed,
          changedByUserId: actorId,
          note: reason,
          timestamp: DateTime.now(),
        ),
      ],
    );
    _requests[index] = updated;
    return updated;
  }
}
