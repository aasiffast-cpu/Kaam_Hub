import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamhub/app/app.dart';
import 'package:kaamhub/core/constants/app_strings.dart';
import 'package:kaamhub/features/customer/worker_profile_screen.dart';
import 'package:kaamhub/features/worker/worker_document_upload_screen.dart';
import 'package:kaamhub/models/user_role.dart';
import 'package:kaamhub/models/worker_model.dart';
import 'package:kaamhub/services/auth_notifier.dart';
import 'package:kaamhub/services/mock_auth_service.dart';

void main() {
  testWidgets('KaamHub foundation test: verifies branding and role portals', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KaamHubApp());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);
    expect(find.text('Customer Dashboard'), findsOneWidget);
    expect(find.text('Service Provider Dashboard'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Login and Sign Up navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(const KaamHubApp());
    await tester.pumpAndSettle();

    // Tap Log In button
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();
    expect(find.text('Account Login'), findsOneWidget);
    expect(find.text('Welcome Back to KaamHub'), findsOneWidget);

    // Tap Sign Up Now link to switch to registration
    await tester.tap(find.text('Sign Up Now'));
    await tester.pumpAndSettle();
    expect(find.text('Create New Account'), findsOneWidget);
    expect(find.text('Join KaamHub Marketplace'), findsOneWidget);
  });

  testWidgets('Worker dashboard interactive test: Accept job updates state', (
    WidgetTester tester,
  ) async {
    final mockAuth = MockAuthService();
    await mockAuth.signInWithDemoAccount(UserRole.worker);
    final authNotifier = AuthNotifier(authService: mockAuth);

    await tester.pumpWidget(KaamHubApp(authNotifier: authNotifier));
    await tester.pumpAndSettle();

    // Tap into Service Provider Dashboard
    await tester.tap(find.text('Service Provider Dashboard'));
    await tester.pumpAndSettle();

    // Verify initial active jobs is 2
    expect(find.text('Active Jobs'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // Verify Accept Job button is present and tap it
    expect(find.text('Accept Job'), findsOneWidget);
    await tester.ensureVisible(find.text('Accept Job'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept Job'));
    await tester.pumpAndSettle();

    // Verify status updated to ACCEPTED and active jobs count incremented to 3
    expect(find.text('ACCEPTED'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Mark Completed'), findsOneWidget);
  });

  testWidgets(
    'Compulsory Document Upload screen: all 4 requirements are enforced',
    (WidgetTester tester) async {
      final mockAuth = MockAuthService();
      await mockAuth.signInWithDemoAccount(UserRole.worker);
      final authNotifier = AuthNotifier(authService: mockAuth);

      await tester.pumpWidget(
        MaterialApp(
          home: WorkerDocumentUploadScreen(authNotifier: authNotifier),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify title and progress
      expect(find.text('Mandatory Document Upload'), findsOneWidget);
      expect(find.text('Verification Progress'), findsOneWidget);

      // 2. Verify all 4 compulsory requirements are present
      expect(find.textContaining('1. Profile Photo'), findsOneWidget);
      expect(find.textContaining('2. CNIC Front Side'), findsOneWidget);
      expect(find.textContaining('3. CNIC Back Side'), findsOneWidget);
      expect(
        find.textContaining('4. Police Clearance Certificate'),
        findsOneWidget,
      );

      // 3. Attempt submitting without documents triggers compulsory validation
      final submitButton = find.textContaining('Submit Documents');
      expect(submitButton, findsOneWidget);
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify mandatory validation message displays
      expect(find.textContaining('mandatory'), findsOneWidget);
    },
  );

  testWidgets(
    'Individual Worker Profile screen displays verified badges and booking CTA',
    (WidgetTester tester) async {
      final testWorker = WorkerModel(
        id: 'test_worker_1',
        userId: 'test_uid_1',
        displayName: 'Rashid Ali Ustad',
        phoneNumber: '+92 300 7654321',
        profileImageUrl: '',
        serviceCategory: 'Electrician',
        city: 'Sahiwal',
        serviceAreas: const ['Farid Town', 'Civil Lines'],
        experienceYears: 6,
        startingRate: 800,
        verificationStatus: WorkerVerificationStatus.approved,
        averageRating: 4.9,
        reviewCount: 38,
        completedJobsCount: 84,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(home: WorkerProfileScreen(initialWorker: testWorker)),
      );
      await tester.pumpAndSettle();

      // Verify worker details rendered
      expect(find.text('Rashid Ali Ustad'), findsWidgets);
      expect(find.textContaining('Electrician'), findsWidgets);
      expect(find.textContaining('6 Years Experience'), findsOneWidget);
      expect(find.textContaining('Sahiwal'), findsWidgets);

      // Verify verified trust badges
      expect(find.text('✓ NADRA CNIC Verified'), findsOneWidget);
      expect(find.text('✓ Punjab Police Cleared'), findsOneWidget);

      // Verify rates and booking CTA
      expect(find.text('Rs. 800'), findsOneWidget);
      expect(find.text('Book Service Now'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
    },
  );
}
