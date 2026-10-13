import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Admin dashboard shell representing Stage 1 navigation foundation.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceM,
              vertical: 8,
            ),
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
            const Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    title: 'Total Bookings',
                    count: '142',
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _AdminStatCard(
                    title: 'Pending Applications',
                    count: '5',
                    icon: Icons.pending_rounded,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceM),
            const Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    title: 'Active Workers',
                    count: '28',
                    icon: Icons.engineering_rounded,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(width: AppConstants.spaceM),
                Expanded(
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
                            color: AppColors.badgePendingBg,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusFull,
                            ),
                          ),
                          child: const Text(
                            'Needs Review',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.badgePendingText,
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
