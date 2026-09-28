import 'package:flutter/material.dart';

import '../../core/motion/motion_widgets.dart';
import '../../core/navigation/settled_dialog.dart';
import 'data/nutrition_catalog.dart';
import 'data/nutrition_models.dart';
import 'data/nutrition_plan_catalog.dart';
import 'data/nutrition_store.dart';
import 'nutrition_preferences_screen.dart';
import 'nutrition_widgets.dart';

class NutritionPlanTemplatesScreen extends StatelessWidget {
  final DateTime anchorDate;

  const NutritionPlanTemplatesScreen({super.key, required this.anchorDate});

  @override
  Widget build(BuildContext context) {
    final monday = NutritionStore.weekStart(anchorDate);
    return Scaffold(
      backgroundColor: NutritionPalette.canvas,
      appBar: AppBar(title: const Text('Meal Plan Library')),
      body: ValueListenableBuilder<int>(
        valueListenable: NutritionStore.changes,
        builder: (context, _, __) => FutureBuilder<String?>(
          future: NutritionStore.activeTemplateIdForWeek(anchorDate),
          builder: (context, activeSnapshot) {
            final activeId = activeSnapshot.data;
            return ValueListenableBuilder<List<NutritionMealPlanTemplate>>(
              valueListenable: NutritionPlanCatalog.listenable,
              builder: (context, templates, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    MotionReveal(
                      child: _PlanLibraryHero(monday: monday),
                    ),
                    const SizedBox(height: 18),
                    ...List.generate(templates.length, (index) {
                      final template = templates[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: MotionReveal(
                          delay: Duration(milliseconds: 45 * index),
                          child: _TemplateCard(
                            template: template,
                            active: template.id == activeId,
                            onApply: () => _apply(context, template),
                          ),
                        ),
                      );
                    }),
                    if (activeId != null) ...[
                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: () => _clearWeek(context),
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Reset this week to automatic plan'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const _NutritionQualityNote(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _apply(
    BuildContext context,
    NutritionMealPlanTemplate template,
  ) async {
    final confirmed = await showSettledDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Apply ${template.name}?'),
        content: const Text(
          'This replaces the planned meals for Monday–Sunday of the selected week. Food already logged as eaten and hydration history are preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Apply Plan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final preferences = await NutritionStore.preferences();
    final result = await NutritionStore.applyTemplate(
      template: template,
      anchorDate: anchorDate,
      preferences: preferences,
    );
    if (!context.mounted) {
      return;
    }

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${template.name} is ready for this week.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final edit = await showSettledDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Plan not applied'),
        content: Text(
          '${result.message}\n\n${result.blockedMeals.take(5).join('\n')}${result.blockedMeals.length > 5 ? '\n…' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Edit Preferences'),
          ),
        ],
      ),
    );
    if (edit == true && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const NutritionPreferencesScreen(),
        ),
      );
    }
  }

  Future<void> _clearWeek(BuildContext context) async {
    final confirmed = await showSettledDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset planned week?'),
        content: const Text(
          'The selected template will be removed and FitWithSaju will regenerate its automatic daily plan. Food logs and water entries are not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset Week'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await NutritionStore.clearWeek(anchorDate);
    }
  }
}

class _PlanLibraryHero extends StatelessWidget {
  final DateTime monday;

  const _PlanLibraryHero({required this.monday});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [NutritionPalette.hero, NutritionPalette.brand],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: NutritionPalette.accent.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'WEEKLY PROGRAMS',
              style: TextStyle(
                color: NutritionPalette.accent,
                fontSize: 11,
                letterSpacing: .6,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Choose a plan. Keep full control.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.08,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Apply a complete Monday–Sunday structure to the week of ${nutritionLongDate(monday)}. You can still swap, save, log, or adjust individual meals afterward.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .82),
              height: 1.45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final NutritionMealPlanTemplate template;
  final bool active;
  final VoidCallback onApply;

  const _TemplateCard({
    required this.template,
    required this.active,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _TemplateStats.from(template);
    final isHighProtein = template.id == 'high-protein-7-day';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: active ? NutritionPalette.accent : NutritionPalette.line,
          width: active ? 1.6 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A16261E),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isHighProtein
                        ? NutritionPalette.accent.withValues(alpha: .16)
                        : NutritionPalette.tint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isHighProtein
                        ? Icons.fitness_center_rounded
                        : Icons.eco_rounded,
                    color: NutritionPalette.brand,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (active)
                        const Text(
                          'ACTIVE THIS WEEK',
                          style: TextStyle(
                            color: NutritionPalette.brand,
                            fontSize: 10,
                            letterSpacing: .5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      Text(
                        template.name,
                        style: const TextStyle(
                          fontSize: 19,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          color: NutritionPalette.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(
              template.description,
              style: const TextStyle(
                color: NutritionPalette.muted,
                height: 1.45,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                const _StatPill(
                    label: '7 days', icon: Icons.calendar_month_outlined),
                _StatPill(
                    label: '${stats.mealsPerDay} meals/day',
                    icon: Icons.restaurant_outlined),
                _StatPill(
                  label:
                      '${stats.minProtein.round()}–${stats.maxProtein.round()} g protein/day',
                  icon: Icons.fitness_center_rounded,
                ),
                _StatPill(
                  label: '~${stats.averageCalories.round()} kcal/day',
                  icon: Icons.local_fire_department_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isHighProtein) ...[
              const _ProteinWeekPreview(),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: active ? null : onApply,
                icon: Icon(active
                    ? Icons.check_circle_rounded
                    : Icons.auto_awesome_rounded),
                label: Text(
                    active ? 'Applied to this week' : 'Apply to selected week'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProteinWeekPreview extends StatelessWidget {
  const _ProteinWeekPreview();

  @override
  Widget build(BuildContext context) {
    const values = <int>[190, 195, 195, 200, 190, 205, 200];
    const labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: NutritionPalette.tint.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Protein across the week',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '≈196 g/day avg',
                style: TextStyle(
                  color: NutritionPalette.brand,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (index) {
              final factor = values[index] / 205;
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      '${values[index]}',
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 46 * factor,
                      width: 12,
                      decoration: BoxDecoration(
                        color: NutritionPalette.brand,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        color: NutritionPalette.muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: NutritionPalette.canvas,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: NutritionPalette.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: NutritionPalette.brand),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _NutritionQualityNote extends StatelessWidget {
  const _NutritionQualityNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NutritionPalette.line),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: NutritionPalette.brand),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'High-protein plan values are planning estimates. Protein amounts follow the supplied reference; calorie, carbohydrate, and fat values are estimated until reviewed. Adjust portions to your own goals and dietary needs.',
              style: TextStyle(
                color: NutritionPalette.muted,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateStats {
  final int mealsPerDay;
  final double minProtein;
  final double maxProtein;
  final double averageCalories;

  const _TemplateStats({
    required this.mealsPerDay,
    required this.minProtein,
    required this.maxProtein,
    required this.averageCalories,
  });

  factory _TemplateStats.from(NutritionMealPlanTemplate template) {
    final proteins = <double>[];
    final calories = <double>[];
    var maxMeals = 0;
    for (var weekday = 1; weekday <= 7; weekday++) {
      final meals = template.mealsForWeekday(weekday);
      if (meals.length > maxMeals) {
        maxMeals = meals.length;
      }
      var protein = 0.0;
      var kcal = 0.0;
      for (final meal in meals) {
        final recipe = NutritionCatalog.byId(meal.recipeId);
        if (recipe != null) {
          protein += recipe.macros.protein * meal.servings;
          kcal += recipe.macros.calories * meal.servings;
        }
      }
      if (meals.isNotEmpty) {
        proteins.add(protein);
        calories.add(kcal);
      }
    }
    final minProtein =
        proteins.isEmpty ? 0.0 : proteins.reduce((a, b) => a < b ? a : b);
    final maxProtein =
        proteins.isEmpty ? 0.0 : proteins.reduce((a, b) => a > b ? a : b);
    final averageCalories = calories.isEmpty
        ? 0.0
        : calories.reduce((a, b) => a + b) / calories.length;
    return _TemplateStats(
      mealsPerDay: maxMeals,
      minProtein: minProtein,
      maxProtein: maxProtein,
      averageCalories: averageCalories,
    );
  }
}
