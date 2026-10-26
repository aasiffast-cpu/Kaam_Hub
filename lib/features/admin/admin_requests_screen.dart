import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/service_request_model.dart';
import '../../models/report_model.dart';
import '../../services/mock_request_service.dart';
import '../../services/mock_support_services.dart';

/// Admin screen for managing all service requests (overview + disputes).
class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockRequestService _requestService = MockRequestService();
  final MockReportService _reportService = MockReportService();

  List<ServiceRequestModel> _allRequests = [];
  List<ServiceRequestModel> _disputes = [];
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _requestService.getAllRequestsForAdmin(),
      _reportService.getAllReports(),
    ]);
    if (mounted) {
      setState(() {
        _allRequests = results[0] as List<ServiceRequestModel>;
        _disputes = _allRequests
            .where((r) => r.status == ServiceRequestStatus.disputed)
            .toList();
        _reports = results[1] as List<ReportModel>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests & Reports'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadData),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All (${_allRequests.length})'),
            Tab(text: 'Disputes (${_disputes.length})'),
            Tab(text: 'Reports (${_reports.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _RequestListTab(requests: _allRequests),
                _DisputeListTab(
                    disputes: _disputes,
                    requestService: _requestService,
                    onRefresh: _loadData),
                _ReportsTab(
                    reports: _reports,
                    reportService: _reportService,
                    onRefresh: _loadData),
              ],
            ),
    );
  }
}

// ─── All Requests Tab ───────────────────────────────────────────────────────

class _RequestListTab extends StatelessWidget {
  final List<ServiceRequestModel> requests;
  const _RequestListTab({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(child: Text('No requests yet.'));
    }
    return ListView.separated(
      padding: AppConstants.paddingScreen,
      itemCount: requests.length,
      separatorBuilder: (_, r) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final req = requests[index];
        return _RequestTile(request: req);
      },
    );
  }
}

class _RequestTile extends StatelessWidget {
  final ServiceRequestModel request;
  const _RequestTile({required this.request});

  Color get _statusColor {
    switch (request.status) {
      case ServiceRequestStatus.completed:
        return AppColors.success;
      case ServiceRequestStatus.cancelled:
        return AppColors.error;
      case ServiceRequestStatus.disputed:
        return AppColors.warning;
      case ServiceRequestStatus.inProgress:
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${request.id.substring(request.id.length - 6)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(20),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(request.status.displayName,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(request.serviceCategory,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          Text(
            '${request.customerName} → ${request.workerName ?? 'Unassigned'}',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(request.serviceAddress,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            _formatDate(request.createdAt),
            style:
                const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Disputes Tab ───────────────────────────────────────────────────────────

class _DisputeListTab extends StatelessWidget {
  final List<ServiceRequestModel> disputes;
  final MockRequestService requestService;
  final VoidCallback onRefresh;

  const _DisputeListTab({
    required this.disputes,
    required this.requestService,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (disputes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 56, color: AppColors.success),
            SizedBox(height: 16),
            Text('No active disputes!',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: AppConstants.paddingScreen,
      itemCount: disputes.length,
      separatorBuilder: (_, r) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final req = disputes[index];
        return Container(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          decoration: BoxDecoration(
            color: AppColors.warning.withAlpha(10),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.warning.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.report_problem_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Text(req.serviceCategory,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                  '${req.customerName} ↔ ${req.workerName ?? 'Provider'}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              if (req.disputeReason != null)
                Text('Reason: ${req.disputeReason}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.error)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await requestService.cancelRequest(
                          requestId: req.id,
                          actorId: 'admin',
                          reason: 'Admin resolved dispute - cancelled',
                        );
                        onRefresh();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Dispute resolved: Cancelled')));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error)),
                      child: const Text('Cancel Request'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await requestService.completeJob(
                          requestId: req.id,
                          actorId: 'admin',
                        );
                        onRefresh();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Dispute resolved: Marked completed')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mark Complete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Reports Tab ─────────────────────────────────────────────────────────────

class _ReportsTab extends StatelessWidget {
  final List<ReportModel> reports;
  final MockReportService reportService;
  final VoidCallback onRefresh;

  const _ReportsTab({
    required this.reports,
    required this.reportService,
    required this.onRefresh,
  });

  Color _statusColor(ReportStatus s) {
    switch (s) {
      case ReportStatus.resolved:
        return AppColors.success;
      case ReportStatus.dismissed:
        return AppColors.textMuted;
      case ReportStatus.underReview:
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Center(child: Text('No reports filed.'));
    }
    return ListView.separated(
      padding: AppConstants.paddingScreen,
      itemCount: reports.length,
      separatorBuilder: (_, r) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final report = reports[index];
        return Container(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Report against: ${report.reportedUserName}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(report.status).withAlpha(20),
                      borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull),
                    ),
                    child: Text(report.status.displayName,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _statusColor(report.status))),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('By: ${report.reporterName}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              Text('Reason: ${report.reason}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              if (report.details != null)
                Text(report.details!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              if (report.status == ReportStatus.pending) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await reportService.updateReportStatus(
                            reportId: report.id,
                            status: ReportStatus.dismissed,
                            adminNote: 'Reviewed and dismissed',
                          );
                          onRefresh();
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary),
                        child: const Text('Dismiss'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await reportService.updateReportStatus(
                            reportId: report.id,
                            status: ReportStatus.resolved,
                            adminNote: 'Reviewed and resolved',
                          );
                          onRefresh();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Resolve'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
