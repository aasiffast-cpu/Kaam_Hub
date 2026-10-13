import 'package:flutter_test/flutter_test.dart';
import 'package:kaamhub/app/app.dart';
import 'package:kaamhub/core/constants/app_strings.dart';
import 'package:kaamhub/models/user_role.dart';
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
    expect(find.text('Customer Experience'), findsOneWidget);
    expect(find.text('Service Worker Portal'), findsOneWidget);
  });

  testWidgets('Worker dashboard interactive test: Accept job updates state', (
    WidgetTester tester,
  ) async {
    final mockAuth = MockAuthService();
    await mockAuth.signInWithDemoAccount(UserRole.worker);
    final authNotifier = AuthNotifier(authService: mockAuth);

    await tester.pumpWidget(KaamHubApp(authNotifier: authNotifier));
    await tester.pumpAndSettle();

    // Tap into Worker Portal
    await tester.tap(find.text('Service Worker Portal'));
    await tester.pumpAndSettle();

    // Verify initial active jobs is 2
    expect(find.text('Active Jobs'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // Verify Accept Job button is present and tap it
    expect(find.text('Accept Job'), findsOneWidget);
    await tester.tap(find.text('Accept Job'));
    await tester.pumpAndSettle();

    // Verify status updated to ACCEPTED and active jobs count incremented to 3
    expect(find.text('ACCEPTED'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Mark Completed'), findsOneWidget);
  });
}
