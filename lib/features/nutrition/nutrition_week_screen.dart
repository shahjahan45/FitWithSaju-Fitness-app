import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import 'data/nutrition_catalog.dart';
import 'data/nutrition_models.dart';
import 'data/nutrition_store.dart';
import 'meal_detail_screen.dart';
import 'nutrition_widgets.dart';

class NutritionWeekScreen extends StatelessWidget {
  final DateTime anchorDate;

  const NutritionWeekScreen({super.key, required this.anchorDate});

  DateTime get _monday {
    final local = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);
    return local.subtract(Duration(days: local.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutritionPalette.canvas,
      appBar: AppBar(title: const Text('Weekly meal plan')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          itemCount: 7,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final date = _monday.add(Duration(days: index));
            return FutureBuilder<List<PlannedNutritionMeal>>(
              future: NutritionStore.planForDate(date),
              builder: (context, snapshot) {
                final plan = snapshot.data ?? const <PlannedNutritionMeal>[];
                return MotionReveal(
                  delay: Duration(milliseconds: 35 * index),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: NutritionPalette.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nutritionLongDate(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            FutureBuilder<NutritionMacros>(
                              future: NutritionStore.plannedTotals(date),
                              builder: (context, totalSnapshot) {
                                final totals = totalSnapshot.data ??
                                    const NutritionMacros.zero();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${totals.protein.round()} g protein',
                                      style: const TextStyle(
                                        color: NutritionPalette.brand,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      '${totals.calories.round()} kcal',
                                      style: const TextStyle(
                                        color: NutritionPalette.muted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...plan.map((meal) {
                          final recipe = NutritionCatalog.byId(meal.recipeId);
                          if (recipe == null) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color:
                                  NutritionPalette.tint.withValues(alpha: .55),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => Navigator.of(context).push(
                                  FitRoutes.route(
                                    context,
                                    motion: FitRouteMotion.detail,
                                    builder: (_) => MealDetailScreen(
                                        date: date, meal: meal),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      NutritionArtwork(
                                        artwork: recipe.artwork,
                                        assetPath: recipe.artworkAsset,
                                        networkUrl: recipe.imageUrl,
                                        size: 46,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${meal.slot} · ${meal.time}',
                                              style: const TextStyle(
                                                color: NutritionPalette.brand,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            Text(
                                              recipe.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${recipe.macros.calories.round()} kcal',
                                        style: const TextStyle(
                                          color: NutritionPalette.muted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
