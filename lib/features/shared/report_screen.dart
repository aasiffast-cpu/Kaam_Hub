import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_support_services.dart';

/// Report or block a user. Available from chat or profile.
class ReportScreen extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;
  final String? conversationId;
  final String? requestId;
  final AuthNotifier? authNotifier;

  const ReportScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
    this.conversationId,
    this.requestId,
    this.authNotifier,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final MockReportService _reportService = MockReportService();
  final TextEditingController _detailsController = TextEditingController();

  String? _selectedReason;
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Scam or Fraud',
    'Harassment or Abuse',
    'Unsafe Behavior',
    'No-Show / Unprofessional',
    'Fake Profile',
    'Threatening Language',
    'Other',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = widget.authNotifier?.currentUser;
    try {
      await _reportService.submitReport(
        reporterId: user?.uid ?? 'user',
        reporterName: user?.name ?? 'User',
        reportedUserId: widget.reportedUserId,
        reportedUserName: widget.reportedUserName,
        reason: _selectedReason!,
        details: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
        conversationId: widget.conversationId,
        requestId: widget.requestId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
              'Report submitted. Our safety team will review within 24 hours.'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: AppColors.error,
              content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report User')),
      body: SingleChildScrollView(
        padding: AppConstants.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Safety notice
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(15),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.error.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded,
                      color: AppColors.error, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reporting: ${widget.reportedUserName}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text(
                          'Your report is confidential. Our team will review and take action within 24 hours. Reported content may be reviewed by authorized moderators.',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),

            // Reason selection
            const Text('Reason for Report *',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppConstants.spaceS),
            ..._reasons.map((reason) => _ReasonTile(
                  reason: reason,
                  isSelected: _selectedReason == reason,
                  onTap: () => setState(() => _selectedReason = reason),
                )),
            const SizedBox(height: AppConstants.spaceM),

            // Additional details
            const Text('Additional Details (Optional)',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppConstants.spaceS),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(
                hintText:
                    'Describe the incident (do not share sensitive personal info)...',
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  borderSide:
                      const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: AppConstants.spaceL),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReport,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.report_rounded),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Report',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),
          ],
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String reason;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReasonTile({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.error.withAlpha(15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            border: Border.all(
              color: isSelected ? AppColors.error : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.error : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(reason,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.error
                        : AppColors.textPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
