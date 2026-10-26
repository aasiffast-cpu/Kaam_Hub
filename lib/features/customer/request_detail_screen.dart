import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/service_request_model.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_request_service.dart';
import '../../services/mock_support_services.dart';
import 'review_screen.dart';

/// Detailed view of a single service request with status timeline
/// and available actions based on user role and current status.
class RequestDetailScreen extends StatefulWidget {
  final String requestId;
  final AuthNotifier? authNotifier;
  final bool isWorkerView;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
    this.authNotifier,
    this.isWorkerView = false,
  });

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final MockRequestService _requestService = MockRequestService();
  final MockReviewService _reviewService = MockReviewService();

  ServiceRequestModel? _request;
  bool _isLoading = true;
  bool _isActing = false;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() => _isLoading = true);
    final req = await _requestService.getRequest(widget.requestId);
    if (mounted) {
      setState(() {
        _request = req;
        _isLoading = false;
      });
    }
  }

  Future<void> _performAction(Future<ServiceRequestModel> Function() action) async {
    setState(() => _isActing = true);
    try {
      final updated = await action();
      if (mounted) setState(() => _request = updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: AppColors.error,
              content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isActing = false);
    }
  }

  void _showCancelDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Reason for cancellation...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Back')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              final user = widget.authNotifier?.currentUser;
              _performAction(() => _requestService.cancelRequest(
                    requestId: widget.requestId,
                    actorId: user?.uid ?? 'user',
                    reason: reasonController.text.trim().isEmpty
                        ? 'No reason given'
                        : reasonController.text.trim(),
                  ));
            },
            child: const Text('Confirm Cancel',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQuoteDialog() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Send Quote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (Rs.)',
                border: OutlineInputBorder(),
                prefixText: 'Rs. ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Enter a valid amount')));
                return;
              }
              Navigator.pop(ctx);
              final user = widget.authNotifier?.currentUser;
              _performAction(() => _requestService.sendQuote(
                    requestId: widget.requestId,
                    workerId: user?.uid ?? 'worker_001',
                    workerName: user?.name ?? 'Worker',
                    quotedAmount: amount,
                    note: noteController.text.trim(),
                  ));
            },
            child: const Text('Send Quote',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request')),
        body: const Center(child: Text('Request not found')),
      );
    }

    final req = _request!;
    final user = widget.authNotifier?.currentUser;
    final isCustomer = !widget.isWorkerView;

    return Scaffold(
      appBar: AppBar(
        title: Text(req.serviceCategory),
        actions: [
          if (!req.status.isTerminal)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'cancel') _showCancelDialog();
                if (val == 'dispute') {
                  _performAction(() => _requestService.disputeRequest(
                        requestId: req.id,
                        actorId: user?.uid ?? 'user',
                        reason: 'Dispute raised by user',
                      ));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'cancel', child: Text('Cancel Request')),
                const PopupMenuItem(
                    value: 'dispute', child: Text('Raise Dispute')),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppConstants.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _StatusBanner(status: req.status),
            const SizedBox(height: AppConstants.spaceL),

            // Request Info
            _InfoCard(children: [
              _InfoRow(
                  icon: Icons.handyman_rounded,
                  label: 'Category',
                  value: req.serviceCategory),
              _InfoRow(
                  icon: Icons.person_rounded,
                  label: 'Customer',
                  value: req.customerName),
              if (req.workerName != null)
                _InfoRow(
                    icon: Icons.engineering_rounded,
                    label: 'Provider',
                    value: req.workerName!),
              _InfoRow(
                  icon: Icons.location_on_rounded,
                  label: 'Address',
                  value: req.serviceAddress),
              if (req.preferredDate != null)
                _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Preferred Date',
                    value:
                        '${req.preferredDate!.day}/${req.preferredDate!.month}/${req.preferredDate!.year}'),
              if (req.preferredTimeSlot != null)
                _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Time Slot',
                    value: req.preferredTimeSlot!),
              if (req.quotedAmount != null)
                _InfoRow(
                  icon: Icons.payments_rounded,
                  label: 'Quoted Amount',
                  value: 'Rs. ${req.quotedAmount!.toInt()}',
                  valueColor: AppColors.success,
                ),
            ]),
            const SizedBox(height: AppConstants.spaceM),

            // Description
            const Text('Problem Description',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppConstants.spaceS),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(req.description,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: AppConstants.spaceL),

            // Status Timeline
            const Text('Status Timeline',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppConstants.spaceS),
            _StatusTimeline(history: req.statusHistory),
            const SizedBox(height: AppConstants.spaceL),

            // Actions
            _buildActions(req, isCustomer, user?.uid ?? ''),
            const SizedBox(height: AppConstants.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(
      ServiceRequestModel req, bool isCustomer, String userId) {
    final actions = <Widget>[];

    if (_isActing) {
      return const Center(child: CircularProgressIndicator());
    }

    // Customer actions
    if (isCustomer) {
      if (req.status == ServiceRequestStatus.quoted) {
        actions.add(_ActionButton(
          label: 'Accept Quote (Rs. ${req.quotedAmount?.toInt()})',
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          onPressed: () => _performAction(() =>
              _requestService.acceptQuote(
                  requestId: req.id, customerId: userId)),
        ));
      }
      if (req.status == ServiceRequestStatus.inProgress ||
          req.status == ServiceRequestStatus.accepted) {
        actions.add(_ActionButton(
          label: 'Confirm Job Completed',
          icon: Icons.task_alt_rounded,
          color: AppColors.success,
          onPressed: () => _performAction(() =>
              _requestService.completeJob(
                  requestId: req.id, actorId: userId)),
        ));
      }
      if (req.status == ServiceRequestStatus.completed &&
          !_reviewService.hasReviewedRequest(req.id) &&
          req.workerId != null) {
        actions.add(_ActionButton(
          label: 'Leave a Review',
          icon: Icons.star_rounded,
          color: AppColors.accent,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewScreen(
                  requestId: req.id,
                  workerId: req.workerId!,
                  workerName: req.workerName ?? 'Worker',
                  authNotifier: widget.authNotifier,
                ),
              ),
            );
          },
        ));
      }
    } else {
      // Worker actions
      if (req.status == ServiceRequestStatus.requested) {
        actions.add(_ActionButton(
          label: 'Send Quote',
          icon: Icons.request_quote_rounded,
          color: AppColors.primary,
          onPressed: _showQuoteDialog,
        ));
      }
      if (req.status == ServiceRequestStatus.accepted) {
        actions.add(_ActionButton(
          label: 'Mark as In Progress',
          icon: Icons.play_circle_rounded,
          color: AppColors.info,
          onPressed: () => _performAction(() =>
              _requestService.startJob(
                  requestId: req.id, workerId: userId)),
        ));
      }
      if (req.status == ServiceRequestStatus.inProgress) {
        actions.add(_ActionButton(
          label: 'Mark as Completed',
          icon: Icons.task_alt_rounded,
          color: AppColors.success,
          onPressed: () => _performAction(() =>
              _requestService.completeJob(
                  requestId: req.id, actorId: userId)),
        ));
      }
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Actions',
            style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppConstants.spaceS),
        ...actions.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: a,
            )),
      ],
    );
  }
}

// ── Supporting Widgets ───────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final ServiceRequestStatus status;
  const _StatusBanner({required this.status});

  Color get _color {
    switch (status) {
      case ServiceRequestStatus.completed:
        return AppColors.success;
      case ServiceRequestStatus.cancelled:
        return AppColors.error;
      case ServiceRequestStatus.disputed:
        return AppColors.warning;
      case ServiceRequestStatus.inProgress:
        return AppColors.info;
      case ServiceRequestStatus.accepted:
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (status) {
      case ServiceRequestStatus.completed:
        return Icons.task_alt_rounded;
      case ServiceRequestStatus.cancelled:
        return Icons.cancel_rounded;
      case ServiceRequestStatus.disputed:
        return Icons.report_problem_rounded;
      case ServiceRequestStatus.inProgress:
        return Icons.construction_rounded;
      case ServiceRequestStatus.accepted:
        return Icons.check_circle_rounded;
      case ServiceRequestStatus.quoted:
        return Icons.request_quote_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: _color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: _color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Status',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              Text(status.displayName,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: children
            .map((child) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: child,
                ))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary)),
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final List<StatusHistoryEntry> history;
  const _StatusTimeline({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text('No history available.',
          style: TextStyle(color: AppColors.textMuted));
    }
    return Column(
      children: history.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isLast = i == history.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isLast ? AppColors.primary : AppColors.cardBorder,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary,
                        width: isLast ? 2 : 1),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: AppColors.cardBorder,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.status.displayName,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isLast
                                ? AppColors.primary
                                : AppColors.textPrimary)),
                    if (item.note != null)
                      Text(item.note!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    Text(
                      _formatDate(item.timestamp),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }
}
