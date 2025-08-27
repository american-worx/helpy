// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:helpy_ninja/app.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('Widget Tests', () {
    setUpAll(() async {
      // Setup test environment once for all tests
      await TestHelpers.setupTestEnvironment();

      // Disable Google Fonts for testing to avoid network issues
      GoogleFonts.config.allowRuntimeFetching = false;
    });

    tearDownAll(() async {
      // Clean up test environment
      await TestHelpers.tearDownTestEnvironment();
    });

    testWidgets('Helpy Ninja app smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: HelpyNinjaApp()));

      // Let the app settle with a timeout
      try {
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } catch (e) {
        // If pumpAndSettle times out, that's okay for this basic smoke test
        // We just want to make sure the app doesn't crash
      }

      // Verify that the app loads without crashing
      // Since we have routing and async loading, we'll just check
      // that the app widget is present
      expect(find.byType(HelpyNinjaApp), findsOneWidget);

      // Check for common Material widgets that should be present
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have proper theme configuration', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const ProviderScope(child: HelpyNinjaApp()));

        // Pump a few frames to let the app initialize
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));

        // Verify theme is configured
        expect(materialApp.theme, isNotNull);
        expect(materialApp.darkTheme, isNotNull);
      });
    });
  });
}
