import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Modal dialog providing real steps to Install/Download KaamHub onto Android or iOS phones.
class DownloadAppDialog extends StatelessWidget {
  const DownloadAppDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => const DownloadAppDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Logo Badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
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
              const SizedBox(height: 14),

              const Text(
                'Install KaamHub on Mobile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'موبائل پر کام ہب انسٹال کریں',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Method 1: Android Chrome / Browser Install (PWA)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.android_rounded,
                            color: AppColors.primary, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Android Phone (Chrome / Browser):',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildStepRow(
                      number: '1',
                      en: 'Tap the 3 dots (⋮) menu at top-right of your browser',
                      ur: 'براؤزر کے اوپر دائیں کونے میں تین نقطوں (⋮) کو دبائیں',
                    ),
                    const SizedBox(height: 8),
                    _buildStepRow(
                      number: '2',
                      en: 'Tap "Install App" or "Add to Home Screen"',
                      ur: '"Install app" یا "Add to Home screen" پر کلک کریں',
                    ),
                    const SizedBox(height: 8),
                    _buildStepRow(
                      number: '3',
                      en: 'KaamHub installs on your phone like a Play Store app!',
                      ur: 'کام ہب سرکلر لوگو کے ساتھ آپ کے موبائل پر انسٹال ہو جائے گی!',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Method 2: iPhone / Safari Install
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.apple_rounded,
                            color: AppColors.textPrimary, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'iPhone / iOS (Safari Browser):',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildStepRow(
                      number: '1',
                      en: 'Tap Share button (⎋) at the bottom',
                      ur: 'نیچے شیئر (⎋) کے بٹن کو دبائیں',
                    ),
                    const SizedBox(height: 6),
                    _buildStepRow(
                      number: '2',
                      en: 'Scroll down and tap "Add to Home Screen"',
                      ur: '"Add to Home Screen" پر کلک کریں',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Got It Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got It / سمجھ آ گئی  ✓',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildStepRow({
    required String number,
    required String en,
    required String ur,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                en,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                ur,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
