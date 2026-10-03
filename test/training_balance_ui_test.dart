import 'package:fitwithsaju/core/settings/app_preferences.dart';
import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/recovery/training_balance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final anchorDate = DateTime(2026, 10, 3);

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

  testWidgets('training balance renders safely with reduced motion',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          theme: AppTheme.light,
          home: TrainingBalanceScreen(anchorDate: anchorDate),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('training-balance-hero')), findsOneWidget);
    expect(
      find.byKey(const Key('training-balance-recovery-context')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    final list = find.byKey(const Key('training-balance-scroll'));
    expect(list, findsOneWidget);
    for (var attempt = 0;
        attempt < 4 &&
            find
                .byKey(const Key('training-balance-plan-preview'))
                .evaluate()
                .isEmpty;
        attempt++) {
      await tester.drag(list, const Offset(0, -200));
      await tester.pumpAndSettle();
    }

    expect(
        find.byKey(const Key('training-balance-plan-preview')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
