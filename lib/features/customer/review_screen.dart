import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_support_services.dart';

/// Screen to submit a rating & review after a completed service request.
/// Enforced: only linked request customer can submit a review, only once.
class ReviewScreen extends StatefulWidget {
  final String requestId;
  final String workerId;
  final String workerName;
  final AuthNotifier? authNotifier;

  const ReviewScreen({
    super.key,
    required this.requestId,
    required this.workerId,
    required this.workerName,
    this.authNotifier,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final MockReviewService _reviewService = MockReviewService();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = widget.authNotifier?.currentUser;
    setState(() => _isSubmitting = true);
    try {
      await _reviewService.submitReview(
        requestId: widget.requestId,
        customerId: user?.uid ?? 'customer_demo_001',
        customerName: user?.name ?? 'Customer',
        workerId: widget.workerId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Review submitted. Shukriya!'),
            ],
          ),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: AppColors.error,
              content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review')),
      body: SingleChildScrollView(
        padding: AppConstants.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Worker info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withAlpha(20),
                  child: Text(
                    widget.workerName.isNotEmpty
                        ? widget.workerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.workerName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const Text('Rate your experience',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceXL),

            // Star Rating
            const Text('Rating *',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppConstants.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      index < _rating.floor()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 44,
                      color: AppColors.accent,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppConstants.spaceS),
            Center(
              child: Text(
                _getRatingLabel(_rating),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent),
              ),
            ),
            const SizedBox(height: AppConstants.spaceXL),

            // Comment
            const Text('Comment (Optional)',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppConstants.spaceS),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText:
                    'How was the service? Share your experience...',
                hintStyle: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  borderSide:
                      const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              maxLines: 4,
              maxLength: 300,
            ),
            const SizedBox(height: AppConstants.spaceL),

            // Privacy note
            const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.info),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reviews are public. Only customers who have completed the service can review.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceXL),

            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitReview,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                  : const Icon(Icons.star_rounded),
              label: Text(
                _isSubmitting ? 'Submitting...' : 'Submit Review',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 5) return '⭐ Excellent!';
    if (rating >= 4) return '😊 Good';
    if (rating >= 3) return '😐 Average';
    if (rating >= 2) return '😟 Poor';
    return '😞 Very Poor';
  }
}
