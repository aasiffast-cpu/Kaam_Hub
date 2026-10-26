import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/worker_model.dart';
import '../../services/auth_notifier.dart';

/// Screen showing provider's application/verification status.
class WorkerApplicationStatusScreen extends StatelessWidget {
  final WorkerModel? worker;
  final AuthNotifier? authNotifier;

  const WorkerApplicationStatusScreen({
    super.key,
    this.worker,
    this.authNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final status = worker?.verificationStatus ?? WorkerVerificationStatus.pending;

    return Scaffold(
      appBar: AppBar(title: const Text('Verification Status')),
      body: SingleChildScrollView(
        padding: AppConstants.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppConstants.spaceL),

            // Status Icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: _statusColor(status).withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(
                    color: _statusColor(status).withAlpha(80), width: 2),
              ),
              child: Icon(_statusIcon(status),
                  color: _statusColor(status), size: 46),
            ),
            const SizedBox(height: AppConstants.spaceM),

            Text(
              _statusTitle(status),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _statusColor(status),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              _statusMessage(status, worker?.rejectionReason),
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceXL),

            // Document checklist
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.checklist_rounded,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text('Document Checklist',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceM),
                  _DocItem(
                    label: 'Profile Photo',
                    isProvided: worker?.profileImageUrl.isNotEmpty ?? false,
                  ),
                  _DocItem(
                    label: 'CNIC Front (Shanakhti Card)',
                    isProvided: worker?.cnicFrontUrl != null,
                  ),
                  _DocItem(
                    label: 'CNIC Back',
                    isProvided: worker?.cnicBackUrl != null,
                  ),
                  _DocItem(
                    label: 'Police Clearance Certificate',
                    isProvided: worker?.policeClearanceUrl != null,
                  ),
                ],
              ),
            ),

            if (status == WorkerVerificationStatus.rejected &&
                worker?.rejectionReason != null) ...[
              const SizedBox(height: AppConstants.spaceM),
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.error.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Text('Rejection Reason',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.error)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(worker!.rejectionReason!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spaceL),

            if (status == WorkerVerificationStatus.pending)
              const _InfoNotice(
                icon: Icons.access_time_rounded,
                color: AppColors.warning,
                text:
                    'Your application is under review. This typically takes 1–2 business days. You will be notified via in-app notification.',
              ),

            if (status == WorkerVerificationStatus.approved)
              const _InfoNotice(
                icon: Icons.verified_rounded,
                color: AppColors.success,
                text:
                    'Congratulations! Your profile is now live. Customers can find and contact you. Keep your availability updated.',
              ),

            if (status == WorkerVerificationStatus.rejected) ...[
              const _InfoNotice(
                icon: Icons.refresh_rounded,
                color: AppColors.error,
                text:
                    'Please correct the issues mentioned above and re-upload your documents. Contact support if you need help.',
              ),
              const SizedBox(height: AppConstants.spaceM),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/worker/upload_documents');
                  },
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('Re-upload Documents'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spaceXL),
          ],
        ),
      ),
    );
  }

  Color _statusColor(WorkerVerificationStatus s) {
    switch (s) {
      case WorkerVerificationStatus.approved:
        return AppColors.success;
      case WorkerVerificationStatus.rejected:
        return AppColors.error;
      case WorkerVerificationStatus.pending:
        return AppColors.warning;
    }
  }

  IconData _statusIcon(WorkerVerificationStatus s) {
    switch (s) {
      case WorkerVerificationStatus.approved:
        return Icons.verified_rounded;
      case WorkerVerificationStatus.rejected:
        return Icons.cancel_rounded;
      case WorkerVerificationStatus.pending:
        return Icons.hourglass_top_rounded;
    }
  }

  String _statusTitle(WorkerVerificationStatus s) {
    switch (s) {
      case WorkerVerificationStatus.approved:
        return 'Verified & Approved!';
      case WorkerVerificationStatus.rejected:
        return 'Application Rejected';
      case WorkerVerificationStatus.pending:
        return 'Under Review';
    }
  }

  String _statusMessage(
      WorkerVerificationStatus s, String? rejectionReason) {
    switch (s) {
      case WorkerVerificationStatus.approved:
        return 'Your profile is live. Customers can now find and book your services.';
      case WorkerVerificationStatus.rejected:
        return 'Your application was not approved. Please see the reason below and re-upload your documents.';
      case WorkerVerificationStatus.pending:
        return 'Your documents are being reviewed by our team. Please wait for approval notification.';
    }
  }
}

class _DocItem extends StatelessWidget {
  final String label;
  final bool isProvided;

  const _DocItem({required this.label, required this.isProvided});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isProvided
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isProvided ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: isProvided
                      ? AppColors.textPrimary
                      : AppColors.error)),
          if (!isProvided)
            const Text(' (Missing)',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoNotice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoNotice({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
