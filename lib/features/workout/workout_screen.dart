import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/workout_factory.dart';
import 'active_workout_screen.dart';
import 'custom_workout_screen.dart';
import 'day_plan_editor_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<Map<String, dynamic>> _plan = [];
  List<Map<String, dynamic>> _custom = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      LocalStore.weeklyPlan(),
      LocalStore.customWorkouts(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _plan = results[0];
      _custom = results[1];
      _loading = false;
    });
  }

  Future<void> _editDay(Map<String, dynamic> item) async {
    final changed = await Navigator.of(context).push<bool>(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.detail,
        builder: (_) => DayPlanEditorScreen(plan: item),
      ),
    );
    if (changed == true) {
      await _load();
    }
  }

  Future<void> _copyDay(String fromDay) async {
    final toDay = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          children: [
            const Text(
              'Copy workout to',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ...LocalStore.weekDays.where((day) => day != fromDay).map(
                  (day) => ListTile(
                    title: Text(day),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(sheetContext).pop(day),
                  ),
                ),
          ],
        ),
      ),
    );
    if (toDay == null) {
      return;
    }
    await LocalStore.copyDayPlan(fromDay, toDay);
    await _load();
  }

  Future<void> _createWorkout([Map<String, dynamic>? workout]) async {
    final changed = await Navigator.of(context).push<bool>(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.detail,
        builder: (_) => CustomWorkoutScreen(workout: workout),
      ),
    );
    if (changed == true) {
      await _load();
    }
  }

  void _startMapWorkout(Map<String, dynamic> map, {bool custom = false}) {
    final workout = custom
        ? WorkoutFactory.fromCustom(map)
        : WorkoutFactory.fromPlan(map);
    if (workout.exercises.isEmpty) {
      return;
    }
    Navigator.of(context).push(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.fullScreen,
        builder: (_) => ActiveWorkoutScreen(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              key: const PageStorageKey('workout-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                const Text(
                  'Workout',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Plan your week. Train one day at a time.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Weekly plan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      'Tap a day to edit',
                      style: TextStyle(
                        color: AppColors.muted.withValues(alpha: .9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._plan.map((item) {
                  final isRest = item['isRest'] == true;
                  final exerciseCount =
                      ((item['exerciseIds'] as Iterable?) ?? const []).length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FitCard(
                      onTap: () => _editDay(item),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: isRest
                                  ? AppColors.surfaceAlt
                                  : AppColors.primary.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isRest
                                  ? Icons.bedtime_outlined
                                  : Icons.fitness_center_rounded,
                              color: isRest ? AppColors.muted : AppColors.primary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['day'].toString(),
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['title'].toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                                if (!isRest)
                                  Text(
                                    '$exerciseCount exercises • ${item['durationMinutes']} min',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'copy') {
                                await _copyDay(item['day'].toString());
                              } else if (value == 'rest') {
                                await LocalStore.setRestDay(item['day'].toString());
                                await _load();
                              } else if (value == 'start') {
                                _startMapWorkout(item);
                              }
                            },
                            itemBuilder: (_) => [
                              if (!isRest)
                                const PopupMenuItem(
                                  value: 'start',
                                  child: Text('Start workout'),
                                ),
                              if (!isRest)
                                const PopupMenuItem(
                                  value: 'copy',
                                  child: Text('Copy to another day'),
                                ),
                              const PopupMenuItem(
                                value: 'rest',
                                child: Text('Set as rest day'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'My workouts',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Create workout',
                      onPressed: _createWorkout,
                      icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_custom.isEmpty)
                  FitCard(
                    onTap: _createWorkout,
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primarySoft,
                          child: Icon(Icons.add_rounded, color: AppColors.primary),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create your first workout',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Choose exercises and save it on this device.',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._custom.map((item) {
                    final count = ((item['exerciseIds'] as Iterable?) ?? const []).length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: AppColors.surface,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primarySoft,
                          child: Icon(Icons.bolt_rounded, color: AppColors.primary),
                        ),
                        title: Text(
                          item['name'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text('$count exercises'),
                        onTap: () => _startMapWorkout(item, custom: true),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await _createWorkout(item);
                            } else if (value == 'delete') {
                              await LocalStore.deleteCustomWorkout(item['id'].toString());
                              await _load();
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 18),
                SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _createWorkout,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Create Custom Workout',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
