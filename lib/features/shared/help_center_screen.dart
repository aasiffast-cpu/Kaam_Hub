import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Help center / FAQ screen for KaamHub users.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        padding: AppConstants.paddingScreen,
        children: [
          // Contact bar
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text('KaamHub Support',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ],
                ),
                SizedBox(height: 8),
                Text('📞 0300-KAAMHUB',
                    style: TextStyle(color: Colors.white70)),
                Text('📧 support@kaamhub.pk',
                    style: TextStyle(color: Colors.white70)),
                Text('⏰ Mon–Sat: 9 AM – 9 PM',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),

          const Text('Frequently Asked Questions',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppConstants.spaceM),

          ..._faqs.map((faq) => _FaqTile(
                question: faq['q']!,
                answer: faq['a']!,
              )),

          const SizedBox(height: AppConstants.spaceL),
          const Text('Safety & Trust',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppConstants.spaceS),
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(15),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.info.withAlpha(40)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user_rounded,
                        color: AppColors.info, size: 20),
                    SizedBox(width: 8),
                    Text('Verification Process',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.info)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'All service providers are required to submit:\n'
                  '• Valid CNIC (front and back)\n'
                  '• Police Clearance Certificate (Punjab Khidmat Markaz)\n\n'
                  'Our admin team reviews these documents before approving any provider. '
                  'Verification confirms identity only and does not guarantee service quality. '
                  'Always use in-app communication and reporting tools.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),

          // Legal links placeholder
          ListTile(
            leading: const Icon(Icons.description_rounded,
                color: AppColors.primary),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Terms of Service — coming soon')));
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded,
                color: AppColors.primary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Privacy Policy — coming soon')));
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded,
                color: AppColors.error),
            title: const Text('Request Account Deletion',
                style: TextStyle(color: AppColors.error)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.error),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Account Deletion'),
                  content: const Text(
                      'To delete your account and all associated data, please contact support@kaamhub.pk with your registered phone number. '
                      'Your request will be processed within 7 business days.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK')),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppConstants.spaceXL),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding:
            const EdgeInsets.only(bottom: 12, left: 4, right: 4),
        title: Text(question,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700)),
        children: [
          Text(answer,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

const List<Map<String, String>> _faqs = [
  {
    'q': 'How do I book a service?',
    'a':
        'Browse service providers by category or search. Open a provider profile, tap "Request Service", fill in the details, and send your request. The provider will review and respond with a quote.',
  },
  {
    'q': 'Is it safe to share my address?',
    'a':
        'Your address is only shared with the specific service provider assigned to your request. It is never publicly visible or accessible to other users.',
  },
  {
    'q': 'How are providers verified?',
    'a':
        'Every provider must submit their CNIC (front and back) and a Punjab Police Clearance Certificate. Our admin team reviews these before approving the profile. Verification is date-based; it does not guarantee future behavior.',
  },
  {
    'q': 'How do I pay for services?',
    'a':
        'In the current MVP, payments are made directly to the provider in cash at the time of service. Online payment will be added in a future update.',
  },
  {
    'q': 'Can I cancel a request?',
    'a':
        'Yes. You can cancel a request before the job is In Progress. Open the request, tap the menu icon, and select "Cancel Request". Provide a reason to help us improve the service.',
  },
  {
    'q': 'What if I have a problem with the service?',
    'a':
        'You can raise a dispute from the request detail page, or report the user. Our team will review within 24 hours and follow up via in-app notification.',
  },
  {
    'q': 'How do I become a service provider?',
    'a':
        'Register and select "Service Provider" as your role. Fill in your profile details and upload your CNIC and Police Clearance Certificate. Your application will be reviewed by our team.',
  },
];
