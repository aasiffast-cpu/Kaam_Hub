import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/worker_model.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_worker_service.dart';

/// Worker dashboard screen with verification status tracking and interactive job handling.
class WorkerDashboardScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const WorkerDashboardScreen({super.key, this.authNotifier});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  final MockWorkerService _workerService = MockWorkerService();
  WorkerModel? _worker;

  bool _isAvailable = true;
  int _activeJobs = 2;
  int _completedJobs = 18;

  // Interactive sample request state
  String _jobStatus =
      'pending'; // 'pending', 'accepted', 'completed', 'declined'

  @override
  void initState() {
    super.initState();
    _loadWorkerData();
  }

  void _loadWorkerData() async {
    final user = widget.authNotifier?.currentUser;
    WorkerModel? worker;
    if (user != null) {
      worker = await _workerService.getWorkerByUserId(user.uid);
    }
    // Fallback to default demo worker
    worker ??= await _workerService.getWorkerById('w_sahiwal_01');

    if (mounted) {
      setState(() {
        _worker = worker;
      });
    }
  }

  void _acceptJob() {
    setState(() {
      _jobStatus = 'accepted';
      _activeJobs++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Job Accepted! Customer notified you are on your way.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _declineJob() {
    setState(() {
      _jobStatus = 'declined';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job declined. Request passed to nearby providers.'),
      ),
    );
  }

  void _completeJob() {
    setState(() {
      _jobStatus = 'completed';
      _activeJobs--;
      _completedJobs++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text('Job marked completed! Earnings added to your summary.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authNotifier?.currentUser;
    final worker = _worker;
    final isPendingVerification =
        worker?.verificationStatus == WorkerVerificationStatus.pending;
    final isApproved =
        worker?.verificationStatus == WorkerVerificationStatus.approved;
    final hasCompleteDocs = worker?.hasCompleteDocuments ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user != null
                  ? '${user.name} (Worker)'
                  : (worker?.displayName ?? 'Worker Dashboard'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text(
              '${worker?.serviceCategory ?? 'Electrician'} • ${worker?.city ?? 'Lahore'}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                _isAvailable ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isAvailable ? AppColors.success : AppColors.textMuted,
                ),
              ),
              Switch(
                value: _isAvailable,
                onChanged: (val) {
                  setState(() {
                    _isAvailable = val;
                  });
                },
                activeThumbColor: AppColors.success,
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                tooltip: 'Profile',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.profile);
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppConstants.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verification Notice Banner
            if (isPendingVerification) ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.badgePendingBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: AppColors.badgePendingText.withAlpha(50),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.pending_actions_rounded,
                          color: AppColors.badgePendingText,
                          size: 26,
                        ),
                        const SizedBox(width: AppConstants.spaceM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Verification: Pending Admin Review',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.badgePendingText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasCompleteDocs
                                    ? 'All 4 documents (Profile Photo, CNIC Front/Back, Police Clearance) are submitted and under review by KaamHub safety team.'
                                    : 'Please complete your document submission to expedite account activation.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.badgePendingText,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.workerDocumentUpload,
                              arguments: worker,
                            );
                          },
                          icon: const Icon(Icons.upload_file_rounded, size: 16),
                          label: Text(
                            hasCompleteDocs
                                ? 'View Uploaded Documents'
                                : 'Upload Compulsory Documents',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.badgePendingText,
                            side: const BorderSide(
                              color: AppColors.badgePendingText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (isApproved) ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.badgeApprovedBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.success.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.badgeApprovedText,
                      size: 28,
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓ Profile Verified & Police Cleared',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.badgeApprovedText,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your profile is live across the corridor! You can receive direct customer booking requests.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.badgeApprovedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (worker != null) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.workerProfile,
                            arguments: worker,
                          );
                        }
                      },
                      child: const Text('View Profile'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.error.withAlpha(60)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Compulsory Documents Missing',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'You must upload your Profile Photo, CNIC Front, CNIC Back, and Police Clearance Certificate before your profile can be approved.',
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.workerDocumentUpload,
                          arguments: worker,
                        );
                      },
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text('Upload All 4 Documents Now'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spaceL),

            // Public Profile Preview CTA
            if (worker != null) ...[
              InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.workerProfile,
                    arguments: worker,
                  );
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.visibility_rounded,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview My Public Profile',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'See how customers view your rates, photos, and badges',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),
            ],

            // Performance Metric Counters
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Active Jobs',
                    value: '$_activeJobs',
                    icon: Icons.work_outline_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _MetricCard(
                    title: 'Completed',
                    value: '$_completedJobs',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _MetricCard(
                    title: 'Rating',
                    value: '${worker?.averageRating ?? 4.9} ★',
                    icon: Icons.star_border_rounded,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceL),

            // Incoming Requests Header
            const Text(
              'Incoming Job Requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceS),

            // Interactive Request Card
            if (_jobStatus == 'pending') ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tap & Pipe Leak Repair',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rs. 1,000 est.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Customer: Gulberg III, Lahore • 2.4 km away',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.map_rounded, size: 16),
                            label: const Text('View Map'),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.mapLocation,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceS),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _declineJob,
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _acceptJob,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Accept Job'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_jobStatus == 'accepted') ...[
              Card(
                elevation: 0,
                color: AppColors.badgeApprovedBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  side: BorderSide(color: AppColors.success.withAlpha(50)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tap & Pipe Leak Repair',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.badgeApprovedText,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusFull,
                              ),
                            ),
                            child: const Text(
                              'ACCEPTED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Service Address: House 42, Block B, Gulberg III, Lahore',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.badgeApprovedText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _completeJob,
                              icon: const Icon(Icons.check_circle_rounded),
                              label: const Text('Mark Completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_jobStatus == 'completed') ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        color: AppColors.success,
                        size: 28,
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      const Expanded(
                        child: Text(
                          'Job successfully completed & recorded.',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _jobStatus = 'pending');
                        },
                        child: const Text('Reset Demo'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      const Expanded(child: Text('Job was declined.')),
                      TextButton(
                        onPressed: () {
                          setState(() => _jobStatus = 'pending');
                        },
                        child: const Text('Reset Demo'),
                      ),
                    ],
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
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
