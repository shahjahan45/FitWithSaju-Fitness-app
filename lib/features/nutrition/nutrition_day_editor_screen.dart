import 'package:flutter/material.dart';

import '../../core/widgets/app_screen.dart';

import '../../core/navigation/settled_dialog.dart';

import '../../core/motion/motion_widgets.dart';
import 'data/nutrition_catalog.dart';
import 'data/nutrition_models.dart';
import 'data/nutrition_store.dart';
import 'nutrition_bottom_sheet_safe_area.dart';
import 'nutrition_widgets.dart';

class NutritionDayEditorScreen extends StatefulWidget {
  final DateTime date;

  const NutritionDayEditorScreen({super.key, required this.date});

  @override
  State<NutritionDayEditorScreen> createState() =>
      _NutritionDayEditorScreenState();
}

class _NutritionDayEditorScreenState extends State<NutritionDayEditorScreen> {
  List<PlannedNutritionMeal>? _plan;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await NutritionStore.planForDate(widget.date);
    if (mounted) {
      setState(() => _plan = List<PlannedNutritionMeal>.of(value));
    }
  }

  Future<void> _save(List<PlannedNutritionMeal> value) async {
    setState(() {
      _plan = value;
      _saving = true;
    });
    await NutritionStore.savePlanForDate(widget.date, value);
    if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return Scaffold(
      backgroundColor: NutritionPalette.canvas,
      appBar: AppBar(
        title: const Text('Edit day plan'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 18),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: plan == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: fitPagePadding(context, bottom: 32),
              children: [
                MotionReveal(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: NutritionPalette.hero,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nutritionLongDate(widget.date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Adjust servings, meal time, add a meal, or remove a planned item. Logged food is kept separate and is never deleted here.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .8),
                            height: 1.4,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (plan.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: NutritionPalette.line),
                    ),
                    child: const Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: NutritionPalette.tint,
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: NutritionPalette.brand,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No meals planned yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Add meals one at a time or apply a weekly plan to build this day automatically.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: NutritionPalette.muted,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(plan.length, (index) {
                    final meal = plan[index];
                    final recipe = NutritionCatalog.byId(meal.recipeId);
                    if (recipe == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MotionReveal(
                        delay: Duration(milliseconds: 35 * index),
                        child: _EditableMealCard(
                          meal: meal,
                          recipe: recipe,
                          onMinus: () => _changeServings(index, -.5),
                          onPlus: () => _changeServings(index, .5),
                          onTime: () => _changeTime(index),
                          onDelete: () => _delete(index),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 4),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _addMeal,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add meal to this day'),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _changeServings(int index, double delta) async {
    final plan = List<PlannedNutritionMeal>.of(_plan!);
    final current = plan[index];
    final value = (current.servings + delta).clamp(.5, 4.0).toDouble();
    plan[index] = PlannedNutritionMeal(
      slot: current.slot,
      recipeId: current.recipeId,
      time: current.time,
      servings: value,
    );
    await _save(plan);
  }

  Future<void> _changeTime(int index) async {
    final current = _plan![index];
    final parts = current.time.split(':');
    final initial = TimeOfDay(
      hour: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 12 : 12,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) {
      return;
    }
    final plan = List<PlannedNutritionMeal>.of(_plan!);
    plan[index] = PlannedNutritionMeal(
      slot: current.slot,
      recipeId: current.recipeId,
      time:
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
      servings: current.servings,
    );
    await _save(plan);
  }

  Future<void> _delete(int index) async {
    final plan = List<PlannedNutritionMeal>.of(_plan!)..removeAt(index);
    await _save(plan);
  }

  Future<void> _addMeal() async {
    final recipe = await showSettledModalBottomSheet<NutritionRecipe>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => NutritionBottomSheetSafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .66,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a meal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose any supported FitWithSaju recipe. You can adjust servings and time after adding it.',
                style: TextStyle(color: NutritionPalette.muted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: NutritionCatalog.recipes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = NutritionCatalog.recipes[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: NutritionArtwork(
                        artwork: item.artwork,
                        assetPath: item.artworkAsset,
                        networkUrl: item.imageUrl,
                        size: 46,
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${item.slot} · ${item.macros.protein.round()} g protein · ${item.macros.calories.round()} kcal',
                      ),
                      onTap: () => Navigator.pop(sheetContext, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (recipe == null || !mounted) {
      return;
    }
    final plan = List<PlannedNutritionMeal>.of(_plan!);
    plan.add(
      PlannedNutritionMeal(
        slot: recipe.slot,
        recipeId: recipe.id,
        time: _defaultTime(recipe.slot),
      ),
    );
    plan.sort((a, b) => a.time.compareTo(b.time));
    await _save(plan);
  }

  static String _defaultTime(String slot) => switch (slot.toLowerCase()) {
        'breakfast' => '08:00',
        'lunch' => '13:00',
        'dinner' => '19:00',
        _ => '16:30',
      };
}

class _EditableMealCard extends StatelessWidget {
  final PlannedNutritionMeal meal;
  final NutritionRecipe recipe;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onTime;
  final VoidCallback onDelete;

  const _EditableMealCard({
    required this.meal,
    required this.recipe,
    required this.onMinus,
    required this.onPlus,
    required this.onTime,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final macros = recipe.macros.scale(meal.servings);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NutritionPalette.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              NutritionArtwork(
                artwork: recipe.artwork,
                assetPath: recipe.artworkAsset,
                networkUrl: recipe.imageUrl,
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${meal.slot} · ${meal.time}',
                      style: const TextStyle(
                        color: NutritionPalette.brand,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      recipe.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${macros.protein.round()} g protein · ${macros.calories.round()} kcal',
                      style: const TextStyle(
                          color: NutritionPalette.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove meal',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTime,
                  icon: const Icon(Icons.schedule_rounded, size: 18),
                  label: Text(meal.time),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: NutritionPalette.tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: onMinus,
                        icon: const Icon(Icons.remove_rounded)),
                    Text(
                      '${formatAmount(meal.servings)}×',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                        onPressed: onPlus, icon: const Icon(Icons.add_rounded)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
