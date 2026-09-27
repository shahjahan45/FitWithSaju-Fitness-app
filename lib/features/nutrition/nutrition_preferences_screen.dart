import 'package:flutter/material.dart';

import '../../core/motion/motion_widgets.dart';
import 'data/nutrition_models.dart';
import 'data/nutrition_store.dart';
import 'nutrition_widgets.dart';

class NutritionPreferencesScreen extends StatefulWidget {
  const NutritionPreferencesScreen({super.key});

  @override
  State<NutritionPreferencesScreen> createState() =>
      _NutritionPreferencesScreenState();
}

class _NutritionPreferencesScreenState
    extends State<NutritionPreferencesScreen> {
  NutritionPreferences? _value;
  bool _saving = false;

  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _water = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await NutritionStore.preferences();
    if (!mounted) {
      return;
    }
    setState(() {
      _value = value;
      _calories.text = value.calorieTarget.round().toString();
      _protein.text = value.proteinTarget.round().toString();
      _carbs.text = value.carbsTarget.round().toString();
      _fat.text = value.fatTarget.round().toString();
      _water.text = value.waterTargetMl.toString();
    });
  }

  @override
  void dispose() {
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _water.dispose();
    super.dispose();
  }

  void _replace({
    String? goal,
    List<String>? dietary,
    List<String>? allergies,
    List<String>? cuisines,
    String? budget,
    int? prepMinutes,
    String? units,
  }) {
    final value = _value;
    if (value == null) {
      return;
    }
    setState(() {
      _value = NutritionPreferences(
        goal: goal ?? value.goal,
        dietary: dietary ?? value.dietary,
        allergies: allergies ?? value.allergies,
        cuisines: cuisines ?? value.cuisines,
        budget: budget ?? value.budget,
        prepMinutes: prepMinutes ?? value.prepMinutes,
        units: units ?? value.units,
        calorieTarget: value.calorieTarget,
        proteinTarget: value.proteinTarget,
        carbsTarget: value.carbsTarget,
        fatTarget: value.fatTarget,
        waterTargetMl: value.waterTargetMl,
      );
    });
  }

  Future<void> _save() async {
    final value = _value;
    if (value == null || _saving) {
      return;
    }
    final calories = double.tryParse(_calories.text.trim());
    final protein = double.tryParse(_protein.text.trim());
    final carbs = double.tryParse(_carbs.text.trim());
    final fat = double.tryParse(_fat.text.trim());
    final water = int.tryParse(_water.text.trim());
    if (calories == null ||
        calories < 1000 ||
        calories > 6000 ||
        protein == null ||
        protein < 0 ||
        protein > 400 ||
        carbs == null ||
        carbs < 0 ||
        carbs > 800 ||
        fat == null ||
        fat < 0 ||
        fat > 300 ||
        water == null ||
        water < 500 ||
        water > 8000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please review your target values.')),
      );
      return;
    }
    setState(() => _saving = true);
    await NutritionStore.savePreferences(
      NutritionPreferences(
        goal: value.goal,
        dietary: value.dietary,
        allergies: value.allergies,
        cuisines: value.cuisines,
        budget: value.budget,
        prepMinutes: value.prepMinutes,
        units: value.units,
        calorieTarget: calories,
        proteinTarget: protein,
        carbsTarget: carbs,
        fatTarget: fat,
        waterTargetMl: water,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nutrition preferences saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = _value;
    return Scaffold(
      backgroundColor: NutritionPalette.canvas,
      appBar: AppBar(title: const Text('Nutrition preferences')),
      body: value == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  const MotionReveal(
                    child: Text(
                      'Make the plan fit you',
                      style: TextStyle(
                        color: NutritionPalette.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'These settings filter meal suggestions. Nutrition values are estimates and the targets below are user-configured, not medical advice.',
                    style: TextStyle(
                      color: NutritionPalette.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _PickerSection(
                    title: 'Goal',
                    values: const [
                      'Weight management',
                      'Muscle gain',
                      'Balanced eating',
                    ],
                    selected: <String>{value.goal},
                    onChanged: (item) => _replace(goal: item),
                    multi: false,
                  ),
                  _PickerSection(
                    title: 'Dietary preferences',
                    values: const ['Vegetarian', 'Vegan', 'Gluten-free'],
                    selected: value.dietary.toSet(),
                    onChanged: (item) {
                      final next = value.dietary.toSet();
                      next.contains(item) ? next.remove(item) : next.add(item);
                      if (item == 'Vegan' && next.contains('Vegan')) {
                        next.add('Vegetarian');
                      }
                      _replace(dietary: next.toList());
                    },
                  ),
                  _PickerSection(
                    title: 'Food allergies / exclusions',
                    subtitle:
                        'These are never silently relaxed during meal swaps.',
                    values: const [
                      'Dairy',
                      'Eggs',
                      'Fish',
                      'Gluten',
                      'Peanuts',
                      'Sesame',
                      'Soy',
                    ],
                    selected: value.allergies.toSet(),
                    onChanged: (item) {
                      final next = value.allergies.toSet();
                      next.contains(item) ? next.remove(item) : next.add(item);
                      _replace(allergies: next.toList());
                    },
                  ),
                  _PickerSection(
                    title: 'Preferred cuisines',
                    values: const [
                      'Middle Eastern',
                      'Mediterranean',
                      'Asian',
                      'International',
                    ],
                    selected: value.cuisines.toSet(),
                    onChanged: (item) {
                      final next = value.cuisines.toSet();
                      next.contains(item) ? next.remove(item) : next.add(item);
                      _replace(cuisines: next.toList());
                    },
                  ),
                  _PickerSection(
                    title: 'Budget',
                    values: const ['Economy', 'Moderate', 'Flexible'],
                    selected: <String>{value.budget},
                    onChanged: (item) => _replace(budget: item),
                    multi: false,
                  ),
                  _PickerSection(
                    title: 'Preparation time',
                    values: const ['15 min', '30 min', '45 min'],
                    selected: <String>{'${value.prepMinutes} min'},
                    onChanged: (item) =>
                        _replace(prepMinutes: int.parse(item.split(' ').first)),
                    multi: false,
                  ),
                  _PickerSection(
                    title: 'Measurement units',
                    values: const ['Metric', 'US customary'],
                    selected: <String>{value.units},
                    onChanged: (item) => _replace(units: item),
                    multi: false,
                  ),
                  const SizedBox(height: 8),
                  const NutritionSectionTitle(title: 'Daily targets'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: NutritionPalette.line),
                    ),
                    child: Column(
                      children: [
                        _NumberField(
                            controller: _calories,
                            label: 'Energy',
                            suffix: 'kcal'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: _NumberField(
                                    controller: _protein,
                                    label: 'Protein',
                                    suffix: 'g')),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _NumberField(
                                    controller: _carbs,
                                    label: 'Carbs',
                                    suffix: 'g')),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: _NumberField(
                                    controller: _fat,
                                    label: 'Fat',
                                    suffix: 'g')),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _NumberField(
                                    controller: _water,
                                    label: 'Water',
                                    suffix: 'ml')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: NutritionPalette.brand,
                        foregroundColor: Colors.white,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save preferences',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PickerSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onChanged;
  final bool multi;

  const _PickerSection({
    required this.title,
    required this.values,
    required this.selected,
    required this.onChanged,
    this.subtitle,
    this.multi = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: const TextStyle(
                    color: NutritionPalette.muted, fontSize: 12)),
          ],
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((item) {
              final active = selected.contains(item);
              return FilterChip(
                selected: active,
                showCheckmark: multi,
                label: Text(item),
                onSelected: (_) => onChanged(item),
                selectedColor: NutritionPalette.tint,
                side: BorderSide(
                    color: active
                        ? NutritionPalette.brand
                        : NutritionPalette.line),
                labelStyle: TextStyle(
                  color: active ? NutritionPalette.brand : NutritionPalette.ink,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;

  const _NumberField(
      {required this.controller, required this.label, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, suffixText: suffix),
    );
  }
}
