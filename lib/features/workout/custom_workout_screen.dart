import 'package:flutter/material.dart';

import '../../core/widgets/app_screen.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../data/exercise_catalog.dart';
import '../../data/models/exercise.dart';

class CustomWorkoutScreen extends StatefulWidget {
  final Map<String, dynamic>? workout;

  const CustomWorkoutScreen({
    super.key,
    this.workout,
  });

  @override
  State<CustomWorkoutScreen> createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _searchController;
  late final Set<String> _selected;
  bool _saving = false;
  String _query = '';

  bool get isEditing => widget.workout != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: (widget.workout?['name'] ?? 'My Workout').toString(),
    );
    _searchController = TextEditingController();
    _selected = ((widget.workout?['exerciseIds'] as Iterable?) ?? const [])
        .map((e) => e.toString())
        .toSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Exercise> get _filteredExercises {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return ExerciseCatalog.instance.exercises;
    }
    return ExerciseCatalog.instance.exercises.where((exercise) {
      final text = '${exercise.name} ${exercise.muscle} ${exercise.equipment}'
          .toLowerCase();
      return text.contains(query);
    }).toList();
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose at least one exercise.')),
      );
      return;
    }
    setState(() => _saving = true);
    await LocalStore.saveCustomWorkout(
      id: widget.workout?['id']?.toString(),
      name: _nameController.text,
      exerciseIds: _selected.toList(),
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Workout' : 'Create Workout'),
      ),
      body: ListView(
        padding: fitPagePadding(context, bottom: 30),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Workout name',
              prefixIcon: Icon(Icons.edit_rounded),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Choose exercises',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${_selected.length} selected',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search exercise, muscle or equipment',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          if (_filteredExercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_off_rounded, color: AppColors.muted),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No exercises match this search.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ..._filteredExercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: AppColors.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _selected.contains(exercise.id)
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: CheckboxListTile(
                  value: _selected.contains(exercise.id),
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  secondary: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${exercise.muscle} • ${exercise.equipment}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selected.add(exercise.id);
                      } else {
                        _selected.remove(exercise.id);
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 58,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded),
              label: Text(
                isEditing ? 'Update Workout' : 'Save Workout',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
