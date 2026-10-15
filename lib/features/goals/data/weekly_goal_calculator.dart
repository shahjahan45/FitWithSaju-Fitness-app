import 'weekly_goal_models.dart';

class WeeklyGoalCalculator {
  WeeklyGoalCalculator._();

  static WeeklyGoalsSnapshot calculate({
    required DateTime anchorDate,
    required WeeklyGoalTargets targets,
    required List<Map<String, dynamic>> workoutHistory,
    required Set<String> readinessDateKeys,
    required Map<String, int> waterTotalsByDate,
    required int waterTargetMl,
  }) {
    final anchor = _day(anchorDate);
    final weekStart = anchor.subtract(Duration(days: anchor.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final previousStart = weekStart.subtract(const Duration(days: 7));
    final previousEnd = weekStart.subtract(const Duration(days: 1));

    var workouts = 0;
    var minutes = 0;
    var previousWorkouts = 0;
    var previousMinutes = 0;

    for (final session in workoutHistory) {
      final parsed = DateTime.tryParse(session['date']?.toString() ?? '');
      if (parsed == null) {
        continue;
      }
      final date = _day(parsed);
      final duration = _nonNegativeInt(session['durationMinutes']);
      if (!date.isBefore(weekStart) && !date.isAfter(anchor)) {
        workouts++;
        minutes += duration;
      } else if (!date.isBefore(previousStart) && !date.isAfter(previousEnd)) {
        previousWorkouts++;
        previousMinutes += duration;
      }
    }

    var hydrationDays = 0;
    var readinessDays = 0;
    var previousHydrationDays = 0;
    var previousReadinessDays = 0;

    for (var i = 0; i < 14; i++) {
      final date = previousStart.add(Duration(days: i));
      if (date.isAfter(anchor)) {
        break;
      }
      final key = _key(date);
      final currentWeek = !date.isBefore(weekStart);
      final hydrationMet = waterTargetMl > 0 &&
          (waterTotalsByDate[key] ?? 0) >= waterTargetMl;
      final readinessMet = readinessDateKeys.contains(key);
      if (currentWeek) {
        if (hydrationMet) hydrationDays++;
        if (readinessMet) readinessDays++;
      } else {
        if (hydrationMet) previousHydrationDays++;
        if (readinessMet) previousReadinessDays++;
      }
    }

    final previousWeekGoalsMet = <bool>[
      previousWorkouts >= targets.workouts,
      previousMinutes >= targets.trainingMinutes,
      previousHydrationDays >= targets.hydrationDays,
      previousReadinessDays >= targets.readinessDays,
    ].where((value) => value).length;

    final current = <WeeklyGoalProgress>[
      WeeklyGoalProgress(current: workouts, target: targets.workouts),
      WeeklyGoalProgress(current: minutes, target: targets.trainingMinutes),
      WeeklyGoalProgress(current: hydrationDays, target: targets.hydrationDays),
      WeeklyGoalProgress(current: readinessDays, target: targets.readinessDays),
    ];
    final goalsMet = current.where((goal) => goal.complete).length;
    final remainingDays = 7 - anchor.weekday;
    final coaching = _coaching(
      goalsMet: goalsMet,
      remainingDays: remainingDays,
      workouts: current[0],
      minutes: current[1],
      hydration: current[2],
      readiness: current[3],
    );

    return WeeklyGoalsSnapshot(
      weekStart: weekStart,
      weekEnd: weekEnd,
      targets: targets,
      workouts: current[0],
      trainingMinutes: current[1],
      hydrationDays: current[2],
      readinessDays: current[3],
      previousWeekGoalsMet: previousWeekGoalsMet,
      coachingTitle: coaching.$1,
      coachingMessage: coaching.$2,
    );
  }

  static (String, String) _coaching({
    required int goalsMet,
    required int remainingDays,
    required WeeklyGoalProgress workouts,
    required WeeklyGoalProgress minutes,
    required WeeklyGoalProgress hydration,
    required WeeklyGoalProgress readiness,
  }) {
    if (goalsMet == 4) {
      return (
        'Weekly goals complete',
        'You have met all four consistency targets. Keep the rest of the week balanced instead of adding extra work just to exceed the numbers.',
      );
    }
    if (remainingDays <= 1 && goalsMet <= 1) {
      return (
        'Finish the week realistically',
        'A target is guidance, not a requirement to catch up all at once. Prioritize the habits that fit your plan and recovery today.',
      );
    }
    if (!hydration.complete || !readiness.complete) {
      return (
        'Build the easy consistency wins',
        'Hydration and recovery check-ins can support the training plan without adding workout volume. Keep the targets practical for your week.',
      );
    }
    if (!workouts.complete || !minutes.complete) {
      return (
        'Stay with your planned training',
        'You are building good support habits. Complete planned sessions when appropriate rather than squeezing in extra training only to hit a target.',
      );
    }
    return (
      'Consistency is building',
      'You are close to completing the week. Keep using your plan, readiness and recovery feedback together.',
    );
  }

  static int _nonNegativeInt(dynamic value) {
    final parsed = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    return parsed < 0 ? 0 : parsed;
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String _key(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
