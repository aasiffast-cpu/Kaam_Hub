import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Worker dashboard shell representing Stage 1 navigation foundation.
class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
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
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              decoration: BoxDecoration(
                color: AppColors.badgePendingBg,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: AppColors.badgePendingText.withAlpha(50),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.pending_actions_rounded,
                    color: AppColors.badgePendingText,
                  ),
                  SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verification: Pending Admin Review',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.badgePendingText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your CNIC & credentials are being reviewed by the safety team.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.badgePendingText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),

            // Performance Metric Counters
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Active Jobs',
                    value: '2',
                    icon: Icons.work_outline_rounded,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _MetricCard(
                    title: 'Completed',
                    value: '18',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _MetricCard(
                    title: 'Rating',
                    value: '4.8 ★',
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

            // Sample Request Card
            Card(
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
                    const Text(
                      'Customer: Gulberg III, Lahore • 2.4 km away',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceM),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
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
