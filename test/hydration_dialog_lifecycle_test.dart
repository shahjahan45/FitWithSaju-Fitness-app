import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/nutrition/data/nutrition_store.dart';
import 'package:fitwithsaju/features/nutrition/hydration_amount_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('custom hydration submit settles before store refresh',
      (tester) async {
    final date = DateTime(2026, 9, 29);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                key: const Key('open-hydration-dialog'),
                onPressed: () async {
                  final ml = await showHydrationAmountDialog(
                    context,
                    units: 'Metric',
                  );
                  if (ml != null) {
                    await NutritionStore.addWater(date, ml);
                  }
                },
                child: const Text('Add water'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-hydration-dialog')));
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('hydration-custom-water-field'));
    final add = find.byKey(const Key('hydration-custom-water-add'));
    expect(field, findsOneWidget);
    expect(add, findsOneWidget);

    await tester.enterText(field, '300');
    await tester.tap(add);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(await NutritionStore.waterTotalMl(date), 300);
    expect(find.byKey(const Key('hydration-custom-water-field')), findsNothing);
  });
}
