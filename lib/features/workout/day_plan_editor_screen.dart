import 'package:flutter/material.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../data/exercise_catalog.dart';
import '../../data/models/exercise.dart';

class DayPlanEditorScreen extends StatefulWidget {
  final Map<String, dynamic> plan;

  const DayPlanEditorScreen({
    super.key,
    required this.plan,
  });

  @override
  State<DayPlanEditorScreen> createState() => _DayPlanEditorScreenState();
}

class _DayPlanEditorScreenState extends State<DayPlanEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _durationController;
  late final TextEditingController _searchController;
  late final Set<String> _selected;
  late bool _isRest;
  bool _saving = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: (widget.plan['title'] ?? 'Workout').toString(),
    );
    _durationController = TextEditingController(
      text:
          ((widget.plan['durationMinutes'] as num?)?.toInt() ?? 45).toString(),
    );
    _searchController = TextEditingController();
    _selected = ((widget.plan['exerciseIds'] as Iterable?) ?? const [])
        .map((e) => e.toString())
        .toSet();
    _isRest = widget.plan['isRest'] == true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
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
    if (!_isRest && _selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose at least one exercise.')),
      );
      return;
    }
    setState(() => _saving = true);
    final duration = int.tryParse(_durationController.text.trim()) ?? 45;
    await LocalStore.saveDayPlan(<String, dynamic>{
      'day': widget.plan['day'],
      'title': _isRest
          ? 'Rest'
          : (_titleController.text.trim().isEmpty
              ? 'Workout'
              : _titleController.text.trim()),
      'isRest': _isRest,
      'durationMinutes': _isRest ? 0 : duration.clamp(10, 180),
      'exerciseIds': _isRest ? <String>[] : _selected.toList(),
    });
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.plan['day']} Plan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(horizontal: 2),
            title: const Text(
              'Rest day',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text('No exercises scheduled for this day.'),
            value: _isRest,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primarySoft,
            onChanged: (value) => setState(() => _isRest = value),
          ),
          const SizedBox(height: 14),
          if (!_isRest) ...[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Workout name',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Estimated duration',
                suffixText: 'min',
                prefixIcon: Icon(Icons.schedule_rounded),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Exercises',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose the movements for this day. Your selection is saved locally.',
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 14),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${exercise.muscle} • ${exercise.equipment}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    secondary: const Icon(
                      Icons.fitness_center_rounded,
                      color: AppColors.primary,
                    ),
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
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 58,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
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
                _isRest ? 'Save Rest Day' : 'Save Day Plan',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
