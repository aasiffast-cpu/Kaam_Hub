import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/download_app_dialog.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_role.dart';
import '../../services/auth_notifier.dart';

/// Screen allowing users to select and preview their experience by role.
class RoleSelectionScreen extends StatelessWidget {
  final AuthNotifier? authNotifier;

  const RoleSelectionScreen({super.key, this.authNotifier});

  @override
  Widget build(BuildContext context) {
    final currentUser = authNotifier?.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppConstants.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'KaamHub',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => DownloadAppDialog.show(context),
                    icon: const Icon(Icons.download_rounded,
                        color: AppColors.primary, size: 18),
                    label: const Text(
                      'Download App',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceS),
              // Circular App Branding
              Center(
                child: Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.primary, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(30),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/kaamhub_logo_circular.png',
                      fit: BoxFit.cover,
                    ),
                  ),
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
              const SizedBox(height: AppConstants.spaceL),

              // Active user banner if logged in, or Sign In button
              if (currentUser != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceM,
                    vertical: AppConstants.spaceS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.badgeApprovedBg,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: AppColors.badgeApprovedText.withAlpha(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.badgeApprovedText,
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.spaceS),
                      Expanded(
                        child: Text(
                          'Signed in as: ${currentUser.name} (${currentUser.role.displayName})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.badgeApprovedText,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                        child: const Text('Profile'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceM),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: 'Log In',
                        icon: Icons.login_rounded,
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.signUp);
                          },
                          icon: const Icon(Icons.person_add_rounded, size: 20),
                          label: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusM,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceM),
              ],

              const Text(
                'Explore / Switch Portal:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceS),

              // Quick Corridor Map Access
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.mapLocation);
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(40),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusS,
                          ),
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Open Corridor Street Map',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Sahiwal ➔ Okara ➔ Pattoki ➔ Lahore (All Streets)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Role Cards
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      title: 'Customer Dashboard',
                      subtitle: 'Browse verified workers along Sahiwal-Lahore corridor, book services & track orders.',
                      icon: Icons.dashboard_customize_rounded,
                      color: AppColors.primary,
                      onTap: () async {
                        if (authNotifier != null &&
                            currentUser?.role != UserRole.customer) {
                          await authNotifier!.signInWithDemo(UserRole.customer);
                        }
                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.customerDashboard,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    _RoleCard(
                      title: 'Service Provider Dashboard',
                      subtitle: 'Accept jobs, check earnings, upload compulsory CNIC & police clearance, preview public profile.',
                      icon: Icons.engineering_rounded,
                      color: AppColors.secondary,
                      onTap: () async {
                        if (authNotifier != null &&
                            currentUser?.role != UserRole.worker) {
                          await authNotifier!.signInWithDemo(UserRole.worker);
                        }
                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.serviceProviderDashboard,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceM),
                    _RoleCard(
                      title: 'Administrator Console (Guarded)',
                      subtitle: AppStrings.adminRoleDescription,
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppColors.accent,
                      onTap: () async {
                        if (authNotifier != null &&
                            currentUser?.role != UserRole.admin) {
                          await authNotifier!.signInWithDemo(UserRole.admin);
                        }
                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.adminDashboard,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const Text(
                'Stage 2 Authentication & Role Routing • KaamHub MVP',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppConstants.spaceXS),
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
                        fontSize: 15,
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
