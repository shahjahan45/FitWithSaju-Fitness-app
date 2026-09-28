import 'package:flutter/material.dart';

import '../../core/navigation/settled_dialog.dart';

import '../../core/motion/motion_widgets.dart';
import 'data/nutrition_catalog.dart';
import 'data/nutrition_models.dart';
import 'data/nutrition_store.dart';
import 'nutrition_bottom_sheet_safe_area.dart';
import 'nutrition_widgets.dart';

class MealDetailScreen extends StatefulWidget {
  final DateTime date;
  final PlannedNutritionMeal meal;
  final bool planned;

  const MealDetailScreen({
    super.key,
    required this.date,
    required this.meal,
    this.planned = true,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late PlannedNutritionMeal _meal;
  int _yield = 1;
  bool _saved = false;

  NutritionRecipe get _recipe =>
      NutritionCatalog.byId(_meal.recipeId) ?? NutritionCatalog.recipes.first;

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
    _yield = _recipe.yieldServings;
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await NutritionStore.savedMealIds();
    if (!mounted) {
      return;
    }
    setState(() => _saved = saved.contains(_recipe.id));
  }

  Future<void> _toggleSaved() async {
    final value = await NutritionStore.toggleSavedMeal(_recipe.id);
    if (!mounted) {
      return;
    }
    setState(() => _saved = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(value ? 'Meal saved.' : 'Removed from saved meals.')),
    );
  }

  Future<void> _swap() async {
    final prefs = await NutritionStore.preferences();
    if (!mounted) {
      return;
    }
    final alternatives = NutritionStore.compatibleAlternatives(
      current: _recipe,
      preferences: prefs,
    );
    final chosen = await showSettledModalBottomSheet<NutritionRecipe>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      builder: (sheetContext) => _SwapSheet(
        current: _recipe,
        alternatives: alternatives,
      ),
    );
    if (chosen == null || !mounted) {
      return;
    }

    final previous = _recipe;
    await NutritionStore.swapMeal(
      date: widget.date,
      slot: _meal.slot,
      recipeId: chosen.id,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _meal = PlannedNutritionMeal(
        slot: _meal.slot,
        recipeId: chosen.id,
        time: _meal.time,
        servings: _meal.servings,
      );
      _yield = chosen.yieldServings;
      _saved = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${chosen.name} added to ${_meal.slot.toLowerCase()}.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await NutritionStore.swapMeal(
              date: widget.date,
              slot: _meal.slot,
              recipeId: previous.id,
            );
            if (!mounted) {
              return;
            }
            setState(() {
              _meal = PlannedNutritionMeal(
                slot: _meal.slot,
                recipeId: previous.id,
                time: _meal.time,
                servings: _meal.servings,
              );
              _yield = previous.yieldServings;
            });
          },
        ),
      ),
    );
  }

  Future<void> _logMeal() async {
    var servings = _meal.servings;
    final result = await showSettledModalBottomSheet<double>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => NutritionBottomSheetSafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log this meal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose the amount you actually ate. Historical nutrition is saved as a snapshot.',
                style: TextStyle(color: NutritionPalette.muted, height: 1.4),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: servings > .25
                        ? () => setSheetState(() => servings -= .25)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${formatAmount(servings)} serving${servings == 1 ? '' : 's'}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 3),
                        NutritionMacroLine(
                            macros: _recipe.macros, servings: servings),
                      ],
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
    if (result == null || !mounted) {
      return;
    }
    final added = await NutritionStore.logMeal(
      date: widget.date,
      recipe: _recipe,
      servings: result,
      sourceKey: widget.planned
          ? '${NutritionStore.dateKey(widget.date)}:${_meal.slot}'
          : 'extra:${NutritionStore.dateKey(widget.date)}:${_recipe.id}',
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Meal logged successfully.'
              : 'This planned meal is already logged. Edit or undo the existing log first.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    final yieldFactor = _yield / recipe.yieldServings;
    return Scaffold(
      backgroundColor: NutritionPalette.canvas,
      appBar: AppBar(
        title: Text(recipe.slot),
        actions: [
          IconButton(
            tooltip: _saved ? 'Remove from saved meals' : 'Save meal',
            onPressed: _toggleSaved,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                key: ValueKey(_saved),
                color: _saved ? NutritionPalette.brand : NutritionPalette.ink,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
          children: [
            MotionReveal(
              child: Hero(
                tag:
                    'nutrition-meal-${NutritionStore.dateKey(widget.date)}-${_meal.slot}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    height: 230,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: NutritionPalette.tint,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: recipe.artworkAsset == null
                        ? Text(
                            recipe.artwork,
                            style: const TextStyle(fontSize: 96),
                          )
                        : Image.asset(
                            recipe.artworkAsset!,
                            width: 190,
                            height: 190,
                            fit: BoxFit.contain,
                            semanticLabel: 'Meal illustration',
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            MotionReveal(
              delay: const Duration(milliseconds: 50),
              child: Text(
                recipe.name,
                style: const TextStyle(
                  color: NutritionPalette.ink,
                  fontSize: 30,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                NutritionInfoPill(
                    text: '${recipe.prepMinutes} min',
                    icon: Icons.schedule_rounded),
                NutritionInfoPill(text: recipe.cuisine),
                ...recipe.dietaryTags
                    .map((tag) => NutritionInfoPill(text: tag)),
              ],
            ),
            if (recipe.allergens.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Allergens: ${recipe.allergens.join(', ')}',
                style: const TextStyle(
                  color: NutritionPalette.warning,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: NutritionPalette.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimated nutrition per serving',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 9),
                  NutritionMacroLine(macros: recipe.macros),
                  const SizedBox(height: 8),
                  Text(
                    recipe.servingLabel,
                    style: const TextStyle(
                        color: NutritionPalette.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const NutritionSectionTitle(title: 'Recipe yield'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NutritionPalette.line),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed:
                        _yield > 1 ? () => setState(() => _yield--) : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text('$_yield servings',
                            style:
                                const TextStyle(fontWeight: FontWeight.w900)),
                        const Text(
                          'Ingredient quantities scale; nutrition per serving stays the same.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: NutritionPalette.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _yield < 12 ? () => setState(() => _yield++) : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const NutritionSectionTitle(title: 'Ingredients'),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 18, color: NutritionPalette.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(ingredient.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      '${formatAmount(ingredient.quantity * yieldFactor)} ${ingredient.unit}',
                      style: const TextStyle(
                          color: NutritionPalette.muted,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const NutritionSectionTitle(title: 'How to prepare'),
            const SizedBox(height: 8),
            ...List.generate(recipe.instructions.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: NutritionPalette.tint,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: NutritionPalette.brand,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recipe.instructions[index],
                        style: const TextStyle(height: 1.45),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
            Row(
              children: [
                if (widget.planned) ...[
                  Expanded(
                      child: NutritionSoftButton(
                          label: 'Swap meal',
                          icon: Icons.swap_horiz_rounded,
                          onTap: _swap)),
                  const SizedBox(width: 10),
                ],
                Expanded(
                    child: NutritionSoftButton(
                        label: _saved ? 'Saved' : 'Save',
                        icon: Icons.bookmark_rounded,
                        onTap: _toggleSaved)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: NutritionPalette.brand),
                onPressed: _logMeal,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Log this meal',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapSheet extends StatelessWidget {
  final NutritionRecipe current;
  final List<NutritionRecipe> alternatives;

  const _SwapSheet({required this.current, required this.alternatives});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .78,
      child: NutritionBottomSheetSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Swap meal',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(
              'Alternatives respect your stored allergies and dietary exclusions.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            if (alternatives.isEmpty)
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'No suitable alternatives match your current restrictions. Edit preferences if you want to broaden non-allergy preferences.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: NutritionPalette.muted, height: 1.5),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: alternatives.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final recipe = alternatives[index];
                    final kcalDiff =
                        recipe.macros.calories - current.macros.calories;
                    final proteinDiff =
                        recipe.macros.protein - current.macros.protein;
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.of(context).pop(recipe),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: NutritionPalette.line),
                          ),
                          child: Row(
                            children: [
                              NutritionArtwork(
                                  artwork: recipe.artwork,
                                  assetPath: recipe.artworkAsset,
                                  networkUrl: recipe.imageUrl,
                                  size: 72),
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
                                          fontSize: 12),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${kcalDiff >= 0 ? '+' : ''}${kcalDiff.round()} kcal · ${proteinDiff >= 0 ? '+' : ''}${proteinDiff.round()}g protein',
                                      style: const TextStyle(
                                          color: NutritionPalette.brand,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: NutritionPalette.muted),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
