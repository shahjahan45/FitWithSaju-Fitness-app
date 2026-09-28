import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_models.dart';

enum NutritionCatalogSource { bundled, cached, live }

class NutritionCatalogSyncResult {
  final bool success;
  final int count;
  final String message;

  const NutritionCatalogSyncResult({
    required this.success,
    required this.count,
    required this.message,
  });
}

class NutritionCatalog {
  NutritionCatalog._();

  static const _cacheKey = 'nutrition_recipe_catalog_cache_v1';
  static const _apiBaseUrlKey = 'exercise_api_base_url_v1';
  static const _syncedAtKey = 'nutrition_recipe_catalog_synced_at_v1';

  static const List<NutritionRecipe> bundledRecipes = [
    NutritionRecipe(
      id: 'berry_oats',
      name: 'Berry overnight oats',
      slot: 'Breakfast',
      artwork: '🥣',
      artworkAsset: 'assets/nutrition/oats.png',
      cuisine: 'International',
      prepMinutes: 10,
      yieldServings: 1,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 420, protein: 25, carbs: 53, fat: 12),
      dietaryTags: ['Vegetarian'],
      allergens: ['Dairy', 'Gluten'],
      ingredients: [
        NutritionIngredient(
            name: 'Rolled oats', quantity: 60, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 120, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Mixed berries',
            quantity: 100,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Chia seeds', quantity: 12, unit: 'g', category: 'Pantry'),
      ],
      instructions: [
        'Mix oats, yogurt, chia seeds, and a splash of water in a jar.',
        'Cover and refrigerate for at least 4 hours or overnight.',
        'Top with berries immediately before eating.',
      ],
    ),
    NutritionRecipe(
      id: 'avocado_eggs',
      name: 'Avocado eggs & toast',
      slot: 'Breakfast',
      artwork: '🥑',
      cuisine: 'International',
      prepMinutes: 12,
      yieldServings: 1,
      servingLabel: '1 plate',
      macros: NutritionMacros(calories: 445, protein: 24, carbs: 38, fat: 23),
      dietaryTags: ['Vegetarian'],
      allergens: ['Eggs', 'Gluten'],
      ingredients: [
        NutritionIngredient(
            name: 'Eggs', quantity: 2, unit: 'pcs', category: 'Protein'),
        NutritionIngredient(
            name: 'Whole-grain bread',
            quantity: 2,
            unit: 'slices',
            category: 'Bakery'),
        NutritionIngredient(
            name: 'Avocado', quantity: 0.5, unit: 'pcs', category: 'Produce'),
        NutritionIngredient(
            name: 'Tomato', quantity: 80, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Toast the bread and mash avocado over the slices.',
        'Cook eggs to your preferred doneness.',
        'Serve with sliced tomato and season to taste.',
      ],
    ),
    NutritionRecipe(
      id: 'banana_chia',
      name: 'Banana chia breakfast pot',
      slot: 'Breakfast',
      artwork: '🍌',
      cuisine: 'International',
      prepMinutes: 8,
      yieldServings: 1,
      servingLabel: '1 pot',
      macros: NutritionMacros(calories: 380, protein: 17, carbs: 52, fat: 13),
      dietaryTags: ['Vegetarian', 'Gluten-free'],
      allergens: ['Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Banana', quantity: 1, unit: 'pcs', category: 'Produce'),
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 150, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Chia seeds', quantity: 18, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Honey', quantity: 8, unit: 'g', category: 'Pantry'),
      ],
      instructions: [
        'Slice half the banana and mash the rest.',
        'Mix mashed banana with yogurt and chia seeds.',
        'Top with banana slices and a small drizzle of honey.',
      ],
    ),
    NutritionRecipe(
      id: 'chicken_rice',
      name: 'Grilled chicken rice bowl',
      slot: 'Lunch',
      artwork: '🍗',
      artworkAsset: 'assets/nutrition/meal.png',
      cuisine: 'Mediterranean',
      prepMinutes: 25,
      yieldServings: 2,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 560, protein: 46, carbs: 64, fat: 13),
      dietaryTags: ['Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Chicken breast',
            quantity: 300,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Basmati rice', quantity: 160, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Cucumber', quantity: 140, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Tomato', quantity: 140, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 16, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Season and grill chicken until fully cooked, then rest and slice.',
        'Cook rice according to package instructions.',
        'Divide rice, chicken, cucumber, and tomato into bowls.',
        'Finish with olive oil, lemon, and herbs.',
      ],
    ),
    NutritionRecipe(
      id: 'lentil_bowl',
      name: 'Lentil tahini power bowl',
      slot: 'Lunch',
      artwork: '🥗',
      cuisine: 'Middle Eastern',
      prepMinutes: 20,
      yieldServings: 2,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 510, protein: 24, carbs: 66, fat: 18),
      dietaryTags: ['Vegetarian', 'Vegan', 'Gluten-free'],
      allergens: ['Sesame'],
      ingredients: [
        NutritionIngredient(
            name: 'Cooked lentils',
            quantity: 320,
            unit: 'g',
            category: 'Pantry'),
        NutritionIngredient(
            name: 'Quinoa', quantity: 120, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Spinach', quantity: 120, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Tahini', quantity: 32, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Carrot', quantity: 140, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Cook quinoa and allow it to cool slightly.',
        'Warm lentils and prepare the vegetables.',
        'Assemble bowls and drizzle with lemon-tahini dressing.',
      ],
    ),
    NutritionRecipe(
      id: 'tuna_wrap',
      name: 'Tuna crunch wrap',
      slot: 'Lunch',
      artwork: '🌯',
      cuisine: 'International',
      prepMinutes: 12,
      yieldServings: 1,
      servingLabel: '1 wrap',
      macros: NutritionMacros(calories: 495, protein: 39, carbs: 49, fat: 16),
      dietaryTags: ['Halal'],
      allergens: ['Fish', 'Gluten', 'Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Tuna', quantity: 120, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Whole-grain wrap',
            quantity: 1,
            unit: 'pcs',
            category: 'Bakery'),
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 35, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Lettuce', quantity: 50, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Cucumber', quantity: 60, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Mix tuna with yogurt and seasoning.',
        'Layer lettuce, cucumber, and tuna onto the wrap.',
        'Fold tightly and serve immediately.',
      ],
    ),
    NutritionRecipe(
      id: 'salmon_greens',
      name: 'Herb salmon & greens',
      slot: 'Dinner',
      artwork: '🐟',
      artworkAsset: 'assets/nutrition/salmon.png',
      cuisine: 'Mediterranean',
      prepMinutes: 28,
      yieldServings: 2,
      servingLabel: '1 plate',
      macros: NutritionMacros(calories: 585, protein: 43, carbs: 42, fat: 27),
      dietaryTags: ['Gluten-free'],
      allergens: ['Fish'],
      ingredients: [
        NutritionIngredient(
            name: 'Salmon fillet',
            quantity: 300,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Baby potatoes',
            quantity: 360,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Green beans', quantity: 240, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 18, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Roast potatoes until golden and tender.',
        'Season salmon with herbs and bake until cooked through.',
        'Steam green beans and plate with salmon and potatoes.',
      ],
    ),
    NutritionRecipe(
      id: 'beef_quinoa',
      name: 'Lean beef quinoa plate',
      slot: 'Dinner',
      artwork: '🥩',
      cuisine: 'International',
      prepMinutes: 30,
      yieldServings: 2,
      servingLabel: '1 plate',
      macros: NutritionMacros(calories: 610, protein: 48, carbs: 55, fat: 22),
      dietaryTags: ['Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Lean beef', quantity: 300, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Quinoa', quantity: 150, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Bell pepper', quantity: 180, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Broccoli', quantity: 220, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Cook quinoa according to package instructions.',
        'Sear seasoned beef and rest before slicing.',
        'Sauté vegetables until tender-crisp and serve together.',
      ],
    ),
    NutritionRecipe(
      id: 'tofu_stirfry',
      name: 'Ginger tofu stir-fry',
      slot: 'Dinner',
      artwork: '🍲',
      cuisine: 'Asian',
      prepMinutes: 24,
      yieldServings: 2,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 520, protein: 29, carbs: 62, fat: 19),
      dietaryTags: ['Vegetarian', 'Vegan'],
      allergens: ['Soy'],
      ingredients: [
        NutritionIngredient(
            name: 'Firm tofu', quantity: 320, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Jasmine rice', quantity: 150, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Broccoli', quantity: 220, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Bell pepper', quantity: 160, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Soy sauce', quantity: 24, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Press and cube tofu, then sear until golden.',
        'Cook rice and stir-fry the vegetables.',
        'Add tofu, ginger, and sauce; toss briefly and serve.',
      ],
    ),
    NutritionRecipe(
      id: 'yogurt_berries',
      name: 'Greek yogurt & berries',
      slot: 'Snack',
      artwork: '🫐',
      artworkAsset: 'assets/nutrition/yogurt.png',
      cuisine: 'International',
      prepMinutes: 3,
      yieldServings: 1,
      servingLabel: '1 bowl',
      macros: NutritionMacros(calories: 215, protein: 20, carbs: 27, fat: 4),
      dietaryTags: ['Vegetarian', 'Gluten-free'],
      allergens: ['Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 180, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Mixed berries',
            quantity: 100,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Honey', quantity: 8, unit: 'g', category: 'Pantry'),
      ],
      instructions: [
        'Add yogurt to a bowl, top with berries, and drizzle with honey.'
      ],
    ),
    NutritionRecipe(
      id: 'apple_peanut',
      name: 'Apple & peanut snack',
      slot: 'Snack',
      artwork: '🍎',
      cuisine: 'International',
      prepMinutes: 3,
      yieldServings: 1,
      servingLabel: '1 snack',
      macros: NutritionMacros(calories: 235, protein: 7, carbs: 31, fat: 11),
      dietaryTags: ['Vegetarian', 'Vegan', 'Gluten-free'],
      allergens: ['Peanuts'],
      ingredients: [
        NutritionIngredient(
            name: 'Apple', quantity: 1, unit: 'pcs', category: 'Produce'),
        NutritionIngredient(
            name: 'Peanut butter', quantity: 24, unit: 'g', category: 'Pantry'),
      ],
      instructions: ['Slice the apple and serve with measured peanut butter.'],
    ),
    NutritionRecipe(
      id: 'hummus_veg',
      name: 'Hummus veggie snack box',
      slot: 'Snack',
      artwork: '🥕',
      cuisine: 'Middle Eastern',
      prepMinutes: 5,
      yieldServings: 1,
      servingLabel: '1 box',
      macros: NutritionMacros(calories: 225, protein: 8, carbs: 28, fat: 10),
      dietaryTags: ['Vegetarian', 'Vegan', 'Gluten-free'],
      allergens: ['Sesame'],
      ingredients: [
        NutritionIngredient(
            name: 'Hummus', quantity: 65, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Carrot', quantity: 100, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Cucumber', quantity: 100, unit: 'g', category: 'Produce'),
      ],
      instructions: ['Cut vegetables into sticks and serve with hummus.'],
    ),
    NutritionRecipe(
      id: 'hp_eggs_whites_berries',
      name: 'Eggs, egg whites & berries',
      slot: 'Breakfast',
      artwork: '🍳',
      cuisine: 'International',
      prepMinutes: 12,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 430, protein: 40, carbs: 32, fat: 15),
      dietaryTags: ['High-protein', 'Gluten-free'],
      allergens: ['Eggs'],
      ingredients: [
        NutritionIngredient(
            name: 'Eggs', quantity: 3, unit: 'pcs', category: 'Protein'),
        NutritionIngredient(
            name: 'Egg whites', quantity: 240, unit: 'ml', category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed berries',
            quantity: 120,
            unit: 'g',
            category: 'Produce'),
      ],
      instructions: [
        'Scramble the eggs and egg whites until fully cooked.',
        'Serve with fresh berries.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_chicken_rice_broccoli',
      name: 'Chicken, rice & broccoli',
      slot: 'Lunch',
      artwork: '🍗',
      cuisine: 'International',
      prepMinutes: 25,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 620, protein: 55, carbs: 72, fat: 12),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Chicken breast',
            quantity: 170,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Basmati rice', quantity: 180, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Broccoli', quantity: 180, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 8, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Season and cook the chicken thoroughly.',
        'Cook rice and steam broccoli.',
        'Serve together with measured olive oil.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_yogurt_whey_berries',
      name: 'Greek yogurt, whey & berries',
      slot: 'Snack',
      artwork: '🫐',
      cuisine: 'International',
      prepMinutes: 4,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 330, protein: 45, carbs: 30, fat: 5),
      dietaryTags: ['High-protein', 'Vegetarian', 'Gluten-free'],
      allergens: ['Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 250, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Whey protein', quantity: 30, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed berries',
            quantity: 100,
            unit: 'g',
            category: 'Produce'),
      ],
      instructions: [
        'Stir whey into yogurt until smooth.',
        'Top with berries.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_salmon_vegetables',
      name: 'Salmon & vegetables',
      slot: 'Dinner',
      artwork: '🐟',
      cuisine: 'International',
      prepMinutes: 25,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 560, protein: 50, carbs: 22, fat: 28),
      dietaryTags: ['High-protein', 'Gluten-free'],
      allergens: ['Fish'],
      ingredients: [
        NutritionIngredient(
            name: 'Salmon fillet',
            quantity: 200,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 250,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 8, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Season salmon and bake or pan-sear until cooked.',
        'Cook vegetables until tender-crisp.',
        'Serve together.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_protein_oatmeal_yogurt',
      name: 'Protein oatmeal & Greek yogurt',
      slot: 'Breakfast',
      artwork: '🥣',
      cuisine: 'International',
      prepMinutes: 8,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 520, protein: 50, carbs: 60, fat: 10),
      dietaryTags: ['High-protein', 'Vegetarian'],
      allergens: ['Dairy', 'Gluten'],
      ingredients: [
        NutritionIngredient(
            name: 'Rolled oats', quantity: 70, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Whey protein', quantity: 45, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 180, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Banana', quantity: 0.5, unit: 'pcs', category: 'Produce'),
      ],
      instructions: [
        'Cook oats with water or milk.',
        'Stir in whey after removing from heat.',
        'Serve with Greek yogurt and banana.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_beef_potatoes_veg',
      name: 'Lean beef, potatoes & vegetables',
      slot: 'Lunch',
      artwork: '🥩',
      cuisine: 'International',
      prepMinutes: 30,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 610, protein: 45, carbs: 55, fat: 22),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Lean ground beef',
            quantity: 170,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Potatoes', quantity: 280, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 180,
            unit: 'g',
            category: 'Produce'),
      ],
      instructions: [
        'Cook lean beef thoroughly.',
        'Roast or boil potatoes.',
        'Cook vegetables and serve together.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_cottage_berries_eggs',
      name: 'Cottage cheese, berries & eggs',
      slot: 'Snack',
      artwork: '🧀',
      cuisine: 'International',
      prepMinutes: 10,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 380, protein: 40, carbs: 25, fat: 14),
      dietaryTags: ['High-protein', 'Vegetarian', 'Gluten-free'],
      allergens: ['Dairy', 'Eggs'],
      ingredients: [
        NutritionIngredient(
            name: 'Cottage cheese',
            quantity: 220,
            unit: 'g',
            category: 'Dairy'),
        NutritionIngredient(
            name: 'Mixed berries',
            quantity: 100,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Eggs', quantity: 2, unit: 'pcs', category: 'Protein'),
      ],
      instructions: [
        'Cook eggs to preference.',
        'Serve with cottage cheese and berries.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_chicken_salad',
      name: 'Chicken breast & salad',
      slot: 'Dinner',
      artwork: '🥗',
      cuisine: 'International',
      prepMinutes: 20,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 520, protein: 60, carbs: 18, fat: 18),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Chicken breast',
            quantity: 200,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed salad greens',
            quantity: 180,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Tomato', quantity: 100, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 10, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Grill chicken until fully cooked.',
        'Toss salad vegetables with olive oil and seasoning.',
        'Slice chicken and serve over salad.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_eggs_turkey_toast',
      name: 'Eggs, egg whites, turkey & toast',
      slot: 'Breakfast',
      artwork: '🍳',
      cuisine: 'International',
      prepMinutes: 15,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 540, protein: 50, carbs: 38, fat: 22),
      dietaryTags: ['High-protein', 'Halal'],
      allergens: ['Eggs', 'Gluten'],
      ingredients: [
        NutritionIngredient(
            name: 'Eggs', quantity: 3, unit: 'pcs', category: 'Protein'),
        NutritionIngredient(
            name: 'Egg whites', quantity: 240, unit: 'ml', category: 'Protein'),
        NutritionIngredient(
            name: 'Turkey breast slices',
            quantity: 100,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Whole-grain bread',
            quantity: 2,
            unit: 'slices',
            category: 'Bakery'),
      ],
      instructions: [
        'Cook eggs and egg whites.',
        'Warm turkey slices.',
        'Serve with toasted bread.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_shrimp_rice_veg',
      name: 'Shrimp, rice & vegetables',
      slot: 'Lunch',
      artwork: '🍤',
      cuisine: 'International',
      prepMinutes: 22,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 560, protein: 45, carbs: 65, fat: 10),
      dietaryTags: ['High-protein', 'Gluten-free'],
      allergens: ['Shellfish'],
      ingredients: [
        NutritionIngredient(
            name: 'Shrimp', quantity: 200, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Basmati rice', quantity: 180, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 180,
            unit: 'g',
            category: 'Produce'),
      ],
      instructions: [
        'Cook rice.',
        'Sauté shrimp until opaque and fully cooked.',
        'Add vegetables and serve with rice.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_steak_vegetables',
      name: 'Lean steak & vegetables',
      slot: 'Dinner',
      artwork: '🥩',
      cuisine: 'International',
      prepMinutes: 25,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 570, protein: 55, carbs: 20, fat: 25),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Lean steak', quantity: 200, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 250,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 8, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Season and cook steak to a safe internal temperature.',
        'Cook vegetables until tender.',
        'Rest steak before slicing.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_eggwhite_omelet_turkey',
      name: 'Egg-white omelet, eggs & turkey',
      slot: 'Breakfast',
      artwork: '🥚',
      cuisine: 'International',
      prepMinutes: 15,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 500, protein: 50, carbs: 15, fat: 25),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: ['Eggs'],
      ingredients: [
        NutritionIngredient(
            name: 'Egg whites', quantity: 250, unit: 'ml', category: 'Protein'),
        NutritionIngredient(
            name: 'Eggs', quantity: 3, unit: 'pcs', category: 'Protein'),
        NutritionIngredient(
            name: 'Turkey breast slices',
            quantity: 100,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Spinach', quantity: 80, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Cook spinach briefly.',
        'Add egg whites and eggs to form an omelet.',
        'Fill with warmed turkey and fold.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_chicken_sweetpotato_broccoli',
      name: 'Chicken, sweet potato & broccoli',
      slot: 'Lunch',
      artwork: '🍗',
      cuisine: 'International',
      prepMinutes: 28,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 620, protein: 60, carbs: 60, fat: 15),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Chicken breast',
            quantity: 200,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Sweet potato',
            quantity: 300,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Broccoli', quantity: 180, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 8, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Roast sweet potato.',
        'Cook chicken thoroughly.',
        'Steam broccoli and serve together.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_shake_yogurt',
      name: 'Protein shake & Greek yogurt',
      slot: 'Snack',
      artwork: '🥤',
      cuisine: 'International',
      prepMinutes: 3,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 300, protein: 45, carbs: 20, fat: 5),
      dietaryTags: ['High-protein', 'Vegetarian', 'Gluten-free'],
      allergens: ['Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Whey protein', quantity: 40, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 200, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Water', quantity: 300, unit: 'ml', category: 'Beverages'),
      ],
      instructions: [
        'Shake whey with cold water.',
        'Serve with Greek yogurt.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_whitefish_vegetables',
      name: 'White fish & vegetables',
      slot: 'Dinner',
      artwork: '🐟',
      cuisine: 'International',
      prepMinutes: 22,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 470, protein: 45, carbs: 25, fat: 18),
      dietaryTags: ['High-protein', 'Gluten-free'],
      allergens: ['Fish'],
      ingredients: [
        NutritionIngredient(
            name: 'White fish fillet',
            quantity: 210,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 250,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 10, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Season and bake fish until opaque and flaky.',
        'Cook vegetables and serve alongside.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_pancakes_eggs',
      name: 'Protein pancakes & eggs',
      slot: 'Breakfast',
      artwork: '🥞',
      cuisine: 'International',
      prepMinutes: 18,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 520, protein: 45, carbs: 55, fat: 15),
      dietaryTags: ['High-protein', 'Vegetarian'],
      allergens: ['Eggs', 'Dairy', 'Gluten'],
      ingredients: [
        NutritionIngredient(
            name: 'Protein pancake mix',
            quantity: 90,
            unit: 'g',
            category: 'Pantry'),
        NutritionIngredient(
            name: 'Whey protein', quantity: 25, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Eggs', quantity: 2, unit: 'pcs', category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed berries',
            quantity: 80,
            unit: 'g',
            category: 'Produce'),
      ],
      instructions: [
        'Prepare pancake batter with protein powder.',
        'Cook pancakes on a non-stick pan.',
        'Serve with cooked eggs and berries.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_beef_rice_veg',
      name: 'Lean beef, rice & vegetables',
      slot: 'Lunch',
      artwork: '🥩',
      cuisine: 'International',
      prepMinutes: 28,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 640, protein: 50, carbs: 65, fat: 20),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Lean ground beef',
            quantity: 190,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Basmati rice', quantity: 180, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 180,
            unit: 'g',
            category: 'Produce'),
      ],
      instructions: [
        'Cook rice.',
        'Cook beef thoroughly and drain excess fat.',
        'Serve with vegetables and rice.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_cottage_whey_berries',
      name: 'Cottage cheese, whey & berries',
      slot: 'Snack',
      artwork: '🧀',
      cuisine: 'International',
      prepMinutes: 4,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 390, protein: 45, carbs: 28, fat: 12),
      dietaryTags: ['High-protein', 'Vegetarian', 'Gluten-free'],
      allergens: ['Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Cottage cheese',
            quantity: 220,
            unit: 'g',
            category: 'Dairy'),
        NutritionIngredient(
            name: 'Whey protein', quantity: 25, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed berries',
            quantity: 100,
            unit: 'g',
            category: 'Produce'),
      ],
      instructions: [
        'Stir whey into cottage cheese.',
        'Top with berries.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_salmon_salad',
      name: 'Salmon & salad',
      slot: 'Dinner',
      artwork: '🐟',
      cuisine: 'International',
      prepMinutes: 22,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 550, protein: 50, carbs: 20, fat: 28),
      dietaryTags: ['High-protein', 'Gluten-free'],
      allergens: ['Fish'],
      ingredients: [
        NutritionIngredient(
            name: 'Salmon fillet',
            quantity: 200,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed salad greens',
            quantity: 180,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Cucumber', quantity: 100, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 8, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Cook salmon until done.',
        'Toss salad with vegetables and olive oil.',
        'Serve salmon over salad.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_eggs_whites_yogurt',
      name: 'Eggs, egg whites & Greek yogurt',
      slot: 'Breakfast',
      artwork: '🍳',
      cuisine: 'International',
      prepMinutes: 12,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 470, protein: 45, carbs: 20, fat: 22),
      dietaryTags: ['High-protein', 'Vegetarian', 'Gluten-free'],
      allergens: ['Eggs', 'Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Eggs', quantity: 3, unit: 'pcs', category: 'Protein'),
        NutritionIngredient(
            name: 'Egg whites', quantity: 240, unit: 'ml', category: 'Protein'),
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 180, unit: 'g', category: 'Dairy'),
      ],
      instructions: [
        'Cook eggs and egg whites.',
        'Serve with Greek yogurt.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_steak_potatoes_veg',
      name: 'Steak, potatoes & vegetables',
      slot: 'Lunch',
      artwork: '🥩',
      cuisine: 'International',
      prepMinutes: 30,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 630, protein: 55, carbs: 50, fat: 22),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Lean steak', quantity: 200, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Potatoes', quantity: 260, unit: 'g', category: 'Produce'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 180,
            unit: 'g',
            category: 'Produce'),
      ],
      instructions: [
        'Cook steak to a safe internal temperature.',
        'Roast potatoes and vegetables.',
        'Rest and slice steak before serving.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_shake_cottage',
      name: 'Protein shake & cottage cheese',
      slot: 'Snack',
      artwork: '🥤',
      cuisine: 'International',
      prepMinutes: 3,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 320, protein: 45, carbs: 18, fat: 8),
      dietaryTags: ['High-protein', 'Vegetarian', 'Gluten-free'],
      allergens: ['Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Whey protein', quantity: 35, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Cottage cheese',
            quantity: 200,
            unit: 'g',
            category: 'Dairy'),
        NutritionIngredient(
            name: 'Water', quantity: 300, unit: 'ml', category: 'Beverages'),
      ],
      instructions: [
        'Shake whey with water.',
        'Serve with cottage cheese.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_chicken_vegetables',
      name: 'Chicken breast & vegetables',
      slot: 'Dinner',
      artwork: '🍗',
      cuisine: 'International',
      prepMinutes: 22,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 530, protein: 60, carbs: 20, fat: 17),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Chicken breast',
            quantity: 210,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 280,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 8, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Cook chicken thoroughly.',
        'Cook vegetables and serve alongside.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_protein_oatmeal_eggs',
      name: 'Protein oatmeal & eggs',
      slot: 'Breakfast',
      artwork: '🥣',
      cuisine: 'International',
      prepMinutes: 12,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 500, protein: 50, carbs: 50, fat: 12),
      dietaryTags: ['High-protein'],
      allergens: ['Eggs', 'Dairy', 'Gluten'],
      ingredients: [
        NutritionIngredient(
            name: 'Rolled oats', quantity: 65, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Whey protein', quantity: 40, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Eggs', quantity: 2, unit: 'pcs', category: 'Protein'),
      ],
      instructions: [
        'Cook oats.',
        'Stir in whey after removing from heat.',
        'Serve with cooked eggs.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_chicken_rice_vegetables',
      name: 'Chicken, rice & vegetables',
      slot: 'Lunch',
      artwork: '🍗',
      cuisine: 'International',
      prepMinutes: 25,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 650, protein: 60, carbs: 70, fat: 12),
      dietaryTags: ['High-protein', 'Halal', 'Gluten-free'],
      allergens: [],
      ingredients: [
        NutritionIngredient(
            name: 'Chicken breast',
            quantity: 210,
            unit: 'g',
            category: 'Protein'),
        NutritionIngredient(
            name: 'Basmati rice', quantity: 190, unit: 'g', category: 'Pantry'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 180,
            unit: 'g',
            category: 'Produce'),
      ],
      instructions: [
        'Cook rice.',
        'Cook chicken thoroughly.',
        'Cook vegetables and serve together.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_yogurt_whey_fruit',
      name: 'Greek yogurt, whey & fruit',
      slot: 'Snack',
      artwork: '🫐',
      cuisine: 'International',
      prepMinutes: 4,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 320, protein: 45, carbs: 30, fat: 4),
      dietaryTags: ['High-protein', 'Vegetarian', 'Gluten-free'],
      allergens: ['Dairy'],
      ingredients: [
        NutritionIngredient(
            name: 'Greek yogurt', quantity: 250, unit: 'g', category: 'Dairy'),
        NutritionIngredient(
            name: 'Whey protein', quantity: 30, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Fresh fruit', quantity: 120, unit: 'g', category: 'Produce'),
      ],
      instructions: [
        'Stir whey into yogurt.',
        'Top with chopped fruit.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
    NutritionRecipe(
      id: 'hp_shrimp_vegetables',
      name: 'Shrimp & vegetables',
      slot: 'Dinner',
      artwork: '🍤',
      cuisine: 'International',
      prepMinutes: 20,
      yieldServings: 1,
      servingLabel: '1 serving',
      macros: NutritionMacros(calories: 480, protein: 45, carbs: 22, fat: 16),
      dietaryTags: ['High-protein', 'Gluten-free'],
      allergens: ['Shellfish'],
      ingredients: [
        NutritionIngredient(
            name: 'Shrimp', quantity: 210, unit: 'g', category: 'Protein'),
        NutritionIngredient(
            name: 'Mixed vegetables',
            quantity: 280,
            unit: 'g',
            category: 'Produce'),
        NutritionIngredient(
            name: 'Olive oil', quantity: 8, unit: 'ml', category: 'Pantry'),
      ],
      instructions: [
        'Sauté shrimp until opaque and fully cooked.',
        'Cook vegetables and serve together.',
      ],
      nutritionProvenance:
          'High-protein reference plan: protein value follows the supplied plan; calories, carbs, and fats are FitWithSaju estimates pending nutrition review.',
      reviewStatus: 'unreviewed',
    ),
  ];

  static List<NutritionRecipe> _recipes =
      List<NutritionRecipe>.of(bundledRecipes);
  static final ValueNotifier<List<NutritionRecipe>> listenable =
      ValueNotifier<List<NutritionRecipe>>(
          List<NutritionRecipe>.of(bundledRecipes));
  static final ValueNotifier<NutritionCatalogSource> source =
      ValueNotifier<NutritionCatalogSource>(NutritionCatalogSource.bundled);

  static String? lastError;
  static DateTime? lastSyncedAt;

  static List<NutritionRecipe> get recipes => _recipes;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    final syncedAt = prefs.getString(_syncedAtKey);
    if (syncedAt != null) {
      lastSyncedAt = DateTime.tryParse(syncedAt);
    }
    if (raw == null || raw.isEmpty) {
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }
      final remote = decoded
          .whereType<Map>()
          .map((item) =>
              NutritionRecipe.fromApi(Map<String, dynamic>.from(item)))
          .where((recipe) => recipe.id.isNotEmpty)
          .toList(growable: false);
      if (remote.isNotEmpty) {
        _setRecipes(
            _mergeRemoteWithBundled(remote), NutritionCatalogSource.cached);
      }
    } catch (_) {
      // Corrupt cache must never block the bundled nutrition catalog.
    }
  }

  static Future<String> apiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiBaseUrlKey) ?? '';
  }

  static Future<NutritionCatalogSyncResult> sync({String? baseUrl}) async {
    final configured = baseUrl ?? await apiBaseUrl();
    final normalized = _normalizeBaseUrl(configured);
    if (normalized.isEmpty) {
      return const NutritionCatalogSyncResult(
        success: false,
        count: 0,
        message: 'Enter your FitWithSaju API URL first.',
      );
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final uri = Uri.parse('$normalized/api/recipes?per_page=200');
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response =
          await request.close().timeout(const Duration(seconds: 12));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        lastError = 'Recipe server returned HTTP ${response.statusCode}.';
        return NutritionCatalogSyncResult(
          success: false,
          count: recipes.length,
          message: lastError!,
        );
      }

      final decoded = jsonDecode(body);
      final list = decoded is Map ? decoded['data'] : decoded;
      if (list is! List) {
        throw const FormatException('Recipe API did not return a data list.');
      }
      final remote = list
          .whereType<Map>()
          .map((item) =>
              NutritionRecipe.fromApi(Map<String, dynamic>.from(item)))
          .where((recipe) => recipe.id.isNotEmpty)
          .toList(growable: false);
      if (remote.isEmpty) {
        throw const FormatException(
            'Recipe API returned no published recipes.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(remote.map((recipe) => recipe.toCacheJson()).toList()),
      );
      final now = DateTime.now();
      await prefs.setString(_syncedAtKey, now.toIso8601String());
      lastSyncedAt = now;
      lastError = null;
      _setRecipes(_mergeRemoteWithBundled(remote), NutritionCatalogSource.live);
      return NutritionCatalogSyncResult(
        success: true,
        count: remote.length,
        message: 'Synced ${remote.length} published recipes from the server.',
      );
    } on TimeoutException {
      lastError = 'The recipe server took too long to respond.';
    } on SocketException {
      lastError = 'Could not connect to the recipe server.';
    } on FormatException catch (error) {
      lastError = error.message;
    } catch (_) {
      lastError =
          'Recipe sync failed. Your offline meal catalog is still available.';
    } finally {
      client.close(force: true);
    }

    return NutritionCatalogSyncResult(
      success: false,
      count: recipes.length,
      message: lastError ?? 'Recipe sync failed.',
    );
  }

  static Future<void> resetToBundled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_syncedAtKey);
    lastSyncedAt = null;
    lastError = null;
    _setRecipes(List<NutritionRecipe>.of(bundledRecipes),
        NutritionCatalogSource.bundled);
  }

  static NutritionRecipe? byId(String id) {
    for (final recipe in _recipes) {
      if (recipe.id == id) {
        return recipe;
      }
    }
    for (final recipe in bundledRecipes) {
      if (recipe.id == id) {
        return recipe;
      }
    }
    return null;
  }

  static List<NutritionRecipe> forSlot(String slot) =>
      _recipes.where((recipe) => recipe.slot == slot).toList();

  static void _setRecipes(
    List<NutritionRecipe> value,
    NutritionCatalogSource catalogSource,
  ) {
    _recipes = List<NutritionRecipe>.unmodifiable(value);
    listenable.value = _recipes;
    source.value = catalogSource;
  }

  static List<NutritionRecipe> _mergeRemoteWithBundled(
    List<NutritionRecipe> remote,
  ) {
    final bundledById = <String, NutritionRecipe>{
      for (final recipe in bundledRecipes) recipe.id: recipe,
    };
    final merged = remote.map((recipe) {
      final bundled = bundledById[recipe.id];
      if (bundled == null) {
        return recipe;
      }
      return NutritionRecipe(
        id: recipe.id,
        name: recipe.name,
        slot: recipe.slot,
        artwork: recipe.artwork == '🍽️' ? bundled.artwork : recipe.artwork,
        artworkAsset: bundled.artworkAsset,
        imageUrl: recipe.imageUrl,
        cuisine: recipe.cuisine,
        prepMinutes: recipe.prepMinutes,
        yieldServings: recipe.yieldServings,
        servingLabel: recipe.servingLabel,
        macros: recipe.macros,
        dietaryTags: recipe.dietaryTags,
        allergens: recipe.allergens,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        nutritionProvenance: recipe.nutritionProvenance,
        reviewStatus: recipe.reviewStatus,
      );
    }).toList();
    final remoteIds = remote.map((recipe) => recipe.id).toSet();
    merged.addAll(
      bundledRecipes.where((recipe) => !remoteIds.contains(recipe.id)),
    );
    return List<NutritionRecipe>.unmodifiable(merged);
  }

  static String _normalizeBaseUrl(String input) {
    var value = input.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }
}
