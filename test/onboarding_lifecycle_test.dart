import 'package:fitwithsaju/app/app_root.dart';
import 'package:fitwithsaju/core/settings/app_preferences.dart';
import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AppPreferences.initialize();
  });

  testWidgets(
    'startup and onboarding switch phases without deactivating the onboarding tree',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const AppRoot(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump();

      var stack = tester.widget<IndexedStack>(
        find.byKey(const ValueKey('app-phase-stack')),
      );
      expect(stack.index, 1);

      await tester.tap(find.text('Get Started'));
      await tester.pump();
      expect(find.text('What are you training for?'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Where are you starting?'), findsOneWidget);

      await tester.tap(find.text('Intermediate'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Where do you usually train?'), findsOneWidget);

      await tester.tap(find.text('Start My Journey'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      stack = tester.widget<IndexedStack>(
        find.byKey(const ValueKey('app-phase-stack')),
      );
      expect(stack.index, 2);
      expect(
        find.byType(OnboardingScreen, skipOffstage: false),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
