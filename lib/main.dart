import 'dart:async';

import 'package:flutter/material.dart';

import 'app/fitwithsaju_app.dart';
import 'data/exercise_catalog.dart';
import 'features/nutrition/data/nutrition_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    ExerciseCatalog.instance.initialize(),
    NutritionCatalog.initialize(),
  ]);
  runApp(const FitWithSajuApp());

  final apiBaseUrl = await ExerciseCatalog.instance.apiBaseUrl();
  if (apiBaseUrl.isNotEmpty) {
    unawaited(ExerciseCatalog.instance.sync(baseUrl: apiBaseUrl));
    unawaited(NutritionCatalog.sync(baseUrl: apiBaseUrl));
  }
}
