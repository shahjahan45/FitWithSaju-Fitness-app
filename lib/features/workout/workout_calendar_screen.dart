import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/navigation/settled_dialog.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/workout_factory.dart';
import '../../data/workout_program_schedule.dart';
import 'active_workout_screen.dart';

class WorkoutCalendarScreen extends StatefulWidget {
  const WorkoutCalendarScreen({super.key});

  @override
  State<WorkoutCalendarScreen> createState() => _WorkoutCalendarScreenState();
}

class _WorkoutCalendarScreenState extends State<WorkoutCalendarScreen> {
  Map<String, dynamic>? _active;
  List<ProgramCalendarEntry> _entries = const [];
  int _week = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load(initial: true);
  }

  Future<void> _load({bool initial = false}) async {
    final active = await LocalStore.activeProgram();
    final plan = await LocalStore.weeklyPlan();
    final history = await LocalStore.history();
    final overrides = await LocalStore.programScheduleOverrides();
    final entries = active == null
        ? <ProgramCalendarEntry>[]
        : WorkoutProgramSchedule.build(
            activeProgram: active,
            weeklyPlan: plan,
            history: history,
            overrides: overrides,
          );
    if (!mounted) {
      return;
    }
    setState(() {
      _active = active;
      _entries = entries;
      if (initial && active != null) {
        _week = WorkoutProgramSchedule.currentWeek(active);
      }
      final maxWeek = ((active?['durationWeeks'] as num?)?.toInt() ?? 1)
          .clamp(1, 52)
          .toInt();
      _week = _week.clamp(1, maxWeek).toInt();
      _loading = false;
    });
  }

  List<ProgramCalendarEntry> get _weekEntries =>
      _entries.where((entry) => entry.week == _week).toList();

  Future<void> _start(ProgramCalendarEntry entry) async {
    if (entry.isRest ||
        entry.isCompleted ||
        entry.isSkipped ||
        entry.status == 'prestart') {
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
            '${draft['title'] ?? 'A workout'} is saved for resuming. Discard it before starting this scheduled session?',
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

    final workout = WorkoutFactory.fromPlan(entry.planForWorkout());
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

  Future<void> _reschedule(ProgramCalendarEntry entry) async {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final picked = await showSettledModalBottomSheet<DateTime>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reschedule session',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const Text(
                'Choose a new training day within the next two weeks.',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 270,
                child: ListView.separated(
                  itemCount: 14,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final date = base.add(Duration(days: index));
                    return Material(
                      type: MaterialType.transparency,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primarySoft,
                          foregroundColor: AppColors.primary,
                          child: Text('${date.day}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        title: Text(_weekday(date),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(_shortDate(date)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(sheetContext).pop(date),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) {
      return;
    }
    await LocalStore.rescheduleProgramSession(
      programId: entry.programId,
      sessionKey: entry.sessionKey,
      scheduledDate: picked,
    );
    await _load();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Session moved to ${_shortDate(picked)}.')),
    );
  }

  Future<void> _skip(ProgramCalendarEntry entry) async {
    final confirmed = await showSettledDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Skip this session?'),
        content: const Text(
          'This marks the scheduled session as skipped. It will stay visible in the calendar and will not count as completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Skip session'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await LocalStore.skipProgramSession(
      programId: entry.programId,
      sessionKey: entry.sessionKey,
    );
    await _load();
  }

  Future<void> _resetSchedule(ProgramCalendarEntry entry) async {
    await LocalStore.resetProgramSessionSchedule(entry.sessionKey);
    await _load();
  }

  Future<void> _toggleDeload() async {
    final active = _active;
    if (active == null) {
      return;
    }
    final current = WorkoutProgramSchedule.deloadWeeks(active).contains(_week);
    await LocalStore.setProgramWeekDeload(_week, !current);
    await _load();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          current
              ? 'Week $_week restored to normal training volume.'
              : 'Week $_week is now a deload week.',
        ),
      ),
    );
  }

  Future<void> _actions(ProgramCalendarEntry entry) async {
    if (entry.isRest || entry.status == 'prestart') {
      return;
    }
    final action = await showSettledModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                entry.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Week ${entry.week} • ${_shortDate(entry.scheduledDate)}',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              if (!entry.isCompleted &&
                  !entry.isSkipped &&
                  (entry.isToday || entry.isMissed))
                FilledButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop('start'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start session'),
                ),
              if (!entry.isCompleted && !entry.isSkipped) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop('reschedule'),
                  icon: const Icon(Icons.event_repeat_rounded),
                  label: const Text('Reschedule'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop('skip'),
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('Skip this session'),
                ),
              ],
              if (entry.isRescheduled || entry.isSkipped) ...[
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop('reset'),
                  child: const Text('Restore original schedule'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) {
      return;
    }
    switch (action) {
      case 'start':
        await _start(entry);
        break;
      case 'reschedule':
        await _reschedule(entry);
        break;
      case 'skip':
        await _skip(entry);
        break;
      case 'reset':
        await _resetSchedule(entry);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final active = _active;
    if (active == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Training Calendar')),
        body: const FitScrollableScreen(
          children: [
            SizedBox(height: 72),
            Icon(Icons.calendar_month_rounded,
                size: 64, color: AppColors.primary),
            SizedBox(height: 18),
            Text(
              'No active program',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Text(
              'Start a workout program first, then its scheduled sessions will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
          ],
        ),
      );
    }

    final durationWeeks =
        ((active['durationWeeks'] as num?)?.toInt() ?? 1).clamp(1, 52).toInt();
    final deload = WorkoutProgramSchedule.deloadWeeks(active).contains(_week);
    final entries = _weekEntries;
    final completed = entries.where((e) => e.isCompleted).length;
    final training =
        entries.where((e) => !e.isRest && e.status != 'prestart').length;
    final missed = entries.where((e) => e.isMissed).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Training Calendar')),
      body: FitScrollableScreen(
        horizontalPadding: 20,
        topPadding: 14,
        bottomSpacing: 28,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active['name']?.toString() ?? 'Active program',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Week $_week of $durationWeeks${deload ? ' • Deload' : ''}',
                  style: TextStyle(
                    color: deload ? AppColors.primary : Colors.white70,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _MiniMetric(
                        value: '$completed/$training', label: 'Completed'),
                    const SizedBox(width: 10),
                    _MiniMetric(value: '$missed', label: 'Missed'),
                    const SizedBox(width: 10),
                    _MiniMetric(
                      value: '${entries.where((e) => e.isRescheduled).length}',
                      label: 'Moved',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _week > 1 ? () => setState(() => _week--) : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'PROGRAM WEEK $_week',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _weekRange(entries),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: _week < durationWeeks
                    ? () => setState(() => _week++)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleDeload,
                  icon: Icon(deload
                      ? Icons.restart_alt_rounded
                      : Icons.self_improvement_rounded),
                  label: Text(deload ? 'Normal week' : 'Set deload week'),
                ),
              ),
            ],
          ),
          if (deload) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Deload week reduces each workout by one set per exercise and starts at about 85% of your previous working weight.',
                style: TextStyle(height: 1.4, fontWeight: FontWeight.w700),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: _SessionCard(
                entry: entry,
                onTap: () => _actions(entry),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Missed training is information, not failure. Reschedule it when recovery and your week allow, or skip it and continue with the next planned session.',
                    style: TextStyle(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _weekRange(List<ProgramCalendarEntry> entries) {
    if (entries.isEmpty) {
      return '';
    }
    return '${_shortDate(entries.first.scheduledDate)} – ${_shortDate(entries.last.scheduledDate)}';
  }

  static String _weekday(DateTime date) =>
      LocalStore.weekDays[date.weekday - 1];

  static String _shortDate(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _MiniMetric extends StatelessWidget {
  final String value;
  final String label;

  const _MiniMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ProgramCalendarEntry entry;
  final VoidCallback onTap;

  const _SessionCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tone = _tone(entry.status);
    return FitCard(
      onTap: entry.isRest ? null : onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: tone.$1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  entry.day.substring(0, 3).toUpperCase(),
                  style: TextStyle(
                      color: tone.$2,
                      fontSize: 10,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.scheduledDate.day}',
                  style: TextStyle(
                      color: tone.$2,
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.isRest ? 'Recovery day' : entry.title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                    ),
                    _StatusPill(status: entry.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  entry.isRest
                      ? 'Rest, mobility, walking, sleep and normal nutrition.'
                      : '${(entry.plan['exerciseIds'] as List?)?.length ?? 0} exercises • ${entry.plan['durationMinutes'] ?? 45} min${entry.isDeload ? ' • Deload' : ''}',
                  style: const TextStyle(color: AppColors.muted, height: 1.35),
                ),
                if (entry.isRescheduled) ...[
                  const SizedBox(height: 7),
                  Text(
                    'Moved from ${_formatShortDate(entry.originalDate)}',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
          if (!entry.isRest) ...[
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatShortDate(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  static (Color, Color) _tone(String status) {
    switch (status) {
      case 'completed':
        return (AppColors.primarySoft, AppColors.primary);
      case 'missed':
        return (const Color(0xFFFFEEE7), const Color(0xFFC5532F));
      case 'skipped':
        return (const Color(0xFFF1F2F4), AppColors.muted);
      case 'today':
        return (AppColors.text, Colors.white);
      case 'rest':
        return (AppColors.secondarySoft, AppColors.secondary);
      case 'prestart':
        return (AppColors.surfaceAlt, AppColors.muted);
      default:
        return (AppColors.surfaceAlt, AppColors.text);
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'completed' => 'DONE',
      'missed' => 'MISSED',
      'skipped' => 'SKIPPED',
      'today' => 'TODAY',
      'rest' => 'REST',
      'prestart' => 'BEFORE START',
      _ => 'UPCOMING',
    };
    final color = switch (status) {
      'completed' => AppColors.primary,
      'missed' => const Color(0xFFC5532F),
      'skipped' => AppColors.muted,
      'today' => AppColors.text,
      'rest' => AppColors.secondary,
      'prestart' => AppColors.muted,
      _ => AppColors.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }
}
