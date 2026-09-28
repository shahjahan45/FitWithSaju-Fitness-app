import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_catalog.dart';
import 'nutrition_models.dart';

class NutritionStore {
  NutritionStore._();

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static const _preferencesKey = 'nutrition_preferences_v1';
  static const _plansKey = 'nutrition_plans_v1';
  static const _logsKey = 'nutrition_food_logs_v1';
  static const _waterKey = 'nutrition_water_logs_v1';
  static const _savedKey = 'nutrition_saved_meals_v1';
  static const _selectedDateKey = 'nutrition_selected_date_v1';
  static const _shoppingCheckedKey = 'nutrition_shopping_checked_v1';
  static const _shoppingManualKey = 'nutrition_shopping_manual_v1';
  static const _activeTemplateKey = 'nutrition_active_template_v1';

  static void _notify() => changes.value++;

  static String dateKey(DateTime date) {
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime dateFromKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) {
      return DateTime.now();
    }
    return DateTime(
      int.tryParse(parts[0]) ?? DateTime.now().year,
      int.tryParse(parts[1]) ?? DateTime.now().month,
      int.tryParse(parts[2]) ?? DateTime.now().day,
    );
  }

  static Future<NutritionPreferences> preferences() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_preferencesKey);
    if (raw == null || raw.isEmpty) {
      const defaults = NutritionPreferences(
        goal: 'Balanced eating',
        dietary: <String>[],
        allergies: <String>[],
        cuisines: <String>['Middle Eastern', 'Mediterranean'],
        budget: 'Moderate',
        prepMinutes: 30,
        units: 'Metric',
        calorieTarget: 2100,
        proteinTarget: 140,
        carbsTarget: 240,
        fatTarget: 65,
        waterTargetMl: 2500,
      );
      await prefs.setString(_preferencesKey, jsonEncode(defaults.toJson()));
      return defaults;
    }
    final decoded = jsonDecode(raw);
    return NutritionPreferences.fromJson(decoded);
  }

  static Future<void> savePreferences(NutritionPreferences value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferencesKey, jsonEncode(value.toJson()));
    _notify();
  }

  static Future<DateTime> selectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_selectedDateKey);
    return raw == null ? DateTime.now() : dateFromKey(raw);
  }

  static Future<void> setSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedDateKey, dateKey(date));
    _notify();
  }

  static Future<List<PlannedNutritionMeal>> planForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final plans = _decodeMap(prefs.getString(_plansKey));
    final key = dateKey(date);
    final raw = plans[key];
    if (raw is List) {
      return raw.map(PlannedNutritionMeal.fromJson).toList();
    }

    final seeded = _defaultPlanFor(date);
    plans[key] = seeded.map((item) => item.toJson()).toList();
    await prefs.setString(_plansKey, jsonEncode(plans));
    return seeded;
  }

  static Future<void> savePlanForDate(
    DateTime date,
    List<PlannedNutritionMeal> meals,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final plans = _decodeMap(prefs.getString(_plansKey));
    plans[dateKey(date)] = meals.map((meal) => meal.toJson()).toList();
    await prefs.setString(_plansKey, jsonEncode(plans));
    _notify();
  }

  static DateTime weekStart(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return local.subtract(Duration(days: local.weekday - 1));
  }

  static Future<String?> activeTemplateIdForWeek(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final values = _decodeMap(prefs.getString(_activeTemplateKey));
    final value = values[dateKey(weekStart(date))];
    return value?.toString();
  }

  static Future<NutritionTemplateApplyResult> applyTemplate({
    required NutritionMealPlanTemplate template,
    required DateTime anchorDate,
    required NutritionPreferences preferences,
  }) async {
    final blocked = <String>[];
    final missing = <String>[];

    for (final meals in template.days.values) {
      for (final meal in meals) {
        final recipe = NutritionCatalog.byId(meal.recipeId);
        if (recipe == null) {
          missing.add(meal.recipeId);
          continue;
        }
        if (!_isRecipeCompatible(recipe, preferences)) {
          blocked.add(recipe.name);
        }
      }
    }

    if (missing.isNotEmpty) {
      return NutritionTemplateApplyResult(
        success: false,
        message:
            'This plan needs ${missing.length} meal${missing.length == 1 ? '' : 's'} that are not available in the current recipe catalog.',
        blockedMeals: missing,
      );
    }
    if (blocked.isNotEmpty) {
      return NutritionTemplateApplyResult(
        success: false,
        message:
            'This plan conflicts with your dietary preferences or allergy exclusions. FitWithSaju will not relax those restrictions automatically.',
        blockedMeals: blocked.toSet().toList(),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final plans = _decodeMap(prefs.getString(_plansKey));
    final monday = weekStart(anchorDate);
    for (var index = 0; index < 7; index++) {
      final date = monday.add(Duration(days: index));
      final meals = template.mealsForWeekday(index + 1);
      plans[dateKey(date)] = meals.map((meal) => meal.toJson()).toList();
    }
    await prefs.setString(_plansKey, jsonEncode(plans));

    final active = _decodeMap(prefs.getString(_activeTemplateKey));
    active[dateKey(monday)] = template.id;
    await prefs.setString(_activeTemplateKey, jsonEncode(active));
    _notify();

    return NutritionTemplateApplyResult(
      success: true,
      message:
          '${template.name} applied to the week of ${dateKey(monday)}. Existing food and hydration logs were preserved.',
    );
  }

  static Future<void> clearWeek(DateTime anchorDate) async {
    final prefs = await SharedPreferences.getInstance();
    final plans = _decodeMap(prefs.getString(_plansKey));
    final monday = weekStart(anchorDate);
    for (var index = 0; index < 7; index++) {
      plans.remove(dateKey(monday.add(Duration(days: index))));
    }
    await prefs.setString(_plansKey, jsonEncode(plans));
    final active = _decodeMap(prefs.getString(_activeTemplateKey));
    active.remove(dateKey(monday));
    await prefs.setString(_activeTemplateKey, jsonEncode(active));
    _notify();
  }

  static Future<void> swapMeal({
    required DateTime date,
    required String slot,
    required String recipeId,
  }) async {
    final plan = await planForDate(date);
    final index = plan.indexWhere((meal) => meal.slot == slot);
    if (index < 0) {
      return;
    }
    final current = plan[index];
    plan[index] = PlannedNutritionMeal(
      slot: current.slot,
      recipeId: recipeId,
      time: current.time,
      servings: current.servings,
    );
    await savePlanForDate(date, plan);
  }

  static Future<List<Map<String, dynamic>>> foodLogs(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeList(prefs.getString(_logsKey));
    final key = dateKey(date);
    return all.where((item) => item['dateKey']?.toString() == key).toList();
  }

  static Future<bool> logMeal({
    required DateTime date,
    required NutritionRecipe recipe,
    required double servings,
    required String sourceKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeList(prefs.getString(_logsKey));
    final key = dateKey(date);
    if (all.any((item) =>
        item['dateKey']?.toString() == key &&
        item['sourceKey']?.toString() == sourceKey)) {
      return false;
    }
    final snapshot = recipe.macros.scale(servings);
    all.insert(0, <String, dynamic>{
      'id': 'food_${DateTime.now().microsecondsSinceEpoch}',
      'dateKey': key,
      'sourceKey': sourceKey,
      'recipeId': recipe.id,
      'recipeName': recipe.name,
      'slot': recipe.slot,
      'servings': servings,
      'nutrition': snapshot.toJson(),
      'loggedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_logsKey, jsonEncode(all.take(500).toList()));
    _notify();
    return true;
  }

  static Future<void> deleteFoodLog(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeList(prefs.getString(_logsKey));
    all.removeWhere((item) => item['id']?.toString() == id);
    await prefs.setString(_logsKey, jsonEncode(all));
    _notify();
  }

  static Future<void> updateFoodLogServings(
    String id,
    double servings,
  ) async {
    if (servings <= 0) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeList(prefs.getString(_logsKey));
    final index = all.indexWhere((item) => item['id']?.toString() == id);
    if (index < 0) {
      return;
    }
    final current = all[index];
    final previousServings = (current['servings'] as num?)?.toDouble() ?? 1.0;
    final previousSnapshot = NutritionMacros.fromJson(current['nutrition']);
    final perServing = previousServings <= 0
        ? previousSnapshot
        : previousSnapshot.scale(1 / previousServings);
    all[index] = <String, dynamic>{
      ...current,
      'servings': servings,
      'nutrition': perServing.scale(servings).toJson(),
      'editedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_logsKey, jsonEncode(all));
    _notify();
  }

  static Future<NutritionMacros> consumedTotals(DateTime date) async {
    final logs = await foodLogs(date);
    var total = const NutritionMacros.zero();
    for (final log in logs) {
      total = total + NutritionMacros.fromJson(log['nutrition']);
    }
    return total;
  }

  static Future<NutritionMacros> plannedTotals(DateTime date) async {
    final plan = await planForDate(date);
    var total = const NutritionMacros.zero();
    for (final meal in plan) {
      final recipe = NutritionCatalog.byId(meal.recipeId);
      if (recipe != null) {
        total = total + recipe.macros.scale(meal.servings);
      }
    }
    return total;
  }

  static Future<List<Map<String, dynamic>>> waterEntries(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeList(prefs.getString(_waterKey));
    final key = dateKey(date);
    return all.where((item) => item['dateKey']?.toString() == key).toList();
  }

  static Future<int> waterTotalMl(DateTime date) async {
    final entries = await waterEntries(date);
    return entries.fold<int>(
      0,
      (sum, item) => sum + ((item['ml'] as num?)?.toInt() ?? 0),
    );
  }

  static Future<void> addWater(DateTime date, int ml) async {
    if (ml <= 0) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeList(prefs.getString(_waterKey));
    all.insert(0, <String, dynamic>{
      'id': 'water_${DateTime.now().microsecondsSinceEpoch}',
      'dateKey': dateKey(date),
      'ml': ml,
      'loggedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_waterKey, jsonEncode(all.take(800).toList()));
    _notify();
  }

  static Future<void> deleteWater(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeList(prefs.getString(_waterKey));
    all.removeWhere((item) => item['id']?.toString() == id);
    await prefs.setString(_waterKey, jsonEncode(all));
    _notify();
  }

  static Future<void> updateWater(String id, int ml) async {
    if (ml <= 0) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final all = _decodeList(prefs.getString(_waterKey));
    final index = all.indexWhere((item) => item['id']?.toString() == id);
    if (index < 0) {
      return;
    }
    all[index] = <String, dynamic>{
      ...all[index],
      'ml': ml,
      'editedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_waterKey, jsonEncode(all));
    _notify();
  }

  static Future<Set<String>> savedMealIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_savedKey) ?? const <String>[]).toSet();
  }

  static Future<bool> toggleSavedMeal(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_savedKey) ?? <String>[]).toSet();
    final saved = !current.contains(recipeId);
    if (saved) {
      current.add(recipeId);
    } else {
      current.remove(recipeId);
    }
    await prefs.setStringList(_savedKey, current.toList());
    _notify();
    return saved;
  }

  static Future<Map<String, bool>> shoppingChecked() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _decodeMap(prefs.getString(_shoppingCheckedKey));
    return raw.map((key, value) => MapEntry(key, value == true));
  }

  static Future<void> setShoppingChecked(String id, bool checked) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _decodeMap(prefs.getString(_shoppingCheckedKey));
    raw[id] = checked;
    await prefs.setString(_shoppingCheckedKey, jsonEncode(raw));
    _notify();
  }

  static Future<List<Map<String, dynamic>>> manualShoppingItems() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_shoppingManualKey));
  }

  static Future<void> addManualShoppingItem(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final items = _decodeList(prefs.getString(_shoppingManualKey));
    items.add(<String, dynamic>{
      'id': 'manual_${DateTime.now().microsecondsSinceEpoch}',
      'name': trimmed,
      'category': 'Other',
    });
    await prefs.setString(_shoppingManualKey, jsonEncode(items));
    _notify();
  }

  static Future<void> deleteManualShoppingItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = _decodeList(prefs.getString(_shoppingManualKey));
    items.removeWhere((item) => item['id']?.toString() == id);
    await prefs.setString(_shoppingManualKey, jsonEncode(items));
    _notify();
  }

  static Future<void> updateManualShoppingItem(
    String id,
    String name,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final items = _decodeList(prefs.getString(_shoppingManualKey));
    final index = items.indexWhere((item) => item['id']?.toString() == id);
    if (index < 0) {
      return;
    }
    items[index] = <String, dynamic>{
      ...items[index],
      'name': trimmed,
      'editedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_shoppingManualKey, jsonEncode(items));
    _notify();
  }

  static List<NutritionRecipe> compatibleAlternatives({
    required NutritionRecipe current,
    required NutritionPreferences preferences,
  }) {
    final allergySet =
        preferences.allergies.map((item) => item.toLowerCase()).toSet();
    final dietary =
        preferences.dietary.map((item) => item.toLowerCase()).toSet();
    final candidates = NutritionCatalog.forSlot(current.slot).where((recipe) {
      if (recipe.id == current.id) {
        return false;
      }
      final recipeAllergens =
          recipe.allergens.map((item) => item.toLowerCase()).toSet();
      if (recipeAllergens.any(allergySet.contains)) {
        return false;
      }
      if (dietary.contains('vegan') && !recipe.dietaryTags.contains('Vegan')) {
        return false;
      }
      if (dietary.contains('vegetarian') &&
          !recipe.dietaryTags.contains('Vegetarian') &&
          !recipe.dietaryTags.contains('Vegan')) {
        return false;
      }
      if (dietary.contains('gluten-free') &&
          !recipe.dietaryTags.contains('Gluten-free')) {
        return false;
      }
      return true;
    }).toList();

    candidates.sort((a, b) {
      var scoreA = 0;
      var scoreB = 0;
      if (preferences.cuisines.contains(a.cuisine)) {
        scoreA += 2;
      }
      if (preferences.cuisines.contains(b.cuisine)) {
        scoreB += 2;
      }
      if (a.prepMinutes <= preferences.prepMinutes) {
        scoreA += 1;
      }
      if (b.prepMinutes <= preferences.prepMinutes) {
        scoreB += 1;
      }
      return scoreB.compareTo(scoreA);
    });
    return candidates;
  }

  static Future<Map<String, dynamic>> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    return <String, dynamic>{
      'preferences': jsonDecode(prefs.getString(_preferencesKey) ?? '{}'),
      'plans': jsonDecode(prefs.getString(_plansKey) ?? '{}'),
      'foodLogs': jsonDecode(prefs.getString(_logsKey) ?? '[]'),
      'waterLogs': jsonDecode(prefs.getString(_waterKey) ?? '[]'),
      'savedMeals': prefs.getStringList(_savedKey) ?? <String>[],
      'selectedDate': prefs.getString(_selectedDateKey),
      'shoppingChecked':
          jsonDecode(prefs.getString(_shoppingCheckedKey) ?? '{}'),
      'shoppingManual': jsonDecode(prefs.getString(_shoppingManualKey) ?? '[]'),
      'activeTemplates':
          jsonDecode(prefs.getString(_activeTemplateKey) ?? '{}'),
    };
  }

  static Future<void> importData(dynamic value) async {
    if (value is! Map) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (value['preferences'] is Map) {
      await prefs.setString(_preferencesKey, jsonEncode(value['preferences']));
    }
    if (value['plans'] is Map) {
      await prefs.setString(_plansKey, jsonEncode(value['plans']));
    }
    if (value['foodLogs'] is List) {
      await prefs.setString(_logsKey, jsonEncode(value['foodLogs']));
    }
    if (value['waterLogs'] is List) {
      await prefs.setString(_waterKey, jsonEncode(value['waterLogs']));
    }
    if (value['savedMeals'] is List) {
      await prefs.setStringList(
        _savedKey,
        (value['savedMeals'] as List).map((item) => item.toString()).toList(),
      );
    }
    if (value['selectedDate'] != null) {
      await prefs.setString(_selectedDateKey, value['selectedDate'].toString());
    }
    if (value['shoppingChecked'] is Map) {
      await prefs.setString(
        _shoppingCheckedKey,
        jsonEncode(value['shoppingChecked']),
      );
    }
    if (value['shoppingManual'] is List) {
      await prefs.setString(
        _shoppingManualKey,
        jsonEncode(value['shoppingManual']),
      );
    }
    if (value['activeTemplates'] is Map) {
      await prefs.setString(
        _activeTemplateKey,
        jsonEncode(value['activeTemplates']),
      );
    }
    _notify();
  }

  static bool _isRecipeCompatible(
    NutritionRecipe recipe,
    NutritionPreferences preferences,
  ) {
    final allergySet =
        preferences.allergies.map((item) => item.toLowerCase()).toSet();
    final recipeAllergens =
        recipe.allergens.map((item) => item.toLowerCase()).toSet();
    if (recipeAllergens.any(allergySet.contains)) {
      return false;
    }
    final dietary =
        preferences.dietary.map((item) => item.toLowerCase()).toSet();
    final tags = recipe.dietaryTags.map((item) => item.toLowerCase()).toSet();
    if (dietary.contains('vegan') && !tags.contains('vegan')) {
      return false;
    }
    if (dietary.contains('vegetarian') &&
        !tags.contains('vegetarian') &&
        !tags.contains('vegan')) {
      return false;
    }
    if (dietary.contains('gluten-free') && !tags.contains('gluten-free')) {
      return false;
    }
    return true;
  }

  static List<PlannedNutritionMeal> _defaultPlanFor(DateTime date) {
    final rotation = date.weekday % 3;
    final breakfast = ['berry_oats', 'avocado_eggs', 'banana_chia'][rotation];
    final lunch = ['chicken_rice', 'lentil_bowl', 'tuna_wrap'][rotation];
    final dinner = ['salmon_greens', 'beef_quinoa', 'tofu_stirfry'][rotation];
    final snack = ['yogurt_berries', 'apple_peanut', 'hummus_veg'][rotation];
    return <PlannedNutritionMeal>[
      PlannedNutritionMeal(
          slot: 'Breakfast', recipeId: breakfast, time: '08:00'),
      PlannedNutritionMeal(slot: 'Lunch', recipeId: lunch, time: '13:00'),
      PlannedNutritionMeal(slot: 'Dinner', recipeId: dinner, time: '19:00'),
      PlannedNutritionMeal(slot: 'Snack', recipeId: snack, time: '16:30'),
    ];
  }

  static Map<String, dynamic> _decodeMap(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic>
        ? decoded
        : decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <Map<String, dynamic>>[];
    }
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
