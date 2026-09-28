import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import 'data/nutrition_catalog.dart';
import 'data/nutrition_models.dart';
import 'data/nutrition_store.dart';
import 'meal_detail_screen.dart';
import 'nutrition_widgets.dart';

class SavedMealsScreen extends StatelessWidget {
  const SavedMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutritionPalette.canvas,
      appBar: AppBar(title: const Text('Saved meals')),
      body: ValueListenableBuilder<int>(
        valueListenable: NutritionStore.changes,
        builder: (context, _, __) => FutureBuilder<Set<String>>(
          future: NutritionStore.savedMealIds(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final recipes = NutritionCatalog.recipes
                .where((recipe) => snapshot.data!.contains(recipe.id))
                .toList();
            if (recipes.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_border_rounded,
                          size: 48, color: NutritionPalette.muted),
                      SizedBox(height: 12),
                      Text('No saved meals yet',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900)),
                      SizedBox(height: 6),
                      Text(
                        'Save meals from the daily plan or meal details and they will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: NutritionPalette.muted, height: 1.45),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: recipes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(
                      FitRoutes.route(
                        context,
                        motion: FitRouteMotion.detail,
                        builder: (_) => MealDetailScreen(
                          date: DateTime.now(),
                          meal: PlannedNutritionMeal(
                            slot: recipe.slot,
                            recipeId: recipe.id,
                            time: '',
                          ),
                          planned: false,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: NutritionPalette.line),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          NutritionArtwork(
                              artwork: recipe.artwork,
                              assetPath: recipe.artworkAsset,
                              networkUrl: recipe.imageUrl,
                              size: 78),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(recipe.slot.toUpperCase(),
                                    style: const TextStyle(
                                        color: NutritionPalette.brand,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900)),
                                const SizedBox(height: 3),
                                Text(recipe.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16)),
                                const SizedBox(height: 5),
                                NutritionMacroLine(macros: recipe.macros),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove saved meal',
                            onPressed: () =>
                                NutritionStore.toggleSavedMeal(recipe.id),
                            icon: const Icon(Icons.bookmark_remove_rounded,
                                color: NutritionPalette.brand),
                          ),
                        ],
                      ),
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
