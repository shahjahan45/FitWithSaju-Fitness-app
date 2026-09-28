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
    return remote.map((recipe) {
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
    }).toList(growable: false);
  }

  static String _normalizeBaseUrl(String input) {
    var value = input.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }
}
