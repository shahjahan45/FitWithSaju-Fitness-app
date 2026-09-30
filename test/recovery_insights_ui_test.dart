import 'package:fitwithsaju/core/settings/app_preferences.dart';
import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/recovery/recovery_insights_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final anchorDate = DateTime(2026, 9, 30);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.initialize();
    await AppPreferences.setReduceMotion(true);
    await LocalStore.saveReadinessCheckIn(
      date: anchorDate,
      sleepQuality: 4,
      energy: 4,
      soreness: 2,
      stress: 2,
    );
  });

  testWidgets('recovery insights renders safely with reduced motion',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.light,
          home: RecoveryInsightsScreen(anchorDate: anchorDate),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recovery-insights-overview')), findsOneWidget);
    expect(
        find.byKey(const Key('weekly-recovery-review-card')), findsOneWidget);
    expect(find.textContaining('fitness guidance'), findsWidgets);
    expect(tester.takeException(), isNull);

    // The chart sits below the initial test viewport and ListView children are
    // built lazily. Scroll until that section is materialized before asserting
    // it exists; this keeps the test stable across Flutter viewport/cache changes.
    final list = find.byKey(const Key('recovery-insights-scroll'));
    expect(list, findsOneWidget);
    for (var attempt = 0;
        attempt < 5 &&
            find.byKey(const Key('recovery-insights-chart')).evaluate().isEmpty;
        attempt++) {
      await tester.drag(list, const Offset(0, -220));
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const Key('recovery-insights-chart')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
