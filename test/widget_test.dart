import 'package:flutter_test/flutter_test.dart';
import 'package:kaamhub/app/app.dart';
import 'package:kaamhub/core/constants/app_strings.dart';

void main() {
  testWidgets('KaamHub foundation smoke test: verifies branding and roles', (
    WidgetTester tester,
  ) async {
    // Build KaamHubApp and trigger a frame.
    await tester.pumpWidget(const KaamHubApp());
    await tester.pumpAndSettle();

    // Verify brand title and tagline are present
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);

    // Verify role cards are displayed
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Service Worker'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
  });
}
