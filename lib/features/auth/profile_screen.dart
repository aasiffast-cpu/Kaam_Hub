import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_role.dart';
import '../../services/auth_notifier.dart';

/// Account & Profile screen displaying active user credentials and Sign Out action.
class ProfileScreen extends StatelessWidget {
  final AuthNotifier authNotifier;

  const ProfileScreen({super.key, required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    final user = authNotifier.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Padding(
            padding: AppConstants.paddingScreen,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'You are not currently signed in.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceL),
                PrimaryButton(
                  text: 'Sign In',
                  width: 160,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.phoneSignIn);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Color roleColor;
    switch (user.role) {
      case UserRole.customer:
        roleColor = AppColors.primary;
        break;
      case UserRole.worker:
        roleColor = AppColors.secondary;
        break;
      case UserRole.admin:
        roleColor = AppColors.accent;
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Account Profile')),
      body: SingleChildScrollView(
        padding: AppConstants.paddingScreen,
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spaceM),
            CircleAvatar(
              radius: 44,
              backgroundColor: roleColor.withAlpha(25),
              child: Icon(
                user.isAdmin
                    ? Icons.admin_panel_settings_rounded
                    : (user.isWorker
                          ? Icons.handyman_rounded
                          : Icons.person_rounded),
                size: 48,
                color: roleColor,
              ),
            ),
            const SizedBox(height: AppConstants.spaceM),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.phoneNumber,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceS),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withAlpha(25),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                user.role.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: roleColor,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceXL),

            // Profile info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'User ID',
                      value: user.uid,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Member Since',
                      value:
                          '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Account Status',
                      value: user.isActive ? 'Active' : 'Suspended',
                      valueColor: user.isActive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceXL),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                onPressed: () async {
                  await authNotifier.signOut();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.roleSelection,
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
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
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: AppConstants.spaceM),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
