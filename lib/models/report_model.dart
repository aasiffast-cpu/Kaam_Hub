/// Report filed by a user against another user or conversation.
class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final String? conversationId;
  final String? requestId;
  final String reason;
  final String? details;
  final ReportStatus status;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    this.conversationId,
    this.requestId,
    required this.reason,
    this.details,
    this.status = ReportStatus.pending,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      reporterId: map['reporterId'] as String? ?? '',
      reporterName: map['reporterName'] as String? ?? '',
      reportedUserId: map['reportedUserId'] as String? ?? '',
      reportedUserName: map['reportedUserName'] as String? ?? '',
      conversationId: map['conversationId'] as String?,
      requestId: map['requestId'] as String?,
      reason: map['reason'] as String? ?? '',
      details: map['details'] as String?,
      status: ReportStatus.fromString(map['status'] as String?),
      adminNote: map['adminNote'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'reporterId': reporterId,
        'reporterName': reporterName,
        'reportedUserId': reportedUserId,
        'reportedUserName': reportedUserName,
        'conversationId': conversationId,
        'requestId': requestId,
        'reason': reason,
        'details': details,
        'status': status.toJson(),
        'adminNote': adminNote,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

enum ReportStatus {
  pending,
  underReview,
  resolved,
  dismissed;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }

  static ReportStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'underreview':
      case 'under_review':
        return ReportStatus.underReview;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }

  String toJson() => name;
}
