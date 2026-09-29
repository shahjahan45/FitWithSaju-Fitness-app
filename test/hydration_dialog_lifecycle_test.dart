import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/nutrition/data/nutrition_store.dart';
import 'package:fitwithsaju/features/nutrition/nutrition_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
      'custom hydration submit waits for dialog teardown before refresh',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const NutritionPlanScreen(),
      ),
    );

    await tester.pumpAndSettle();
    const customWaterKey = Key('hydration-custom-water-button');
    final customWaterButton = find.byKey(customWaterKey);
    final planList = find.byKey(const Key('nutrition-plan-scroll'));
    expect(planList, findsOneWidget);
    final planScrollable = find.descendant(
      of: planList,
      matching: find.byType(Scrollable),
    );
    expect(planScrollable, findsOneWidget);
    await tester.scrollUntilVisible(
      customWaterButton,
      300,
      scrollable: planScrollable,
    );
    expect(customWaterButton, findsOneWidget);
    await tester.tap(customWaterButton);
    await tester.pumpAndSettle();

    expect(find.text('Add water'), findsOneWidget);
    final amountField = find.byKey(const Key('hydration-custom-water-field'));
    final addButton = find.byKey(const Key('hydration-custom-water-add'));
    expect(amountField, findsOneWidget);
    expect(addButton, findsOneWidget);
    await tester.enterText(amountField, '300');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final total = await NutritionStore.waterTotalMl(DateTime.now());
    expect(total, 300);
    expect(find.textContaining('300 ml'), findsWidgets);
  });
}
