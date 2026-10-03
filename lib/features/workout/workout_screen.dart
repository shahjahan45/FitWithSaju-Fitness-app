import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/navigation/settled_dialog.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/workout_factory.dart';
import '../recovery/readiness_summary_card.dart';
import '../recovery/smart_training_guidance_card.dart';
import '../recovery/training_balance_summary_card.dart';
import 'active_program_screen.dart';
import 'active_workout_screen.dart';
import 'custom_workout_screen.dart';
import 'day_plan_editor_screen.dart';
import 'workout_programs_screen.dart';
import 'workout_calendar_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<Map<String, dynamic>> _plan = [];
  List<Map<String, dynamic>> _custom = [];
  Map<String, dynamic>? _activeDraft;
  Map<String, dynamic>? _activeProgram;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = await LocalStore.weeklyPlan();
    final custom = await LocalStore.customWorkouts();
    final activeDraft = await LocalStore.activeWorkout();
    final activeProgram = await LocalStore.activeProgram();
    if (!mounted) {
      return;
    }
    setState(() {
      _plan = plan;
      _custom = custom;
      _activeDraft = activeDraft;
      _activeProgram = activeProgram;
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

  Future<void> _openPrograms() async {
    final changed = await Navigator.of(context).push<bool>(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.detail,
        builder: (_) => const WorkoutProgramsScreen(),
      ),
    );
    if (changed == true) {
      await _load();
    }
  }

  Future<void> _openActiveProgram() async {
    final changed = await Navigator.of(context).push<bool>(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.detail,
        builder: (_) => const ActiveProgramScreen(),
      ),
    );
    if (changed == true) {
      await _load();
    }
  }

  Future<void> _openCalendar() async {
    await Navigator.of(context).push(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.detail,
        builder: (_) => const WorkoutCalendarScreen(),
      ),
    );
    await _load();
  }

  Future<void> _copyDay(String fromDay) async {
    final toDay = await showSettledModalBottomSheet<String>(
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
                  (day) => Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      title: Text(day),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(sheetContext).pop(day),
                    ),
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

  Future<void> _startMapWorkout(
    Map<String, dynamic> map, {
    bool custom = false,
  }) async {
    if (_activeDraft != null) {
      final discard = await showSettledDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Workout already in progress'),
          content: Text(
            '${_activeDraft!['title'] ?? 'A workout'} is saved for resuming. Discard it before starting another workout?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep it'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Discard & start'),
            ),
          ],
        ),
      );
      if (discard != true) {
        return;
      }
      await LocalStore.clearActiveWorkout();
      if (!mounted) {
        return;
      }
      _activeDraft = null;
    }

    final workout =
        custom ? WorkoutFactory.fromCustom(map) : WorkoutFactory.fromPlan(map);
    if (workout.exercises.isEmpty) {
      return;
    }
    await Navigator.of(context).push(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.fullScreen,
        builder: (_) => ActiveWorkoutScreen(workout: workout),
      ),
    );
    await _load();
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
                const MotionReveal(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Plan your week. Train one day at a time.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const MotionReveal(
                  delay: Duration(milliseconds: 25),
                  child:
                      ReadinessSummaryCard(eyebrow: 'RECOVERY BEFORE TRAINING'),
                ),
                const SizedBox(height: 12),
                const MotionReveal(
                  delay: Duration(milliseconds: 40),
                  child: SmartTrainingGuidanceCard(),
                ),
                const SizedBox(height: 12),
                const MotionReveal(
                  delay: Duration(milliseconds: 55),
                  child: TrainingBalanceSummaryCard(
                    eyebrow: 'WEEKLY TRAINING BALANCE',
                  ),
                ),
                const SizedBox(height: 16),
                if (_activeProgram != null) ...[
                  MotionReveal(
                    delay: const Duration(milliseconds: 40),
                    child: _ActiveProgramCard(
                      program: _activeProgram!,
                      onTap: _openActiveProgram,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MotionReveal(
                    delay: const Duration(milliseconds: 55),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openCalendar,
                            icon: const Icon(Icons.calendar_month_rounded),
                            label: const Text('Training calendar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_activeDraft != null) ...[
                  MotionReveal(
                    delay: const Duration(milliseconds: 55),
                    child: _ResumeDraftCard(
                      draft: _activeDraft!,
                      onResume: () async {
                        final workout = WorkoutFactory.fromDraft(_activeDraft!);
                        if (workout.exercises.isEmpty) {
                          return;
                        }
                        await Navigator.of(context).push(
                          FitRoutes.route(
                            context,
                            motion: FitRouteMotion.fullScreen,
                            builder: (_) => ActiveWorkoutScreen(
                              workout: workout,
                              resumeDraft: _activeDraft,
                            ),
                          ),
                        );
                        await _load();
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                MotionReveal(
                  delay: const Duration(milliseconds: 90),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly plan',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tap a day to edit',
                              style: TextStyle(
                                  color: AppColors.muted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _openPrograms,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: const Text('Programs'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ..._plan.map((item) {
                  final isRest = item['isRest'] == true;
                  final exerciseCount =
                      ((item['exerciseIds'] as Iterable?) ?? const []).length;
                  return MotionReveal(
                    delay: const Duration(milliseconds: 120),
                    child: Padding(
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
                                color: isRest
                                    ? AppColors.muted
                                    : AppColors.primary,
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
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900),
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
                                  await LocalStore.setRestDay(
                                      item['day'].toString());
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
                    ),
                  );
                }),
                const SizedBox(height: 20),
                MotionReveal(
                  delay: const Duration(milliseconds: 180),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'My workouts',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Create workout',
                        onPressed: _createWorkout,
                        icon: const Icon(Icons.add_circle_rounded,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_custom.isEmpty)
                  FitCard(
                    onTap: _createWorkout,
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primarySoft,
                          child:
                              Icon(Icons.add_rounded, color: AppColors.primary),
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
                    final count =
                        ((item['exerciseIds'] as Iterable?) ?? const []).length;
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
                            child: Icon(Icons.bolt_rounded,
                                color: AppColors.primary),
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
                                await LocalStore.deleteCustomWorkout(
                                    item['id'].toString());
                                await _load();
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
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

class _ActiveProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final VoidCallback onTap;

  const _ActiveProgramCard({required this.program, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final startedAt = DateTime.tryParse(program['startedAt']?.toString() ?? '');
    final weeks = (program['durationWeeks'] as num?)?.toInt() ?? 1;
    final elapsed = startedAt == null
        ? 0
        : DateTime.now().difference(startedAt).inDays.clamp(0, 9999);
    final week = (elapsed ~/ 7 + 1).clamp(1, weeks);
    return Material(
      color: AppColors.text,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child:
                    const Icon(Icons.route_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACTIVE PROGRAM',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      program['name']?.toString() ?? 'Workout Program',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Week $week of $weeks • ${program['trainingDays']} days/week',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumeDraftCard extends StatelessWidget {
  final Map<String, dynamic> draft;
  final VoidCallback onResume;

  const _ResumeDraftCard({
    required this.draft,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final completed = ((draft['sets'] as Iterable?) ?? const []).length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primarySoft,
            AppColors.secondarySoft.withValues(alpha: .45),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(Icons.play_arrow_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESUME WORKOUT',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  draft['title']?.toString() ?? 'Workout',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '$completed completed sets saved',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onResume,
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }
}
