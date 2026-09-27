import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import 'data/nutrition_models.dart';
import 'data/nutrition_store.dart';
import 'nutrition_plan_screen.dart';
import 'nutrition_widgets.dart';

class NutritionHomeShortcut extends StatelessWidget {
  const NutritionHomeShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NutritionStore.changes,
      builder: (context, _, __) => FutureBuilder<List<dynamic>>(
        future: Future.wait<dynamic>([
          NutritionStore.preferences(),
          NutritionStore.plannedTotals(DateTime.now()),
          NutritionStore.consumedTotals(DateTime.now()),
          NutritionStore.foodLogs(DateTime.now()),
        ]),
        builder: (context, snapshot) {
          final preferences = snapshot.hasData
              ? snapshot.data![0] as NutritionPreferences
              : const NutritionPreferences(
                  goal: 'Balanced eating',
                  dietary: <String>[],
                  allergies: <String>[],
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
          final planned = snapshot.hasData
              ? snapshot.data![1] as NutritionMacros
              : const NutritionMacros.zero();
          final consumed = snapshot.hasData
              ? snapshot.data![2] as NutritionMacros
              : const NutritionMacros.zero();
          final logs = snapshot.hasData
              ? snapshot.data![3] as List<Map<String, dynamic>>
              : <Map<String, dynamic>>[];
          final target = preferences.calorieTarget;
          final progress = target <= 0
              ? 0.0
              : (consumed.calories / target).clamp(0.0, 1.0).toDouble();

          return PressableScale(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigator.of(context).push(
              FitRoutes.route(
                context,
                motion: FitRouteMotion.detail,
                builder: (_) => const NutritionPlanScreen(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: NutritionPalette.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: NutritionPalette.tint,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: NutritionPalette.brand,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DIET & MEAL PLAN',
                          style: TextStyle(
                            color: NutritionPalette.brand,
                            fontSize: 10,
                            letterSpacing: .5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          preferences.goal,
                          style: const TextStyle(
                            color: NutritionPalette.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            value: progress,
                            backgroundColor: NutritionPalette.tint,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              NutritionPalette.brand,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${consumed.calories.round()} eaten · ${planned.calories.round()} planned · ${logs.length} logged',
                          style: const TextStyle(
                            color: NutritionPalette.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: NutritionPalette.muted,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
