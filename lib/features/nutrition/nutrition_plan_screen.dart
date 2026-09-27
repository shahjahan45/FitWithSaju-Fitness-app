import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import 'data/nutrition_catalog.dart';
import 'data/nutrition_models.dart';
import 'data/nutrition_store.dart';
import 'meal_detail_screen.dart';
import 'nutrition_preferences_screen.dart';
import 'nutrition_week_screen.dart';
import 'nutrition_widgets.dart';
import 'saved_meals_screen.dart';
import 'shopping_list_screen.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({super.key});

  @override
  State<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  DateTime? _selectedDate;
  int _dateDirection = 1;

  @override
  void initState() {
    super.initState();
    NutritionStore.selectedDate().then((value) {
      if (mounted) {
        setState(() => _selectedDate = value);
      }
    });
  }

  Future<void> _selectDate(DateTime date) async {
    final current = _selectedDate;
    await NutritionStore.setSelectedDate(date);
    if (!mounted) {
      return;
    }
    setState(() {
      if (current != null) {
        _dateDirection = date.isBefore(current) ? -1 : 1;
      }
      _selectedDate = date;
    });
  }

  Future<void> _moveWeek(int weeks) async {
    final current = _selectedDate ?? DateTime.now();
    await _selectDate(current.add(Duration(days: weeks * 7)));
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.detail,
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = _selectedDate;
    if (date == null) {
      return const Scaffold(
        backgroundColor: NutritionPalette.canvas,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: NutritionPalette.canvas,
      appBar: AppBar(
        title: const Text('Diet & Meal Plan'),
        actions: [
          IconButton(
            tooltip: 'Nutrition preferences',
            onPressed: () => _open(const NutritionPreferencesScreen()),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: NutritionStore.changes,
        builder: (context, _, __) => FutureBuilder<_PlanData>(
          future: _load(date),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final reduce = AppMotion.reducedMotion(context);
            final direction = Directionality.of(context) == TextDirection.rtl
                ? -_dateDirection
                : _dateDirection;
            return AnimatedSwitcher(
              duration: AppMotion.duration(context, AppMotion.internalTab),
              switchInCurve: AppMotion.enterCurve,
              switchOutCurve: AppMotion.exitCurve,
              transitionBuilder: (child, animation) {
                if (reduce) {
                  return FadeTransition(opacity: animation, child: child);
                }
                final slide = Tween<Offset>(
                  begin: Offset(.035 * direction, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<String>(NutritionStore.dateKey(date)),
                child: _buildContent(context, date, snapshot.data!),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<_PlanData> _load(DateTime date) async {
    final values = await Future.wait<dynamic>([
      NutritionStore.planForDate(date),
      NutritionStore.preferences(),
      NutritionStore.consumedTotals(date),
      NutritionStore.plannedTotals(date),
      NutritionStore.foodLogs(date),
      NutritionStore.waterEntries(date),
      NutritionStore.waterTotalMl(date),
      NutritionStore.savedMealIds(),
    ]);
    return _PlanData(
      plan: values[0] as List<PlannedNutritionMeal>,
      preferences: values[1] as NutritionPreferences,
      consumed: values[2] as NutritionMacros,
      planned: values[3] as NutritionMacros,
      foodLogs: values[4] as List<Map<String, dynamic>>,
      waterEntries: values[5] as List<Map<String, dynamic>>,
      waterMl: values[6] as int,
      savedIds: values[7] as Set<String>,
    );
  }

  Widget _buildContent(BuildContext context, DateTime date, _PlanData data) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final eatenMeals = data.foodLogs.length;
    return NutritionPageBackground(
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            const MotionReveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your meal plan',
                    style: TextStyle(
                      color: NutritionPalette.ink,
                      fontSize: 32,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Local sample plan · estimated nutrition',
                    style: TextStyle(
                      color: NutritionPalette.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            MotionReveal(
              delay: const Duration(milliseconds: 30),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Previous week',
                    onPressed: () => _moveWeek(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Week of ${nutritionLongDate(weekStart)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: NutritionPalette.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next week',
                    onPressed: () => _moveWeek(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            MotionReveal(
              delay: const Duration(milliseconds: 40),
              child: SizedBox(
                height: 67,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, __) => const SizedBox(width: 7),
                  itemBuilder: (context, index) {
                    final itemDate = weekStart.add(Duration(days: index));
                    final selected = NutritionStore.dateKey(itemDate) ==
                        NutritionStore.dateKey(date);
                    return _DateTile(
                      date: itemDate,
                      selected: selected,
                      onTap: () => _selectDate(itemDate),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            MotionReveal(
              delay: const Duration(milliseconds: 70),
              child: NutritionSoftButton(
                label: '${data.preferences.goal}  ·  Edit preferences',
                onTap: () => _open(const NutritionPreferencesScreen()),
              ),
            ),
            const SizedBox(height: 14),
            MotionReveal(
              delay: const Duration(milliseconds: 95),
              child: _NutritionSummary(
                planned: data.planned,
                consumed: data.consumed,
                targets: data.preferences.targetMacros,
                eatenMeals: eatenMeals,
                plannedMealCount: data.plan.length,
                onLogs: () => _showFoodLogs(date, data.foodLogs),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NutritionSoftButton(
                    label: 'Week',
                    icon: Icons.calendar_view_week_rounded,
                    onTap: () => _open(NutritionWeekScreen(anchorDate: date)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NutritionSoftButton(
                    label: 'Saved',
                    icon: Icons.bookmark_outline_rounded,
                    onTap: () => _open(const SavedMealsScreen()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NutritionSoftButton(
                    label: 'Shopping',
                    icon: Icons.shopping_basket_outlined,
                    onTap: () => _open(ShoppingListScreen(startDate: date)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            NutritionSectionTitle(
              title: NutritionStore.dateKey(date) ==
                      NutritionStore.dateKey(DateTime.now())
                  ? 'Today’s meals'
                  : nutritionLongDate(date),
            ),
            const SizedBox(height: 10),
            ...List.generate(data.plan.length, (index) {
              final meal = data.plan[index];
              final recipe = NutritionCatalog.byId(meal.recipeId);
              if (recipe == null) {
                return const SizedBox.shrink();
              }
              final logged = data.foodLogs.any(
                (item) =>
                    item['sourceKey']?.toString() ==
                    '${NutritionStore.dateKey(date)}:${meal.slot}',
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MotionReveal(
                  delay: Duration(milliseconds: 130 + (index * 40)),
                  child: _MealCard(
                    date: date,
                    meal: meal,
                    recipe: recipe,
                    saved: data.savedIds.contains(recipe.id),
                    logged: logged,
                    onOpen: () =>
                        _open(MealDetailScreen(date: date, meal: meal)),
                    onSave: () => NutritionStore.toggleSavedMeal(recipe.id),
                    onSwap: () => _swapDirect(date, meal, recipe),
                    onLog: () => _logDirect(date, meal, recipe),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            _HydrationCard(
              date: date,
              currentMl: data.waterMl,
              goalMl: data.preferences.waterTargetMl,
              units: data.preferences.units,
              entries: data.waterEntries,
              onRefresh: () => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _swapDirect(
    DateTime date,
    PlannedNutritionMeal meal,
    NutritionRecipe current,
  ) async {
    final prefs = await NutritionStore.preferences();
    if (!mounted) {
      return;
    }
    final alternatives = NutritionStore.compatibleAlternatives(
      current: current,
      preferences: prefs,
    );
    if (alternatives.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No suitable alternatives match your current allergy and dietary restrictions.',
          ),
        ),
      );
      return;
    }
    final chosen = await showModalBottomSheet<NutritionRecipe>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: .68,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Text('Choose an alternative',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Allergy restrictions remain enforced.',
                style: TextStyle(color: NutritionPalette.muted)),
            const SizedBox(height: 14),
            ...alternatives.map((recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.of(context).pop(recipe),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: NutritionPalette.line),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            NutritionArtwork(
                                artwork: recipe.artwork,
                                assetPath: recipe.artworkAsset,
                                size: 64),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(recipe.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${recipe.prepMinutes} min · ${recipe.macros.calories.round()} kcal · ${recipe.macros.protein.round()}g protein',
                                    style: const TextStyle(
                                        color: NutritionPalette.muted,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) {
      return;
    }
    await NutritionStore.swapMeal(
        date: date, slot: meal.slot, recipeId: chosen.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meal.slot} changed to ${chosen.name}.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => NutritionStore.swapMeal(
            date: date,
            slot: meal.slot,
            recipeId: current.id,
          ),
        ),
      ),
    );
  }

  Future<void> _logDirect(
    DateTime date,
    PlannedNutritionMeal meal,
    NutritionRecipe recipe,
  ) async {
    var servings = meal.servings;
    final selected = await showModalBottomSheet<double>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Log ${recipe.name}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: servings > .25
                        ? () => setSheetState(() => servings -= .25)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '${formatAmount(servings)} serving${servings == 1 ? '' : 's'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: servings < 4
                        ? () => setSheetState(() => servings += .25)
                        : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              NutritionMacroLine(macros: recipe.macros, servings: servings),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: NutritionPalette.brand),
                  onPressed: () => Navigator.of(sheetContext).pop(servings),
                  child: const Text('Log eaten',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) {
      return;
    }
    final added = await NutritionStore.logMeal(
      date: date,
      recipe: recipe,
      servings: selected,
      sourceKey: '${NutritionStore.dateKey(date)}:${meal.slot}',
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              added ? 'Meal logged.' : 'This planned meal is already logged.')),
    );
  }

  Future<bool> _editFoodLogServings(
    BuildContext dialogContext,
    Map<String, dynamic> log,
  ) async {
    final current = (log['servings'] as num?)?.toDouble() ?? 1.0;
    final controller = TextEditingController(text: formatAmount(current));
    final value = await showDialog<double>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Edit consumed portion'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Servings eaten',
            helperText: 'Example: 0.5, 1, 1.5',
          ),
          onSubmitted: (text) => Navigator.of(context).pop(
            double.tryParse(text),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              double.tryParse(controller.text),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value <= 0) {
      return false;
    }
    await NutritionStore.updateFoodLogServings(
      log['id']?.toString() ?? '',
      value,
    );
    return true;
  }

  Future<void> _showFoodLogs(
    DateTime date,
    List<Map<String, dynamic>> logs,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Food log · ${nutritionLongDate(date)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                    child: Text('Nothing logged yet.',
                        style: TextStyle(color: NutritionPalette.muted))),
              )
            else
              ...logs.map((log) {
                final macros = NutritionMacros.fromJson(log['nutrition']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(log['recipeName']?.toString() ?? 'Meal',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                      '${formatAmount((log['servings'] as num?)?.toDouble() ?? 1)} servings · ${macros.calories.round()} kcal'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit consumed portion',
                        onPressed: () async {
                          final updated = await _editFoodLogServings(
                            sheetContext,
                            log,
                          );
                          if (updated && sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Undo food log',
                        onPressed: () async {
                          await NutritionStore.deleteFoodLog(
                            log['id']?.toString() ?? '',
                          );
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                        icon: const Icon(Icons.undo_rounded),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  const _DateTile(
      {required this.date, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NutritionPalette.brand : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? NutritionPalette.brand : NutritionPalette.line),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              nutritionDayLabel(date),
              style: TextStyle(
                color: selected ? Colors.white : NutritionPalette.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${date.day}',
              style: TextStyle(
                color: selected ? Colors.white : NutritionPalette.ink,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionSummary extends StatelessWidget {
  final NutritionMacros planned;
  final NutritionMacros consumed;
  final NutritionMacros targets;
  final int eatenMeals;
  final int plannedMealCount;
  final VoidCallback onLogs;

  const _NutritionSummary({
    required this.planned,
    required this.consumed,
    required this.targets,
    required this.eatenMeals,
    required this.plannedMealCount,
    required this.onLogs,
  });

  @override
  Widget build(BuildContext context) {
    final progress = targets.calories <= 0
        ? 0.0
        : (consumed.calories / targets.calories).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NutritionPalette.hero,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'EATEN / DAILY TARGET',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4),
                ),
              ),
              GestureDetector(
                onTap: onLogs,
                child: Text(
                  '$eatenMeals of $plannedMealCount meals',
                  style: const TextStyle(
                      color: NutritionPalette.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${consumed.calories.round()} / ${targets.calories.round()} kcal',
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress,
              backgroundColor: NutritionPalette.brand,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(NutritionPalette.accent),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _SummaryMacro(
                      label: 'Protein',
                      eaten: consumed.protein,
                      target: targets.protein)),
              Expanded(
                  child: _SummaryMacro(
                      label: 'Carbs',
                      eaten: consumed.carbs,
                      target: targets.carbs)),
              Expanded(
                  child: _SummaryMacro(
                      label: 'Fat', eaten: consumed.fat, target: targets.fat)),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Planned today: ${planned.calories.round()} kcal · ${planned.protein.round()}g protein',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMacro extends StatelessWidget {
  final String label;
  final double eaten;
  final double target;

  const _SummaryMacro(
      {required this.label, required this.eaten, required this.target});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          '${eaten.round()} / ${target.round()} g',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final DateTime date;
  final PlannedNutritionMeal meal;
  final NutritionRecipe recipe;
  final bool saved;
  final bool logged;
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final VoidCallback onSwap;
  final VoidCallback onLog;

  const _MealCard({
    required this.date,
    required this.meal,
    required this.recipe,
    required this.saved,
    required this.logged,
    required this.onOpen,
    required this.onSave,
    required this.onSwap,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NutritionPalette.line),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onOpen,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag:
                      'nutrition-meal-${NutritionStore.dateKey(date)}-${meal.slot}',
                  child: Material(
                    color: Colors.transparent,
                    child: NutritionArtwork(
                        artwork: recipe.artwork,
                        assetPath: recipe.artworkAsset),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${meal.slot.toUpperCase()} · ${meal.time}',
                              style: const TextStyle(
                                  color: NutritionPalette.brand,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (logged)
                            const Icon(Icons.check_circle_rounded,
                                color: NutritionPalette.brand, size: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(recipe.name,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              height: 1.15)),
                      const SizedBox(height: 6),
                      Text(
                          '${formatAmount(meal.servings)} serving · ${recipe.macros.scale(meal.servings).calories.round()} kcal',
                          style: const TextStyle(
                              color: NutritionPalette.muted, fontSize: 11)),
                      const SizedBox(height: 5),
                      NutritionMacroLine(
                          macros: recipe.macros, servings: meal.servings),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _MealAction(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Swap',
                      onTap: onSwap)),
              Expanded(
                  child: _MealAction(
                      icon: saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      label: saved ? 'Saved' : 'Save',
                      onTap: onSave)),
              Expanded(
                  child: _MealAction(
                      icon: logged
                          ? Icons.check_circle_rounded
                          : Icons.add_task_rounded,
                      label: logged ? 'Logged' : 'Log',
                      onTap: logged ? null : onLog)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MealAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MealAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          children: [
            Icon(icon,
                size: 18,
                color: onTap == null
                    ? NutritionPalette.muted
                    : NutritionPalette.brand),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: onTap == null
                        ? NutritionPalette.muted
                        : NutritionPalette.ink)),
          ],
        ),
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  final DateTime date;
  final int currentMl;
  final int goalMl;
  final String units;
  final List<Map<String, dynamic>> entries;
  final VoidCallback onRefresh;

  const _HydrationCard({
    required this.date,
    required this.currentMl,
    required this.goalMl,
    required this.units,
    required this.entries,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        goalMl <= 0 ? 0.0 : (currentMl / goalMl).clamp(0.0, 1.0).toDouble();
    final us = units == 'US customary';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NutritionPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE6F4FF),
                child: Icon(Icons.water_drop_rounded, color: Color(0xFF378BCC)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hydration',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900)),
                    Text('${_display(currentMl)} / ${_display(goalMl)}',
                        style: const TextStyle(
                            color: NutritionPalette.muted, fontSize: 12)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showHistory(context),
                child: const Text('History'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE6F4FF),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF55A7E4)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _WaterButton(
                      label: us ? '+8 oz' : '+250 ml',
                      onTap: () => _add(us ? 237 : 250))),
              const SizedBox(width: 8),
              Expanded(
                  child: _WaterButton(
                      label: us ? '+16 oz' : '+500 ml',
                      onTap: () => _add(us ? 473 : 500))),
              const SizedBox(width: 8),
              Expanded(
                  child: _WaterButton(
                      label: 'Custom', onTap: () => _custom(context))),
            ],
          ),
        ],
      ),
    );
  }

  String _display(int ml) {
    return units == 'US customary'
        ? '${(ml / 29.5735).round()} fl oz'
        : '$ml ml';
  }

  Future<void> _add(int ml) async {
    await NutritionStore.addWater(date, ml);
    onRefresh();
  }

  Future<void> _custom(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add water'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: 'Amount',
              suffixText: units == 'US customary' ? 'fl oz' : 'ml'),
          onSubmitted: (text) => Navigator.of(context).pop(int.tryParse(text)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(int.tryParse(controller.text)),
              child: const Text('Add')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value <= 0) {
      return;
    }
    final ml = units == 'US customary' ? (value * 29.5735).round() : value;
    await _add(ml);
  }

  Future<bool> _editWaterEntry(
    BuildContext dialogContext,
    Map<String, dynamic> entry,
  ) async {
    final currentMl = (entry['ml'] as num?)?.toInt() ?? 0;
    final us = units == 'US customary';
    final currentDisplay = us ? (currentMl / 29.5735).round() : currentMl;
    final controller = TextEditingController(text: '$currentDisplay');
    final value = await showDialog<int>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Edit water entry'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount',
            suffixText: us ? 'fl oz' : 'ml',
          ),
          onSubmitted: (text) => Navigator.of(context).pop(
            int.tryParse(text),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              int.tryParse(controller.text),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value <= 0) {
      return false;
    }
    final ml = us ? (value * 29.5735).round() : value;
    await NutritionStore.updateWater(
      entry['id']?.toString() ?? '',
      ml,
    );
    onRefresh();
    return true;
  }

  Future<void> _showHistory(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Water entries',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                    child: Text('No water logged for this date.',
                        style: TextStyle(color: NutritionPalette.muted))),
              )
            else
              ...entries.map((entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.water_drop_outlined),
                    title: Text(_display((entry['ml'] as num?)?.toInt() ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit water entry',
                          onPressed: () async {
                            final updated = await _editWaterEntry(
                              sheetContext,
                              entry,
                            );
                            if (updated && sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Undo water entry',
                          onPressed: () async {
                            await NutritionStore.deleteWater(
                              entry['id']?.toString() ?? '',
                            );
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          icon: const Icon(Icons.undo_rounded),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _WaterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _PlanData {
  final List<PlannedNutritionMeal> plan;
  final NutritionPreferences preferences;
  final NutritionMacros consumed;
  final NutritionMacros planned;
  final List<Map<String, dynamic>> foodLogs;
  final List<Map<String, dynamic>> waterEntries;
  final int waterMl;
  final Set<String> savedIds;

  const _PlanData({
    required this.plan,
    required this.preferences,
    required this.consumed,
    required this.planned,
    required this.foodLogs,
    required this.waterEntries,
    required this.waterMl,
    required this.savedIds,
  });
}
