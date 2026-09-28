import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_catalog.dart';
import 'nutrition_models.dart';

enum NutritionPlanCatalogSource { bundled, cached, live }

class NutritionPlanCatalogSyncResult {
  final bool success;
  final int count;
  final String message;

  const NutritionPlanCatalogSyncResult({
    required this.success,
    required this.count,
    required this.message,
  });
}

class NutritionPlanCatalog {
  NutritionPlanCatalog._();

  static const _cacheKey = 'nutrition_plan_template_cache_v1';
  static const _syncedAtKey = 'nutrition_plan_template_synced_at_v1';

  static const NutritionMealPlanTemplate balancedWeek =
      NutritionMealPlanTemplate(
    id: 'balanced-week-sample',
    name: 'Balanced Week',
    description:
        'A flexible seven-day starter plan using FitWithSaju balanced meals. Four meals per day with estimated nutrition.',
    goal: 'Balanced eating',
    bundled: true,
    days: <int, List<PlannedNutritionMeal>>{
      DateTime.monday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast', recipeId: 'berry_oats', time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'chicken_rice', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'yogurt_berries', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'salmon_greens', time: '19:00'),
      ],
      DateTime.tuesday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast', recipeId: 'avocado_eggs', time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'lentil_bowl', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'apple_peanut', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'beef_quinoa', time: '19:00'),
      ],
      DateTime.wednesday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast', recipeId: 'banana_chia', time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'tuna_wrap', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'hummus_veg', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'tofu_stirfry', time: '19:00'),
      ],
      DateTime.thursday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast', recipeId: 'berry_oats', time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'chicken_rice', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'yogurt_berries', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'salmon_greens', time: '19:00'),
      ],
      DateTime.friday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast', recipeId: 'avocado_eggs', time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'lentil_bowl', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'apple_peanut', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'beef_quinoa', time: '19:00'),
      ],
      DateTime.saturday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast', recipeId: 'banana_chia', time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'tuna_wrap', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'hummus_veg', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'tofu_stirfry', time: '19:00'),
      ],
      DateTime.sunday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast', recipeId: 'berry_oats', time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'chicken_rice', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'yogurt_berries', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'salmon_greens', time: '19:00'),
      ],
    },
  );

  static const NutritionMealPlanTemplate highProteinWeek =
      NutritionMealPlanTemplate(
    id: 'high-protein-7-day',
    name: '7-Day High-Protein',
    description:
        'Four meals per day based on the supplied high-protein reference. Daily protein ranges from 190–205 g (about 196 g/day average). Protein labels follow the reference; other nutrition values are estimates pending review.',
    goal: 'Muscle gain',
    bundled: true,
    days: <int, List<PlannedNutritionMeal>>{
      DateTime.monday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast',
            recipeId: 'hp_eggs_whites_berries',
            time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'hp_chicken_rice_broccoli', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'hp_yogurt_whey_berries', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'hp_salmon_vegetables', time: '19:00'),
      ],
      DateTime.tuesday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast',
            recipeId: 'hp_protein_oatmeal_yogurt',
            time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'hp_beef_potatoes_veg', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'hp_cottage_berries_eggs', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'hp_chicken_salad', time: '19:00'),
      ],
      DateTime.wednesday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast', recipeId: 'hp_eggs_turkey_toast', time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'hp_shrimp_rice_veg', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'hp_yogurt_whey_berries', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'hp_steak_vegetables', time: '19:00'),
      ],
      DateTime.thursday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast',
            recipeId: 'hp_eggwhite_omelet_turkey',
            time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch',
            recipeId: 'hp_chicken_sweetpotato_broccoli',
            time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'hp_shake_yogurt', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'hp_whitefish_vegetables', time: '19:00'),
      ],
      DateTime.friday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast', recipeId: 'hp_pancakes_eggs', time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'hp_beef_rice_veg', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'hp_cottage_whey_berries', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'hp_salmon_salad', time: '19:00'),
      ],
      DateTime.saturday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast',
            recipeId: 'hp_eggs_whites_yogurt',
            time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch', recipeId: 'hp_steak_potatoes_veg', time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'hp_shake_cottage', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'hp_chicken_vegetables', time: '19:00'),
      ],
      DateTime.sunday: <PlannedNutritionMeal>[
        PlannedNutritionMeal(
            slot: 'Breakfast',
            recipeId: 'hp_protein_oatmeal_eggs',
            time: '08:00'),
        PlannedNutritionMeal(
            slot: 'Lunch',
            recipeId: 'hp_chicken_rice_vegetables',
            time: '13:00'),
        PlannedNutritionMeal(
            slot: 'Snack', recipeId: 'hp_yogurt_whey_fruit', time: '16:30'),
        PlannedNutritionMeal(
            slot: 'Dinner', recipeId: 'hp_shrimp_vegetables', time: '19:00'),
      ],
    },
  );

  static const List<NutritionMealPlanTemplate> bundledTemplates =
      <NutritionMealPlanTemplate>[
    highProteinWeek,
    balancedWeek,
  ];

  static List<NutritionMealPlanTemplate> _templates =
      List<NutritionMealPlanTemplate>.of(bundledTemplates);
  static final ValueNotifier<List<NutritionMealPlanTemplate>> listenable =
      ValueNotifier<List<NutritionMealPlanTemplate>>(
    List<NutritionMealPlanTemplate>.of(bundledTemplates),
  );
  static final ValueNotifier<NutritionPlanCatalogSource> source =
      ValueNotifier<NutritionPlanCatalogSource>(
          NutritionPlanCatalogSource.bundled);

  static String? lastError;
  static DateTime? lastSyncedAt;

  static List<NutritionMealPlanTemplate> get templates => _templates;

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
          .map((item) => NutritionMealPlanTemplate.fromApi(
              Map<String, dynamic>.from(item)))
          .where((template) => template.id.isNotEmpty)
          .toList(growable: false);
      if (remote.isNotEmpty) {
        _setTemplates(
            _mergeRemoteWithBundled(remote), NutritionPlanCatalogSource.cached);
      }
    } catch (_) {
      // Corrupt template cache must never block the bundled plans.
    }
  }

  static Future<NutritionPlanCatalogSyncResult> sync({String? baseUrl}) async {
    final configured = baseUrl ?? await NutritionCatalog.apiBaseUrl();
    final normalized = _normalizeBaseUrl(configured);
    if (normalized.isEmpty) {
      return const NutritionPlanCatalogSyncResult(
        success: false,
        count: 0,
        message: 'Enter your FitWithSaju API URL first.',
      );
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request =
          await client.getUrl(Uri.parse('$normalized/api/meal-plan-templates'));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response =
          await request.close().timeout(const Duration(seconds: 12));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        lastError = 'Meal-plan server returned HTTP ${response.statusCode}.';
        return NutritionPlanCatalogSyncResult(
          success: false,
          count: templates.length,
          message: lastError!,
        );
      }
      final decoded = jsonDecode(body);
      final list = decoded is Map ? decoded['data'] : decoded;
      if (list is! List) {
        throw const FormatException(
            'Meal-plan API did not return a data list.');
      }
      final remote = list
          .whereType<Map>()
          .map((item) => NutritionMealPlanTemplate.fromApi(
              Map<String, dynamic>.from(item)))
          .where((template) => template.id.isNotEmpty)
          .toList(growable: false);
      if (remote.isEmpty) {
        throw const FormatException(
            'Meal-plan API returned no published templates.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(remote.map((template) => template.toCacheJson()).toList()),
      );
      final now = DateTime.now();
      await prefs.setString(_syncedAtKey, now.toIso8601String());
      lastSyncedAt = now;
      lastError = null;
      _setTemplates(
          _mergeRemoteWithBundled(remote), NutritionPlanCatalogSource.live);
      return NutritionPlanCatalogSyncResult(
        success: true,
        count: remote.length,
        message:
            'Synced ${remote.length} published meal plans from the server.',
      );
    } on TimeoutException {
      lastError = 'The meal-plan server took too long to respond.';
    } on SocketException {
      lastError = 'Could not connect to the meal-plan server.';
    } on FormatException catch (error) {
      lastError = error.message;
    } catch (_) {
      lastError = 'Meal-plan sync failed. Bundled plans are still available.';
    } finally {
      client.close(force: true);
    }

    return NutritionPlanCatalogSyncResult(
      success: false,
      count: templates.length,
      message: lastError ?? 'Meal-plan sync failed.',
    );
  }

  static Future<void> resetToBundled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_syncedAtKey);
    lastSyncedAt = null;
    lastError = null;
    _setTemplates(
      List<NutritionMealPlanTemplate>.of(bundledTemplates),
      NutritionPlanCatalogSource.bundled,
    );
  }

  static NutritionMealPlanTemplate? byId(String id) {
    for (final template in _templates) {
      if (template.id == id) {
        return template;
      }
    }
    for (final template in bundledTemplates) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }

  static List<NutritionMealPlanTemplate> _mergeRemoteWithBundled(
    List<NutritionMealPlanTemplate> remote,
  ) {
    final result = <String, NutritionMealPlanTemplate>{
      for (final template in bundledTemplates) template.id: template,
    };
    for (final template in remote) {
      result[template.id] = template;
    }
    return result.values.toList(growable: false);
  }

  static void _setTemplates(
    List<NutritionMealPlanTemplate> value,
    NutritionPlanCatalogSource catalogSource,
  ) {
    _templates = List<NutritionMealPlanTemplate>.unmodifiable(value);
    listenable.value = _templates;
    source.value = catalogSource;
  }

  static String _normalizeBaseUrl(String input) {
    var value = input.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }
}
