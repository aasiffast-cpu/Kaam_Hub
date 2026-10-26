import '../models/notification_model.dart';
import '../models/review_model.dart';
import '../models/report_model.dart';

/// Mock notification service for KaamHub.
class MockNotificationService {
  static final MockNotificationService _instance =
      MockNotificationService._internal();
  factory MockNotificationService() => _instance;
  MockNotificationService._internal() {
    _seedNotifications();
  }

  final List<NotificationModel> _notifications = [];

  void _seedNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      NotificationModel(
        id: 'notif_001',
        userId: 'customer_demo_001',
        type: NotificationType.bookingAccepted,
        title: 'Booking Accepted!',
        body: 'Muhammad Usman ne aapki electrician request accept kar li.',
        isRead: false,
        relatedId: 'req_001',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: 'notif_002',
        userId: 'customer_demo_001',
        type: NotificationType.newMessage,
        title: 'New Message',
        body: 'Muhammad Usman: Theek hai, kal 10 baje aa jata hoon',
        isRead: false,
        relatedId: 'conv_001',
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      NotificationModel(
        id: 'notif_003',
        userId: 'customer_demo_001',
        type: NotificationType.jobCompleted,
        title: 'Job Completed',
        body: 'Tariq Mehmood ne plumbing job complete kar di. Rating dein!',
        isRead: true,
        relatedId: 'req_002',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: 'notif_004',
        userId: 'worker_demo_001',
        type: NotificationType.newRequest,
        title: 'Naya Service Request!',
        body: 'Sara Fatima ne fan installation request bheji hai.',
        isRead: false,
        relatedId: 'req_003',
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      NotificationModel(
        id: 'notif_005',
        userId: 'worker_demo_001',
        type: NotificationType.applicationApproved,
        title: 'Verification Approved!',
        body: 'Mubarak ho! Aapka account verify ho gaya. Ab jobs accept karein.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  Future<List<NotificationModel>> getNotificationsForUser(
      String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _notifications
        .where((n) => n.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int getUnreadCount(String userId) {
    return _notifications
        .where((n) => n.userId == userId && !n.isRead)
        .length;
  }

  Future<void> markAllRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  Future<void> markRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
  }
}

/// Mock review service.
class MockReviewService {
  static final MockReviewService _instance = MockReviewService._internal();
  factory MockReviewService() => _instance;
  MockReviewService._internal() {
    _seedReviews();
  }

  final List<ReviewModel> _reviews = [];
  // Track which requests have been reviewed to prevent duplicates
  final Set<String> _reviewedRequestIds = {};

  void _seedReviews() {
    final now = DateTime.now();
    _reviews.addAll([
      ReviewModel(
        id: 'rev_001',
        requestId: 'req_002',
        customerId: 'customer_demo_001',
        customerName: 'Ali Hassan',
        workerId: 'worker_002',
        rating: 4.5,
        comment: 'Bahut acha kaam kiya. Waqt par aaye aur clean job ki.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
    _reviewedRequestIds.add('req_002');
  }

  Future<List<ReviewModel>> getReviewsForWorker(String workerId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _reviews
        .where((r) => r.workerId == workerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool hasReviewedRequest(String requestId) {
    return _reviewedRequestIds.contains(requestId);
  }

  /// Only allow review for completed requests, one review per request.
  Future<ReviewModel> submitReview({
    required String requestId,
    required String customerId,
    required String customerName,
    required String workerId,
    required double rating,
    String? comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_reviewedRequestIds.contains(requestId)) {
      throw Exception('You have already reviewed this request');
    }
    final id = 'rev_${DateTime.now().millisecondsSinceEpoch}';
    final review = ReviewModel(
      id: id,
      requestId: requestId,
      customerId: customerId,
      customerName: customerName,
      workerId: workerId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.add(review);
    _reviewedRequestIds.add(requestId);
    return review;
  }
}

/// Mock report service.
class MockReportService {
  static final MockReportService _instance = MockReportService._internal();
  factory MockReportService() => _instance;
  MockReportService._internal();

  final List<ReportModel> _reports = [];

  Future<List<ReportModel>> getAllReports() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_reports)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<ReportModel> submitReport({
    required String reporterId,
    required String reporterName,
    required String reportedUserId,
    required String reportedUserName,
    required String reason,
    String? details,
    String? conversationId,
    String? requestId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = 'report_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final report = ReportModel(
      id: id,
      reporterId: reporterId,
      reporterName: reporterName,
      reportedUserId: reportedUserId,
      reportedUserName: reportedUserName,
      conversationId: conversationId,
      requestId: requestId,
      reason: reason,
      details: details,
      createdAt: now,
      updatedAt: now,
    );
    _reports.insert(0, report);
    return report;
  }

  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? adminNote,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final r = _reports[index];
      _reports[index] = ReportModel(
        id: r.id,
        reporterId: r.reporterId,
        reporterName: r.reporterName,
        reportedUserId: r.reportedUserId,
        reportedUserName: r.reportedUserName,
        conversationId: r.conversationId,
        requestId: r.requestId,
        reason: r.reason,
        details: r.details,
        status: status,
        adminNote: adminNote ?? r.adminNote,
        createdAt: r.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}
