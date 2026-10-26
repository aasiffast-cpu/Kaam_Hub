import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaamhub/app/app.dart';
import 'package:kaamhub/app/routes.dart';
import 'package:kaamhub/core/localization/app_locale_notifier.dart';
import 'package:kaamhub/core/localization/app_localizations.dart';
import 'package:kaamhub/features/splash/splash_screen.dart';

void main() {
  group('Localization and RTL tests', () {
    test('LocaleNotifier toggles between English and Urdu with correct RTL direction', () {
      final notifier = LocaleNotifier();
      notifier.setLanguage('en');
      expect(notifier.isUrdu, isFalse);
      expect(notifier.textDirection, TextDirection.ltr);

      notifier.toggleLanguage();
      expect(notifier.isUrdu, isTrue);
      expect(notifier.textDirection, TextDirection.rtl);

      notifier.setLanguage('en');
      expect(notifier.isUrdu, isFalse);
    });

    test('AppLocalizations provides translated bilingual strings', () {
      final enLoc = AppLocalizations(const Locale('en'));
      expect(enLoc.appName, 'KaamHub');
      expect(enLoc.appTagline, 'Verified Local Service Experts');
      expect(enLoc.currencyPkr, 'PKR');

      final urLoc = AppLocalizations(const Locale('ur'));
      expect(urLoc.appName, 'کام ہب');
      expect(urLoc.appTagline, 'قابل بھروسہ مقامی ہنر مند');
      expect(urLoc.currencyPkr, 'روپے');
    });
  });

  group('Splash Screen tests', () {
    testWidgets('SplashScreen displays brand mark, English/Urdu buttons, and navigates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const KaamHubApp(initialRoute: AppRoutes.splash),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('KaamHub'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('اردو'), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);

      // Tap Urdu language button
      await tester.tap(find.text('اردو'));
      await tester.pumpAndSettle();

      expect(LocaleNotifier().isUrdu, isTrue);

      // Tap Get Started button to navigate
      final getStartedFinder = find.textContaining('شروع کریں');
      expect(getStartedFinder, findsOneWidget);
      await tester.tap(getStartedFinder);
      await tester.pumpAndSettle();

      // Reset locale back to English
      LocaleNotifier().setLanguage('en');
    });
  });
}
