import 'dart:async';

import 'package:flutter/material.dart';

import 'app/fitwithsaju_app.dart';
import 'data/exercise_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ExerciseCatalog.instance.initialize();
  runApp(const FitWithSajuApp());

  final apiBaseUrl = await ExerciseCatalog.instance.apiBaseUrl();
  if (apiBaseUrl.isNotEmpty) {
    unawaited(ExerciseCatalog.instance.sync(baseUrl: apiBaseUrl));
  }
}
