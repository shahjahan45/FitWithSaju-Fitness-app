import 'package:fitwithsaju/features/nutrition/data/nutrition_catalog.dart';
import 'package:fitwithsaju/features/nutrition/data/nutrition_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled nutrition catalog keeps stable recipe ids', () {
    expect(NutritionCatalog.bundledRecipes.length, 12);
    expect(NutritionCatalog.byId('berry_oats')?.name, 'Berry overnight oats');
    expect(NutritionCatalog.byId('chicken_rice')?.slot, 'Lunch');
  });

  test('recipe api model parses nutrition, ingredients, and review metadata',
      () {
    final recipe = NutritionRecipe.fromApi(<String, dynamic>{
      'id': 'api_recipe',
      'name': 'API Meal',
      'slot': 'Dinner',
      'cuisine': 'Mediterranean',
      'prep_minutes': 18,
      'yield_servings': 2,
      'serving_label': '1 plate',
      'nutrition': <String, dynamic>{
        'calories': 500,
        'protein': 40,
        'carbs': 55,
        'fat': 15,
      },
      'dietary_tags': <String>['Halal'],
      'allergens': <String>[],
      'ingredients': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'Rice',
          'quantity': 100,
          'unit': 'g',
          'category': 'Pantry',
        },
      ],
      'instructions': <String>['Cook and serve.'],
      'nutrition_provenance': 'Test fixture',
      'review_status': 'reviewed',
    });

    expect(recipe.id, 'api_recipe');
    expect(recipe.macros.protein, 40);
    expect(recipe.ingredients.single.name, 'Rice');
    expect(recipe.reviewStatus, 'reviewed');
  });
}
