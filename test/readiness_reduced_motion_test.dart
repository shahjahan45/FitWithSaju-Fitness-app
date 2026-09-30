import 'package:fitwithsaju/core/settings/app_preferences.dart';
import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/recovery/recovery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.initialize();
    await AppPreferences.setReduceMotion(true);
    await LocalStore.saveReadinessCheckIn(
      date: DateTime.now(),
      sleepQuality: 4,
      energy: 4,
      soreness: 2,
      stress: 2,
    );
  });

  testWidgets('recovery score ring renders with reduced motion enabled',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const RecoveryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('readiness-hero-card')), findsOneWidget);
    expect(find.byKey(const Key('readiness-score-ring')), findsOneWidget);
    expect(find.textContaining('/ 100'), findsOneWidget);
  });
}
