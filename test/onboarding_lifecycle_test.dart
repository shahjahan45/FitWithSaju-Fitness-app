import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/onboarding/onboarding_screen.dart';
import 'package:fitwithsaju/features/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _OnboardingHarness extends StatefulWidget {
  const _OnboardingHarness();

  @override
  State<_OnboardingHarness> createState() => _OnboardingHarnessState();
}

class _OnboardingHarnessState extends State<_OnboardingHarness> {
  bool complete = false;

  @override
  Widget build(BuildContext context) {
    return complete
        ? const MainShell()
        : OnboardingScreen(
            onComplete: () => setState(() => complete = true),
          );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'onboarding can move goal to level to place to home without lifecycle errors',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const _OnboardingHarness(),
        ),
      );

      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('What are you training for?'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Where are you starting?'), findsOneWidget);
      await tester.tap(find.text('Intermediate'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Where do you usually train?'), findsOneWidget);
      await tester.tap(find.text('Start My Journey'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(MainShell), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
