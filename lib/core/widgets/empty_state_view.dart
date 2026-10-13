import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import 'primary_button.dart';

/// Clean empty state display when lists or queries return no results.
class EmptyStateView extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;

  const EmptyStateView({
    super.key,
    this.title = AppStrings.noDataFound,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionButtonText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceL),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: AppConstants.spaceL),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppConstants.spaceS),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            if (actionButtonText != null && onActionPressed != null) ...[
              const SizedBox(height: AppConstants.spaceL),
              PrimaryButton(
                text: actionButtonText!,
                onPressed: onActionPressed,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
