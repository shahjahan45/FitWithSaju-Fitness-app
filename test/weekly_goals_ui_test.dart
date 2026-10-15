import 'package:fitwithsaju/core/settings/app_preferences.dart';
import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/goals/weekly_goals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AppPreferences.initialize();
    await AppPreferences.setReduceMotion(true);
  });

  testWidgets('weekly goals screen is reduced-motion safe and opens editor', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          disableAnimations: true,
          viewPadding: EdgeInsets.only(bottom: 24),
        ),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const WeeklyGoalsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weekly-goals-scroll')), findsOneWidget);
    expect(find.byKey(const Key('weekly-goals-hero')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('weekly-goals-edit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('weekly-goals-save-targets')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
