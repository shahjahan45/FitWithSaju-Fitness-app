import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/navigation/settled_dialog.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/workout_factory.dart';
import '../../data/workout_program_catalog.dart';
import 'active_workout_screen.dart';

class ActiveProgramScreen extends StatefulWidget {
  const ActiveProgramScreen({super.key});

  @override
  State<ActiveProgramScreen> createState() => _ActiveProgramScreenState();
}

class _ActiveProgramScreenState extends State<ActiveProgramScreen> {
  Map<String, dynamic>? _active;
  WorkoutProgramDefinition? _definition;
  List<Map<String, dynamic>> _history = const [];
  List<Map<String, dynamic>> _plan = const [];
  WorkoutProgramProgress? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final active = await LocalStore.activeProgram();
    final history = await LocalStore.history();
    final plan = await LocalStore.weeklyPlan();
    final definition = active == null
        ? null
        : WorkoutProgramCatalog.find(active['programId']?.toString() ?? '');
    final progress = active == null
        ? null
        : WorkoutProgramProgress.calculate(
            activeProgram: active,
            history: history,
          );
    if (!mounted) {
      return;
    }
    setState(() {
      _active = active;
      _history = history;
      _plan = plan;
      _definition = definition;
      _progress = progress;
      _loading = false;
    });
  }

  Future<void> _startToday() async {
    final today = LocalStore.weekDays[DateTime.now().weekday - 1];
    Map<String, dynamic>? todayPlan;
    for (final item in _plan) {
      if (item['day'] == today) {
        todayPlan = item;
        break;
      }
    }
    if (todayPlan == null || todayPlan['isRest'] == true) {
      return;
    }

    final draft = await LocalStore.activeWorkout();
    if (!mounted) {
      return;
    }
    if (draft != null) {
      final discard = await showSettledDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Workout already in progress'),
          content: Text(
            '${draft['title'] ?? 'A workout'} is saved for resuming. Discard it before starting today’s program session?',
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
    }

    final workout = WorkoutFactory.fromPlan(todayPlan);
    if (workout.exercises.isEmpty || !mounted) {
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

  Future<void> _endProgram() async {
    final progress = _progress;
    if (progress == null) {
      return;
    }
    final completed = progress.completion >= 1;
    final confirmed = await showSettledDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(completed ? 'Finish this program?' : 'End active program?'),
        content: Text(
          completed
              ? 'Your program will be archived as completed. Your current weekly plan and all workout history remain available.'
              : 'Your progress will be archived. Your current weekly plan and workout history will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(completed ? 'Finish program' : 'End program'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await LocalStore.endActiveProgram(
        status: completed ? 'completed' : 'ended');
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  bool _completedThisWeek(String day) {
    final active = _active;
    if (active == null) return false;
    final programId = active['programId']?.toString() ?? '';
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));
    final workoutId = 'program_${programId}_${day.toLowerCase()}';
    return _history.any((session) {
      if (session['workoutId']?.toString() != workoutId) return false;
      final date = DateTime.tryParse(session['date']?.toString() ?? '');
      return date != null &&
          !date.isBefore(monday) &&
          date.isBefore(nextMonday);
    });
  }

  Map<String, dynamic>? _nextSession() {
    if (_plan.isEmpty) return null;
    final todayIndex = DateTime.now().weekday - 1;
    for (var offset = 0; offset < 7; offset++) {
      final targetDay = LocalStore.weekDays[(todayIndex + offset) % 7];
      for (final item in _plan) {
        if (item['day'] == targetDay && item['isRest'] != true) {
          if (offset == 0 && _completedThisWeek(targetDay)) {
            continue;
          }
          return <String, dynamic>{...item, 'offset': offset};
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final active = _active;
    final progress = _progress;
    if (active == null || progress == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Program')),
        body: FitScrollableScreen(
          children: [
            const SizedBox(height: 48),
            Icon(
              Icons.event_available_rounded,
              size: 64,
              color: AppColors.primary.withValues(alpha: .7),
            ),
            const SizedBox(height: 18),
            const Text(
              'No active program',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a program from the Workout tab to begin guided weekly tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
          ],
        ),
      );
    }

    final name =
        active['name']?.toString() ?? _definition?.name ?? 'Workout Program';
    final next = _nextSession();
    final today = LocalStore.weekDays[DateTime.now().weekday - 1];
    Map<String, dynamic>? todayPlan;
    for (final item in _plan) {
      if (item['day'] == today) {
        todayPlan = item;
        break;
      }
    }
    final canStartToday = todayPlan != null && todayPlan['isRest'] != true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Active Program'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'end') {
                _endProgram();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'end', child: Text('End program')),
            ],
          ),
        ],
      ),
      body: FitScrollableScreen(
        horizontalPadding: 20,
        topPadding: 14,
        bottomSpacing: 28,
        children: [
          MotionReveal(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'WEEK ${progress.currentWeek}/${progress.durationWeeks}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${active['level'] ?? _definition?.level ?? ''} • ${active['trainingDays']} training days/week',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress.completion,
                      minHeight: 9,
                      backgroundColor: Colors.white12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '${progress.completedSessions}/${progress.totalSessions} sessions',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        '${(progress.completion * 100).round()}%',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  value:
                      '${progress.thisWeekCompleted}/${progress.thisWeekPlanned}',
                  label: 'This week',
                  icon: Icons.calendar_view_week_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  value: '${progress.durationWeeks - progress.currentWeek + 1}',
                  label: 'Weeks left',
                  icon: Icons.timelapse_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'This week',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ..._plan.map((day) {
            final isToday = day['day'] == today;
            final rest = day['isRest'] == true;
            final done = !rest && _completedThisWeek(day['day'].toString());
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primarySoft : AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isToday ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        day['day'].toString().substring(0, 3),
                        style: TextStyle(
                          color: isToday ? AppColors.primary : AppColors.muted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day['title'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          if (!rest)
                            Text(
                              '${((day['exerciseIds'] as Iterable?) ?? const []).length} exercises • ${day['durationMinutes']} min',
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      rest
                          ? Icons.bedtime_outlined
                          : done
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                      color: rest
                          ? AppColors.muted
                          : done
                              ? AppColors.success
                              : AppColors.primary,
                    ),
                  ],
                ),
              ),
            );
          }),
          if (next != null) ...[
            const SizedBox(height: 14),
            FitCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primarySoft,
                    child:
                        Icon(Icons.skip_next_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEXT SESSION',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          next['title'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          (next['offset'] as int) == 0
                              ? 'Today'
                              : 'In ${next['offset']} day${(next['offset'] as int) == 1 ? '' : 's'} • ${next['day']}',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (canStartToday)
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _startToday,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start today’s session'),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.self_improvement_rounded,
                      color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Today is a recovery day. Keep moving lightly and return for the next scheduled session.',
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _MetricCard(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}
