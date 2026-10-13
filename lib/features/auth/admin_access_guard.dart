import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/auth_notifier.dart';

/// Security Guard Widget that protects Admin screens from unauthorized role access.
class AdminAccessGuard extends StatelessWidget {
  final AuthNotifier authNotifier;
  final Widget child;

  const AdminAccessGuard({
    super.key,
    required this.authNotifier,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final user = authNotifier.currentUser;

    // Check if authenticated AND assigned the Admin role
    if (user != null && user.isAdmin) {
      return child;
    }

    // Access Denied Shield View
    return Scaffold(
      appBar: AppBar(title: const Text('Security Verification')),
      body: Center(
        child: Padding(
          padding: AppConstants.paddingScreen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceL),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gpp_bad_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceS),
              Text(
                user == null
                    ? 'You must be signed in with an Administrator account to view this console.'
                    : 'Your account (${user.name} • ${user.role.displayName}) is not authorized for Administrator access.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXL),
              PrimaryButton(
                text: 'Return to Role Selection',
                width: 240,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
