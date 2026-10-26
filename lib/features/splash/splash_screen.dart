import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_locale_notifier.dart';
import '../../models/user_role.dart';
import '../../services/auth_notifier.dart';

/// Splash screen — animated brand intro, language selector, then auto-routes
/// based on existing auth state (logged-in users go directly to their dashboard).
class SplashScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;
  const SplashScreen({super.key, this.authNotifier});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();

    // Auto-navigate after 2.8 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) _navigateForward();
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _navigateForward() {
    _navigationTimer?.cancel();
    if (!mounted) return;

    final auth = widget.authNotifier;
    if (auth != null && auth.isAuthenticated && auth.currentUser != null) {
      // User already logged in — go directly to their dashboard
      final role = auth.currentUser!.role;
      switch (role) {
        case UserRole.customer:
          Navigator.pushReplacementNamed(context, AppRoutes.customerDashboard);
          break;
        case UserRole.worker:
          Navigator.pushReplacementNamed(
              context, AppRoutes.serviceProviderDashboard);
          break;
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          break;
      }
    } else {
      // Not logged in — start with onboarding walkthrough (Next, Next, Next)
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier();
    final isUrdu = localeNotifier.isUrdu;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: AppConstants.paddingScreen,
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated KaamHub Circular Brand Mark
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
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
                      const SizedBox(height: 18),
                      Text(
                        isUrdu
                            ? 'قابل بھروسہ گھریلو خدمات — پاکستان'
                            : 'Verified Local Service Experts',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isUrdu
                            ? 'پلمبر، الیکٹریشن، مستری اور دیگر ماہرین'
                            : 'Trusted Home Services — Pakistan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Language Selection & Get Started
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      isUrdu
                          ? 'زبان منتخب کریں / Select Language'
                          : 'Select Language / زبان منتخب کریں',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _LanguageButton(
                            label: 'English',
                            isSelected: !isUrdu,
                            onTap: () {
                              setState(() {
                                localeNotifier.setLanguage('en');
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LanguageButton(
                            label: 'اردو',
                            isSelected: isUrdu,
                            onTap: () {
                              setState(() {
                                localeNotifier.setLanguage('ur');
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateForward,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusM),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          isUrdu ? 'شروع کریں  ←' : 'Get Started  →',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),

              FadeTransition(
                opacity: _fadeAnim,
                child: const Text(
                  'v1.0 • Lahore - Sahiwal - Okara Corridor',
                  style: TextStyle(fontSize: 11, color: Colors.white54),
                ),
              ),
              const SizedBox(height: AppConstants.spaceS),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white38,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}
