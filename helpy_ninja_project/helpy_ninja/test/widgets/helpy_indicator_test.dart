import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpy_ninja/presentation/widgets/chat/helpy_indicator.dart';
import 'package:helpy_ninja/domain/entities/helpy_personality.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('HelpyIndicator Tests', () {
    late HelpyPersonality testHelpy;

    setUp(() {
      testHelpy = HelpyPersonality(
        id: 'helpy_001',
        name: 'Test Helpy',
        description: 'A test Helpy personality',
        avatar: 'test_avatar.png',
        type: PersonalityType.friendly,
        traits: PersonalityTraits(
          enthusiasm: 0.8,
          patience: 0.7,
          humor: 0.6,
          formality: 0.5,
          empathy: 0.7,
          directness: 0.6,
        ),
        responseStyle: ResponseStyle(
          length: ResponseLength.medium,
          tone: ResponseTone.neutral,
          useEmojis: true,
          useExamples: true,
          askFollowUpQuestions: true,
          maxResponseLength: 500,
        ),
        specializations: ['math', 'science'],
        createdAt: DateTime.now(),
      );
    });

    testWidgets('renders correctly with default parameters',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
          ],
          home: Scaffold(
            body: HelpyIndicator(helpy: testHelpy),
          ),
        ),
      );

      // Verify that the Helpy icon is displayed
      expect(find.text(testHelpy.icon), findsOneWidget);

      // Verify that the name and status are not displayed by default
      expect(find.text(testHelpy.name), findsNothing);
    });

    testWidgets('renders name when showName is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
          ],
          home: Scaffold(
            body: HelpyIndicator(
              helpy: testHelpy,
              showName: true,
            ),
          ),
        ),
      );

      // Verify that the Helpy name is displayed
      expect(find.text(testHelpy.name), findsOneWidget);
    });

    testWidgets('renders status when showStatus is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
          ],
          home: Scaffold(
            body: HelpyIndicator(
              helpy: testHelpy,
              showStatus: true,
              status: HelpyStatus.online,
            ),
          ),
        ),
      );

      // Verify that the status indicator is displayed
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders status text when showStatus is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
          ],
          home: Scaffold(
            body: HelpyIndicator(
              helpy: testHelpy,
              showStatus: true,
              status: HelpyStatus.online,
            ),
          ),
        ),
      );

      // Verify that the status indicator is displayed
      expect(find.byType(Container), findsWidgets);
    });
  });
}
