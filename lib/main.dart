import 'dart:async';

import 'package:flutter/material.dart';

import 'app/fitwithsaju_app.dart';
import 'core/settings/app_preferences.dart';
import 'data/exercise_catalog.dart';
import 'features/nutrition/data/nutrition_catalog.dart';
import 'features/nutrition/data/nutrition_plan_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AppPreferences.initialize(),
    ExerciseCatalog.instance.initialize(),
    NutritionCatalog.initialize(),
    NutritionPlanCatalog.initialize(),
  ]);
  runApp(const FitWithSajuApp());

  if (AppPreferences.current.autoSyncContent) {
    final apiBaseUrl = await ExerciseCatalog.instance.apiBaseUrl();
    if (apiBaseUrl.isNotEmpty) {
      unawaited(ExerciseCatalog.instance.sync(baseUrl: apiBaseUrl));
      unawaited(NutritionCatalog.sync(baseUrl: apiBaseUrl));
      unawaited(NutritionPlanCatalog.sync(baseUrl: apiBaseUrl));
    }
  }
}
