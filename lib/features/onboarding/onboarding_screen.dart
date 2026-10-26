import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_locale_notifier.dart';
import '../../core/widgets/download_app_dialog.dart';
import '../../services/auth_notifier.dart';

/// Interactive Multi-Step Onboarding Walkthrough (Next, Next, Next).
/// Features circular KaamHub logo, bilingual support, download button, and smooth transitions.
class OnboardingScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const OnboardingScreen({super.key, this.authNotifier});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.home_repair_service_rounded,
      'titleEn': 'Local Services at Your Doorstep',
      'titleUr': 'قابل بھروسہ گھریلو خدمات آپ کی دہلیز پر',
      'descEn':
          'Connect instantly with expert Plumbers, Electricians, Carpenters, and Masons across Pakistan.',
      'descUr':
          'پلمبر، الیکٹریشن، مستری، پینٹر اور دیگر ماہرین تک فوری اور آسان رسائی حاصل کریں۔',
    },
    {
      'icon': Icons.verified_user_rounded,
      'titleEn': '100% Verified & Police Cleared',
      'titleUr': 'تصدیق شدہ اور محفوظ کاریگر',
      'descEn':
          'Every service worker is verified with CNIC and Punjab Police Clearance for your family’s peace of mind.',
      'descUr':
          'شناختی کارڈ اور پولیس سرٹیفکیٹ سے تصدیق شدہ ماہرین۔ شفاف ریٹس اور مکمل تحفظ۔',
    },
    {
      'icon': Icons.my_location_rounded,
      'titleEn': 'Auto GPS & Instant Booking',
      'titleUr': 'خودکار لوکیشن اور فوری بکنگ',
      'descEn':
          'Automatic location detection across Lahore, Sahiwal, Okara and corridor cities with live chat support.',
      'descUr':
          'لاہور، ساہیوال، اوکاڑہ اور تمام بڑے شہروں میں تیز رفتار بکنگ اور براہِ راست رابطہ۔',
    },
  ];

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier();
    final isUrdu = localeNotifier.isUrdu;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: TextButton.icon(
            onPressed: () => DownloadAppDialog.show(context),
            icon: const Icon(Icons.download_rounded,
                color: AppColors.primary, size: 18),
            label: const Text(
              'App Download',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          // Language toggle
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Skip button
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              isUrdu ? 'چھوڑیں' : 'Skip',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Circular Logo in App
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.primary, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
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

            const SizedBox(height: 8),
            const Text(
              'KaamHub',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),

            // PageView Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Feature illustration badge
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withAlpha(15),
                            border: Border.all(
                              color: AppColors.primary.withAlpha(40),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 54,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Title
                        Text(
                          isUrdu
                              ? slide['titleUr'] as String
                              : slide['titleEn'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Description
                        Text(
                          isUrdu
                              ? slide['descUr'] as String
                              : slide['descEn'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withAlpha(220),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator Dots & Next / Finish Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Next / Get Started Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onNext,
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
                      child: Text(
                        isLastPage
                            ? (isUrdu ? 'شروع کریں  →' : 'Get Started  →')
                            : (isUrdu ? 'اگلا مرحلہ  →' : 'Next  →'),
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
          ],
        ),
      ),
    );
  }
}
