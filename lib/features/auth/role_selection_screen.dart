import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';

/// Screen allowing users to select and preview their experience by role.
/// Used in Stage 1 to validate navigation before Firebase Auth is wired in Stage 2.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spaceL),
              // App Branding
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(50),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.handyman_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),
              const Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXS),
              const Text(
                AppStrings.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXL),
              const Text(
                AppStrings.selectRolePrompt,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),
              // Role Cards
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      title: 'Customer',
                      subtitle: AppStrings.customerRoleDescription,
                      icon: Icons.person_search_rounded,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.customerHome);
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    _RoleCard(
                      title: 'Service Worker',
                      subtitle: AppStrings.workerRoleDescription,
                      icon: Icons.construction_rounded,
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.workerDashboard);
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    _RoleCard(
                      title: 'Administrator',
                      subtitle: AppStrings.adminRoleDescription,
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppColors.accent,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.adminDashboard);
                      },
                    ),
                  ],
                ),
              ),
              const Text(
                'Stage 1 Navigation Verification • KaamHub MVP',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppConstants.spaceS),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceS),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
