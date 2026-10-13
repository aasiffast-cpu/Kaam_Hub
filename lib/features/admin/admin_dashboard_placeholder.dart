import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_notifier.dart';

/// Admin dashboard console representing Stage 2 role-guarded management.
class AdminDashboardScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const AdminDashboardScreen({super.key, this.authNotifier});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _pendingApplications = 5;
  int _activeWorkers = 28;

  // Verification status of the sample applicant
  String _sampleApplicantStatus =
      'needs_review'; // 'needs_review', 'approved', 'rejected'

  void _approveApplicant() {
    setState(() {
      _sampleApplicantStatus = 'approved';
      if (_pendingApplications > 0) _pendingApplications--;
      _activeWorkers++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          'Worker Approved! Tariq Mahmood can now receive customer bookings.',
        ),
      ),
    );
  }

  void _rejectApplicant() {
    setState(() {
      _sampleApplicantStatus = 'rejected';
      if (_pendingApplications > 0) _pendingApplications--;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.error,
        content: Text(
          'Application rejected. Verification status updated in database.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(30),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, size: 14, color: AppColors.accent),
                SizedBox(width: 4),
                Text(
                  'Super Admin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
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
      body: SingleChildScrollView(
        padding: AppConstants.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Security Notice
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(20),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.info.withAlpha(60)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security_rounded, color: AppColors.info),
                  SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Text(
                      'Admin panel guarded by Firebase Security Rules & backend role claims.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),

            // Top Metrics Grid
            const Text(
              'Marketplace Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceS),
            Row(
              children: [
                const Expanded(
                  child: _AdminStatCard(
                    title: 'Total Bookings',
                    count: '142',
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _AdminStatCard(
                    title: 'Pending Approvals',
                    count: '$_pendingApplications',
                    icon: Icons.pending_rounded,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceM),
            Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    title: 'Active Workers',
                    count: '$_activeWorkers',
                    icon: Icons.engineering_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                const Expanded(
                  child: _AdminStatCard(
                    title: 'Open Complaints',
                    count: '1',
                    icon: Icons.report_problem_rounded,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceL),

            // Pending Worker Approvals
            const Text(
              'Pending Worker Verifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceS),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tariq Mahmood',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _sampleApplicantStatus == 'approved'
                                ? AppColors.badgeApprovedBg
                                : (_sampleApplicantStatus == 'rejected'
                                      ? AppColors.badgeRejectedBg
                                      : AppColors.badgePendingBg),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusFull,
                            ),
                          ),
                          child: Text(
                            _sampleApplicantStatus == 'approved'
                                ? 'VERIFIED'
                                : (_sampleApplicantStatus == 'rejected'
                                      ? 'REJECTED'
                                      : 'Needs Review'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _sampleApplicantStatus == 'approved'
                                  ? AppColors.badgeApprovedText
                                  : (_sampleApplicantStatus == 'rejected'
                                        ? AppColors.badgeRejectedText
                                        : AppColors.badgePendingText),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Category: Electrician • 6 Years Exp • Johar Town, Lahore',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Documents: CNIC Front/Back + 3 past work photos uploaded',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    if (_sampleApplicantStatus == 'needs_review') ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _rejectApplicant,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _approveApplicant,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _sampleApplicantStatus == 'approved'
                                ? 'Status: Approved & Profile Published'
                                : 'Status: Rejected by Safety Team',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _sampleApplicantStatus == 'approved'
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(
                                () => _sampleApplicantStatus = 'needs_review',
                              );
                            },
                            child: const Text('Reset Demo'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
