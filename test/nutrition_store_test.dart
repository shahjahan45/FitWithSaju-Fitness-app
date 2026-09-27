import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitwithsaju/features/nutrition/data/nutrition_catalog.dart';
import 'package:fitwithsaju/features/nutrition/data/nutrition_models.dart';
import 'package:fitwithsaju/features/nutrition/data/nutrition_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('daily nutrition plan persists meal swaps', () async {
    final date = DateTime(2026, 9, 28);
    final before = await NutritionStore.planForDate(date);
    expect(before, hasLength(4));

    await NutritionStore.swapMeal(
      date: date,
      slot: 'Lunch',
      recipeId: 'lentil_bowl',
    );

    final after = await NutritionStore.planForDate(date);
    expect(
      after.firstWhere((meal) => meal.slot == 'Lunch').recipeId,
      'lentil_bowl',
    );
  });

  test('food logging rejects duplicate planned meal logs', () async {
    final date = DateTime(2026, 9, 28);
    final recipe = NutritionCatalog.byId('berry_oats')!;

    final first = await NutritionStore.logMeal(
      date: date,
      recipe: recipe,
      servings: .5,
      sourceKey: '2026-09-28:Breakfast',
    );
    final duplicate = await NutritionStore.logMeal(
      date: date,
      recipe: recipe,
      servings: 1,
      sourceKey: '2026-09-28:Breakfast',
    );

    expect(first, isTrue);
    expect(duplicate, isFalse);
    final totals = await NutritionStore.consumedTotals(date);
    expect(totals.calories, recipe.macros.calories * .5);
  });

  test('allergies are never relaxed for meal alternatives', () async {
    final current = NutritionCatalog.byId('chicken_rice')!;
    const preferences = NutritionPreferences(
      goal: 'Balanced eating',
      dietary: <String>[],
      allergies: <String>['Fish', 'Dairy'],
      cuisines: <String>[],
      budget: 'Moderate',
      prepMinutes: 30,
      units: 'Metric',
      calorieTarget: 2100,
      proteinTarget: 140,
      carbsTarget: 240,
      fatTarget: 65,
      waterTargetMl: 2500,
    );

    final alternatives = NutritionStore.compatibleAlternatives(
      current: current,
      preferences: preferences,
    );

    expect(
      alternatives.every(
        (recipe) =>
            !recipe.allergens.contains('Fish') &&
            !recipe.allergens.contains('Dairy'),
      ),
      isTrue,
    );
  });

  test('hydration entries are stored by local date', () async {
    final date = DateTime(2026, 9, 28);
    await NutritionStore.addWater(date, 250);
    await NutritionStore.addWater(date, 500);
    expect(await NutritionStore.waterTotalMl(date), 750);
    expect(await NutritionStore.waterTotalMl(date.add(const Duration(days: 1))),
        0);
  });

  test('food log portions can be corrected without losing snapshot basis',
      () async {
    final date = DateTime(2026, 9, 28);
    final recipe = NutritionCatalog.byId('berry_oats')!;
    await NutritionStore.logMeal(
      date: date,
      recipe: recipe,
      servings: .5,
      sourceKey: 'extra:portion-edit',
    );
    final log = (await NutritionStore.foodLogs(date)).single;

    await NutritionStore.updateFoodLogServings(
      log['id']!.toString(),
      1.5,
    );

    final updated = (await NutritionStore.foodLogs(date)).single;
    expect(updated['servings'], 1.5);
    final snapshot = NutritionMacros.fromJson(updated['nutrition']);
    expect(snapshot.calories, closeTo(recipe.macros.calories * 1.5, .001));
  });

  test('water and manual shopping items can be edited independently', () async {
    final date = DateTime(2026, 9, 28);
    await NutritionStore.addWater(date, 250);
    final water = (await NutritionStore.waterEntries(date)).single;
    await NutritionStore.updateWater(water['id']!.toString(), 400);
    expect(await NutritionStore.waterTotalMl(date), 400);

    await NutritionStore.addManualShoppingItem('Sparkling water');
    final manual = (await NutritionStore.manualShoppingItems()).single;
    await NutritionStore.updateManualShoppingItem(
      manual['id']!.toString(),
      'Mineral water',
    );
    expect(
      (await NutritionStore.manualShoppingItems()).single['name'],
      'Mineral water',
    );
  });
}
