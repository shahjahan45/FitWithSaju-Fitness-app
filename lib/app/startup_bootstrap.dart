import 'dart:async';

import '../core/settings/app_preferences.dart';
import '../data/exercise_catalog.dart';
import '../features/nutrition/data/nutrition_catalog.dart';
import '../features/nutrition/data/nutrition_plan_catalog.dart';

/// Loads local app content after Flutter has been allowed to render its first
/// frame. The Android system splash therefore hands off quickly to the branded
/// Flutter splash instead of waiting for catalog/cache reads.
class StartupBootstrap {
  StartupBootstrap._();

  static Future<void>? _initialization;

  static Future<void> ensureInitialized() {
    return _initialization ??= _initialize();
  }

  static Future<void> _initialize() async {
    await Future.wait<void>([
      _safe(AppPreferences.initialize),
      _safe(ExerciseCatalog.instance.initialize),
      _safe(NutritionCatalog.initialize),
      _safe(NutritionPlanCatalog.initialize),
    ]);

    if (!AppPreferences.current.autoSyncContent) {
      return;
    }

    final apiBaseUrl = await ExerciseCatalog.instance.apiBaseUrl();
    if (apiBaseUrl.isEmpty) {
      return;
    }

    // Network refresh is intentionally non-blocking. Cached/bundled content is
    // already available and the app should never wait on the server to open.
    unawaited(ExerciseCatalog.instance.sync(baseUrl: apiBaseUrl));
    unawaited(NutritionCatalog.sync(baseUrl: apiBaseUrl));
    unawaited(NutritionPlanCatalog.sync(baseUrl: apiBaseUrl));
  }

  static Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Bundled/default data keeps startup usable if a cache read fails.
    }
  }
}
