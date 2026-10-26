import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_locale_notifier.dart';
import '../../core/widgets/download_app_dialog.dart';
import '../../services/auth_notifier.dart';

/// Clean, dedicated Welcome & Auth Gateway screen.
/// Separates authentication (Login / Sign Up) completely from service exploration.
class WelcomeAuthScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const WelcomeAuthScreen({super.key, this.authNotifier});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier();
    final isUrdu = localeNotifier.isUrdu;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Download App Action
          TextButton.icon(
            onPressed: () => DownloadAppDialog.show(context),
            icon: const Icon(Icons.download_rounded,
                color: AppColors.primary, size: 20),
            label: Text(
              isUrdu ? 'ایپ ڈاؤن لوڈ' : 'Download App',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Language Switcher
          TextButton(
            onPressed: () {
              setState(() {
                localeNotifier.setLanguage(isUrdu ? 'en' : 'ur');
              });
            },
            child: Text(
              isUrdu ? 'English' : 'اردو',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Circular KaamHub Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
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
              const SizedBox(height: 20),

              // Brand Title
              const Text(
                'KaamHub',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                isUrdu
                    ? 'پاکستان کی تصدیق شدہ گھریلو سروسز مارکیٹ'
                    : 'Verified Local Home Services in Pakistan',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isUrdu
                    ? 'پلمبر، الیکٹریشن، مستری اور میکینک فوری دستیاب ہیں'
                    : 'Plumbers, Electricians, Carpenters & Mechanics at your doorstep',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withAlpha(200),
                ),
              ),

              const Spacer(flex: 2),

              // Action 1: Log In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: Text(
                    isUrdu ? 'لاگ ان کریں  (Log In)' : 'Log In  →',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusM),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Action 2: Sign Up Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signUp);
                  },
                  icon: const Icon(Icons.person_add_rounded, size: 20),
                  label: Text(
                    isUrdu
                        ? 'نیا اکاؤنٹ بنائیں  (Sign Up)'
                        : 'Create New Account  →',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Divider "OR"
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      isUrdu ? 'یا' : 'OR',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Action 3: Guest / Explore Mode
              InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.customerDashboard);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.explore_outlined,
                          color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isUrdu
                            ? 'بغیر لاگ ان سروسز دیکھیں  (Guest Mode)'
                            : 'Browse Services without Login  →',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Safe Pilot Footer
              const Text(
                'Lahore • Sahiwal • Okara Corridor Pilot',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
